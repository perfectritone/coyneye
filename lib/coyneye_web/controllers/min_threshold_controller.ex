defmodule CoyneyeWeb.MinThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.MinThreshold
  alias Coyneye.Repo

  def create(conn, %{"min_threshold" => params}) do
    %MinThreshold{}
    |> MinThreshold.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, _threshold} ->
        conn
        |> redirect(to: CoyneyeWeb.Router.Helpers.prices_path(conn, :index))
    end
  end
end
