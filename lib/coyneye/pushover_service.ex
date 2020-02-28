defmodule Coyneye.PushoverService do
  require HTTPoison

  @url "https://api.pushover.net/1/messages.json"
  @headers [{"Content-Type", "application/json"}]

  def notify(message) do
    HTTPoison.post(@url, body(message), @headers)
  end

  def body(message) do
    Poison.encode!(%{
      token: token(),
      user: user(),
      message: message,
      sound: sound(message),
    })
  end

  defp token do
    System.fetch_env!("PUSHOVER_TOKEN")
  end

  defp user do
    System.fetch_env!("PUSHOVER_USER")
  end

  defp sound(message) do
    cond do
      String.match?(message, ~r/above/) -> "pushover"
      String.match?(message, ~r/below/) -> "falling"
      true -> "gamelan"
    end
  end
end
