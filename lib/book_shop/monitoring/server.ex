defmodule BookShop.Monitoring.Server do
  use GenServer

  import BookShop.Helper

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}, {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Logger.info("BookShop.Monitoring.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info(_event, state) do
    {:noreply, state}
  end

  # Command handlers
end
