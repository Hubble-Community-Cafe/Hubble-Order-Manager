defmodule HubbleOrderManagerWeb.SessionController do
  use HubbleOrderManagerWeb, :controller

  alias HubbleOrderManagerWeb.Auth

  def login(conn, params) do
    login(conn, params, "Welcome back!")
  end

  # Token login
  defp login(conn, %{"token" => token}, info) do
    login_token = Application.get_env(:hubble_order_manager, :auth)[:login_token]

    IO.inspect(login_token, label: "Login Token")
    IO.inspect(token, label: "Token")

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
