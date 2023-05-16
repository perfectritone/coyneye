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

  def create(conn, %{"amount" => interval}) do
    ThresholdCreator.create_by(direction: :max, interval: String.to_integer(interval))

    success_redirect(conn)
  end

  def destroy_all(conn, %{}) do
    _result = Coyneye.Threshold.delete_all_max()
    success_redirect(conn)
  end

  defp success_redirect(conn) do
    conn
    |> redirect(to: ~p"/prices")
  end
end
