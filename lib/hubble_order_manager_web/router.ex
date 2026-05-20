defmodule HubbleOrderManagerWeb.Router do
  use HubbleOrderManagerWeb, :router

  import HubbleOrderManagerWeb.Auth
  import HubbleOrderManagerWeb.Branding, only: [fetch_branding: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HubbleOrderManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_session
    plug :fetch_branding
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HubbleOrderManagerWeb do
    pipe_through [:browser]

    live_session :public, on_mount: {HubbleOrderManagerWeb.Branding, :default} do
      live "/", OrderLive.Index, :index
    end
  end

  scope "/auth", HubbleOrderManagerWeb do
    pipe_through [:browser]

    get "/microsoft", OIDCController, :request
    get "/microsoft/callback", OIDCController, :callback
  end

  scope "/", HubbleOrderManagerWeb do
    pipe_through [:browser, :require_authenticated_session]

    live_session :require_authenticated_user, on_mount: {HubbleOrderManagerWeb.Branding, :default} do
      live "/orders/edit", OrderLive.Edit
    end
  end

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
