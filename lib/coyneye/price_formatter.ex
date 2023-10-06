defmodule Coyneye.PriceFormatter do
  @moduledoc """
  Simple price formatting
  """

  def call(-1), do: nil
  def call(nil), do: nil

  def call(float) do
    :erlang.float_to_binary(float, decimals: 2)
  end
end
