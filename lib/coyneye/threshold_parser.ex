defmodule Coyneye.ThresholdParser do
  alias Coyneye.Threshold

  @moduledoc """
  Threshold parser.
  Intermediary between controller and interactions with the DB
  """
  @multiplier_regex ~r/(?<base>\d+)\+(?<multiplicand>\d+)x(?<multiplier>\d+)/

  def parse_amounts(amounts) do
    String.split(amounts, [" ", ","], trim: true)
    |> parse_amounts_enum
  end

  defp parse_amounts_enum(amounts) do
    Enum.flat_map(amounts, &parse_amount/1)
  end

  defp parse_amount(amount) do
    if captures = Regex.named_captures(@multiplier_regex, amount) do
      parse_multiplier(captures)
    else
      [cast_threshold(amount)]
    end
  end

  defp parse_multiplier(%{"multiplier" => multiplier, "base" => base, "multiplicand" => multiplicand}) do
    {multiplier, _} = Integer.parse(multiplier)
    {base, _} = Float.parse(base)
    {multiplicand, _} = Float.parse(multiplicand)

    Enum.map(Enum.to_list(0..multiplier), fn(x) -> base + x * multiplicand end)
  end

  defp cast_threshold(amount) do
    Float.parse(amount)
    |> Kernel.elem(0)
  end
end
