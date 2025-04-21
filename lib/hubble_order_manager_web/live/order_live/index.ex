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
    orders_without_animation = Enum.map(Orders.list_orders(), fn order ->
      Map.put(order, :animation_class, nil)
    end)

    {:ok,
     socket
     |> assign(:orders, orders_without_animation)}
  end

  @impl true
  def handle_info({:order_created, order}, socket) do
    # Add a temporary "bounce" class to the new order
    order_with_animation = Map.put(order, :animation_class, "bounce")
    # Remove the animation class from all other orders
    orders_without_animation = Enum.map(socket.assigns.orders, fn order ->
      Map.put(order, :animation_class, nil)
    end)


    {:noreply,
     socket
     |> assign(:orders, [order_with_animation | orders_without_animation])}
  end
end
