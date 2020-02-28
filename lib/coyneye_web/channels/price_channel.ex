defmodule CoyneyeWeb.PriceChannel do
  use Phoenix.Channel

  def join("price:eth/usd", _message, socket) do
    {:ok, socket}
  end
end
