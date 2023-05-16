defmodule CoyneyeWeb.Router do
  use CoyneyeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CoyneyeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CoyneyeWeb do
    pipe_through :browser

    get "/", PriceController, :index
    get "/prices", PriceController, :index
    get "/prices/:currency_pair", PriceController, :show
    post "/max_thresholds", MaxThresholdController, :create
    post "/max_thresholds/interval", MaxThresholdController, :create
    delete "/max_thresholds", MaxThresholdController, :destroy_all
    post "/min_thresholds", MinThresholdController, :create
    post "/min_thresholds/interval", MinThresholdController, :create
    delete "/min_thresholds", MinThresholdController, :destroy_all

    live "/recent_price", PriceLive
    live "/minimum_unmet_maximum_threshold", MaxThresholdLive
    live "/maximum_unmet_minimum_threshold", MinThresholdLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoyneyeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:coyneye, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CoyneyeWeb.Telemetry
    end
  end
end
