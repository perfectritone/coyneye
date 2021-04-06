defmodule Coyneye.Price do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for `prices` table
  """

  schema "prices" do
    field :amount, :float
    belongs_to :currency, Coyneye.Model.Currency

    timestamps()
  end

  @doc false
  def changeset(price, attrs) do
    price
    |> cast(attrs, [:amount, :currency_id])
    |> validate_required([:amount, :currency_id])
  end
end
