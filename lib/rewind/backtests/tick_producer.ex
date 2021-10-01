defmodule Rewind.Backtests.TickProducer do
  use GenStage
  alias Rewind.Backtests

  defmodule State do
    defstruct ~w[working_backtests last_ticks]a
  end

  @behaviour Broadway.Producer

  @impl true
  def init(_opts) do
    working_backtests = Backtests.by_status(["working"])
    state = %State{working_backtests: working_backtests, last_ticks: %{}}
    Process.send_after(self(), :subscribe_all_backtests, 0)
    {:producer, state}
  end

  @impl true
  def handle_info(:subscribe_all_backtests, state) do
    Backtests.subscribe()
    {:noreply, [], state}
  end

  @impl true
  def handle_info({"backtest:*", _}, state) do
    working_backtests = Backtests.by_status(["working"])
    state = %{state | working_backtests: working_backtests}
    {:noreply, [], state}
  end

  @impl true
  def handle_demand(incoming_demand, state) do
    {ticks, state} = map_next_backtest(
      &Backtests.Services.NextTick.execute/2,
      incoming_demand,
      state
    )

    {:noreply, ticks, state}
  end

  defp map_next_backtest(fun, incoming_demand, state) do
    backtests = state.working_backtests
    map_next_backtest([], backtests, [], fun, incoming_demand, state)
  end

  defp map_next_backtest(result, [], [], _fun, _incoming_demand, state) do
    {result, state}
  end

  defp map_next_backtest(result, [], next_backtests, fun, incoming_demand, state) do
    backtests = next_backtests |> Enum.reverse()
    map_next_backtest(result, backtests, [], fun, incoming_demand, state)
  end

  defp map_next_backtest(result, [backtest | backtests], next_backtests, fun, incoming_demand, state) do
    cond do
      incoming_demand > 0 ->
        last_tick = Map.get(state.last_ticks, backtest.id)
        next_tick = fun.(backtest, last_tick)

        if next_tick == nil do
          {result, state}
        else
          result = result ++ [{next_tick, backtest.receiver}]
          next_backtests = [backtest | next_backtests]
          last_ticks = Map.put(state.last_ticks, backtest.id, next_tick)
          state = %{state | last_ticks: last_ticks}
          map_next_backtest(result, backtests, next_backtests, fun, incoming_demand - 1, state)
        end

      true ->
        {result, state}
    end
  end
end
