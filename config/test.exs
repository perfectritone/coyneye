import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :coyneye, Coyneye.Repo,
  username: "postgres",
  password: "postgres",
  database: "coyneye_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :coyneye, CoyneyeWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
# config :logger, level: :warn

config :logger,
  :console,
  format: "[$level] $message\n",
  handle_sasl_reports: true,
  handle_otp_reports: true,
  level: :debug
