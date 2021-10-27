defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Threshold

  def create(conn, %{"met" => _, "max_threshold" => params}) do
    Threshold.create_max_met(params)
    |> create_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "max_threshold" => params}) do
    Threshold.create_max_exceeded(params)
    |> create_redirect(conn)
  end

  defp create_redirect({:ok, _threshold}, conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.prices_path(conn, :index))
  end
end
