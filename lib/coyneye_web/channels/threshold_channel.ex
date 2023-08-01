defmodule CoyneyeWeb.ThresholdChannel do
  use CoyneyeWeb, :channel

  @moduledoc """
  Channel for updating thresholds when they are met
  """

  @impl true
  def join("threshold:eth_usd:" <> user_id, _payload, socket) do
    if String.to_integer(user_id) == socket.assigns.user do
      {:ok, socket}
    else
      {:error, socket}
    end
  end
end
