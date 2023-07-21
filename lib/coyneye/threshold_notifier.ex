defmodule Coyneye.ThresholdNotifier do
  alias Coyneye.{Currency, PriceFormatter, PushoverService, Threshold}

  @moduledoc """
  Send threshold notifications to the Pushover Service
  """

  def call(price) do
    Threshold.check_thresholds(price)
    |> handle_pushover_notifications(price)
    |> broadcast_threshold_update
    |> set_threshold_success
  end

  def handle_pushover_notifications(%{} = thresholds_met, price) do
    threshold_direction(thresholds_met)
    |> send_threshold_notifications(price)

    thresholds_met
  end

  defp send_threshold_notifications(nil, _price), do: {:ok}

  defp send_threshold_notifications(threshold_direction, price) do
    notification_message(threshold_direction, price)
    |> PushoverService.notify()
  end

  defp threshold_direction(%{max_threshold_met: true}), do: "above"

  defp threshold_direction(%{min_threshold_met: true}), do: "below"

  defp threshold_direction(%{}), do: nil

  defp notification_message(direction, price) do
    "USD/ETH is #{direction} threshold (#{price})"
  end

  defp broadcast_threshold_update(%{max_threshold_met: true}) do
    currency_pair = Currency.default_pair()

    CoyneyeWeb.Endpoint.broadcast!("threshold:#{currency_pair}", "max_threshold_met",
      %{
        new_max_threshold: formatted_threshold(Threshold.cached_max_amount),
        currency_pair: currency_pair
      })

    %{max_threshold_met: true}
  end

  defp broadcast_threshold_update(%{min_threshold_met: true}) do
    currency_pair = Currency.default_pair()

    CoyneyeWeb.Endpoint.broadcast!("threshold:#{currency_pair}", "min_threshold_met",
      %{
        new_min_threshold: formatted_threshold(Threshold.cached_min_amount),
        currency_pair: currency_pair
      })

    %{min_threshold_met: true}
  end

  defp broadcast_threshold_update(%{}), do: %{}

  defp set_threshold_success(%{max_threshold_met: true}) do
    Threshold.notified(:max_threshold)
  end
  defp set_threshold_success(%{min_threshold_met: true}) do
    Threshold.notified(:min_threshold)
  end
  defp set_threshold_success(%{}), do: nil

  defp formatted_threshold(threshold_amount), do: PriceFormatter.call(threshold_amount)
end
