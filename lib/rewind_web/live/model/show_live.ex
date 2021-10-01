defmodule RewindWeb.Model.ShowLive do
  use RewindWeb, :live_view
  alias Rewind.{Models, Backtests}

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
             |> assign(:backtest_changeset, Backtests.job_changeset_last_year(%{}))

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    Backtests.subscribe_by_model_id(id)

    socket = socket
             |> assign_model(id)
             |> assign_backtests()
             |> assign_pinned_backtests()

    {:noreply, socket}
  end

  def handle_event("create_backtest", %{"backtest" => params}, socket) do
    socket =
      with {:ok, backtest} <- Backtests.insert(socket.assigns.model, params) do
        socket
        |> assign(
          :backtest_changeset,
          Backtests.Backtest.changeset(backtest, %{})
        )
        |> assign_backtests()
      else
        {:error, changeset} ->
          IO.inspect changeset
          socket
          |> assign(:backtest_changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("pin", %{"id" => id}, socket) do
    socket =
      with {:ok, backtest} <- Backtests.get(id),
           {:ok, backtest} <- Backtests.pin(backtest) do
        socket
        |> assign(
          :backtest_changeset,
          Backtests.Backtest.changeset(backtest, %{})
        )
        |> assign_pinned_backtests()
      else
        {:error, changeset} ->
          socket
          |> assign(:backtest_changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("unpin", %{"id" => id}, socket) do
    socket =
      with {:ok, backtest} <- Backtests.get(id),
           {:ok, backtest} <- Backtests.unpin(backtest) do
        socket
        |> assign(
          :backtest_changeset,
          Backtests.Backtest.changeset(backtest, %{})
        )
        |> assign_pinned_backtests()
      else
        {:error, changeset} ->
          socket
          |> assign(:backtest_changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("pause", %{"id" => _id}, socket) do
    IO.puts "------------ PAUSE"

    # socket =
    #   with {:ok, backtest} <- Backtests.get(id),
    #        {:ok, _backtest} <- Backtests.delete(backtest) do
    #     socket
    #     |> assign_pinned_backtests()
    #     |> assign_backtests()
    #   else
    #     {:error, _changeset} -> socket
    #   end

    {:noreply, socket}
  end

  @impl true
  def handle_event("resume", %{"id" => _id}, socket) do
    IO.puts "------------ RESUME"

    # socket =
    #   with {:ok, backtest} <- Backtests.get(id),
    #        {:ok, _backtest} <- Backtests.delete(backtest) do
    #     socket
    #     |> assign_pinned_backtests()
    #     |> assign_backtests()
    #   else
    #     {:error, _changeset} -> socket
    #   end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      with {:ok, backtest} <- Backtests.get(id),
           {:ok, _backtest} <- Backtests.delete(backtest) do
        socket
        |> assign_pinned_backtests()
        |> assign_backtests()
      else
        {:error, _changeset} -> socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({"backtest:model:" <> _, _}, socket) do
    socket = socket
             |> assign_pinned_backtests()
             |> assign_backtests()

    {:noreply, socket}
  end

  defp assign_model(socket, id) do
    {:ok, model} = Models.find(id)

    socket
    |> assign(:model, model)
  end

  defp assign_backtests(socket) do
    socket
    |> assign(:backtests, Backtests.by_model(socket.assigns.model.id))
  end

  defp assign_pinned_backtests(socket) do
    socket
    |> assign(:pinned_backtests, Backtests.pinned_by_model(socket.assigns.model.id))
  end

  defp tick_types do
    Rewind.BacktestTickType.__valid_values__()
    |> Enum.filter(fn
      t when is_atom(t) -> true
      _ -> false
    end)
    # TODO: Support all tick types but start with min_1
    |> Enum.filter(fn
      :min_1 -> true
      _ -> false
    end)
  end

  defp format_product_keys(quotes) do
    case quotes do
      [] -> "-"
      keys -> keys |> Enum.map(fn {v, p} -> "#{v}:#{p}" end) |> Enum.join(", ")
    end
  end

  defp format_candles(candles, assigns \\ %{}) do
    case candles do
      [] ->
        "-"

      candles ->
        ~H"""
        <%= for {p, period_candles} <- candles_by_period(candles) do %>
          <dt class="font-bold italic"><%= p %>:</dt>
          <dd>
            <ul>
              <%= for {v, venue_candles} <- period_candles_by_venue(period_candles) do %>
                <li>
                  <strong><%= v %>:</strong>
                  <%= venue_candles |> Enum.map(& &1.symbol) |> Enum.join(", ") %>
                </li>
              <% end %>
            </ul>
          </dd>
        <% end %>
        """
    end
  end

  defp format_indicators(indicators) do
    case indicators do
      [] -> "-"
      indicators -> indicators |> inspect
    end
  end

  defp candles_by_period(candles) do
    Enum.group_by(candles, & &1.period)
  end

  defp period_candles_by_venue(period_candles) do
    Enum.group_by(period_candles, & &1.venue)
  end
end
