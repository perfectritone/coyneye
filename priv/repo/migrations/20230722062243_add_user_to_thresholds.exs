defmodule Coyneye.Repo.Migrations.AddUserToThresholds do
  use Ecto.Migration

  def up do
    drop index("max_thresholds", ["currency_id", "amount"])
    drop index("min_thresholds", ["currency_id", "amount"])

    alter table("max_thresholds") do
      add :user_id, references("users")
    end

    alter table("min_thresholds") do
      add :user_id, references("users")
    end

    create unique_index(:max_thresholds, [:user_id, :currency_id, :amount])
    create unique_index(:min_thresholds, [:user_id, :currency_id, :amount])
  end

  def down do
    drop index("max_thresholds", ["user_id", "currency_id", "amount"])
    drop index("min_thresholds", ["user_id", "currency_id", "amount"])

    alter table("max_thresholds") do
      remove :user_id
    end

    alter table("min_thresholds") do
      remove :user_id
    end

    create unique_index(:max_thresholds, [:currency_id, :amount])
    create unique_index(:min_thresholds, [:currency_id, :amount])
  end
end
