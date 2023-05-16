defmodule Coyneye.ThresholdCreator do
  alias Coyneye.{Price, Threshold, ThresholdParser}

  @moduledoc """
  Threshold creator.
  """

  def create(amounts, condition: :met, direction: :max) do
    parse_and_create_thresholds(amounts, &Threshold.create_max_met/1)
  end
  def create(amounts, condition: :exceeded, direction: :max) do
    parse_and_create_thresholds(amounts, &Threshold.create_max_exceeded/1)
  end
  def create(amounts, condition: :met, direction: :min) do
    parse_and_create_thresholds(amounts, &Threshold.create_min_met/1)
  end
  def create(amounts, condition: :exceeded, direction: :min) do
    parse_and_create_thresholds(amounts, &Threshold.create_min_exceeded/1)
  end

  def create_10s(direction: :max) do
    number_of_higher_thresholds = 50
    rounded_price = ceil(Price.last_amount / 10) * 10

    amounts = Enum.map(0..number_of_higher_thresholds, fn n -> rounded_price + 10 * n end)

    create_thresholds(amounts, &Threshold.create_max_met/1)
  end
  def create_10s(direction: :min) do
    rounded_price = floor(Price.last_amount / 10) * 10
    number_of_lower_thresholds = Integer.floor_div(rounded_price, 10) - 1

    amounts = Enum.map(0..number_of_lower_thresholds, fn n -> rounded_price - 10 * n end)

    create_thresholds(amounts, &Threshold.create_min_met/1)
  end

  defp parse_and_create_thresholds(amounts, create_threshold) do
    ThresholdParser.parse_amounts(amounts)
    |> create_thresholds(create_threshold)
  end

  defp create_thresholds(amounts, create_threshold) do
    Enum.map(amounts, &(create_threshold.(%{amount: &1})))
  end
end
