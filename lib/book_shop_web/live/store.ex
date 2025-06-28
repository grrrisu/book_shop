defmodule BookShopWeb.Store do
  use BookShopWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      BookShop.Helper.subscribe()
    end

    {:ok,
     socket
     |> stream_configure(:orders, dom_id: &"order-#{&1.order_id}")
     |> stream(:orders, [], at: 0, limit: -5)}
  end

  def handle_info({:incoming_order, order}, socket) do
    order = Map.put_new(order, :event, :incoming_order)
    {:noreply, socket |> stream_insert(:orders, order, at: 0)}
  end

  def handle_info({:order_placed, order}, socket) do
    order = Map.put_new(order, :event, :order_placed)
    {:noreply, socket |> stream_insert(:orders, order, at: 0)}
  end

  def handle_info({:invoice_created, order}, socket) do
    order = Map.put_new(order, :event, :invoice_created)
    {:noreply, socket |> stream_insert(:orders, order, at: 0)}
  end

  def handle_info({:books_shipped, order}, socket) do
    order = Map.put_new(order, :event, :books_shipped)
    {:noreply, socket |> stream_insert(:orders, order, at: 0)}
  end

  def handle_info({:payment_received, order}, socket) do
    order = Map.put_new(order, :event, :payment_received)
    {:noreply, socket |> stream_insert(:orders, order, at: 0)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Order Overview</h2>
        <.table id="orders" rows={@streams.orders}>
          <:col :let={{_, order}} label="id">{order.order_id}</:col>
          <:col :let={{_, order}} label="Event">{order.event}</:col>
          <:col :let={{_, order}} label="Customer">{order.customer.name}</:col>
          <:col :let={{_, order}} label="Books">{books_list(order)}</:col>
          <:col :let={{_, order}} label="Total Price">{Map.get(order, :price)}</:col>
          <:action :let={{_, order}}>
            <.link navigate={~p"/tracing/#{order.order_id}"} class="btn btn-secondary" target="_blank">
              Trace
            </.link>
          </:action>
        </.table>
      </div>
    </Layouts.app>
    """
  end

  @spec books_list(any()) :: binary()
  def books_list(%{books: books}) do
    Enum.map(books, & &1.name)
    |> Enum.join(", ")
  end

  def books_list(_order), do: ""
end
