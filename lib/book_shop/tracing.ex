defmodule BookShop.Tracing do
  alias BookShop.Tracing.Server

  def get_trace(id) do
    GenServer.call(Server, {:get_trace, id})
  end

  def trace_start(order_id, context, description) do
    trace = %{trace_id: order_id, context: context, description: description}
    GenServer.cast(Server, {:trace_start, trace})
  end

  def trace(order_id, context, description) do
    trace = %{trace_id: order_id, context: context, description: description}
    GenServer.cast(Server, {:trace_add, trace})
  end

  def trace(order_id, description) do
    trace = %{trace_id: order_id, description: description}
    GenServer.cast(Server, {:trace_add, trace})
  end

  def trace_end(trace) do
    GenServer.cast(Server, {:trace_end, trace})
  end
end
