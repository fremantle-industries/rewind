defmodule Rewind.Backtests.Queries.Enqueued do
  import Ecto.Query
  alias Rewind.Backtests.Backtest

  def query(limit) do
    from(
      b in Backtest,
      where: b.status == "enqueued",
      order_by: [desc: :inserted_at],
      limit: ^limit
    )
  end
end
