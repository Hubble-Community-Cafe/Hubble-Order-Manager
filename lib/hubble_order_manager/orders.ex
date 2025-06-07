defmodule HubbleOrderManager.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias HubbleOrderManager.Repo

  alias HubbleOrderManager.Orders.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(from o in Order, order_by: [desc: o.inserted_at])
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:order_created)
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    # Print
    IO.inspect(order, label: "Deleting order")
    broadcast({:ok, order}, :order_removed)
    Repo.delete(order)
  end

  @doc """
  Purge orders older than global timeout
  """
  def purge_orders() do
    order_timeout = Application.get_env(:hubble_order_manager, :order)[:order_timeout]

    now = DateTime.utc_now()
    threshold = DateTime.add(now, -order_timeout)

    Repo.delete_all(
      from o in Order,
        where: o.inserted_at < ^threshold
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(HubbleOrderManager.PubSub, "orders")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, order}, event) do
    Phoenix.PubSub.broadcast(HubbleOrderManager.PubSub, "orders", {event, order})
    {:ok, order}
  end
end
