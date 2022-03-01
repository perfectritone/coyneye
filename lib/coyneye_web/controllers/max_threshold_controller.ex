defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.ThresholdParser

  def create(conn, %{"met" => _, "max_threshold" => %{"amount" => amounts}}) do
    ThresholdParser.process_thresholds(amounts, condition: :met)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "max_threshold" => %{"amount" => amounts}}) do
    ThresholdParser.process_thresholds(amounts, condition: :exceeded)

    success_redirect(conn)
  end

  defp success_redirect(conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.price_path(conn, :index))
  end
end
