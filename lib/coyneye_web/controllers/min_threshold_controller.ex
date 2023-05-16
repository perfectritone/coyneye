defmodule CoyneyeWeb.MinThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.ThresholdCreator

  def create(conn, %{"met" => _, "min_threshold" => %{"amount" => amounts}}) do
    ThresholdCreator.create(amounts, condition: :met, direction: :min)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "min_threshold" => %{"amount" => amounts}}) do
    ThresholdCreator.create(amounts, condition: :exceeded, direction: :min)

    success_redirect(conn)
  end

  def create(conn, %{}) do
    ThresholdCreator.create_10s(direction: :min)

    success_redirect(conn)
  end

  def destroy_all(conn, %{}) do
    _result = Coyneye.Threshold.delete_all_min()
    success_redirect(conn)
  end

  defp success_redirect(conn) do
    conn
    |> redirect(to: ~p"/prices")
  end
end
