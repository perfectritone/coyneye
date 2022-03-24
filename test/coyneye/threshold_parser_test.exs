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
    assert ThresholdParser.parse_amounts("100") == "100"
  end
end
