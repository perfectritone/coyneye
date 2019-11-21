defmodule CoyneyeWeb.Router do
  use CoyneyeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CoyneyeWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/prices", PricesController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoyneyeWeb do
  #   pipe_through :api
  # end
end
