defmodule Coyneye.Model.MaxThreshold do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for `max_thresholds` table
  """

  schema "max_thresholds" do
    field :amount, :float
    field :met, :boolean, default: false
    belongs_to :currency, Coyneye.Model.Currency
    field :condition, Ecto.Enum, values: [met: 1, exceeded: 2]

    timestamps()
  end

  @doc false
  def changeset(max_threshold, attrs) do
    max_threshold
    |> cast(attrs, [:amount, :met, :condition, :currency_id])
    |> validate_required([:amount, :met, :condition, :currency_id])
    |> unique_constraint(:max_threshold_for_currency, name: :max_thresholds_currency_id_amount_index)
  end
end
