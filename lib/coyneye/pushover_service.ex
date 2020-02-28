defmodule Coyneye.PushoverService do
  require Mint.HTTP

  def notify(message) do
    {:ok, conn} = Mint.HTTP.connect(:https, "api.pushover.net", 443)

    {:ok, _conn, _request_ref} = Mint.HTTP.request(
      conn,
      "POST",
      "/1/messages.json",
      [],
      body(message)
    )
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
    case message do
      ~r/above/ -> "pushover"
      ~r/below/ -> "falling"
      _ -> "gamelan"
    end
  end
end
