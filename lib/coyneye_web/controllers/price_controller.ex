defmodule CoyneyeWeb.PriceController do
  use CoyneyeWeb, :controller
  alias Coyneye.{Price, PriceFormatter, Threshold}

  def index(conn, _params) do
    render(conn, "index.html",
      %{
        formatted_last_price: Price.formatted_last_price(),
        formatted_last_min_threshold_amount: PriceFormatter.call(Threshold.cached_min_amount),
        formatted_last_max_threshold_amount: PriceFormatter.call(Threshold.cached_max_amount),
        min_threshold_changeset: min_threshold_changeset(),
        max_threshold_changeset: max_threshold_changeset()
      })
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
end
