defmodule Coyneye.PushoverService do
  require HTTPoison

  @moduledoc """
  Push notifications to the Pushover service
  """

  @url "https://api.pushover.net/1/messages.json"
  @headers [{"Content-Type", "application/json"}]

  def notify(message, %{pushover_user: pushover_user}) do
    HTTPoison.post(@url, body(message, pushover_user, application_token()), @headers)
  end

  def body(message, pushover_user, application_token) do
    Poison.encode!(%{
      token: application_token,
      user: pushover_user,
      message: message,
      sound: sound(message)
    })
  end

  defp application_token do
    System.fetch_env!("PUSHOVER_TOKEN")
  end

  defp sound(message) do
    cond do
      Regex.match?(~r/above/, message) -> "pushover"
      Regex.match?(~r/below/, message) -> "falling"
      true -> "gamelan"
    end
  end
end
