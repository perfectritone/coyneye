defmodule CoyneyeWeb.MinThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.{ThresholdCreator, ThresholdInterval, ThresholdParser}

  def create(conn, %{"met" => _, "min_threshold" => %{"amount" => amounts}}) do
    ThresholdParser.parse_amounts(amounts)
    |> ThresholdCreator.create(condition: :met, direction: :min)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "min_threshold" => %{"amount" => amounts}}) do
    ThresholdParser.parse_amounts(amounts)
    |> ThresholdCreator.create(condition: :exceeded, direction: :min)

    success_redirect(conn)
  end

  def create(conn, %{"amount" => interval}) do
    ThresholdInterval.amounts(direction: :min, interval: String.to_integer(interval))
    |> ThresholdCreator.create(condition: :met, direction: :min)

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
