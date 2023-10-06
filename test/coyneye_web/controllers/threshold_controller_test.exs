defmodule CoyneyeWeb.ThresholdController do
  use CoyneyeWeb.ConnCase
  import Coyneye.Factory
  import Mox

  @threshold_1 "1258"
  @threshold_2 "1300"
  @threshold_3 "1450"
  @threshold_list [@threshold_1, @threshold_2, @threshold_3]
  @multiple_thresholds Enum.join(@threshold_list, " ")
  # @invalid_amount "abc"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Coyneye.Repo)

    currency = insert!(:currency)
    insert!(:price, currency: currency)

    :ok
  end

  describe "create max threshold" do
    test "redirects back to index when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/max_thresholds", build_attrs())

      assert redirected_to(conn) == ~p"/prices"

      conn = get(conn, ~p"/prices")
      assert html_response(conn, 200) =~ @threshold_1
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, Routes.max_threshold_path(conn, :create), @invalid_attrs)
    # end

    test "redirects back to index when multiple thresholds are sent", %{conn: conn} do
      attrs = build_attrs(%{amount: @multiple_thresholds})
      conn = post(conn, ~p"/max_thresholds", attrs)

      assert redirected_to(conn) == ~p"/prices"

      conn = get(conn, ~p"/prices")
      lowest_threshold = Enum.min(@threshold_list)
      assert html_response(conn, 200) =~ lowest_threshold
    end

    test "redirects back to index when interval thresholds are sent", %{conn: conn} do
      expect(PriceMock, :last_amount, fn -> 302 end)

      interval_amount = 10.0
      interval_amount_as_string = :erlang.float_to_binary(interval_amount, decimals: 0)
      attrs = %{amount: interval_amount_as_string}
      conn = post(conn, ~p"/max_thresholds/interval", attrs)

      assert redirected_to(conn) == ~p"/prices"

      conn = get(conn, ~p"/prices")
      lowest_threshold = "310.00"
      assert html_response(conn, 200) =~ lowest_threshold
    end
  end

  defp build_attrs(), do: build_attrs(%{amount: @threshold_1})

  defp build_attrs(%{amount: amount}) do
    %{met: "true", max_threshold: %{amount: amount}}
  end
end
