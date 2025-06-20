defmodule BookShop.Store.Server do
  use GenServer

  alias BookShop.Store.Data

  import BookShop.Helper

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, Data.data(), {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Logger.info("BookShop.Store.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info(_event, state) do
    {:noreply, state}
  end

  # Command handlers

  def handle_call(:list_books, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:place_order, books, customer}, state) do
    Logger.info("order validated for customer #{customer.name}")
    order_id = System.unique_integer([:positive])

    :ok =
      broadcast_event({:order_placed, %{order_id: order_id, books: books, customer: customer}})

    {:noreply, state}
  end
end
