defmodule CoyneyeWeb.MinThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.ThresholdParser

  def create(conn, %{"met" => _, "min_threshold" => %{"amount" => amounts}}) do
    ThresholdParser.process_thresholds(amounts, condition: :met, direction: :min)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "min_threshold" => %{"amount" => amounts}}) do
    ThresholdParser.process_thresholds(amounts, condition: :exceeded, direction: :min)

    success_redirect(conn)
  end

  defp success_redirect(conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.price_path(conn, :index))
  end
end
