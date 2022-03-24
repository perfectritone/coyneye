defmodule ThresholdCreator do
  alias Coyneye.{Threshold, ThresholdParser}

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

  defp parse_and_create_thresholds(amounts, create_threshold) do
    ThresholdParser.parse_amounts(amounts)
    |> create_thresholds(create_threshold)
  end

  defp create_thresholds(amounts, create_threshold) do
    Enum.map(amounts, &(create_threshold.(%{amount: &1})))
  end
end
