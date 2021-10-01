defmodule Rewind.Backtests.Backtest do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @type id :: integer

  defmodule Product do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, only: [:venue, :symbol]}
    @primary_key false
    embedded_schema do
      field(:venue, :string)
      field(:symbol, :string)
    end

    @doc false
    def changeset(product, attrs) do
      product
      |> cast(attrs, [:venue, :symbol])
      |> validate_required([:venue, :symbol])
    end
  end

  defmodule Candle do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, only: [:venue, :symbol, :period]}
    @primary_key false
    embedded_schema do
      field(:venue, :string)
      field(:symbol, :string)
      field(:period, :string)
    end

    @doc false
    def changeset(candle, attrs) do
      candle
      |> cast(attrs, [:venue, :symbol, :period])
      |> validate_required([:venue, :symbol, :period])
    end
  end

  defmodule Indicator do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, only: [:name, :venue, :symbol, :period]}
    @primary_key false
    embedded_schema do
      field(:name, :string)
      field(:venue, :string)
      field(:symbol, :string)
      field(:period, :string)
    end

    @doc false
    def changeset(indicator, attrs) do
      indicator
      |> cast(attrs, [:venue, :symbol, :period])
      |> validate_required([:venue, :symbol, :period])
    end
  end

  @timestamps_opts [type: :utc_datetime_usec]
  schema "backtests" do
    field(:model_id, :string)
    field(:from_date, :date)
    field(:from_time, :time)
    field(:to_date, :date)
    field(:to_time, :time)
    embeds_many(:quotes, Product)
    embeds_many(:trades, Product)
    embeds_many(:candles, Candle)
    embeds_many(:indicators, Indicator)
    field(:tick, Rewind.BacktestTickType)
    field(:status, Rewind.BacktestStatusType)
    field(:receiver, :string)
    field(:pinned, :boolean)

    timestamps()
  end

  @doc false
  def changeset(backtest, attrs) do
    backtest
    |> cast(attrs, [
      :model_id,
      :from_date,
      :from_time,
      :to_date,
      :to_time,
      :tick,
      :status,
      :receiver,
      :pinned
    ])
    |> cast_embed(:quotes)
    |> cast_embed(:trades)
    |> cast_embed(:candles)
    |> cast_embed(:indicators)
    |> validate_required([
      :model_id,
      :from_date,
      :from_time,
      :to_date,
      :to_time,
      :tick,
      :status,
      :receiver,
      :pinned
    ])
  end

  def from(backtest) do
    DateTime.new(backtest.from_date, backtest.from_time)
  end

  def to(backtest) do
    DateTime.new(backtest.to_date, backtest.to_time)
  end

  def from!(backtest) do
    DateTime.new!(backtest.from_date, backtest.from_time)
  end

  def to!(backtest) do
    DateTime.new!(backtest.to_date, backtest.to_time)
  end
end
