defmodule Rewind.BacktestTickType do
  use EctoEnum,
    type: :backtest_tick_type,
    enums: [:quote, :trade, :min_1, :min_5, :min_15, :hour_1, :hour_2, :hour_4, :hour_6, :hour_12, :day_1]
end
