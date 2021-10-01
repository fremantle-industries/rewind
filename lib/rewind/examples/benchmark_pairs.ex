defmodule Rewind.Examples.BenchmarkPairs do
  alias Rewind.Models
  alias Rewind.Examples.BenchmarkPairs

  def build(id, input_config) do
    input = struct(BenchmarkPairs.Input, input_config)
    data = build_data(input)
    model = %Models.Model{
      id: id,
      input: input,
      receiver: BenchmarkPairs.Receiver,
      quotes: [],
      trades: [],
      candles: data,
      indicators: data
    }

    {:ok, model}
  end

  defp build_data(input) do
    periods = build_periods(input)
    pairs_with_benchmark = input.pairs ++ [input.benchmark]

    periods
    |> Enum.reduce(
      %{},
      fn p, acc ->
        Map.put(acc, p, pairs_with_benchmark)
      end
    )
  end

  defp build_periods(input) do
    {fast_period, _} = input.distance_from_mean_fast
    {medium_period, _} = input.distance_from_mean_medium
    {slow_period, _} = input.distance_from_mean_slow
    {xslow_period, _} = input.distance_from_mean_xslow

    [fast_period, medium_period, slow_period, xslow_period]
    |> Enum.uniq()
  end
end
