defmodule Coyneye.MinThreshold do
  alias Coyneye.PubSub

  @moduledoc """
  Min Threshold subscriber class
  """

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(PubSub, @topic)
  end

  def notify_subscribers({:ok, threshold}) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {__MODULE__, threshold})
  end
end
