defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

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
    Coyneye.MaxThreshold |> Ecto.Query.last |> Coyneye.Repo.one
    |> case do
      (%Coyneye.MaxThreshold{} = record) ->
        {:ok, threshold_amount } = Map.fetch(record, :amount)

        threshold_amount
      nil -> nil
    end
  end

  def min_threshold do
    Coyneye.MinThreshold |> Ecto.Query.last |> Coyneye.Repo.one
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
