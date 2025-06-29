defmodule BookShop.Accounting.Server do
  use GenServer

  import BookShop.Helper
  import BookShop.Tracing

  require Logger

  @tax 1.2

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{open: %{}, balance: 0}, {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Logger.warning("BookShop.Accounting.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:order_placed, order}, %{open: open} = state) do
    Logger.info("Accounting received order #{inspect(order.books)}")
    trace(order.order_id, "Accounting", "handle_order_placed")

    invoice = %{
      order_id: order.order_id,
      price: total_price(order.books),
      customer: order.customer
    }

    simulate_process()

    broadcast_event({:invoice_created, "Accounting", invoice})
    {:noreply, %{state | open: Map.put_new(open, order.order_id, invoice)}}
  end

  def handle_info({:supplier_shipped, %{price: price}}, state) do
    {:noreply, %{state | balance: state.balance - price}}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  defp total_price(books) do
    (Enum.reduce(books, 0, &(&2 + &1.price)) * @tax) |> round()
  end

  # Command handlers

  def handle_call(:get_balance, _from, state) do
    {:reply, state.balance, state}
  end

  def handle_call({:incoming_payment, order_id, price}, _from, state) do
    case Map.get(state.open, order_id) do
      nil ->
        Logger.warning("Accounting received payment for unknown order #{order_id}")
        {:reply, {:error, :unknown_order}, state}

      %{price: expected_price, customer: customer} when expected_price == price ->
        broadcast_event(
          {:payment_received, "Accounting", %{customer: customer, order_id: order_id}}
        )

        {:reply, :ok,
         %{state | balance: state.balance + price, open: Map.delete(state.open, order_id)}}
    end
  end
end
