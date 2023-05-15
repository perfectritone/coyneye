defmodule Coyneye.FeedClient do
  use WebSockex

  alias Coyneye.{Price, ThresholdNotifier}

  @moduledoc """
  Websocket client for Kraken prices
  """

  @url "wss://ws.kraken.com/"

  def start_link(currency_pairs) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, :no_state)
    subscribe(pid, currency_pairs)

    {:ok, pid}
  end

  def subscribe(pid, currency_pairs) do
    WebSockex.send_frame(pid, subscription_frame(currency_pairs))
  end

  def handle_connect(_conn, state) do
    IO.puts('Feed Client Connected')

    {:ok, state}
  end

  def handle_disconnect(conn, state) do
    IO.puts('Feed Client Disconnected')

    {:reconnect, conn, state}
  end

  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect reason}\n\n#{inspect state}\n")
    exit(:normal)
  end

  def subscription_frame(currency_pairs) do
    subscription_msg =
      %{
        event: "subscribe",
        pair: currency_pairs,
        subscription: %{
          name: "trade"
        }
      }
      |> Poison.encode!()

    {:text, subscription_msg}
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Poison.decode!(msg), state)
  end

  def handle_msg(%{"event" => "heartbeat"}, state), do: {:ok, state}
  def handle_msg(%{"event" => "subscriptionStatus"}, state), do: {:ok, state}
  def handle_msg(%{"event" => "systemStatus"}, state), do: {:ok, state}

  # [
  #   181,
  #   [["225.71000", "0.05500000", "1582787945.553184", "s", "l", ""]],
  #   "trade",
  #   "ETH/USD"
  # ]
  def handle_msg([_channel_id, prices, "trade", _currency_pair], state) do
    latest_trade = Enum.max_by(prices, &Enum.fetch(&1, 2))
    {:ok, price_string} = Enum.fetch(latest_trade, 0)

    {price, _} = Float.parse(price_string)

    Price.persist_price(price)
    Price.notify_channel_subscribers({:ok, price})
    ThresholdNotifier.call(price)

    {:ok, state}
  end
end
