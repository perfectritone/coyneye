defmodule Coyneye.Price do
  require Ecto.Query
  alias Coyneye.{DatabaseCache, PubSub, Repo}
  alias Coyneye.Model.Price

  @moduledoc """
  Price helper
  """

  @topic inspect(__MODULE__)

  def last do
    DatabaseCache.get(:last_price, &last_query/0)
  end

  def last_amount do
    DatabaseCache.get(:last_price, &last_query/0).amount
  end

  def persist_price(amount) do
    result =
      last()
      |> Ecto.Changeset.change(amount: amount)
      |> Repo.update()

    DatabaseCache.put(:last_price, elem(result, 1))

    result
  end

  def subscribe do
    Phoenix.PubSub.subscribe(PubSub, @topic)
  end

  def notify_subscribers({:ok, amount}) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {__MODULE__, amount})
  end

  defp last_query do
    Price |> Ecto.Query.last() |> Repo.one()
  end
end
