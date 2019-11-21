defmodule CoyneyeWeb.PricesController do
  use CoyneyeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
