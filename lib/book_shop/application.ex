defmodule BookShop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:book_shop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BookShop.PubSub},
      {DynamicSupervisor, name: BookShop.CustomerSupervisor, strategy: :one_for_one},
      BookShop.Supplier.Server,
      BookShop.Store.Server,
      BookShop.Logistics.Server,
      BookShop.Accounting.Server,
      BookShop.Marketing.Server,
      BookShopWeb.Endpoint,
      BookShopWeb.Telemetry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BookShop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BookShopWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
