defmodule Rewind.Repo do
  use Ecto.Repo,
    otp_app: :rewind,
    adapter: Ecto.Adapters.Postgres
end
