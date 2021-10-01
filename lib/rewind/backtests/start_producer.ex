defmodule Rewind.Backtests.StartProducer do
  use GenStage
  alias Rewind.Backtests

  defmodule State do
    defstruct ~w[demand]a
  end

  @behaviour Broadway.Producer

  @impl true
  def init(_opts) do
    Process.send_after(self(), :subscribe_all_backtests, 0)
    state = %State{demand: 0}
    {:producer, state}
  end

  @impl true
  def handle_info(:subscribe_all_backtests, state) do
    Backtests.subscribe()
    {:noreply, [], state}
  end

  @impl true
  def handle_info({"backtest:*", _}, state) do
    enqueued_backtests = Backtests.enqueued(state.demand)
    {:noreply, enqueued_backtests, state}
  end

  @impl true
  def handle_demand(incoming_demand, state) do
    enqueued_backtests = Backtests.enqueued(incoming_demand)
    state = %{state | demand: incoming_demand}
    {:noreply, enqueued_backtests, state}
  end
end
