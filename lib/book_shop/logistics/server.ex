defmodule BookShop.Logistics.Server do
  use GenServer

  alias BookShop.Store

  import BookShop.Helper

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{inventory: []}, {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    inventory = Store.list_books() |> Enum.reduce(%{}, &Map.put_new(&2, &1, 5))
    subscribe()
    Logger.info("BookShop.Logistics.Server started and subscribed to store:events")
    {:noreply, %{state | inventory: inventory}}
  end

  # Event handler for incoming events

  def handle_info({:order_placed, books, customer}, %{inventory: inventory} = state) do
    Logger.info("Logistics received order #{inspect(books)}")

    inventory =
      case check_inventory(books, inventory) do
        [] ->
          Enum.reduce(books, inventory, fn book, inventory ->
            Map.update!(inventory, book, &(&1 - 1))
          end)

          :ok = broadcast_event({:books_shipped, books, customer})

        _missing ->
          # order new missing
          # replace order with delay
          inventory
      end

    # ship books
    {:noreply, %{state | inventory: inventory}}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  defp check_inventory(books, inventory) do
    Enum.reduce(books, [], fn book, missing ->
      case Map.get(inventory, book) > 0 do
        true -> missing
        false -> [book | missing]
      end
    end)
  end

  # Command handlers
end
