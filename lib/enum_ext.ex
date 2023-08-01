defmodule EnumExt do
  import Enum

  @moduledoc """
  Extension to the core Enum module
  """

  def present?(enum) do
    !empty?(enum)
  end
end
