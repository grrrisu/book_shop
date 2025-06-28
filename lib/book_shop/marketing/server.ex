defmodule BookShop.Marketing.Server do
  use GenServer

  import BookShop.Helper
  import BookShop.Tracing

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, [], {:continue, []}}
  end

  def handle_continue(_continue_arg, state) do
    subscribe()
    next_newsletter()

    Logger.warning("BookShop.Marketing.Server started and subscribed to store:events")
    {:noreply, state}
  end

  # Event handler for incoming events

  def handle_info({:payment_received, %{customer: customer, order_id: order_id}}, state) do
    trace(order_id, "Marketing", "enlist customer")
    {:noreply, [customer | state]}
  end

  def handle_info({:send_newsletter}, []) do
    next_newsletter()
    {:noreply, []}
  end

  def handle_info({:send_newsletter}, state) do
    Logger.info("Sending newsletter to #{Enum.count(state)} customers")

    Enum.each(state, fn customer ->
      broadcast_event({:newsletter_sent, "buy more books", customer})
    end)

    next_newsletter()

    {:noreply, []}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  def next_newsletter() do
    Process.send_after(
      self(),
      {:send_newsletter},
      2 * Application.get_env(:book_shop, :process_time, 1_000)
    )
  end

  # Command handlers
end
