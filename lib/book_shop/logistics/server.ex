defmodule BookShop.Logistics.Server do
  use GenServer

  alias BookShop.Supplier
  alias BookShop.Store

  import BookShop.Helper
  import BookShop.Tracing

  require Logger

  @starting_inventory 5

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{inventory: %{}, ready: %{}}, {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    inventory =
      Store.list_books() |> Enum.reduce(%{}, &Map.put_new(&2, &1.isbn, @starting_inventory))

    subscribe()
    Logger.info("BookShop.Logistics.Server started and subscribed to store:events")
    {:noreply, %{state | inventory: inventory}}
  end

  # Event handler for incoming events

  def handle_info({:order_placed, %{order_id: order_id, books: books} = event}, state) do
    trace(order_id, "Logistics", "handle_order_placed")
    Logger.info("Logistics processing order #{order_id} for books: #{inspect(books)}")
    {:noreply, handle_order_placed(event, state)}
  end

  def handle_info(
        {:invoice_created, %{order_id: order_id} = invoice} = event,
        %{ready: ready} = state
      ) do
    ready =
      case Map.get(state.ready, order_id) do
        nil ->
          Logger.info(
            "Logistics received invoice for order #{order_id} but order's not yet ready"
          )

          trace(order_id, "Logistics", "waiting_for_books")

          Process.send_after(
            self(),
            event,
            Application.get_env(:book_shop, :process_time) || 1_000
          )

          ready

        books ->
          :ok =
            broadcast_event({:books_shipped, "Logistics", Map.merge(invoice, %{books: books})})

          Map.delete(ready, order_id)
      end

    {:noreply, %{state | ready: ready}}
  end

  def handle_info({:supplier_shipped, %{books: books, quantity: quantity}}, state) do
    Logger.info("Logistics received shipment of #{quantity} copies of #{inspect(books)}")

    inventory =
      Enum.reduce(books, state.inventory, fn book, inv ->
        Map.update!(inv, book, &(&1 + quantity))
      end)

    {:noreply, %{state | inventory: inventory}}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  defp handle_order_placed(%{order_id: order_id, books: books} = event, state) do
    with [] <- check_inventory(books, state.inventory),
         inventory <- adjust_inventory(books, state.inventory),
         ready <- Map.put_new(state.ready, order_id, books) do
      %{state | inventory: inventory, ready: ready}
    else
      missing ->
        missing |> Supplier.order(10)
        trace(order_id, "Logistics", "order_missing_books")

        Process.send_after(
          self(),
          {:order_placed, payload},
          Application.get_env(:book_shop, :process_time) || 1_000
        )

        state
    end
  end

  defp check_inventory(books, inventory) do
    simulate_process()

    Enum.reduce(books, [], fn book, missing ->
      case Map.get(inventory, book.isbn) > 0 do
        true -> missing
        false -> [book.isbn | missing]
      end
    end)
  end

  defp adjust_inventory(books, inventory) do
    simulate_process()

    Enum.reduce(books, inventory, fn book, inventory ->
      Map.update!(inventory, book.isbn, &(&1 - 1))
    end)
  end

  # Command handlers

  def handle_call(:get_stats, _from, state) do
    {:reply,
     %{
       inventory: Enum.reduce(state.inventory, 0, fn {_, quantity}, sum -> sum + quantity end),
       ready: Enum.count(state.ready)
     }, state}
  end
end
