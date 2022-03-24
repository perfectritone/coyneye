defmodule Coyneye.ThresholdParserTest do
  use ExUnit.Case, async: true
  use Coyneye.DataCase
  alias Coyneye.ThresholdParser

  # add some tests here
  # also finish the deleting min/max thresholds case
  #
  # test "min met"
  # test "min exceeded"
  # test "max met"
  # test "max exceeded"
  # test "min met delimited"
  # test "max exceeded delimited"
  #
  test "integer returns itself" do
    assert ThresholdParser.parse_amounts("100") == [100]
  end

  test "float returns itself" do
    assert ThresholdParser.parse_amounts("100.0") == [100.0]
  end

  test "multiple numbers return themselves" do
    assert ThresholdParser.parse_amounts("100 200.1 300") == [100, 200.1, 300]
  end

  test "multipliers return all thresholds calculated" do
    assert ThresholdParser.parse_amounts("100+25x4") == [100, 125, 150, 175, 200]
  end
end
