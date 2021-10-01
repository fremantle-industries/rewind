defmodule Rewind.Backtests.Services.Broadcast do
  @spec execute(struct) :: no_return
  def execute(backtest, pub_sub \\ Rewind.PubSub) do
    msg = %{id: backtest.id, status: backtest.status}

    [
      "backtest:#{backtest.id}",
      "backtest:model:#{backtest.model_id}",
      "backtest:*"
    ]
    |> Enum.each(fn topic ->
      Phoenix.PubSub.broadcast(pub_sub, topic, {topic, msg})
    end)
  end
end
