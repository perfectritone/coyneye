defmodule Coyneye.ThresholdNotifier do
  alias Coyneye.{PushoverService, Threshold}

  @moduledoc """
  Send threshold notifications to the Pushover Service
  """

  def call(price) do
    Threshold.check_thresholds(price)
    |> threshold_direction
    |> send_threshold_notifications(price)
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
    "USDT/ETH is #{direction} threshold (#{price})"
  end
end
