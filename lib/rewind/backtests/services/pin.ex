defmodule Rewind.Backtests.Services.Pin do
  alias Rewind.{Backtests.Backtest, Repo}

  @spec execute(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def execute(backtest) do
    backtest
    |> Backtest.changeset(%{"pinned" => true})
    |> Repo.update()
  end
end
