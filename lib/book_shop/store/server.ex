defmodule BookShop.Store.Server do
  use GenServer

  alias BookShop.Store.Data

  import BookShop.Helper
  import BookShop.Tracing

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
    order_id = System.unique_integer([:positive])

    broadcast_event(
      {:incoming_order, "Store",
       %{order_id: order_id, books: book_data(books), customer: customer}}
    )

    trace_start(order_id, "Store", "place_order")
    validate(books, customer)

    broadcast_event(
      {:order_placed, "Store", %{order_id: order_id, books: book_data(books), customer: customer}}
    )

    {:noreply, state}
  end

  defp validate(_books, customer) do
    Logger.info("order validated for customer #{customer.name}")
    simulate_process()
  end

  defp book_data([%{isbn: _} | _] = books), do: books

  defp book_data([isbn | _] = books) when is_binary(isbn) do
    Enum.map(books, fn isbn -> Data.data() |> Enum.find(&(&1.isbn == isbn)) end)
  end
end
