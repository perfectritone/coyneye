defmodule Coyneye.Model.MinThreshold do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for `min_thresholds` table
  """

  schema "min_thresholds" do
    field :amount, :float
    field :met, :boolean, default: false
    belongs_to :currency, Coyneye.Model.Currency
    belongs_to :user, Coyneye.Accounts.User
    field :condition, Ecto.Enum, values: [met: 1, exceeded: 2]

    timestamps()
  end

  @doc false
  def changeset(min_threshold, attrs) do
    min_threshold
    |> cast(attrs, [:amount, :met, :condition, :currency_id, :user_id])
    |> validate_required([:amount, :met, :condition, :currency_id, :user_id])
    |> unique_constraint(:user_min_threshold_for_currency, name: :min_thresholds_user_id_currency_id_amount_index)
  end
end
