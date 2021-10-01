defmodule Rewind.Candles do
  alias Rewind.Candles.Queries

  def find_by_time_and_period_and_venue_products(time, period, venue_products) do
    query = Queries.FindByTimeAndPeriodAndVenueProducts.query(time, period, venue_products)
    History.Repo.all(query)
  end
end
