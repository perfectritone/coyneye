defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.ThresholdCreator

  def create(conn, %{"met" => _, "max_threshold" => %{"amount" => amounts}}) do
    ThresholdCreator.create(amounts, condition: :met, direction: :max)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "max_threshold" => %{"amount" => amounts}}) do
    ThresholdCreator.create(amounts, condition: :exceeded, direction: :max)

    success_redirect(conn)
  end

  def destroy_all(conn, %{}) do
    result = Coyneye.Threshold.delete_all_max()
    success_redirect(conn)
  end

  defp success_redirect(conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.price_path(conn, :index))
  end
end
