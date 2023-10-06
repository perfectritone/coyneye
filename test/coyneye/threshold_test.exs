defmodule Coyneye.ThresholdTest do
  use ExUnit.Case, async: true
  use Coyneye.DataCase

  setup do
    {:ok, _currency} =
      %Coyneye.Model.Currency{}
      |> Coyneye.Model.Currency.changeset(%{name: Coyneye.Application.eth_usd_currency_pair()})
      |> Coyneye.Repo.insert()

    :ok
  end

  test "create_max creates a threshold and it can be returned" do
    _result = Coyneye.Threshold.create_max_met(%{amount: 100})

    min_maximum = Coyneye.Threshold.minimum_unmet_maximum_amount()

    assert(100.0 = min_maximum)
  end

  test "create_max does not create a threshold when it already exists" do
    first_result = Coyneye.Threshold.create_max_met(%{amount: 100})
    second_result = Coyneye.Threshold.create_max_met(%{amount: 100})

    assert(%Coyneye.Model.MaxThreshold{} = first_result)
    refute(second_result)
  end

  test "create_min creates a threshold and it can be returned" do
    _result = Coyneye.Threshold.create_min_met(%{amount: 50})

    max_minimum = Coyneye.Threshold.maximum_unmet_minimum_amount()

    assert(50.0 = max_minimum)
  end

  test "create_min does not create a threshold when it already exists" do
    first_result = Coyneye.Threshold.create_min_met(%{amount: 100})
    second_result = Coyneye.Threshold.create_min_met(%{amount: 100})

    assert(%Coyneye.Model.MinThreshold{} = first_result)
    refute(second_result)
  end

  test "check_thresholds returns the thresholds that have been exceeded" do
    _min_result = Coyneye.Threshold.create_min_met(%{amount: 50})
    _max_result = Coyneye.Threshold.create_max_met(%{amount: 100})

    result = Coyneye.Threshold.check_thresholds(100)

    assert(result.max_threshold_met)
    refute(result.min_threshold_met)
  end
end
