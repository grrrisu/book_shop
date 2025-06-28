defmodule BookShopWeb.Tracing do
  use BookShopWeb, :live_view

  alias BookShop.Tracing

  @expected_steps ["order_placed", "invoice_created", "books_shipped", "payment_received"]

  def mount(params, _session, socket) do
    trace = Tracing.get_trace(params["id"] |> String.to_integer())

    if connected?(socket) do
      Phoenix.PubSub.subscribe(BookShop.PubSub, "store:tracing")
    end

    {:ok, socket |> assign(trace: trace, id: params["id"] |> String.to_integer())}
  end

  def handle_info({:trace_added, trace}, socket) do
    {:noreply,
     assign(socket, :trace, append_trace(trace, socket.assigns.id, socket.assigns.trace))}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp append_trace(%{trace_id: id} = trace, id, current_trace) do
    [trace | current_trace]
  end

  defp append_trace(_trace, _id, current_trace), do: current_trace

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Tracing</h2>
        <p>Tracing details for order ID: {@id}</p>
        <.trace trace={@trace} />
      </div>
    </Layouts.app>
    """
  end

  def step(assigns) do
    assigns =
      assign(
        assigns,
        :time,
        assigns.time
        |> DateTime.from_unix!(:microsecond)
        |> Calendar.strftime("%Y-%m-%d %H:%M:%S-%f")
      )

    ~H"""
    <li>
      <hr class="bg-success" />
      <div class="timeline-start timeline-box">{@time}</div>
      <div class="timeline-middle">
        <.icon name="hero-check-circle-solid text-success size-6" />
      </div>
      <div class="timeline-end join">
        <div class="btn btn-secondary join-item">{@context}</div>
        <div class="btn join-item">{@description}</div>
      </div>
      <hr class="bg-success" />
    </li>
    """
  end

  def remaining_steps(assigns) do
    ~H"""
    <li>
      <hr />
      <div class="timeline-middle">
        <.icon name="hero-x-circle size-6" />
      </div>
      <div class="timeline-end timeline-box">{@description}</div>
    </li>
    """
  end

  def trace(assigns) when is_nil(assigns.trace) do
    ~H"""
    <div class="trace bg-base-300 p-4 rounded-lg shadow">
      Trace not yet available.
    </div>
    """
  end

  def trace(assigns) do
    assigns =
      assign(assigns,
        remaining_steps: @expected_steps -- Enum.map(assigns.trace, & &1.description),
        trace: Enum.reverse(assigns.trace)
      )

    ~H"""
    <div class="trace bg-base-300 p-4 rounded-lg shadow">
      <ul class="timeline timeline-vertical">
        <.step
          :for={step <- @trace}
          time={step.time}
          context={step.context}
          description={step.description}
        />
        <.remaining_steps :for={step <- @remaining_steps} description={step} />
      </ul>
    </div>
    """
  end
end
