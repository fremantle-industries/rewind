defmodule Rewind.Backtests.Supervisor do
  use Supervisor
  alias Rewind.Backtests

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      Backtests.StartBroadway,
      Backtests.TickBroadway
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
