defmodule HubbleOrderManagerWeb.Branding do
  @moduledoc """
  Provides branding configuration (colors, logo, name) to all templates.
  Used as both a Plug (for controllers/root layout) and an on_mount hook (for LiveViews).
  """

  import Phoenix.Component, only: [assign: 2]

  def fetch_branding(conn, _opts) do
    Plug.Conn.merge_assigns(conn, branding_assigns())
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, assign(socket, branding_assigns())}
  end

  defp branding_assigns do
    config = Application.get_env(:hubble_order_manager, :branding, [])

    %{
      bar_name: Keyword.get(config, :bar_name, "Hubble Community Café"),
      bar_logo_url: Keyword.get(config, :bar_logo_url, "/images/Hubble-Logo.png"),
      favicon_url: Keyword.get(config, :favicon_url, "/images/hubble-favicon.ico"),
      primary_color: Keyword.get(config, :primary_color, "#0f4d64"),
      secondary_color: Keyword.get(config, :secondary_color, "#bde8ec"),
      accent_color: Keyword.get(config, :accent_color, "#62cad3")
    }
  end
end
