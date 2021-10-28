defmodule Coyneye.ThresholdTest do
  use ExUnit.Case, async: true
  use Coyneye.DataCase

  test "create_max creates a threshold and it can be returned" do
    _result = Coyneye.Threshold.create_max_met(%{"amount" => 100})

    min_maximum = Coyneye.Threshold.minimum_unmet_maximum_amount()

    assert(100.0 = min_maximum)
  end

  test "create_min creates a threshold and it can be returned" do
    _result = Coyneye.Threshold.create_min_met(%{"amount" => 50})

    max_minimum = Coyneye.Threshold.maximum_unmet_minimum_amount()

    assert(50.0 = max_minimum)
  end

  test "check_thresholds returns the thresholds that have been exceeded" do
    _min_result = Coyneye.Threshold.create_min_met(%{"amount" => 50})
    _max_result = Coyneye.Threshold.create_max_met(%{"amount" => 100})

    result = Coyneye.Threshold.check_thresholds(100)

    assert(result.max_threshold_met)
    refute(result.min_threshold_met)
  end
end
