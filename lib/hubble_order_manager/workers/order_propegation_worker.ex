defmodule HubbleOrderManager.OrderPropegationWorker do
  use GenServer

  alias Phoenix.PubSub

  @pubsub_topic "orders"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Subscribe to the PubSub topic
    PubSub.subscribe(HubbleOrderManager.PubSub, @pubsub_topic)
    {:ok, state}
  end

  @impl true
  def handle_info({:order_created, order}, state) do
    # Push to aurora
    aurora_push(order)

    {:noreply, state}
  end

  def handle_info(_message, state) do
    # Ignore other messages
    {:noreply, state}
  end

  defp aurora_push(order) do
    url = Application.get_env(:hubble_order_manager, :aurora)[:aurora_url]
    key = Application.get_env(:hubble_order_manager, :aurora)[:aurora_api_key]
    body = Jason.encode!(%{orderNumber: order.order_number, timeoutSeconds: 300})

    # Call aurora backend to add order
    case HTTPoison.post(url <> "/api/orders", body, [{"Content-Type", "application/json"}, {"X-API-Key", key}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        IO.puts("HTTP call successful: #{response_body}")

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("HTTP call failed with status: #{status_code}")

      {:error, reason} ->
        IO.puts("HTTP call failed: #{inspect(reason)}")
    end
  end
end
