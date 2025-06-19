defmodule BookShop.Customer do
  @moduledoc """
  Customer keeps the contexts that define your customer domain
  """
  def buy_books(pid) do
    :ok = GenServer.cast(pid, :buy_books)
  end
end
