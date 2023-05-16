defmodule CoyneyeWeb.ThresholdChannel do
  use CoyneyeWeb, :channel

  @moduledoc """
  Channel for updating thresholds when they are met
  """

  @impl true
  def join("threshold:eth_usd", _payload, socket) do
    {:ok, socket}
  end
end
