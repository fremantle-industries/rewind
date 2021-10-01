defmodule Rewind.Backtests do
  alias Rewind.Backtests.{Backtest, Queries, Services}
  alias Rewind.Repo

  @spec get(non_neg_integer) :: {:ok, struct} | {:error, :not_found}
  def get(id) do
    case Repo.get(Backtest, id) do
      nil -> {:error, :not_found}
      b -> {:ok, b}
    end
  end

  @spec enqueued(non_neg_integer) :: [struct]
  def enqueued(limit) do
    limit
    |> Queries.Enqueued.query()
    |> Repo.all()
  end

  @spec by_model(String.t()) :: [struct]
  def by_model(model_id) do
    model_id
    |> Queries.ByModel.query()
    |> Repo.all()
  end

  @spec pinned_by_model(String.t()) :: [struct]
  def pinned_by_model(model_id) do
    model_id
    |> Queries.PinnedByModel.query()
    |> Repo.all()
  end

  @spec by_status([String.t()]) :: [struct]
  def by_status(status) do
    status
    |> Queries.ByStatus.query()
    |> Repo.all()
  end

  @spec job_changeset_last_year(map) :: Ecto.Changeset.t()
  def job_changeset_last_year(params \\ %{}) do
    now = DateTime.utc_now()
    {:ok, date_now} = Date.new(now.year, now.month, now.day)
    {:ok, time_now} = Time.new(now.hour, 0, 0)
    {:ok, current_hour} = DateTime.new(date_now, time_now)
    from = current_hour |> Timex.shift(days: -365)
    to = current_hour |> Timex.shift(hours: 1)

    merged_params =
      Map.merge(
        params,
        %{
          from_date: from,
          from_time: from,
          to_date: to,
          to_time: to
        }
      )

    Backtest.changeset(%Backtest{}, merged_params)
  end

  @spec insert(struct, map) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def insert(model, params) do
    Services.Insert.execute(model, params)
  end

  @spec update(struct, map) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def update(backtest, params) do
    Services.Update.execute(backtest, params)
  end

  @spec pin(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def pin(backtest) do
    Services.Pin.execute(backtest)
  end

  @spec unpin(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def unpin(backtest) do
    Services.Unpin.execute(backtest)
  end

  @spec delete(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  def delete(backtest) do
    Services.Delete.execute(backtest)
  end

  @spec broadcast(struct) :: no_return
  def broadcast(backtest, pub_sub \\ Rewind.PubSub) do
    Services.Broadcast.execute(backtest, pub_sub)
  end

  @spec subscribe :: :ok | {:error, term}
  def subscribe(pub_sub \\ Rewind.PubSub) do
    topic = "backtest:*"
    Phoenix.PubSub.subscribe(pub_sub, topic)
  end

  @spec subscribe_by_id(non_neg_integer) :: :ok | {:error, term}
  def subscribe_by_id(id, pub_sub \\ Rewind.PubSub) do
    topic = "backtest:#{id}"
    Phoenix.PubSub.subscribe(pub_sub, topic)
  end

  @spec subscribe_by_model_id(String.t()) :: :ok | {:error, term}
  def subscribe_by_model_id(model_id, pub_sub \\ Rewind.PubSub) do
    topic = "backtest:model:#{model_id}"
    Phoenix.PubSub.subscribe(pub_sub, topic)
  end
end
