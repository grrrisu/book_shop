defmodule BookShop.Customer do
  @moduledoc """
  Customer keeps the contexts that define your customer domain
  """
  alias BookShop.Customer.Server

  def buy_books do
    :ok = GenServer.cast(Server, :buy_books)
  end
end
