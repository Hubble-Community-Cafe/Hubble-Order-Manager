defmodule HubbleOrderManagerWeb.Auth do
  use HubbleOrderManagerWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  @max_cookie_age_in_days 14
  @session_cookie "_hubble_order_manager_web_session"
  @session_cookie_options [
    sign: true,
    max_age: @max_cookie_age_in_days * 24 * 60 * 60,
    same_site: "Lax"
  ]

  @doc """
    Log in session, verification of is already done by the controller.
    The sessions are very simple as there is practically only one session. The session is defined by a signed cookie.
  """
  def log_in_session(conn) do
    conn
    |> put_resp_cookie(@session_cookie, "LOGGED_IN", @session_cookie_options)
    |> redirect(to: "/backoffice")
  end

  def fetch_current_session(conn, _opts) do
    with {conn} <- ensure_session_token(conn) do
      assign(conn, :is_logged_in, true)
    else
      nil -> assign(conn, :is_logged_in, false)
    end
  end

  def debug(conn, _opts) do
    IO.inspect(Process.get(:plug_masked_csrf_token), label: "CSRF Token")
    conn
  end

  defp ensure_session_token(conn) do
    conn = fetch_cookies(conn, signed: [@session_cookie])

    case conn.cookies[@session_cookie] do
      "LOGGED_IN" -> {conn}
      nil -> nil
    end
  end

  @doc """
    Require an valid session to be present
    """
  def require_authenticated_session(conn, _opts) do
    if conn.assigns.is_logged_in do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
