defmodule HubbleOrderManagerWeb.Plugs.CacheRawBody do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    {:ok, raw_body, conn} = read_body(conn)
    assign(conn, :raw_body, raw_body)
  end
end
