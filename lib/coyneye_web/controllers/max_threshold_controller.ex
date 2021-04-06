defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Model.MaxThreshold
  alias Coyneye.Repo

  def create(conn, %{"max_threshold" => params}) do
    %MaxThreshold{}
    |> MaxThreshold.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, _threshold} ->
        conn
        |> redirect(to: CoyneyeWeb.Router.Helpers.prices_path(conn, :index))
    end
  end
end
