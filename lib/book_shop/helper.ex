defmodule BookShop.Helper do
  alias Phoenix.PubSub

  def subscribe() do
    PubSub.subscribe(BookShop.PubSub, "store:events")
  end

  def broadcast_event(event) do
    dbg(event)
    :ok = PubSub.broadcast(BookShop.PubSub, "store:events", event)
  end
end
