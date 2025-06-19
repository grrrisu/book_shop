defmodule BookShop.Accounting do
  @moduledoc """
  Context for Accounting
  """

  alias BookShop.Accounting.Server

  def pay_invoice(order_id, price) do
    GenServer.call(Server, {:incoming_payment, order_id, price})
  end
end
