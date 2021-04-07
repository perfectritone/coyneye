defmodule Coyneye.Currency do
  alias Coyneye.Repo

  @moduledoc """
  Currency helper
  """

  def record(name) do
    Coyneye.Model.Currency |> Repo.get_by!(name: name)
  end
end
