defmodule BookShop.Supplier do
  @moduledoc """
  Context for Supplier
  """

  alias BookShop.Supplier.Server

  def order(books, quantity) do
    GenServer.cast(Server, {:order, books, quantity})
  end
end
