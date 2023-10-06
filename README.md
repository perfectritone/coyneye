# Coyneye

Coyneye gives users the ability to track live cryptocurrency prices.
By setting and maintaining custom thresholds, users will receive notifications
to their mobile devices via the Pushover app.

## Development

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Ensure postgresql is installed, running and initialized. Update config with credentials
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

To setup the production database on heroku:

  * Set the `DATABASE_URL` environment variable with the username and password included.
  * Migrate with `heroku run mix ecto.migrate`
  * Seed with `heroku run "POOL_SIZE=2 mix run priv/repo/seeds.exs"`

## Test

### Seeding
MIX_ENV="test" mix run priv/repo/seeds.exs

### Run tests
mix test
