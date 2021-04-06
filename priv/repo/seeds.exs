# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Coyneye.Repo.insert!(%Coyneye.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#

{:ok, currency} = %Coyneye.Currency{}
  |> Coyneye.Currency.changeset(%{name: Coyneye.Application.eth_usd_currency_pair})
  |> Coyneye.Repo.insert

%Coyneye.Price{}
  |> Coyneye.Price.changeset(%{amount: 0, currency_id: currency.id})
  |> Coyneye.Repo.insert
