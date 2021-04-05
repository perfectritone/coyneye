defmodule CoyneyeWeb.PriceLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    ETH/USD: <%= @price %>
    """
  end

  def mount(_params, _session, socket) do
    IO.puts("just mounted")
    if connected?(socket), do: Coyneye.Prices.subscribe()

    {:ok, fetch(socket)}
  end

  def handle_info({Coyneye.Prices, _price}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    price = Coyneye.Prices.last.amount
    assign(socket, :price, price)
  end
end
