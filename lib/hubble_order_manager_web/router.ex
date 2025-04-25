defmodule HubbleOrderManagerWeb.Router do
  use HubbleOrderManagerWeb, :router

  import HubbleOrderManagerWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HubbleOrderManagerWeb.Layouts, :root}
    plug :debug
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HubbleOrderManagerWeb do
    pipe_through [:browser]

    live "/", OrderLive.Index, :index
  end

  scope "/", HubbleOrderManagerWeb do
    pipe_through [:browser]

    live_session :current_user do
      live "/login", AuthLive.Login, :new
    end

    post "/test", SessionController, :test
    post "/login", SessionController, :create
  end

  # scope "/", HubbleOrderManagerWeb do
  #   pipe_through [:browser, :require_authenticated_session]

  #   live "/backoffice", OrderLive.Form, :new
  # end

  # Other scopes may use custom stacks.
  scope "/api", HubbleOrderManagerWeb do
    pipe_through :api

    post "/orders/webhook", OrderWebhook, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hubble_order_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HubbleOrderManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
