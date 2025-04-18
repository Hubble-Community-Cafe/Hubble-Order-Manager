defmodule HubbleOrderManager.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order_number, :string

      timestamps(type: :utc_datetime)
    end
  end
end
