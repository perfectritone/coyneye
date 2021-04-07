defmodule CoyneyeWeb.MaxThresholdLive do
  use Phoenix.LiveView

  alias Coyneye.{MaxThreshold, Threshold}

  @moduledoc """
  LiveView for MaxThresholds
  """

  def render(assigns) do
    ~L"""
    (<%= @max_threshold %>)
    """
  end

  def mount(_params, _session, socket) do
    IO.puts("max connected")
    if connected?(socket), do: MaxThreshold.subscribe()

    {:ok, fetch(socket)}
  end

  def handle_info({MaxThreshold, _threshold}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, :max_threshold, amount())
  end

  defp amount, do: Threshold.cached_max
end
