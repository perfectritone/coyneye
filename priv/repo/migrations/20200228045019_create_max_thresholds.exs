defmodule Coyneye.Repo.Migrations.CreateMaxThresholds do
  use Ecto.Migration

  def change do
    create table(:max_thresholds) do
      add :amount, :float
      add :met, :boolean, default: false, null: false
      add :currency_id, references(:currencies, on_delete: :nothing)

      timestamps()
    end

    create index(:max_thresholds, [:currency_id])
  end
end
