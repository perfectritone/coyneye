defmodule CoyneyeWeb.MaxThresholdController do
  use CoyneyeWeb, :controller
  alias Coyneye.Threshold

  def create(conn, %{"met" => _, "max_threshold" => %{"amount" => amount}}) do
    _create_results = String.split(amount, [" ", ","], trim: true)
      |> Enum.map(&Threshold.valid_threshold/1)
      |> Enum.map(&Threshold.create_max_met(%{"amount" => &1}))

    #if Enum.all?(create_results, fn x -> x.elem(0) == :ok end) do
    success_redirect(conn)
    #end
  end
  def create(conn, %{"exceeded" => _, "max_threshold" => params}) do
    Threshold.create_max_exceeded(params)
    |> create_redirect(conn)
  end

  defp create_redirect({:ok, _threshold}, conn), do: success_redirect(conn)

  defp success_redirect(conn) do
    conn
    |> redirect(to: CoyneyeWeb.Router.Helpers.price_path(conn, :index))
  end
end
