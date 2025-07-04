defmodule BookShop.Logistics do
  @moduledoc """
  Context for Logistics
  """

  alias BookShop.Logistics.Server

  def get_stats() do
    GenServer.call(Server, :get_stats, 10_000)
  end
end
