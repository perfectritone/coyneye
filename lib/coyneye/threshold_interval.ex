defmodule Coyneye.ThresholdInterval do
  @moduledoc """
  Threshold interval calculator.
  """

  @max_number_of_thresholds_to_create 50
  def amounts(direction: :max, interval: interval) do
    rounded_price = ceil(price_store().last_amount / interval) * interval

    Enum.map(
      0..@max_number_of_thresholds_to_create,
      fn n -> rounded_price + interval * n end)
  end
  def amounts(direction: :min, interval: interval) do
    rounded_price = floor(price_store().last_amount / interval) * interval
    number_of_lower_thresholds = Integer.floor_div(rounded_price, interval) - 1
                                 |> List.wrap
                                 |> Enum.concat([@max_number_of_thresholds_to_create])
                                 |> Enum.min

    Enum.map(0..number_of_lower_thresholds, fn n -> rounded_price - interval * n end)
  end

  defp price_store, do: Application.get_env(:coyneye, :price_store)
end
