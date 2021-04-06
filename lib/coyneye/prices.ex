defmodule Coyneye.Prices do
  import Ecto.Query

  @moduledoc """
  Prices
  """

  @topic inspect(__MODULE__)

  def last do
    Coyneye.Price |> Ecto.Query.last |> Coyneye.Repo.one
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Coyneye.PubSub, @topic)
  end

  def notify_subscribers({:ok, amount}) do
    Phoenix.PubSub.broadcast(Coyneye.PubSub, @topic, {__MODULE__, amount})
  end
end
