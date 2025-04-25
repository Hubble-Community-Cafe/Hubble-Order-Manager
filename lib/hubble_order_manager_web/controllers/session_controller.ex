defmodule HubbleOrderManagerWeb.SessionController do
  use HubbleOrderManagerWeb, :controller

  alias HubbleOrderManagerWeb.Auth

  def test(conn, params) do
    IO.inspect(params)
    conn
    |> put_flash(:info, "Test")
    |> redirect(to: ~p"/")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  # Token login
  defp create(conn, %{"user" => token}, info) do
    login_token = System.get_env("LOGIN_TOKEN")

    case token do
      ^login_token ->
        conn
        |> put_flash(:info, info)
        |> Auth.log_in_session()

      _ ->
        conn
        |> put_flash(:error, "The link is invalid or it has expired.")
        |> redirect(to: ~p"/users/log-in")
    end
  end
end
