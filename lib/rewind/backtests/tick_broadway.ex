defmodule Rewind.Backtests.TickBroadway do
  use Broadway
  require Logger
  alias Broadway.Message
  alias Rewind.Backtests

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(_) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Backtests.TickProducer, []},
        transformer: {__MODULE__, :transform, []}
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  @impl true
  def handle_message(_, message, _) do
    {tick, receiver} = message.data

    receiver
    |> handle_tick(tick)
    |> process_orders()

    message
  end

  def ack(:ack_id, _successful, failed) do
    # successful
    # |> Enum.each(fn m ->
    #   # IO.puts "-------- successful tick"
    #   # IO.inspect m

    #   # case Backtests.update(m.data, %{status: "working"}) do
    #   #   {:ok, b} ->
    #   #     Backtests.broadcast(b)

    #   #     "started backtest id=~w"
    #   #     |> :io_lib.format([b.id])
    #   #     |> Logger.info()
    #   # end
    # end)

    failed
    |> Enum.each(fn m ->
      "could not process tick=~w"
      |> :io_lib.format([m.data |> inspect])
      |> Logger.error()
    end)

    :ok
  end

  defp handle_tick(receiver, tick) when is_atom(receiver) do
    apply(receiver, :handle_tick, [tick])
  end

  defp handle_tick(receiver, tick) when is_bitstring(receiver) do
    receiver
    |> String.to_atom()
    |> handle_tick(tick)
  end

  defp process_orders({:ok, orders}) do
    "process tick orders=~w"
    |> :io_lib.format([
      orders
    ])
    |> Logger.debug()
  end
end
