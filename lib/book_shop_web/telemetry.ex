defmodule BookShopWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 2_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.start.system_time",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.start.system_time",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.exception.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.socket_connected.duration",
        unit: {:native, :millisecond}
      ),
      sum("phoenix.socket_drain.count"),
      summary("phoenix.channel_joined.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.channel_handled_in.duration",
        tags: [:event],
        unit: {:native, :millisecond}
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Business Metrics
      last_value("book_shop.logistics.stats.ready"),
      last_value("book_shop.logistics.stats.inventory"),
      last_value("book_shop.accounting.balance.sum")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {BookShopWeb, :count_users, []}
      {BookShopWeb.Telemetry, :read_logistics_stats, []},
      {BookShopWeb.Telemetry, :read_balance, []}
    ]
  end

  # custom metrics

  def read_logistics_stats do
    stats = BookShop.Logistics.get_stats()

    :telemetry.execute(
      [:book_shop, :logistics, :stats],
      %{ready: stats.ready, inventory: stats.inventory},
      %{context: "logistics", time: DateTime.utc_now() |> DateTime.to_iso8601()}
    )
  end

  def read_balance do
    balance = BookShop.Accounting.get_balance()

    :telemetry.execute(
      [:book_shop, :accounting, :balance],
      %{sum: balance},
      %{context: "accounting", time: DateTime.utc_now() |> DateTime.to_iso8601()}
    )
  end
end
