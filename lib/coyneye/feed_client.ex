defmodule Coyneye.FeedClient do
  use WebSockex

  alias Coyneye.{Application, Currency, DatabaseCache, Price, Threshold}

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
    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    IO.puts('disconnected')

    {:reconnect, state}
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
    broadcast_price(price)

    Threshold.check_thresholds(price)
    |> send_threshold_notifications(price)

    {:ok, state}
  end

  def broadcast_price(amount) do
    Price.notify_subscribers({:ok, amount})
  end

  def send_threshold_notifications(%{}, _price), do: {:ok}

  def send_threshold_notifications(%{max_threshold_met: true}, price) do
    notification_message("above", price)
    |> Coyneye.PushoverService.notify()
  end

  def send_threshold_notifications(%{min_threshold_met: true}, price) do
    notification_message("below", price)
    |> Coyneye.PushoverService.notify()
  end

  defp notification_message(direction, price) do
    "USDT/ETH is #{direction} threshold (#{price})"
  end

  def eth_usd_currency_record, do: Application.eth_usd_currency_pair() |> currency_record

  def currency_record(name) do
    DatabaseCache.get(:db_cache, fn -> Currency.record(name) end)
  end
end
