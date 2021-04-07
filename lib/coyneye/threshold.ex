defmodule Coyneye.Threshold do
  require Ecto.{Changeset, Query}

  alias Ecto.{Changeset, Query}
  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.Repo

  def minimum_unmet_maximum do
    Query.from(MaxThreshold, where: [met: false], order_by: [asc: :amount], limit: 1)
    |> Repo.one()
    |> threshold_amount
  end

  def maximum_unmet_minimum do
    Query.from(MinThreshold, where: [met: false], order_by: [desc: :amount], limit: 1)
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

  def check_thresholds(price) do
    {max_threshold_records_updated, _} = unmet_max_thresholds_exceeded(price)
    |> Coyneye.Repo.update_all(
      set: [
        met: true,
      ],
    )

    {min_threshold_records_updated, _} = unmet_min_thresholds_exceeded(price)
    |> Coyneye.Repo.update_all(
      set: [
        met: true,
      ],
    )

    %{
      max_threshold_met: max_threshold_records_updated != 0,
      min_threshold_met: min_threshold_records_updated != 0,
    }
  end

  def unmet_max_thresholds do
    Query.from(MaxThreshold, where: [met: false])
  end

  def unmet_min_thresholds do
    Query.from(MinThreshold, where: [met: false])
  end

  def unmet_max_thresholds_exceeded(price) do
    Query.from mt in unmet_max_thresholds, where: mt.amount <= ^price
  end

  def unmet_min_thresholds_exceeded(price) do
    Query.from mt in unmet_min_thresholds, where: mt.amount >= ^price
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
