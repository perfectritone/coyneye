defmodule Coyneye.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @eth_usd_currency_pair "ETH/USD"

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Coyneye.Repo,
      # Start the Telemetry supervisor
      CoyneyeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Coyneye.PubSub},
      # Start the Endpoint (http/https)
      CoyneyeWeb.Endpoint,
      # Start a worker by calling: Coyneye.Worker.start_link(arg)
      # {Coyneye.Worker, arg}
      {Coyneye.FeedClient, [@eth_usd_currency_pair]},
      Coyneye.DatabaseCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coyneye.Supervisor, restart: :always]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CoyneyeWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def eth_usd_currency_pair, do: @eth_usd_currency_pair
end
