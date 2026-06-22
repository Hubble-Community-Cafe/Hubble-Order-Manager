defmodule HubbleOrderManagerWeb.OrderController do
  use HubbleOrderManagerWeb, :controller
  alias HubbleOrderManager.Orders

  # Public, read-only list of the current order numbers. CORS-open so the Hubble
  # plaza screen can poll it from hubble.cafe. The numbers are already shown
  # publicly on the live display, so there is nothing sensitive here.
  def index(conn, _params) do
    numbers = Orders.list_orders() |> Enum.map(& &1.order_number)

    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("cache-control", "no-store")
    |> json(%{orders: numbers})
  end
end
