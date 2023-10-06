defmodule Coyneye.Repo.Migrations.AddPushoverAuthToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :pushover_user, :string, size: 32
    end
  end
end
