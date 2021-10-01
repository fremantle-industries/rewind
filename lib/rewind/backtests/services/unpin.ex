defmodule Rewind.Backtests.Services.Unpin do
  alias Rewind.{Backtests.Backtest, Repo}

  @spec execute(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def execute(backtest) do
    backtest
    |> Backtest.changeset(%{"pinned" => false})
    |> Repo.update()
  end
end
