defmodule Coyneye.Threshold do
  require Ecto.Query

  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.Repo

  def minimum_unmet_maximum do
    Ecto.Query.from(MaxThreshold, where: [met: false], order_by: [asc: :amount], limit: 1)
    |> Repo.one()
    |> threshold_amount
  end

  def maximum_unmet_minimum do
    Ecto.Query.from(MinThreshold, where: [met: false], order_by: [desc: :amount], limit: 1)
    |> Repo.one()
    |> threshold_amount
  end

  def new_max_threshold do
    MaxThreshold.changeset(%MaxThreshold{}, %{})
  end

  def new_min_threshold do
    MinThreshold.changeset(%MinThreshold{}, %{})
  end

  def create_max(%{"amount" => amount}) do
    %MaxThreshold{}
    |> MaxThreshold.changeset(%{"amount" => amount})
    |> Repo.insert()
  end

  def create_min(%{"amount" => amount}) do
    %MinThreshold{}
    |> MinThreshold.changeset(%{"amount" => amount})
    |> Repo.insert()
  end

  defp threshold_amount(nil), do: nil
  defp threshold_amount(query_result = %MaxThreshold{}) do
    {:ok, threshold_amount} = Map.fetch(query_result, :amount)

    threshold_amount
  end
  defp threshold_amount(query_result = %MinThreshold{}) do
    {:ok, threshold_amount} = Map.fetch(query_result, :amount)

    threshold_amount
  end
end
