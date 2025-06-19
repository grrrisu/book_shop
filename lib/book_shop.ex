defmodule BookShop do
  @moduledoc """
  BookShop keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias BookShop.Customer

  def run_demo do
    # Start the application
    Application.ensure_all_started(:book_shop)

    Customer.buy_books()

    # Stop the application
    Process.sleep(10_000)
    Application.stop(:book_shop)
  end
end
