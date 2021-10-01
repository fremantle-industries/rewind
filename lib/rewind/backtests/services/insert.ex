defmodule Rewind.Backtests.Services.Insert do
  alias Rewind.Backtests.{Backtest, Services}
  alias Rewind.Repo

  @spec execute(struct, map) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def execute(model, params) do
    model_id = model.id |> Atom.to_string()
    receiver = model.receiver |> Atom.to_string()
    candles = build_candle_params(model)
    indicators = build_indicator_params(model)
    base_params = %{
      "model_id" => model_id,
      "receiver" => receiver,
      "status" => "enqueued",
      "pinned" => false,
      "quotes" => [],
      "trades" => [],
      "candles" => candles,
      "indicators" => indicators
    }
    merged_params = Map.merge(base_params, params)
    changeset = Backtest.changeset(%Backtest{}, merged_params)

    case Repo.insert(changeset) do
      {:ok, backtest} = result ->
        Services.Broadcast.execute(backtest)
        result

      result ->
        result
    end
  end

  defp build_candle_params(model) do
    model.candles
    |> Enum.flat_map(fn {period, keys} ->
      keys
      |> Enum.map(fn {v, p} ->
        %{
          venue: v,
          symbol: p,
          period: period |> Atom.to_string()
        }
      end)
    end)
  end

  defp build_indicator_params(_model) do
    []
  end
end
