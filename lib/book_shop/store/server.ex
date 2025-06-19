defmodule BookShop.Store.Server do
  use GenServer

  alias Phoenix.PubSub

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok,
     [
       "Elixir in Action",
       "Alice in Wonderland",
       "Dune",
       "The Hitchhiker's Guide to the Galaxy",
       "Neuromancer",
       "Gödel, Escher, Bach: An Eternal Golden Braid",
       "1984",
       "Animal Farm",
       "Treasure Island",
       "Around the World in Eighty Days",
       "A song of Ice and Fire",
       "The lord of the rings",
       "Batman and Robin",
       "Maus",
       "How to rule the world!",
       "Dracula"
     ], {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    PubSub.subscribe(BookShop.PubSub, "store:events")
    Logger.info("BookShop.Store.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info(event, state) do
    dbg(event)
    {:noreply, state}
  end

  # Command handlers

  def handle_call(:list_books, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:place_order, books, customer}, state) do
    Logger.info("order validated for customer #{customer.name}}")
    :ok = broadcast_event({:order_placed, books, customer})

    {:noreply, state}
  end

  def broadcast_event(event) do
    dbg(event)
    :ok = PubSub.broadcast(BookShop.PubSub, "store:events", event)
  end
end
