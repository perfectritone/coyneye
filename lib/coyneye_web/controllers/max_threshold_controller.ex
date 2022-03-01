defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Threshold

  def create(conn, %{"met" => _, "max_threshold" => %{"amount" => amounts}}) do
    process_thresholds(&create_met_thresholds/1, amounts)

    success_redirect(conn)
  end
  def create(conn, %{"exceeded" => _, "max_threshold" => %{"amount" => amounts}}) do
    process_thresholds(&create_exceeded_thresholds/1, amounts)

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

  defp create_met_thresholds(amounts) do
    Enum.map(amounts, create_met_threshold())
  end

  defp create_exceeded_thresholds(amounts) do
    Enum.map(amounts, create_exceeded_threshold())
  end

  defp create_met_threshold do
    # also, can this class include a function with these functions but just
    # override the .create_max_met part?
    &Threshold.create_max_met(%{"amount" => &1})
  end

  defp create_exceeded_threshold do
    &Threshold.create_max_exceeded(%{"amount" => &1})
  end

  defp process_thresholds(create_thresholds, amounts) do
    parse_amounts(amounts)
    |> validate_thresholds
    |> create_thresholds.()
  end
end
