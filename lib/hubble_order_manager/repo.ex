defmodule HubbleOrderManager.Repo do
  use Ecto.Repo,
    otp_app: :hubble_order_manager,
    adapter: Ecto.Adapters.SQLite3
end
