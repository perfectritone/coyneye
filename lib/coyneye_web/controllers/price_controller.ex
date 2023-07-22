defmodule CoyneyeWeb.PriceController do
  use CoyneyeWeb, :controller
  alias Coyneye.{Price, PriceFormatter, Threshold}

  def index(conn, _params) do
    render(conn, "index.html", assigns(conn.assigns.current_user))
  end

  def show(conn, %{"currency_pair" => _currency_pair}) do
    json(conn, %{price: Price.last_amount()})
  end

  def min_threshold_changeset do
    Threshold.new_min_threshold()
  end

  def max_threshold_changeset do
    Threshold.new_max_threshold()
  end

  defp assigns(current_user) do
    %{
      formatted_last_price: Price.formatted_last_price(),
    } |> Map.merge(threshold_assigns(current_user))
  end

  defp threshold_assigns(%Coyneye.Accounts.User{} = current_user) do
    user_id = current_user.id

    %{
      formatted_last_min_threshold_amount: PriceFormatter.call(Threshold.cached_min_for_user(user_id)),
      formatted_last_max_threshold_amount: PriceFormatter.call(Threshold.cached_max_for_user(user_id)),
      min_threshold_changeset: min_threshold_changeset(),
      max_threshold_changeset: max_threshold_changeset()
    }
  end
  defp threshold_assigns(nil), do: %{}
end
