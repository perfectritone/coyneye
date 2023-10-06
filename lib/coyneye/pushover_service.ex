defmodule Coyneye.PushoverService do
  require HTTPoison

  @moduledoc """
  Push notifications to the Pushover service
  """

  @message_url "https://api.pushover.net/1/messages.json"
  @user_validation_url "https://api.pushover.net/1/users/validate.json"
  @headers [{"Content-Type", "application/json"}]

  def notify(message, %{pushover_user: pushover_user}) do
    HTTPoison.post(
      @message_url,
      message_body(message, pushover_user),
      @headers)
  end

  defp message_body(message, pushover_user) do
    Poison.encode!(%{
      token: application_token(),
      user: pushover_user,
      message: message,
      sound: sound(message)
    })
  end

  def validate_user(pushover_user) do
    HTTPoison.post!(
      @user_validation_url,
      validate_body(pushover_user),
      @headers)
    |> Map.fetch!(:body)
    |> Poison.decode!
    |> Map.fetch!("status")
    |> case do
      1 -> true
      0 -> false
    end
  end

  defp validate_body(pushover_user) do
    Poison.encode!(%{
      token: application_token(),
      user: pushover_user
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
