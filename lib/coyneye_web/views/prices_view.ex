defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

  alias Coyneye.Threshold

  def title do
    "Coyneye"
  end

  def max_threshold_changeset do
    Threshold.new_max_threshold
  end

  def min_threshold_changeset do
    Threshold.new_min_threshold
  end

  def max_threshold do
    Threshold.minimum_unmet_maximum
    |> format_float_to_price
  end

  def min_threshold do
    Threshold.maximum_unmet_minimum
    |> format_float_to_price
  end

  defp format_float_to_price(nil), do: nil
  defp format_float_to_price(float) do
    :erlang.float_to_binary(float, decimals: 2)
  end
end
