defmodule Rewind.Backtests.Queries.ByStatus do
  import Ecto.Query
  alias Rewind.Backtests.Backtest

  def query(status) do
    from(
      b in Backtest,
      where: b.status in ^status,
      order_by: [desc: :inserted_at],
      # offset: ^offset,
      # limit: ^page_size
    )
  end
end
