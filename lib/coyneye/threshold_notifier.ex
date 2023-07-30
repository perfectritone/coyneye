defmodule Coyneye.ThresholdNotifier do
  alias Coyneye.{Currency, Accounts, PriceFormatter, PushoverService, Threshold}

  @moduledoc """
  Send threshold notifications to the Pushover Service
  """

  def call(price) do
    results = Threshold.check_thresholds(price)

    results[:users_with_max_threshold_conditions_met]
    |> Enum.map(fn u -> tap(u, &handle_pushover_notifications(&1, :max, price)) end)
    |> Enum.map(&broadcast_threshold_update(&1, :max))

    set_threshold_success(:max)

    results[:users_with_min_threshold_conditions_met]
    |> Enum.map(fn u -> tap(u, &handle_pushover_notifications(&1, :min, price)) end)
    |> Enum.map(&broadcast_threshold_update(&1, :min))

    set_threshold_success(:min)
  end

  def handle_pushover_notifications(user_id, direction, price) do
    Accounts.get_user_pushover_authentication!(user_id)
    |> send_threshold_notifications(threshold_direction(direction), price)
  end

  defp send_threshold_notifications(%{} = pushover_auth, direction, price) do
    notification_message(direction, price)
    |> PushoverService.notify(pushover_auth)
  end

  defp threshold_direction(:max), do: "above"
  defp threshold_direction(:min), do: "below"

  defp notification_message(direction, price) do
    "USD/ETH is #{direction} threshold (#{price})"
  end

  # broadcast based on user_id?
  defp broadcast_threshold_update(_user_id, :max) do
    currency_pair = Currency.default_pair()

    CoyneyeWeb.Endpoint.broadcast!("threshold:#{currency_pair}", "max_threshold_met",
      %{
        new_max_threshold: formatted_threshold(Threshold.cached_max_amount),
        currency_pair: currency_pair
      })

    %{max_threshold_met: true}
  end

  defp broadcast_threshold_update(_user_id, :min) do
    currency_pair = Currency.default_pair()

    CoyneyeWeb.Endpoint.broadcast!("threshold:#{currency_pair}", "min_threshold_met",
      %{
        new_min_threshold: formatted_threshold(Threshold.cached_min_amount),
        currency_pair: currency_pair
      })

    %{min_threshold_met: true}
  end

  # This should also be queued and done after each successful notification, not
  # after all notifications have succeeded
  defp set_threshold_success(:max) do
    Threshold.notified(:max_threshold)
  end
  defp set_threshold_success(:min) do
    Threshold.notified(:min_threshold)
  end

  defp formatted_threshold(threshold_amount), do: PriceFormatter.call(threshold_amount)
end
