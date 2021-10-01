defmodule Rewind.Backtests.Queries.ByModel do
  import Ecto.Query
  alias Rewind.Backtests.Backtest

  def query(model_id) when is_bitstring(model_id) do
    from(
      b in Backtest,
      where: b.model_id == ^model_id,
      order_by: [desc: :inserted_at],
      # offset: ^offset,
      # limit: ^page_size
    )
  end

  def query(model_id) when is_atom(model_id) do
    model_id |> Atom.to_string() |> query()
  end
end
