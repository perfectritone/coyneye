defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Threshold

  def create(conn, %{"met" => _, "max_threshold" => %{"amount" => amounts}}) do
    process_thresholds(amounts, &create_met_threshold/1)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "max_threshold" => %{"amount" => amounts}}) do
    process_thresholds(amounts, &create_exceeded_threshold/1)

    success_redirect(conn)
  end

  defp success_redirect(conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.price_path(conn, :index))
  end

  defp parse_amounts(amounts) do
    String.split(amounts, [" ", ","], trim: true)
  end

  defp validate_thresholds(amounts) do
    Enum.map(amounts, &Threshold.valid_threshold/1)
  end

  defp create_thresholds(amounts, create_threshold) do
    Enum.map(amounts, create_threshold)
  end

  defp create_met_threshold(amount) do
    # also, can this class include a function with these functions but just
    # override the .create_max_met part?
    Threshold.create_max_met(%{"amount" => amount})
  end

  defp create_exceeded_threshold(amount) do
    Threshold.create_max_exceeded(%{"amount" => amount})
  end

  defp process_thresholds(amounts, create_threshold) do
    parse_amounts(amounts)
    |> validate_thresholds
    |> create_thresholds(create_threshold)
  end
end
