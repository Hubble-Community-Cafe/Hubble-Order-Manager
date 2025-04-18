defmodule HubbleOrderManagerWeb.OrderLive.Index do
  use HubbleOrderManagerWeb, :live_view

  alias HubbleOrderManager.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Orders ready at the kitchen
        <:actions>
          <.button variant="primary" navigate={~p"/new"}>
            <.icon name="hero-plus" /> New Order
          </.button>
        </:actions>
      </.header>

      <%= for order <- @orders do %>
        <div class="w-60 text-5xl text-center border">{order.order_number}</div>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Orders.subscribe()

    {:ok,
     socket
     |> assign(:page_title, "Listing Orders")
     |> assign(:orders, Orders.list_orders())}
  end

  @impl true
  def handle_info({:order_created, order}, socket) do
    {:noreply, update(socket, :orders, fn orders -> [order | orders] end)}
  end
end
