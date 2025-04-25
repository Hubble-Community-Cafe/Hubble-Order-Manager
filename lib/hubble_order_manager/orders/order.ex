defmodule HubbleOrderManager.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_number])
    |> validate_required([:order_number])
    |> validate_length(:order_number, min: 1, max: 10)
  end
end
