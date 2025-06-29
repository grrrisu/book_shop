defmodule BookShopWeb.Chaos do
  use BookShopWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Chaos Monkey")}
  end

  def handle_event("nuke", %{"server" => context}, socket) do
    context |> context_server() |> Process.whereis() |> Process.exit(:kill)
    {:noreply, socket |> put_flash(:error, "#{context} was NUKED!")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Chaos Monkey</h2>

        <img src="/images/chaos_monkey-2.png" />
        <p class="mb-4 text-error font-bold">
          NUKE THEM!!!
        </p>
        <div class="flex space-x-4">
          <button phx-click="nuke" phx-value-server="Logistics" class="btn btn-error">
            Logistics
          </button>
          <button phx-click="nuke" phx-value-server="Accounting" class="btn btn-error">
            Accounting
          </button>
          <button phx-click="nuke" phx-value-server="Marketing" class="btn btn-error">
            Marketing
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def context_server(context) do
    case context do
      "Logistics" -> BookShop.Logistics.Server
      "Accounting" -> BookShop.Accounting.Server
      "Marketing" -> BookShop.Marketing.Server
      _ -> nil
    end
  end
end
