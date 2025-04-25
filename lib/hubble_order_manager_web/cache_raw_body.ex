defmodule HubbleOrderManagerWeb.BodyReader do
  @moduledoc """
  A custom body reader that caches the raw body in the connection.
  """

  import Plug.Conn

  def read_body(conn, opts) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, body, conn} ->
        # Cache the body in the connection's private data
        conn = assign(conn, :raw_body, body)
        {:ok, body, conn}

      {:more, body, conn} ->
        # Cache the partial body in the connection's private data
        conn = assign(conn, :raw_body, body)
        {:more, body, conn}
    end
  end
end
