defmodule BookShop.Store do
  @moduledoc """
  Store keeps the contexts that define your book store domain
  and business logic.
  """

  alias BookShop.Store.Server

  def place_order(books, customer) do
    :ok = GenServer.cast(Server, {:place_order, books, customer})
  end

  def list_books do
    GenServer.call(Server, :list_books)
  end
end
