defmodule Coyneye.Repo do
  use Ecto.Repo,
    otp_app: :coyneye,
    adapter: Ecto.Adapters.Postgres
end
