defmodule Coyneye.Repo.Migrations.AddExceededFlagToThresholds do
  use Ecto.Migration

  def up do
    alter table("max_thresholds") do
      add :condition, :integer, default: 1, null: false
    end

    alter table("min_thresholds") do
      add :condition, :integer, default: 1, null: false
    end
  end

  def down do
    alter table("max_thresholds") do
      remove :condition
    end

    alter table("min_thresholds") do
      remove :condition
    end
  end
end
