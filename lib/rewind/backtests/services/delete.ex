defmodule Rewind.Backtests.Services.Delete do
  alias Rewind.Repo

  @spec execute(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def execute(backtest) do
    backtest
    |> Repo.delete()
  end
end
