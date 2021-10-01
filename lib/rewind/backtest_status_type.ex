defmodule Rewind.BacktestStatusType do
  use EctoEnum,
    type: :backtest_status_type,
    enums: [:enqueued, :error, :working, :paused, :complete, :canceled]
end
