defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

  alias Coyneye.Threshold

  def title do
    "Coyneye"
  end

  def max_threshold_changeset do
    Threshold.new_max_threshold()
  end

  def min_threshold_changeset do
    Threshold.new_min_threshold()
  end
end
