defmodule BookShopWeb.Statistics do
  use BookShopWeb, :live_view

  import BookShopWeb.SharedComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      BookShop.Helper.subscribe()
    end

    {:ok,
     socket
     |> assign(:page_title, "Statistics")
     |> assign(incoming: 0, supplier: 0, shipped: 0)
     |> assign(invoice: 0, paid: 0, customers: 0)}
  end

  def handle_info({:order_placed, _order}, socket) do
    {:noreply, socket |> update(:incoming, &(&1 + 1))}
  end

  def handle_info({:supplier_shipped, _order}, socket) do
    {:noreply, socket |> update(:supplier, &(&1 + 1)) |> update(:paid, &(&1 + 1))}
  end

  def handle_info({:books_shipped, _order}, socket) do
    {:noreply, socket |> update(:shipped, &(&1 + 1))}
  end

  def handle_info({:invoice_created, _order}, socket) do
    {:noreply, socket |> update(:invoice, &(&1 + 1))}
  end

  def handle_info({:payment_received, _order}, socket) do
    {:noreply, socket |> update(:customers, &(&1 + 1))}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Statistics</h2>
        <h3 class="font-bold mb-2">Logistics</h3>
        <div class="stats shadow mb-4">
          <.stat number={@incoming} title="Incoming Orders" icon="hero-inbox-arrow-down" />
          <.stat number={@supplier} title="Supplier Deliveries" icon="hero-archive-box" />
          <.stat number={@shipped} title="Books Shipped" icon="hero-truck" />
        </div>
        <h3 class="font-bold mb-2">Accounting</h3>
        <div class="stats shadow mb-4">
          <.stat number={@invoice} title="Invoices created" icon="hero-envelope" />
          <.stat number={@paid} title="Outgoing" icon="hero-arrow-up-on-square-stack" />
          <.stat number={@customers} title="Incoming" icon="hero-arrow-down-on-square-stack" />
        </div>
      </div>
    </Layouts.app>
    """
  end
end
