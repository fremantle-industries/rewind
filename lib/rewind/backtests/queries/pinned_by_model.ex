defmodule Rewind.Backtests.Queries.PinnedByModel do
  import Ecto.Query
  alias Rewind.Backtests.Backtest

  def query(model_id) when is_bitstring(model_id) do
    from(
      b in Backtest,
      where: b.model_id == ^model_id and b.pinned == true,
      order_by: [desc: :inserted_at],
    )
  end

  def query(model_id) when is_atom(model_id) do
    model_id |> Atom.to_string() |> query()
  end
end
