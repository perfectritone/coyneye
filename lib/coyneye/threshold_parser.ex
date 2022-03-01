defmodule Coyneye.ThresholdParser do
  alias Coyneye.Threshold

  @moduledoc """
  Threshold parser.
  Intermediary between controller and interactions with the DB
  """

  def process_thresholds(amounts, condition: :met, direction: :max) do
    parse_validate_and_create_thresholds(amounts, &Threshold.create_max_met/1)
  end
  def process_thresholds(amounts, condition: :exceeded, direction: :max) do
    parse_validate_and_create_thresholds(amounts, &Threshold.create_max_exceeded/1)
  end
  def process_thresholds(amounts, condition: :met, direction: :min) do
    parse_validate_and_create_thresholds(amounts, &Threshold.create_min_met/1)
  end
  def process_thresholds(amounts, condition: :exceeded, direction: :min) do
    parse_validate_and_create_thresholds(amounts, &Threshold.create_min_exceeded/1)
  end

  defp parse_validate_and_create_thresholds(amounts, create_threshold) do
    parse_amounts(amounts)
    |> validate_thresholds
    |> create_thresholds(create_threshold)
  end

  defp parse_amounts(amounts) do
    String.split(amounts, [" ", ","], trim: true)
  end

  defp validate_thresholds(amounts) do
    Enum.map(amounts, &valid_threshold/1)
  end

  defp create_thresholds(amounts, create_threshold) do
    Enum.map(amounts, &(create_threshold.(%{"amount" => &1})))
  end

  defp valid_threshold(amount) do
    Float.parse(amount)
    |> Kernel.elem(0)
  end
end
