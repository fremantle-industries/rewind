defmodule Rewind.Backtests.Services.NextTick do
  alias Rewind.Backtests.Services

  def execute(backtest, previous_tick) do
    Services.GenerateNextTick.execute(backtest, previous_tick)
  end
end
