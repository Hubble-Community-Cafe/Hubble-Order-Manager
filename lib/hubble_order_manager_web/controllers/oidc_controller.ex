defmodule HubbleOrderManagerWeb.OIDCController do
  use HubbleOrderManagerWeb, :controller

  alias HubbleOrderManagerWeb.Auth

  defp oidc_config do
    providers = Application.get_env(:openid_connect, :providers, [])
    Keyword.get(providers, :microsoft, []) |> Map.new()
  end

  defp redirect_uri(_conn) do
    Application.get_env(:hubble_order_manager, :auth)[:oidc_redirect_uri]
  end

  @doc """
  Redirects the user to Microsoft's authorization page.
  """
  def request(conn, _params) do
    state = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
    config = oidc_config()

    case OpenIDConnect.authorization_uri(config, redirect_uri(conn), %{state: state}) do
      {:ok, uri} ->
        conn
        |> put_session(:oidc_state, state)
        |> redirect(external: uri)

      {:error, reason} ->
        IO.inspect(reason, label: "OIDC authorization_uri error")

        conn
        |> put_flash(:error, "Could not initiate login. Please try again.")
        |> redirect(to: ~p"/")
    end
  end

  @doc """
  Handles the callback from Microsoft after authentication.
  Exchanges the code for tokens, verifies the ID token, and checks group membership.
  """
  def callback(conn, %{"code" => code, "state" => state}) do
    saved_state = get_session(conn, :oidc_state)

    if state != saved_state do
      conn
      |> put_flash(:error, "Invalid authentication state. Please try again.")
      |> redirect(to: ~p"/")
    else
      conn = delete_session(conn, :oidc_state)
      config = oidc_config()

      with {:ok, tokens} <- OpenIDConnect.fetch_tokens(config, %{code: code, redirect_uri: redirect_uri(conn)}),
           {:ok, claims} <- OpenIDConnect.verify(config, tokens["id_token"]),
           :ok <- check_group_membership(claims) do
        Auth.log_in_session(conn)
      else
        {:error, :not_in_group} ->
          conn
          |> put_flash(:error, "You are not authorized to access this application.")
          |> redirect(to: ~p"/")

        {:error, reason} ->
          IO.inspect(reason, label: "OIDC authentication error")

          conn
          |> put_flash(:error, "Authentication failed. Please try again.")
          |> redirect(to: ~p"/")
      end
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed. Please try again.")
    |> redirect(to: ~p"/")
  end

  defp check_group_membership(claims) do
    allowed_group_id = Application.get_env(:hubble_order_manager, :auth)[:allowed_group_id]

    cond do
      # No group restriction configured — allow anyone in the tenant
      is_nil(allowed_group_id) || allowed_group_id == "" ->
        :ok

      # Check if the user's groups claim contains the allowed group
      allowed_group_id in (claims["groups"] || []) ->
        :ok

      true ->
        {:error, :not_in_group}
    end
  end
end
