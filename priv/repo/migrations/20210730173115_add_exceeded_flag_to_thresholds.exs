defmodule Coyneye.Repo.Migrations.AddExceededFlagToThresholds do
  use Ecto.Migration
  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.{Repo}

  def change do
    alter table("max_thresholds") do
      add :condition, :integer
    end

    Repo.update_all(MaxThreshold, set: [condition: :met])

    alter table("max_thresholds") do
      modify :condition, :integer, null: true
    end

    alter table("min_thresholds") do
      add :condition, :integer
    end

    Repo.update_all(MinThreshold, set: [condition: :met])

    alter table("min_thresholds") do
      modify :condition, :integer, null: true
    end
  end
end
