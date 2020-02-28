defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

  def title do
    "(#{amount()}) Coyneye"
  end

  def amount do
    price().amount
  end

  defp price do
    Coyneye.Price |> Ecto.Query.last |> Coyneye.Repo.one
  end
end
