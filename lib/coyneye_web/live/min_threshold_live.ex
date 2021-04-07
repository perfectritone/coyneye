defmodule CoyneyeWeb.MinThresholdLive do
  use Phoenix.LiveView

  alias Coyneye.{MinThreshold, PriceFormatter, Threshold}

  @moduledoc """
  LiveView for MinThresholds
  """

  def render(assigns) do
    ~L"""
    (<%= PriceFormatter.call(@min_threshold) %>)
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: MinThreshold.subscribe()

    {:ok, fetch(socket)}
  end

  def handle_info({MinThreshold, _threshold}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, :min_threshold, amount())
  end

  defp amount, do: Threshold.cached_min
end
