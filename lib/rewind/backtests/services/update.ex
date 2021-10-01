defmodule Rewind.Backtests.Services.Update do
  alias Rewind.Backtests.{Backtest, Services}
  alias Rewind.Repo

  @spec execute(struct, map) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def execute(backtest, params) do
    changeset = Backtest.changeset(backtest, params)

    case Repo.update(changeset) do
      {:ok, backtest} = result ->
        Services.Broadcast.execute(backtest)
        result

      result ->
        result
    end
  end
end
