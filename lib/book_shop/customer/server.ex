defmodule BookShop.Customer.Server do
  use GenServer

  alias BookShop.Store

  import BookShop.Helper

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{name: "Jane", billing_address: "my company", shipping_address: "my home"},
     {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Logger.info("BookShop.Store.Customer started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:books_shipped, %{books: books, customer: state}}, state) do
    Logger.info("#{state.name} received #{inspect(books)}")
    # pay invoice
    {:noreply, state}
  end

  def handle_info(_event, state) do
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
end
