defmodule CoyneyeWeb.ThresholdController do
  use CoyneyeWeb.ConnCase

  @threshold_1 "1258"
  @threshold_2 "1300"
  @threshold_3 "1450"
  @threshold_list [@threshold_1, @threshold_2, @threshold_3]
  @multiple_thresholds Enum.join(@threshold_list, " ")
  @invalid_amount "abc"

  describe "create max threshold" do
    test "redirects back to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.max_threshold_path(conn, :create), build_attrs())

      assert redirected_to(conn) == Routes.price_path(conn, :index)

      conn = get(conn, Routes.price_path(conn, :index))
      assert html_response(conn, 200) =~ @threshold_1
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, Routes.max_threshold_path(conn, :create), @invalid_attrs)
    # end

    test "redirects back to index when multiple thresholds are sent", %{conn: conn} do
      attrs = build_attrs(%{amount: @multiple_thresholds})
      conn = post(conn, Routes.max_threshold_path(conn, :create), attrs)

      assert redirected_to(conn) == Routes.price_path(conn, :index)

      conn = get(conn, Routes.price_path(conn, :index))
      lowest_threshold = Enum.min(@threshold_list)
      assert html_response(conn, 200) =~ lowest_threshold
    end

  end

  defp build_attrs(), do: build_attrs(%{amount: @threshold_1})
  defp build_attrs(%{amount: amount}) do
    %{met: "true", max_threshold: %{amount: amount}}
  end
end
