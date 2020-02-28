defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

  require Ecto.Query
  require Coyneye.Repo
  alias Coyneye.Repo
  alias Coyneye.{MaxThreshold, MinThreshold}

  def title do
    "(#{amount()}) Coyneye"
  end

  def amount do
    price().amount
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
      nil -> nil
    end
  end

  defp price do
    Coyneye.Price |> Ecto.Query.last |> Coyneye.Repo.one
  end
end
