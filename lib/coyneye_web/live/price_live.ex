defmodule CoyneyeWeb.PriceLive do
  use Phoenix.LiveView

  @moduledoc """
  LiveView for Prices
  """

  def render(assigns) do
    ~L"""
    ETH/USD: <%= @price %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Coyneye.Prices.subscribe()

    {:ok, fetch(socket)}
  end

  def handle_info({Coyneye.Prices, _price}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, :price, last_price())
  end

  defp last_price, do: Coyneye.Prices.last().amount
end
