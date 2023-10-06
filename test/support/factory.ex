defmodule Coyneye.Factory do
  alias Coyneye.Repo

  @moduledoc """
  Factories to allow tests to build default data in the DB
  """

  # Factories

  def build(:currency) do
    %Coyneye.Model.Currency{name: Coyneye.Application.eth_usd_currency_pair()}
  end

  def build(:price) do
    %Coyneye.Model.Price{amount: 1000.0}
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
