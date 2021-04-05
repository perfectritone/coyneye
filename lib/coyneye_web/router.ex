defmodule CoyneyeWeb.Router do
  use CoyneyeWeb, :router
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {CoyneyeWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CoyneyeWeb do
    pipe_through :browser

    get "/", PricesController, :index
    get "/prices", PricesController, :index
    post "/max_thresholds", MaxThresholdController, :create
    post "/min_thresholds", MinThresholdController, :create

    live "/recent_price", PriceLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoyneyeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CoyneyeWeb.Telemetry
    end
  end
end
