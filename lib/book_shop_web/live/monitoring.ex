defmodule BookShopWeb.Monitoring do
  use BookShopWeb, :live_view

  import BookShopWeb.SharedComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      attach_telemetry()
    end

    {:ok, socket |> assign(balance: 0, inventory: 0, ready: 0, page_title: "Monitoring")}
  end

  def attach_telemetry do
    :telemetry.attach_many(
      "monitoring-telemetry-#{inspect(self())}",
      [[:book_shop, :logistics, :stats], [:book_shop, :accounting, :balance]],
      &__MODULE__.handle_telemetry_event/4,
      %{pid: self()}
    )
  end

  def handle_telemetry_event(_event, measurements, metadata, %{pid: pid}) do
    send(pid, {:telemetry_event, measurements, metadata})
  end

  def handle_info(
        {:telemetry_event, %{sum: balance}, %{context: "accounting", time: time}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(balance: balance / 100)
     |> push_event("update-balance-chart", %{balance: balance, time: time})}
  end

  def handle_info(
        {:telemetry_event, stats, %{context: "logistics", time: time}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(ready: stats.ready, inventory: stats.inventory)
     |> push_event("update-logistics-chart", %{
       ready: stats.ready,
       inventory: stats.inventory,
       time: time
     })}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Monitoring</h2>
        <div class="flex w-2/3 mb-4">
          <div class="w-2/3">
            <.chart title="Accounting" name="accounting-balance" hook="AccountingChart" />
          </div>
          <div class="card w-1/3 bg-base-100 card-xl shadow-sm">
            <div class="card-body">
              <.stat number={@balance} title="Balance" icon="hero-currency-euro" />
            </div>
          </div>
        </div>

        <div class="flex w-2/3">
          <div class="w-2/3">
            <.chart title="Logistics" name="logistics-stats" hook="LogisticsChart" />
          </div>
          <div class="card w-1/3 bg-base-100 card-xl shadow-sm">
            <div class="card-body">
              <.stat number={@inventory} title="Inventory" icon="hero-queue-list" />
              <.stat number={@ready} title="Ready" icon="hero-clipboard-document-check" />
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def chart(assigns) do
    ~H"""
    <h3>{@title}</h3>
    <div id={"#{@name}-container"} phx-update="ignore" class="relative">
      <canvas id={"#{@name}"} phx-hook={@hook}></canvas>
    </div>
    """
  end
end
