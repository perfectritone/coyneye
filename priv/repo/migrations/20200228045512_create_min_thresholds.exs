defmodule Coyneye.Repo.Migrations.CreateMinThresholds do
  use Ecto.Migration

  def change do
    create table(:min_thresholds) do
      add :amount, :float
      add :met, :boolean, default: false, null: false
      add :currency_id, references(:currencies, on_delete: :nothing)

      timestamps()
    end

    create index(:min_thresholds, [:currency_id])
  end
end
