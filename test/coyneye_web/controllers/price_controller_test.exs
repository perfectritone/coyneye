defmodule CoyneyeWeb.PriceControllerTest do
  use CoyneyeWeb.ConnCase
  import Coyneye.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Coyneye.Repo)

    currency = insert!(:currency)
    insert!(:price, currency: currency)

    :ok
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Coyneye"
  end
end
