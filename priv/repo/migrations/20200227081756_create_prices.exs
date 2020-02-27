defmodule Coyneye.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices) do
      add :amount, :float
      add :currency_id, references(:currencies)

      timestamps()
    end
  end
end
