defmodule HubbleOrderManagerWeb.OrderLive.Form do
  use HubbleOrderManagerWeb, :live_view

  alias HubbleOrderManager.Orders
  alias HubbleOrderManager.Orders.Order

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="order-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:order_number]} type="text" label="Order number" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Add Order</.button>
        </footer>
      </.form>
      <div>Tap to remove order</div>
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
  def mount(params, _session, socket) do
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
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:orders, orders)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    order = %Order{}

    socket
    |> assign(:page_title, "New Order")
    |> assign(:order, order)
    |> assign(:form, to_form(Orders.change_order(order)))
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset = Orders.change_order(socket.assigns.order, order_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    save_order(socket, socket.assigns.live_action, order_params)
  end

  defp save_order(socket, :new, order_params) do
    case Orders.create_order(order_params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:order_created, order}, socket) do
    # Add bounce animation to new orders
    order = order
      |> Map.put(:animation_class, "bounce")

    # Remove the animation class from all other orders to prevent them bouncing on re-render
    orders = Enum.map(socket.assigns.orders, fn order ->
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
