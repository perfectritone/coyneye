defmodule Coyneye.ThresholdParser do
  alias Coyneye.Threshold

  @moduledoc """
  Threshold parser.
  Intermediary between controller and interactions with the DB
  """

  def parse_amounts(amounts) do
    String.split(amounts, [" ", ","], trim: true)
    #|> parse_multipliers
    |> validate_thresholds
  end

  def validate_thresholds(amounts) do
    Enum.map(amounts, &valid_threshold/1)
  end

  defp parse_multipliers(amount) do
    Regex.named_captures(~r/(?<base>\d+)\+(?<multiplicand>\d+)x(?<multiplier>\d+)/, amount)
  end

  defp valid_threshold(amount) do
    Float.parse(amount)
    |> Kernel.elem(0)
  end
end
