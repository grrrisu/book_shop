defmodule BookShopWeb.Statistics do
  use BookShopWeb, :live_view

  import BookShopWeb.SharedComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      BookShop.Helper.subscribe()
    end

    {:ok,
     socket
     |> assign(incoming: 0, ready: 0, shipped: 0)
     |> assign(balance: 0, open: 0, paid: 0)}
  end

  def handle_info({:order_placed, _order}, socket) do
    {:noreply, socket |> update(:incoming, &(&1 + 1))}
  end

  def handle_info({:supplier_shipped, _order}, socket) do
    {:noreply, socket |> assign(:balance, balance())}
  end

  def handle_info({:books_shipped, _order}, socket) do
    {:noreply, socket |> update(:shipped, &(&1 + 1)) |> update(:ready, &(&1 - 1))}
  end

  def handle_info({:_xx, _order}, socket) do
    {:noreply, socket |> update(:incoming, &(&1 + 1))}
  end

  def handle_info({:invoice_created, _order}, socket) do
    {:noreply,
     socket
     |> update(:open, &(&1 + 1))
     |> update(:ready, &(&1 + 1))
     |> update(:incoming, &(&1 - 1))}
  end

  def handle_info({:payment_received, _order}, socket) do
    {:noreply,
     socket |> assign(balance: balance()) |> update(:paid, &(&1 + 1)) |> update(:open, &(&1 - 1))}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp balance() do
    BookShop.Accounting.get_balance() / 100
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Statistics</h2>
        <h3 class="font-bold mb-2">Logistics</h3>
        <div class="stats shadow mb-4">
          <.stat number={@incoming} title="Incoming Orders" icon="hero-inbox-arrow-down" />
          <.stat number={@ready} title="Parcels ready" icon="hero-archive-box" />
          <.stat number={@shipped} title="Shipped" icon="hero-flag" />
        </div>
        <h3 class="font-bold mb-2">Accounting</h3>
        <div class="stats shadow mb-4">
          <.stat number={@balance} title="Balance" icon="hero-currency-euro" />
          <.stat number={@open} title="Open invoices" icon="hero-envelope" />
          <.stat number={@paid} title="Paid invoices" icon="hero-credit-card" />
        </div>
      </div>
    </Layouts.app>
    """
  end
end
