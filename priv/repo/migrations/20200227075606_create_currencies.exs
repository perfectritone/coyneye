defmodule Coyneye.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :name, :string

      timestamps()
    end

    create unique_index(:currencies, [:name])
  end
end
