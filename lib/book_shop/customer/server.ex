defmodule BookShop.Customer.Server do
  use GenServer

  alias BookShop.Store
  alias BookShop.Accounting

  import BookShop.Helper

  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    {:ok, %{name: name, billing_address: "my company", shipping_address: "my home"},
     {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Logger.info("BookShop.Customer.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:books_shipped, %{books: books, customer: state} = parcel}, state) do
    Logger.info("#{state.name} received #{inspect(books)}")
    Accounting.pay_invoice(parcel.order_id, parcel.price)
    {:noreply, state}
  end

  def handle_info({:newsletter_sent, _marketing_text, state}, state) do
    Logger.info("#{state.name} received newsletter, must buy more books!")
    handle_buy_books(state)
    {:noreply, state}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  # Command handlers

  def handle_cast(:buy_books, state) do
    handle_buy_books(state)
    {:noreply, state}
  end

  defp handle_buy_books(customer) do
    Store.list_books()
    |> Enum.shuffle()
    |> Enum.take(2)
    |> Store.place_order(customer)
  end
end
