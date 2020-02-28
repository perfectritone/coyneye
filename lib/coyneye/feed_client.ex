defmodule Coyneye.FeedClient do
  use WebSockex

  alias Coyneye.{Repo, Price, Currency, MaxThreshold, MinThreshold}
  require Ecto.Query
  alias Ecto.Query

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
    {:ok, state}
  end

  def subscription_frame(currency_pairs) do
    subscription_msg = %{
      event: "subscribe",
      pair: currency_pairs,
      subscription: %{
        name: "trade"
      }
    } |> Poison.encode!()

    {:text, subscription_msg}
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Poison.decode!(msg), state)
  end

  def handle_msg(%{"event" => "heartbeat"}, state), do: {:ok, state}
  def handle_msg(%{"event" => "subscriptionStatus"}, state), do: {:ok, state}

  # [
  #   181,
  #   [["225.71000", "0.05500000", "1582787945.553184", "s", "l", ""]],
  #   "trade",
  #   "ETH/USD"
  # ]
  def handle_msg([_channel_id, prices, "trade", _currency_pair], state) do
    latest_trade = Enum.max_by(prices, &(Enum.fetch(&1, 2)))
    {:ok, price_string} = Enum.fetch(latest_trade, 0)

    {price, _ } = Float.parse(price_string)

    persist_price(price)
    broadcast_price(price)

    update_thresholds(price)
    |> send_threshold_notifications(price)

    {:ok, state}
  end

  def persist_price(amount) do
    price = %Price{}
    currency = currency_record("ETH/USD")

    changeset = Price.changeset(price, %{amount: amount, currency_id: currency.id})

    Repo.insert(changeset)
  end

  def broadcast_price(amount) do
    CoyneyeWeb.Endpoint.broadcast!("price:eth/usd", "new_price", %{amount: amount})
  end

  def update_thresholds(price) do
    cond do
      met_max_threshold?(price) ->
        "above"
      met_min_threshold?(price) ->
        "below"
      true ->
        nil
    end
  end

  defp met_max_threshold?(price) do
    max_threshold = last_max_threshold_amount()
    if max_threshold && price >= max_threshold.amount do
      max_threshold = Ecto.Changeset.change max_threshold, met: true
      Repo.update max_threshold

      "above"
    end
  end

  defp met_min_threshold?(price) do
    min_threshold = last_min_threshold_amount()
    if min_threshold && price <= min_threshold.amount do
      min_threshold = Ecto.Changeset.change min_threshold, met: true
      Repo.update min_threshold

      "below"
    end
  end

  def send_threshold_notifications(direction, price) when is_binary(direction) do
    message = "USDT/ETH is #{direction} threshold (#{price})"

    Coyneye.PushoverService.notify(message)
  end

  def currency_record(name) do
    {:ok, currency} = %Currency{}
      |> Currency.changeset(%{name: name})
      |> Repo.insert(on_conflict: :nothing)

    if is_nil(currency.id) do
      Currency |> Repo.get_by!(name: name)
    else
      currency
    end
  end

  def last_max_threshold_amount do
    Query.from(MaxThreshold, where: [met: false], order_by: [desc: :id], limit: 1)
    |> Repo.one
    |> case do
      (%MaxThreshold{} = record) -> record
      nil -> nil
    end
  end

  defp last_min_threshold_amount do
    Query.from(MinThreshold, where: [met: false], order_by: [desc: :id], limit: 1)
    |> Repo.one
    |> case do
      (%MinThreshold{} = record) -> record
      nil -> nil
    end
  end
end
