defmodule Rewind.Backtests.Services.GenerateNextTick do
  alias Rewind.Backtests.{Backtest, Tick}

  def execute(backtest, nil) do
    time = Backtest.from!(backtest)
    build_tick(0, time, backtest)
  end

  def execute(backtest, previous_tick) do
    next_tick_time = next_time(previous_tick.time, backtest.tick)
    to = Backtest.to!(backtest)

    if DateTime.compare(next_tick_time, to) == :gt do
      nil
    else
      build_tick(previous_tick.id, next_tick_time, backtest)
    end
  end

  defp next_time(previous_time, :min_1) do
    DateTime.add(previous_time, 60, :second)
  end

  defp build_tick(previous_id, time, backtest) do
    quotes = build_quotes()
    trades = build_trades()
    candles = build_candles(time, backtest)
    indicators = build_indicators()

    %Tick{
      id: previous_id + 1,
      backtest_id: backtest.id,
      time: time,
      quotes: quotes,
      trades: trades,
      candles: candles,
      indicators: indicators
    }
  end

  def build_quotes do
    []
  end

  def build_trades do
    []
  end

  def build_candles(time, backtest) do
    backtest.candles
    |> Enum.group_by(& &1.period)
    |> Enum.flat_map(fn {period, period_candles} ->
      venue_products = period_candles |> Enum.map(fn c -> {c.venue, c.symbol} end)
      candles = Rewind.Candles.find_by_time_and_period_and_venue_products(time, period, venue_products)

      # if Enum.empty?(candles) do
      #   # TODO: Log warning that no candles were found
      # end

      candles
    end)
  end

  def build_indicators do
    []
  end
end
