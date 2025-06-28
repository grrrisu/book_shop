defmodule BookShop.Helper do
  alias Phoenix.PubSub

  import BookShop.Tracing

  require Logger

  def subscribe() do
    PubSub.subscribe(BookShop.PubSub, "store:events")
  end

  def broadcast_event({event_name, context, %{order_id: order_id} = payload}) do
    trace(order_id, context, Atom.to_string(event_name))
    :ok = PubSub.broadcast(BookShop.PubSub, "store:events", {event_name, payload})
  end

  # {:newsletter_sent, binary(), term()}
  # {:supplier_shipped, %{books: term(), price: integer(), quantity: term()}}
  # {:trace_added, trace}
  def broadcast_event(event) do
    Logger.info("Broadcasting event without order_id and context: #{inspect(event)}")
    :ok = PubSub.broadcast(BookShop.PubSub, "store:events", event)
  end

  def simulate_process() do
    # Simulate a process that takes some time to complete
    Application.get_env(:book_shop, :process_time) |> Process.sleep()
  end
end
