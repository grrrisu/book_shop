defmodule BookShop.Accounting do
  @moduledoc """
  Context for Accounting
  """

  alias BookShop.Accounting.Server

  def pay_invoice(order_id, price) do
    GenServer.call(Server, {:incoming_payment, order_id, price})
  end

  def get_balance() do
    GenServer.call(Server, :get_balance)
  end
end
