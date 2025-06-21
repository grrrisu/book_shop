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

  def handle_info({:order_placed, order}, socket) do
    {:noreply, socket |> stream_insert(:orders, order, at: 0)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} title="Book Store">
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Order Overview</h2>
        <.table id="orders" rows={@streams.orders}>
          <:col :let={{_, order}} label="id">{order.order_id}</:col>
          <:col :let={{_, order}} label="Customer">{order.customer.name}</:col>
          <:col :let={{_, order}} label="Books">
            {Enum.map(order.books, & &1.name) |> Enum.join(", ")}
          </:col>
          <:col :let={{_, order}} label="Total Price">{Map.get(order, :price)}</:col>
        </.table>
      </div>
    </Layouts.app>
    """
  end
end
