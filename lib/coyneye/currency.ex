defmodule Coyneye.Currency do
  alias Coyneye.Repo

  @moduledoc """
  Currency helper
  """
  @default_currency_pair "eth_usd"

  def record(name) do
    Coyneye.Model.Currency |> Repo.get_by!(name: name)
  end

  def default_pair, do: @default_currency_pair
end
