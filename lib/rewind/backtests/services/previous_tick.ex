defmodule Rewind.Backtests.Services.PreviousTick do
  alias Rewind.Backtests.Services

  def execute(backtest, tick) do
    Services.GeneratePreviousTick.execute(backtest, tick)
  end
end
