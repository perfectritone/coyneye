# Coyneye

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

## Production

To setup the production database on heroku:

  * Set the `DATABASE_URL` environment variable with the username and password included.
  * Migrate with `heroku run mix ecto.migrate`
  * Seed with `heroku run "POOL_SIZE=2 mix run priv/repo/seeds.exs"`

## Test

### Seeding
MIX_ENV="test" mix run priv/repo/seeds.exs

### Run test
mix test
