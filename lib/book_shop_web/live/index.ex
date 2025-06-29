defmodule BookShopWeb.Index do
  use BookShopWeb, :live_view

  def mount(_params, _session, socket) do
    books = BookShop.Store.list_books()
    {:ok, socket |> assign(books: books, page_title: "Book Shop")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center">
        <h2 class="text-2xl font-bold mb-4">Welcome to the Book Shop</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <.book :for={book <- @books} book={book} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("buy", %{"isbn" => isbn}, socket) do
    customer = %{name: "Peter Parker", billing_address: "my company", shipping_address: "my home"}
    :ok = BookShop.Store.place_order([isbn], customer)
    {:noreply, socket |> put_flash(:info, "Book ordered")}
  end

  def book(assigns) do
    ~H"""
    <div class="card bg-base-100 w-96 shadow-sm" phx-click="buy" phx-value-isbn={@book.isbn}>
      <figure class="h-96 rounded">
        <img src={@book.image_url} alt={@book.name} class="w-full" />
      </figure>
      <div class="card-body bg-base-300">
        <h3 class="card-title">{@book.name}</h3>
        <p>
          <strong>Author:</strong> {@book.author}
        </p>
        <p>
          Category: {@book.category}
        </p>
      </div>
    </div>
    """
  end
end
