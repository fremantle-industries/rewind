defmodule Rewind.Candles.Queries.FindByTimeAndPeriodAndVenueProducts do
  import Ecto.Query
  alias History.Candles.Candle

  def query(time, period, venue_products) do
    base_query = from(c in Candle, where: c.time == ^time and c.period == ^period)
    from(c in base_query, where: ^filter_venue_products(venue_products))
  end

  defp filter_venue_products(venue_products) do
    venue_products
    |> Enum.reduce(
      false,
      fn {v, p}, query ->
        dynamic([c], c.venue == ^v and c.product == ^p or ^query)
      end
    )
  end
end
