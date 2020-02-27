defmodule CoyneyeWeb.PricesView do
  use CoyneyeWeb, :view

  def render("index.html", _assigns) do
    price =  Coyneye.Price |> Ecto.Query.last |> Coyneye.Repo.one
    price.amount
  end
end
