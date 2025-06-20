defmodule BookShop.Marketing.Server do
  use GenServer

  import BookShop.Helper

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, [], {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    Process.send_after(self(), {:send_newsletter}, 1_000)
    Logger.info("BookShop.Marketing.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:payment_received, customer}, state) do
    {:noreply, [customer | state]}
  end

  def handle_info({:send_newsletter}, state) do
    Logger.info("Sending newsletter to #{Enum.count(state)} customers")

    Enum.each(state, fn customer ->
      broadcast_event({:newsletter_sent, "buy more books", customer})
    end)

    Process.send_after(self(), {:send_newsletter}, 1_000)
    {:noreply, []}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  # Command handlers
end
