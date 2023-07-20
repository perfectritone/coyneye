defmodule Coyneye.Repo.Migrations.AddUniquenessConstraintToThresholds do
  use Ecto.Migration

  def change do
    create unique_index(:max_thresholds, [:currency_id, :amount])
    create unique_index(:min_thresholds, [:currency_id, :amount])
  end
end
