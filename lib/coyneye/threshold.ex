defmodule Coyneye.Threshold do
  require Ecto.Query

  alias Ecto.Query
  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.{Currency, DatabaseCache, Repo}

  @moduledoc """
  Threshold helper
  """

  def minimum_unmet_maximum do
    Query.from(MaxThreshold, where: [met: false], order_by: [asc: :amount], limit: 1)
    |> Repo.one()
    |> threshold
  end

  def minimum_unmet_maximums do
    user_minimum_maximum_thresholds = Query.from(
      ummt in MaxThreshold,
      where: [met: false],
      group_by: :user_id,
      select: %{
        user_id: ummt.user_id,
        min_user_amount: min(ummt.amount)
      }
    )

    Repo.all(Query.from(
      mt in MaxThreshold,
      join: ummt in subquery(user_minimum_maximum_thresholds),
      on: [
        user_id: mt.user_id,
        min_user_amount: mt.amount
      ],
      select: [
        mt.user_id,
        mt.amount,
        mt.condition
      ]
    ))
    |> user_closest_threshold_list_to_map
  end

  def maximum_unmet_minimum do
    Query.from(MinThreshold, where: [met: false], order_by: [desc: :amount], limit: 1)
    |> Repo.one()
    |> threshold
  end

  def maximum_unmet_minimums do
    user_maximum_minimum_thresholds = Query.from(
      ummt in MinThreshold,
      where: [met: false],
      group_by: :user_id,
      select: %{
        user_id: ummt.user_id,
        max_user_amount: max(ummt.amount)
      }
    )

    Repo.all(Query.from(
      mt in MinThreshold,
      join: ummt in subquery(user_maximum_minimum_thresholds),
      on: [
        user_id: mt.user_id,
        max_user_amount: mt.amount
      ],
      select: [
        mt.user_id,
        mt.amount,
        mt.condition
      ]
    ))
    |> user_closest_threshold_list_to_map
  end

  defp user_closest_threshold_list_to_map(list) do
    list
    |> Map.new(fn [k | v] -> {k, %{amount: Enum.at(v, 0), condition: Enum.at(v, 1)}} end)
  end

  def minimum_unmet_maximum_amount do
    minimum_unmet_maximum()
    .amount
  end

  def maximum_unmet_minimum_amount do
    maximum_unmet_minimum()
    .amount
  end

  def new_max_threshold do
    MaxThreshold.changeset(%MaxThreshold{}, %{})
  end

  def new_min_threshold do
    MinThreshold.changeset(%MinThreshold{}, %{})
  end

  def create_max_met(%{user: user, amount: amount}) do
    create_max(%{user: user, amount: amount, condition: :met})
  end

  def create_max_exceeded(%{user: user, amount: amount}) do
    create_max(%{user: user, amount: amount, condition: :exceeded})
  end

  def create_max(%{user: user, amount: amount, condition: condition}) do
    Repo.get_by(MaxThreshold, user_id: user.id, amount: amount)
    |> insert_max_threshold_unless_exists(user, amount, condition)
  end

  def insert_max_threshold_unless_exists(%MaxThreshold{} = _record, _user, _amount, _condition), do: nil
  def insert_max_threshold_unless_exists(nil, user, amount, condition) do
    max_threshold =
      MaxThreshold.changeset(
        %MaxThreshold{},
        %{
          "amount" => amount,
          "condition" => condition,
          "currency_id" => Currency.default_record_id(),
          "user_id" => user.id
        })
      |> Repo.insert!()

    update_cache(:max_threshold)

    max_threshold
  end

  def create_min_met(%{user: user, amount: amount}) do
    create_min(%{user: user, amount: amount, condition: :met})
  end

  def create_min_exceeded(%{user: user, amount: amount}) do
    create_min(%{user: user, amount: amount, condition: :exceeded})
  end

  def create_min(%{user: user, amount: amount, condition: condition}) do
    Repo.get_by(MinThreshold, user_id: user.id, amount: amount)
    |> insert_min_threshold_unless_exists(user, amount, condition)
  end

  def insert_min_threshold_unless_exists(%MinThreshold{} = _record, _user, _amount, _condition), do: nil
  def insert_min_threshold_unless_exists(nil, user, amount, condition) do
    min_threshold =
      MinThreshold.changeset(
        %MinThreshold{},
        %{
          "amount" => amount,
          "condition" => condition,
          "currency_id" => Currency.default_record_id(),
          "user_id" => user.id
        })
      |> Repo.insert!()

    update_cache(:min_threshold)

    min_threshold
  end

  def delete_all_max() do
    result = Repo.delete_all(MaxThreshold)

    update_cache(:max_threshold)

    result
  end

  def delete_all_min() do
    result = Repo.delete_all(MinThreshold)

    update_cache(:min_threshold)

    result
  end

  # update name to users_with_met_thresholds and split out updating the DB to another function
  def check_thresholds(price) do
    %{
      users_with_max_threshold_conditions_met: check_max_thresholds(price),
      users_with_min_threshold_conditions_met: check_min_thresholds(price)
    }
    |> tap(fn results ->
      if results.users_with_max_threshold_conditions_met, do: update_cache(:max_threshold)
      if results.users_with_min_threshold_conditions_met, do: update_cache(:min_threshold)
    end)
  end

  def check_max_thresholds(price) do
    cached_max()
    |> Enum.filter(fn {_user_id, %{amount: amount, condition: condition}} ->
      price_meets_max_threshold_condition(price, amount, condition)
    end)
    |> Enum.map(&Kernel.elem(&1, 0))
    |> unmet_max_thresholds_exceeded(price)
    |> set_thresholds_to_met
  end

  def check_min_thresholds(price) do
    cached_min()
    |> Enum.filter(fn {_user_id, %{amount: amount, condition: condition}} ->
      price_meets_min_threshold_condition(price, amount, condition)
    end)
    |> Enum.map(&Kernel.elem(&1, 0))
    |> unmet_min_thresholds_exceeded(price)
    |> set_thresholds_to_met
  end

  # do i need to pass user_ids here?
  # can this be implemented with tap? i want part of the return value from the
  # previous function and just to pass the user_ids on
  def set_thresholds_to_met({_thresholds_query, []}), do: []
  def set_thresholds_to_met({thresholds_query, user_ids}) do
    thresholds_query
    |> Repo.update_all(
      set: [
        met: true
      ]
    )

    user_ids
  end

  def notified(:max_threshold) do
    Query.from(MaxThreshold, where: [met: true])
    |> Repo.delete_all
  end
  def notified(:min_threshold) do
    Query.from(MinThreshold, where: [met: true])
    |> Repo.delete_all
  end

  defp price_meets_max_threshold_condition(price, threshold_amount, :met) do
    price >= threshold_amount
  end
  defp price_meets_max_threshold_condition(price, threshold_amount, :exceeded) do
    price > threshold_amount
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

  def unmet_max_thresholds_exceeded(user_ids, price) do
    {
      Query.from(mt in unmet_max_thresholds(), where: mt.amount <= ^price and mt.user_id in ^user_ids),
      user_ids
    }
  end

  def unmet_min_thresholds_exceeded(user_ids, price) do
    {
      Query.from(mt in unmet_min_thresholds(), where: mt.amount >= ^price and mt.user_id in ^user_ids),
      user_ids
    }
  end

  defp threshold(nil), do: nil

  defp threshold(query_result) do
    {threshold_values, _} = Map.split(query_result, [:amount, :condition, :user_id])

    threshold_values
  end

  # IMPROVEMENT:
  # Currently caches all users' thresholds when any threshold needs to be
  # updated. This could be more efficient but would have to queue changes to
  # avoid missing data when two thresholds are updated at the same time.
  defp update_cache(:max_threshold) do
    DatabaseCache.put(:minimum_unmet_maximum_threshold, minimum_unmet_maximums())
    Coyneye.MaxThreshold.notify_subscribers({:ok, cached_max()})
  end

  defp update_cache(:min_threshold) do
    DatabaseCache.put(:maximum_unmet_minimum_threshold, maximum_unmet_minimums())
    Coyneye.MinThreshold.notify_subscribers({:ok, cached_min()})
  end

  def cached_max do
    DatabaseCache.get(:minimum_unmet_maximum_threshold, &minimum_unmet_maximums/0)
  end

  def cached_min do
    DatabaseCache.get(:maximum_unmet_minimum_threshold, &maximum_unmet_minimums/0)
  end

  def cached_max_amount_for_user(user_id) do
    cached_max()[user_id]
    |> cached_max_amount_helper
  end

  def cached_min_amount_for_user(user_id) do
    cached_min()[user_id]
    |> cached_min_amount_helper
  end

  def cached_max_amount, do: cached_max() |> cached_max_amount_helper
  def cached_max_amount_helper(nil), do: -1
  def cached_max_amount_helper(max), do: Map.get(max, :amount)

  def cached_min_amount, do: cached_min() |> cached_min_amount_helper
  def cached_min_amount_helper(nil), do: -1
  def cached_min_amount_helper(min), do: Map.get(min, :amount)
end
