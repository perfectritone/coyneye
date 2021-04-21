defmodule CoyneyeWeb.PricesController do
  use CoyneyeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"currency_pair" => _currency_pair}) do
    json(conn, %{price: Coyneye.Price.last_amount()})
  end
end
