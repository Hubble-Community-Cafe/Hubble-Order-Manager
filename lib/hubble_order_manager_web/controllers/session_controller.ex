defmodule HubbleOrderManagerWeb.SessionController do
  use HubbleOrderManagerWeb, :controller

  alias HubbleOrderManagerWeb.Auth

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  # Token login
  defp create(conn, %{"token" => token}, info) do
    login_token = System.get_env("LOGIN_TOKEN")

    case token do
      ^login_token ->
        conn
        |> put_flash(:info, info)
        |> Auth.log_in_session()

      _ ->
        conn
        |> put_flash(:error, "Incorrect password.")
        |> redirect(to: ~p"/login")
    end
  end
end
