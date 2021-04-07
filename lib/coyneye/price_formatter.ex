defmodule Coyneye.PriceFormatter do
  def call(-1), do: nil

  def call(float) do
    :erlang.float_to_binary(float, decimals: 2)
  end
end
