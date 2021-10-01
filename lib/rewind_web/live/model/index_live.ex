defmodule RewindWeb.Model.IndexLive do
  use RewindWeb, :live_view
  alias Rewind.Models

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
             |> assign_models()

    {:ok, socket}
  end

  defp assign_models(socket) do
    models = Models.search(nil)

    socket
    |> assign(:models, models)
  end

  defp format_input(input, assigns \\ %{}) do
    items = input
            |> Map.from_struct()
            |> Map.keys()
            |> Enum.map(
              fn k ->
                value = Map.get(input, k)

                ~E"""
                <div>
                  <dt class="font-bold inline"><%= k %>:</dt>
                  <dd class="inline"><%= format(value) %></dd>
                </div>
                """
              end
            )

    ~H"""
    <dl>
      <%= items %>
    </dl>
    """
  end

  defp format_data(data, assigns \\ %{}) do
    items = data
            |> Enum.map(
              fn {key, value} ->
                ~E"""
                <div>
                  <dt class="font-bold inline"><%= key %>:</dt>
                  <dd class="inline"><%= format(value) %></dd>
                </div>
                """
              end
            )

    ~H"""
    <dl>
      <%= items %>
    </dl>
    """
  end

  defp format(value) when is_bitstring(value), do: value
  defp format(value), do: value |> inspect
end
