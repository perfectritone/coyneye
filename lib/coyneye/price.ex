defmodule Coyneye.Price do
  require Ecto.Query
  alias Coyneye.{DatabaseCache, PriceFormatter, Repo}
  alias Coyneye.Model.Price

  @moduledoc """
  Price helper
  """
  @default_currency_pair "eth_usd"

  def last do
    DatabaseCache.get(:last_price, &last_query/0)
  end

  def last_amount do
    DatabaseCache.get(:last_price, &last_query/0).amount
  end

  def formatted_last_price do
    formatted_price(last_amount(), @default_currency_pair)
  end

  def formatted_price(amount, currency_pair) do
    "#{formatted_currency_pair(currency_pair)}: #{PriceFormatter.call(amount)}"
  end

  def persist_price(amount) do
    result =
      last()
      |> Ecto.Changeset.change(amount: amount)
      |> Repo.update()

    DatabaseCache.put(:last_price, elem(result, 1))

    result
  end

  def notify_channel_subscribers({:ok, amount}) do
    currency_pair = @default_currency_pair

    CoyneyeWeb.Endpoint.broadcast!("price:#{currency_pair}", "new_price",
      %{formatted_price: formatted_price(amount, currency_pair), currency_pair: currency_pair})
  end

  defp last_query do
    Price |> Ecto.Query.last() |> Repo.one()
  end

  defp formatted_currency_pair(currency_pair) do
    String.split(currency_pair, "_")
      |> Enum.map_join("/", &String.upcase/1)
  end
end
