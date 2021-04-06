defmodule Coyneye.Threshold do
  require Ecto.Query

  alias Coyneye.Model.{MaxThreshold, MinThreshold}
  alias Coyneye.Repo

  def minimum_unmet_maximum do
    Ecto.Query.from(MaxThreshold, where: [met: false], order_by: [desc: :id], limit: 1)
    |> Repo.one()
    |> threshold_amount
  end

  defp threshold_amount(nil), do: nil
  defp threshold_amount(query_result = %MaxThreshold{}) do
    {:ok, threshold_amount} = Map.fetch(query_result, :amount)

    threshold_amount
  end
end
