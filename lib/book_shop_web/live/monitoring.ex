defmodule BookShopWeb.Monitoring do
  use BookShopWeb, :live_view

  import BookShopWeb.SharedComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      attach_telemetry()
    end

    {:ok, socket |> assign(balance: 0)}
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
    # dbg("Received telemetry event: #{inspect(balance)}")

    {:noreply,
     socket
     |> assign(balance: balance / 100)
     |> push_event("update-balance-chart", %{balance: balance, time: time})}
  end

  def handle_info(
        {:telemetry_event, stats, %{context: "logistics"}} = _msg,
        socket
      ) do
    # dbg("Received telemetry event: #{inspect(msg)}")

    {:noreply, socket |> push_event("update-logistics-chart", stats)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Monitoring</h2>
        <div class="w-full flex justify-center">
          <div class="card w-200 bg-base-100 card-xl shadow-sm">
            <div class="card-body">
              <h2 class="card-title">Accounting</h2>
              <.chart title="Balance" name="accounting-balance" hook="Chart" />
            </div>
          </div>
          <div class="stats shadow mb-4">
            <.stat number={@balance} title="Balance" icon="hero-currency-euro" />
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
