defmodule Rewind.Backtests.StartBroadway do
  use Broadway
  require Logger
  alias Broadway.Message
  alias Rewind.Backtests

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(_) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Backtests.StartProducer, []},
        transformer: {__MODULE__, :transform, []}
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    message
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, successful, failed) do
    successful
    |> Enum.each(fn m ->
      case Backtests.update(m.data, %{status: "working"}) do
        {:ok, b} ->
          Backtests.broadcast(b)

          "started backtest id=~w"
          |> :io_lib.format([b.id])
          |> Logger.info()
      end
    end)

    failed
    |> Enum.each(fn m ->
      "could not start backtest id=~w"
      |> :io_lib.format([m.data.id])
      |> Logger.error()
    end)

    :ok
  end
end
