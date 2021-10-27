defmodule Coyneye.Threshold do
  require Ecto.Query

  alias Ecto.Query
  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.{DatabaseCache, Repo}

  @moduledoc """
  Threshold helper
  """

  def minimum_unmet_maximum do
    Query.from(MaxThreshold, where: [met: false], order_by: [asc: :amount], limit: 1)
    |> Repo.one()
    |> threshold
  end

  def maximum_unmet_minimum do
    Query.from(MinThreshold, where: [met: false], order_by: [desc: :amount], limit: 1)
    |> Repo.one()
    |> threshold
  end

  def minimum_unmet_maximum_amount do
    minimum_unmet_maximum()
    |> Map.fetch("amount")
  end

  def maximum_unmet_minimum_amount do
    maximum_unmet_minimum()
    |> Map.fetch("amount")
  end

  def new_max_threshold do
    MaxThreshold.changeset(%MaxThreshold{}, %{})
  end

  def new_min_threshold do
    MinThreshold.changeset(%MinThreshold{}, %{})
  end

  def create_max_met(%{"amount" => amount}) do
    create_max(%{"amount" => amount, "condition" => :met})
  end

  def create_max_exceeded(%{"amount" => amount}) do
    create_max(%{"amount" => amount, "condition" => :exceeded})
  end

  def create_max(%{"amount" => amount, "condition" => condition}) do
    result =
      %MaxThreshold{}
      |> MaxThreshold.changeset(%{"amount" => amount, "condition" => condition})
      |> Repo.insert()

    new_max()

    result
  end

  def create_min_met(%{"amount" => amount}) do
    create_min(%{"amount" => amount, "condition" => :met})
  end

  def create_min_exceeded(%{"amount" => amount}) do
    create_min(%{"amount" => amount, "condition" => :exceeded})
  end

  def create_min(%{"amount" => amount, "condition" => condition}) do
    result =
      %MinThreshold{}
      |> MinThreshold.changeset(%{"amount" => amount, "condition" => condition})
      |> Repo.insert()

    new_min()

    result
  end

  def check_thresholds(price) do
    max_threshold_records_updated = check_max_threshold(price, cached_max())

    min_threshold_records_updated = check_min_threshold(price, cached_min())

    results = %{
      max_threshold_met: max_threshold_records_updated != 0,
      min_threshold_met: min_threshold_records_updated != 0
    }

    update_cache(results)

    results
  end

  def check_max_threshold(_price, nil), do: 0
  def check_max_threshold(price, max_threshold) do
    {%{amount: threshold_amount, condition: condition}, _} = max_threshold
                        |> Map.split([:amount, :condition])

    if price_meets_max_threshold_condition(price, threshold_amount, condition) do
      unmet_max_thresholds_exceeded(price)
      |> Coyneye.Repo.update_all(
        set: [
          met: true
        ]
      )
      |> elem(0)
    else
      0
    end
  end

  defp price_meets_max_threshold_condition(price, threshold_amount, :met) do
    price >= threshold_amount
  end
  defp price_meets_max_threshold_condition(price, threshold_amount, :exceeded) do
    price > threshold_amount
  end

  def check_min_threshold(_price, nil), do: 0
  def check_min_threshold(price, min_threshold) do
    {%{amount: threshold_amount, condition: condition}, _} = min_threshold
                        |> Map.split([:amount, :condition])

    if price_meets_min_threshold_condition(price, threshold_amount, condition) do
      unmet_min_thresholds_exceeded(price)
      |> Coyneye.Repo.update_all(
        set: [
          met: true
        ]
      )
      |> elem(0)
    else
      0
    end
  end

  defp price_meets_min_threshold_condition(price, threshold_amount, :met) do
    price <= threshold_amount
  end
  defp price_meets_min_threshold_condition(price, threshold_amount, :exceeded) do
    price < threshold_amount
  end

  def unmet_max_thresholds do
    Query.from(MaxThreshold, where: [met: false])
  end

  def unmet_min_thresholds do
    Query.from(MinThreshold, where: [met: false])
  end

  def unmet_max_thresholds_exceeded(price) do
    Query.from(mt in unmet_max_thresholds(), where: mt.amount <= ^price)
  end

  def unmet_min_thresholds_exceeded(price) do
    Query.from(mt in unmet_min_thresholds(), where: mt.amount >= ^price)
  end

  defp threshold(nil), do: nil

  #defp threshold(query_result) when query_result in [%MaxThreshold{}, %MinThreshold{}] do
  defp threshold(query_result) do
    {threshold_values, _} = Map.split(query_result, [:amount, :condition])

    threshold_values
  end

  defp update_cache(%{max_threshold_met: true}) do
    new_max()
  end

  defp update_cache(%{min_threshold_met: true}) do
    new_min()
  end

  defp update_cache(%{}), do: nil

  defp new_max do
    DatabaseCache.put(:minimum_unmet_maximum_threshold, minimum_unmet_maximum())
    Coyneye.MaxThreshold.notify_subscribers({:ok, cached_max()})
  end

  defp new_min do
    DatabaseCache.put(:maximum_unmet_minimum_threshold, maximum_unmet_minimum())
    Coyneye.MinThreshold.notify_subscribers({:ok, cached_min()})
  end

  def cached_max do
    DatabaseCache.get(:minimum_unmet_maximum_threshold, &minimum_unmet_maximum/0)
  end

  def cached_min do
    DatabaseCache.get(:maximum_unmet_minimum_threshold, &maximum_unmet_minimum/0)
  end

  def cached_max_amount, do: cached_max() |> cached_max_amount_helper
  def cached_max_amount_helper(nil), do: -1
  def cached_max_amount_helper(max), do: Map.get(max, :amount)

  def cached_min_amount, do: cached_min() |> cached_min_amount_helper
  def cached_min_amount_helper(nil), do: -1
  def cached_min_amount_helper(min), do: Map.get(min, :amount)
end
