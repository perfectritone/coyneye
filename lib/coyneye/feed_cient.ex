defmodule Coyneye.FeedClient do
  use WebSockex

  @url "wss://api2.poloniex.com"
  @channel 1002
  @usdc_eth_id 225

  def start_link(currency_pair_id) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, :no_state)
    subscribe(pid, currency_pair_id)

    {:ok, pid}
  end

  def handle_connect(_conn, state) do
    IO.puts "Connected!"
    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    IO.puts "disconnected"

    {:ok, state}
  end

  def subscription_frame(channel) do
    subscription_msg = %{
      command: "subscribe",
      channel: channel,
    } |> Poison.encode!()

    {:text, subscription_msg}
  end

  def subscribe(pid, _currency_pair_id) do
    WebSockex.send_frame(pid, subscription_frame(@channel))
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Poison.decode!(msg), state)
  end

  def handle_msg([_, _, [@usdc_eth_id, price | _tail]], state) do
    IO.inspect(price)

    {:ok, state}
  end

  def handle_msg(_, state), do: {:ok, state}
end
