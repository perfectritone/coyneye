defmodule Coyneye.MaxThreshold do
  use Ecto.Schema
  import Ecto.Changeset

  schema "max_thresholds" do
    field :amount, :float
    field :met, :boolean, default: false
    field :currency_id, :id

    timestamps()
  end

  @doc false
  def changeset(max_threshold, attrs) do
    max_threshold
    |> cast(attrs, [:amount, :met])
    |> validate_required([:amount, :met])
  end
end
