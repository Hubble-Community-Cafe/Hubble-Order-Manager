defmodule HubbleOrderManagerWeb.OrderLive.Index do
  use HubbleOrderManagerWeb, :live_view

  alias HubbleOrderManager.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        READY FOR PICKUP
      </.header>
      <div class="grid grid-cols-2 gap-4">
        <%= for order <- @orders do %>
          <div
            id={"order-#{order.inserted_at}"}
            class={"w-40 rounded text-5xl text-center border #{order.animation_class || ""}"}
            phx-hook="RemoveAnimation"
          >
            {order.order_number}
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Orders.subscribe()

    # Add a default :animation_class key to all orders
    orders = Orders.list_orders()
          |> Enum.sort_by(& Integer.parse(&1.order_number), :desc)
          |> Enum.map(fn order ->
              order
                |> Map.put(:animation_class, nil)
            end)

    {:ok,
     socket
     |> assign(:orders, orders)}
  end

  @impl true
  def handle_info({:order_created, order}, socket) do
    # Add bounce animation to new orders
    order = order
      |> Map.put(:animation_class, "bounce")

    # Remove the animation class from all other orders to prevent them bouncing on re-render
    orders = socket.assigns.orders
    |> Enum.map(fn order ->
        Map.put(order, :animation_class, nil)
      end)

    {:noreply,
     socket
     |> assign(:orders, Enum.sort_by([order | orders], & Integer.parse(&1.order_number), :desc))}
  end

  @impl true
  def handle_info({:order_removed, order}, socket) do
    updated_orders = socket.assigns.orders
      |> Enum.reject(fn ord ->
        ord.order_number == order.order_number
      end)

    {:noreply, assign(socket, orders: updated_orders)}
  end
end
