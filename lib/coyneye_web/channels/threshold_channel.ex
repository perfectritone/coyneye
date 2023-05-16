defmodule CoyneyeWeb.ThresholdChannel do
  use CoyneyeWeb, :channel

  @impl true
  def join("threshold:eth_usd", _payload, socket) do
    {:ok, socket}
  end
end
