defmodule BookShop.Customer.Server do
  use GenServer

  alias Phoenix.PubSub

  alias BookShop.Store

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{name: "Jane", billing_address: "my company", shipping_address: "my home"},
     {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    PubSub.subscribe(BookShop.PubSub, "store:events")
    Logger.info("BookShop.Store.Customer started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:order_placed, books, state}, state) do
    Logger.info("#{state.name} received #{inspect(books)}")
    {:noreply, state}
  end

  def handle_info(event, state) do
    raise "Unexpected event: #{inspect(event)}"
    {:noreply, state}
  end

  # Command handlers

  def handle_cast(:buy_books, state) do
    Store.list_books()
    |> Enum.shuffle()
    |> Enum.take(2)
    |> Store.place_order(state)

    {:noreply, state}
  end

  def broadcast_event(event) do
    dbg(event)
    :ok = PubSub.broadcast(BookShop.PubSub, "store:events", event)
  end
end
