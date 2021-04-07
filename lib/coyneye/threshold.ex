defmodule Coyneye.Threshold do
  require Ecto.Query

  alias Ecto.Query
  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.{DatabaseCache, Repo}

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
    result = %MaxThreshold{}
    |> MaxThreshold.changeset(%{"amount" => amount})
    |> Repo.insert()

    DatabaseCache.put(:minimum_unmet_maximum_threshold, minimum_unmet_maximum())

    result
  end

  def create_min(%{"amount" => amount}) do
    result = %MinThreshold{}
    |> MinThreshold.changeset(%{"amount" => amount})
    |> Repo.insert()

    DatabaseCache.put(:maximum_unmet_minimum_threshold, maximum_unmet_minimum())

    result
  end

  def check_thresholds(price) do
    max_threshold_records_updated =
      if 0 < cached_max() and cached_max() <= price do
        unmet_max_thresholds_exceeded(price)
        |> Coyneye.Repo.update_all(
          set: [
            met: true,
          ]
        )
        |> elem(0)
      else 0
      end

    min_threshold_records_updated =
      if cached_min() >= price do
        unmet_min_thresholds_exceeded(price)
        |> Coyneye.Repo.update_all(
          set: [
            met: true,
          ]
        )
        |> elem(0)
      else 0
      end

    results = %{
      max_threshold_met: max_threshold_records_updated != 0,
      min_threshold_met: min_threshold_records_updated != 0,
    }

    update_cache(results)

    results
  end

  def unmet_max_thresholds do
    Query.from(MaxThreshold, where: [met: false])
  end

  def unmet_min_thresholds do
    Query.from(MinThreshold, where: [met: false])
  end

  def unmet_max_thresholds_exceeded(price) do
    Query.from mt in unmet_max_thresholds(), where: mt.amount <= ^price
  end

  def unmet_min_thresholds_exceeded(price) do
    Query.from mt in unmet_min_thresholds(), where: mt.amount >= ^price
  end

  defp threshold_amount(nil), do: -1
  defp threshold_amount(query_result = %MaxThreshold{}) do
    {:ok, threshold_amount} = Map.fetch(query_result, :amount)

    threshold_amount
  end
  defp threshold_amount(query_result = %MinThreshold{}) do
    {:ok, threshold_amount} = Map.fetch(query_result, :amount)

    threshold_amount
  end

  defp update_cache(%{}), do: nil
  defp update_cache(%{max_threshold_met: true}) do
    DatabaseCache.put(:minimum_unmet_maximum_threshold, minimum_unmet_maximum())
  end
  defp update_cache(%{min_threshold_met: true}) do
    DatabaseCache.put(:maximum_unmet_minimum_threshold, maximum_unmet_minimum())
  end

  def cached_max do
    DatabaseCache.get(:minimum_unmet_maximum_threshold, &minimum_unmet_maximum/0)
  end

  def cached_min do
    DatabaseCache.get(:maximum_unmet_minimum_threshold, &maximum_unmet_minimum/0)
  end
end
