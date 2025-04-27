defmodule HubbleOrderManager.OrderTimeoutWorker do
  use GenServer

  alias HubbleOrderManager.Orders
  alias Phoenix.PubSub

  @pubsub_topic "orders"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    order_timeout = Application.get_env(:hubble_order_manager, :order)[:order_timeout]

    # Purge orders that are already older than the global timeout
    Orders.purge_orders()
    # Schedule removal for existing orders
    Orders.list_orders()
    |> Enum.each(fn order ->
        # Schedule removal
        Process.send_after(
          self(),
          {:remove_order, order},
          DateTime.diff(DateTime.add(order.inserted_at, order_timeout), DateTime.utc_now()) * 1000)
      end)

    PubSub.subscribe(HubbleOrderManager.PubSub, @pubsub_topic)
    {:ok, state}
  end

  @impl true
  def handle_info({:order_created, order}, state) do
    order_timeout = Application.get_env(:hubble_order_manager, :order)[:order_timeout]

    # Schedule removal
    Process.send_after(self(), {:remove_order, order}, order_timeout * 1000)

    {:noreply, state}
  end

  @impl true
  def handle_info({:remove_order, order}, state) do
    Orders.delete_order(order)
    {:noreply, state}
  end

  @impl true
  def handle_info(_message, state) do
    # Ignore other messages
    {:noreply, state}
  end
end
