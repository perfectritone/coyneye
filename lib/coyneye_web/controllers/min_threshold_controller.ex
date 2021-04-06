defmodule CoyneyeWeb.MinThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Threshold

  def create(conn, %{"min_threshold" => params}) do
    Threshold.create_min(params)
    |> case do
      {:ok, _threshold} ->
        conn
        |> redirect(to: CoyneyeWeb.Router.Helpers.prices_path(conn, :index))
    end
  end
end
