defmodule Rewind.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Rewind.Repo,
      RewindWeb.Telemetry,
      {Phoenix.PubSub, name: Rewind.PubSub},
      Rewind.Backtests.Supervisor,
      Rewind.Models.Supervisor,
      RewindWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Rewind.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:models, _start_type, _phase_args) do
    # TODO: Do something with the return value
    {:ok, _} = Rewind.Models.load()

    :ok
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RewindWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
