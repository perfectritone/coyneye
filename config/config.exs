# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :coyneye, Coyneye.Repo,
  database: "coyneye_repo",
  username: "rails",
  password: "rails",
  hostname: "127.0.0.1"

config :coyneye,
  ecto_repos: [Coyneye.Repo]

# Configures the endpoint
config :coyneye, CoyneyeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XEXLqqLKbdBOl/fcFLDndpMqkiddWp2kA5Yp9A3ReNP9YNrmZZ9vih/hfw8QEJQt",
  render_errors: [view: CoyneyeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Coyneye.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
