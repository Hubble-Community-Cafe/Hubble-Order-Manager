defmodule Removeme.Repo do
  use Ecto.Repo,
    otp_app: :removeme,
    adapter: Ecto.Adapters.SQLite3
end
