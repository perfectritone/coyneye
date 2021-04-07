defmodule CoyneyeWeb.PriceLive do
  use Phoenix.LiveView

  alias Coyneye.Price

  @moduledoc """
  LiveView for Prices
  """

  def render(assigns) do
    ~L"""
    ETH/USD: <%= @price %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Price.subscribe()

    {:ok, fetch(socket)}
  end

  def handle_info({Price, _price}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, :price, last_price())
  end

  defp last_price, do: Price.last().amount
end
