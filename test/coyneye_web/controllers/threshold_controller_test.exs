defmodule CoyneyeWeb.ThresholdController do
  use CoyneyeWeb.ConnCase

  @threshold_amount "100"
  @create_attrs %{"met": "true", "max_threshold": %{"amount": @threshold_amount}}

  describe "create max threshold" do
    test "redirects back to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.max_threshold_path(conn, :create), @create_attrs)

      assert redirected_to(conn) == Routes.price_path(conn, :index)

      conn = get(conn, Routes.price_path(conn, :index))
      assert html_response(conn, 200) =~ @threshold_amount
    end
  end
end
