defmodule Coyneye.Model.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for `currencies` table
  """

  schema "currencies" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
