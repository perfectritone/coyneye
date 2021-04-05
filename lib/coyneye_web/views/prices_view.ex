defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

  require Ecto.Query
  require Coyneye.Repo
  alias Coyneye.Repo
  alias Coyneye.{MaxThreshold, MinThreshold}

  def title do
    "Coyneye"
  end

  def max_threshold_changeset do
    Coyneye.MaxThreshold.changeset(%Coyneye.MaxThreshold{}, %{})
  end

  def min_threshold_changeset do
    Coyneye.MinThreshold.changeset(%Coyneye.MinThreshold{}, %{})
  end

  def max_threshold do
    Ecto.Query.from(MaxThreshold, where: [met: false], order_by: [desc: :id], limit: 1)
    |> Repo.one
    |> case do
      (%Coyneye.MaxThreshold{} = record) ->
        {:ok, threshold_amount } = Map.fetch(record, :amount)

        threshold_amount
        |> format_float_to_price
      nil -> nil
    end
  end

  def min_threshold do
    Ecto.Query.from(MinThreshold, where: [met: false], order_by: [desc: :id], limit: 1)
    |> Repo.one
    |> case do
      (%Coyneye.MinThreshold{} = record) ->
        {:ok, threshold_amount } = Map.fetch(record, :amount)

        threshold_amount
        |> format_float_to_price
      nil -> nil
    end
  end

  defp format_float_to_price(float) do
    :erlang.float_to_binary(float, [decimals: 2])
  end
end
