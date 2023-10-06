defmodule Coyneye.ThresholdIntervalTest do
  use ExUnit.Case, async: true
  use Coyneye.DataCase
  alias Coyneye.ThresholdInterval
  import Mox

  setup :verify_on_exit!

  test "max thresholds returns set number of thresholds" do
    expect(PriceMock, :last_amount, fn -> 2000 end)

    thresholds = ThresholdInterval.amounts(direction: :max, interval: 10)

    assert Enum.count(thresholds) == 51
  end

  # best way to set the price. connection to the db? mox?
  test "min thresholds returns thresholds limited by 0 lower bound" do
    expect(PriceMock, :last_amount, fn -> 25 end)

    thresholds = ThresholdInterval.amounts(direction: :min, interval: 10)
    expected_unordered_thresholds = [10, 20]

    thresholds_match =
      for threshold <- thresholds, reduce: true do
        acc ->
          Enum.member?(expected_unordered_thresholds, threshold) and acc
      end

    assert Enum.count(thresholds) == 2
    assert thresholds_match == true
  end
end
