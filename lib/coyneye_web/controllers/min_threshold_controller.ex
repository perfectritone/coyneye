defmodule CoyneyeWeb.MinThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Threshold

  def create(conn, %{"met" => _, "min_threshold" => params}) do
    Threshold.create_min_met(params)
    |> create_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "min_threshold" => params}) do
    Threshold.create_min_exceeded(params)
    |> create_redirect(conn)
  end

  defp create_redirect({:ok, _threshold}, conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.price_path(conn, :index))
  end
end
