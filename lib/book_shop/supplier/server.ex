defmodule BookShop.Supplier.Server do
  use GenServer

  import BookShop.Helper

  require Logger

  alias BookShop.Store.Data

  @discount 0.5

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, Data.data(), {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Logger.warning("BookShop.Supplier.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info(_event, state) do
    {:noreply, state}
  end

  # Command handlers

  def handle_cast({:order, books, quantity}, state) do
    broadcast_event(
      {:supplier_shipped,
       %{books: books, quantity: quantity, price: total_price(books, quantity, state)}}
    )

    {:noreply, state}
  end

  defp total_price(books, quantity, state) do
    books
    |> Enum.map(&(Enum.find(state, fn book -> &1 == book.isbn end) |> Map.get(:price)))
    |> Enum.sum()
    |> Kernel.*(quantity)
    |> Kernel.*(@discount)
    |> round()
  end
end
