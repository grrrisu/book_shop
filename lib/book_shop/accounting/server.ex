defmodule BookShop.Accounting.Server do
  use GenServer

  import BookShop.Helper

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
    Logger.info("BookShop.Accounting.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:order_placed, order}, %{open: open} = state) do
    Logger.info("Accounting received order #{inspect(order.books)}")

    invoice = %{
      order_id: order.order_id,
      price: total_price(order.books),
      customer: order.customer
    }

    broadcast_event({:invoice_created, invoice})
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

  def handle_call({:incoming_payment, order_id, price}, _from, state) do
    %{price: ^price, customer: customer} = Map.get(state.open, order_id)
    broadcast_event({:payment_received, customer})

    {:reply, :ok,
     %{state | balance: state.balance + price, open: Map.delete(state.open, order_id)}}
  end
end
