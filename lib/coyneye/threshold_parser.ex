defmodule Coyneye.ThresholdParser do
  @moduledoc """
  Threshold parser.
  Intermediary between controller and interactions with the DB
  """
  @multiplier_regex ~r/(?<base>\d+)(?<operand>[\+-])(?<multiplicand>\d+)[x*](?<multiplier>\d+)/

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

  defp parse_multiplier(%{"base" => base, "operand" => operand, "multiplicand" => multiplicand, "multiplier" => multiplier}) do
    {multiplier, _} = Integer.parse(multiplier)
    {base, _} = Float.parse(base)
    {multiplicand, _} = Float.parse(multiplicand)
    operand_function = case operand do
      "+" -> &sum/2
      "-" -> &difference/2
    end

    Enum.map(Enum.to_list(0..multiplier), fn(x) -> operand_function.(base, x * multiplicand) end)
  end

  defp cast_threshold(amount) do
    Float.parse(amount)
    |> Kernel.elem(0)
  end

  defp sum(a, b), do: a + b
  defp difference(a, b), do: a - b
end
