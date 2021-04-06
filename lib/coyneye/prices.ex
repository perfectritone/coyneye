defmodule Coyneye.Prices do
  require Ecto.Query
  alias Coyneye.{Price, PubSub, Repo}

  @moduledoc """
  Prices
  """

  @topic inspect(__MODULE__)

  def last do
    Price |> Ecto.Query.last |> Repo.one
  end

  def subscribe do
    Phoenix.PubSub.subscribe(PubSub, @topic)
  end

  def notify_subscribers({:ok, amount}) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {__MODULE__, amount})
  end
end
