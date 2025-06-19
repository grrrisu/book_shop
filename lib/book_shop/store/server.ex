defmodule BookShop.Store.Server do
  use GenServer

  alias Phoenix.PubSub

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}, {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    PubSub.subscribe(BookShop.PubSub, "store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:event, event}, state) do
    dbg(event)
    {:noreply, state}
  end

  # Command handlers

  def handle_cast({:buy_book, customer, books}, state) do
    Enum.each(books, fn {book_id, amount} ->
      :ok = broadcast_event({:book_bought, customer, book_id, amount})
    end)

    {:noreply, state}
  end

  def broadcast_event(event) do
    :ok = PubSub.broadcast(BookShop.PubSub, "store:events", event)
  end
end
