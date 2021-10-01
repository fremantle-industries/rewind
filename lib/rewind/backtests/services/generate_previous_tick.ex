defmodule Rewind.Backtests.Services.GeneratePreviousTick do
  alias Rewind.Backtests.Tick

  def execute(_backtest, %Tick{id: 1}) do
    nil
  end

  def execute(backtest, tick) do
    time = previous_time(tick.time, backtest.tick)

    %Tick{
      id: tick.id - 1,
      backtest_id: backtest.id,
      time: time
    }
  end

  defp previous_time(next_time, :min_1) do
    DateTime.add(next_time, -1, :minute)
  end
end
