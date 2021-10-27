defmodule Coyneye.Model.MinThreshold do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for `min_thresholds` table
  """

  schema "min_thresholds" do
    field :amount, :float
    field :met, :boolean, default: false
    field :currency_id, :id
    field :condition, Ecto.Enum, values: [met: 1, exceeded: 2]

    timestamps()
  end

  @doc false
  def changeset(min_threshold, attrs) do
    min_threshold
    |> cast(attrs, [:amount, :met, :condition])
    |> validate_required([:amount, :met, :condition])
  end
end
