defmodule Rewind.Examples.BenchmarkPairs.Receiver do
  require Logger

  def handle_tick(tick) do
    "benchmark pairs tick receiver backtest_id=~w, tick_id=~w, time=~s"
    |> :io_lib.format([
      tick.backtest_id,
      tick.id,
      tick.time |> DateTime.to_iso8601()
    ])
    |> Logger.info()

    {:ok, []}
  end
end
