ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Coyneye.Repo, :manual)

defmodule Coyneye.EctoQuery do
  @callback last_amount() :: Float
end

Mox.defmock(PriceMock, for: Coyneye.EctoQuery)

Application.put_env(:coyneye, :price_store, PriceMock)
