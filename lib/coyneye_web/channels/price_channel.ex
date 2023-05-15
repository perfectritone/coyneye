defmodule CoyneyeWeb.PriceChannel do
  use Phoenix.Channel

  def join("price:eth_usd", _message, socket) do
    {:ok, socket}
  end

  def join("price:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end
end
