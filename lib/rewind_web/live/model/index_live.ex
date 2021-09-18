defmodule RewindWeb.Model.IndexLive do
  use RewindWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
             |> assign_models()

    {:ok, socket}
  end

  defp assign_models(socket) do
    socket
    |> assign(:models, [])
  end
end
