defmodule BookShop.Tracing.Server do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get_trace, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def handle_cast({:trace_start, %{trace_id: id} = trace}, state) do
    case Map.get(state, id) do
      nil ->
        trace = Map.put(trace, :time, System.system_time(:microsecond))
        broadcast_event({:trace_added, trace})
        {:noreply, Map.put(state, id, [trace])}

      _ ->
        {:noreply, state}
    end
  end

  def handle_cast({:trace_add, %{trace_id: id} = trace}, state) do
    case Map.get(state, id) do
      nil ->
        {:noreply, state}

      [last_trace | _] ->
        trace = last_trace |> Map.merge(trace) |> Map.put(:time, System.system_time(:microsecond))
        broadcast_event({:trace_added, trace})
        {:noreply, Map.update!(state, id, &[trace | &1])}
    end
  end

  def handle_cast({:trace_end, %{trace_id: id}}, state) do
    case Map.get(state, id) do
      nil ->
        {:noreply, state}

      trace ->
        trace = Map.put(trace, :end_time, System.monotonic_time())
        {:noreply, Map.replace(state, id, trace)}
    end
  end

  def broadcast_event(event) do
    :ok = Phoenix.PubSub.broadcast(BookShop.PubSub, "store:tracing", event)
  end
end
