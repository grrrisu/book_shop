defmodule BookShopWeb.Monitoring do
  use BookShopWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = attach_telemetry()
    end

    {:ok, socket}
  end

  def attach_telemetry do
    :telemetry.attach_many(
      "monitoring-telemetry",
      [[:book_shop, :logistics, :stats], [:book_shop, :accounting, :balance]],
      &__MODULE__.handle_telemetry_event/4,
      %{pid: self()}
    )
  end

  def handle_telemetry_event(_event, measurements, metadata, %{pid: pid}) do
    send(pid, {:telemetry_event, measurements, metadata})
  end

  def handle_info({:telemetry_event, _measurements, _metadata} = msg, socket) do
    dbg("Received telemetry event: #{inspect(msg)}")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Monitoring</h2>
        <.chart title="Accounting Balane" name="accounting-balance" hook="LineChart" />
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
