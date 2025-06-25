defmodule BookShop do
  @moduledoc """
  BookShop keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias BookShop.Customer

  alias BookShop.CustomerSupervisor

  def run_demo do
    # Start the application
    Application.ensure_all_started(:book_shop)

    Enum.map(
      [
        "Alice",
        "Bob",
        "Charlie",
        "Diana",
        "Eric",
        "Francisa",
        "George",
        "Hannah",
        "Ian",
        "Julia",
        "Kevin",
        "Laura",
        "Mike",
        "Nina",
        "Oscar",
        "Paula",
        "Quentin",
        "Rachel",
        "Steve",
        "Tina",
        "Ursula",
        "Victor",
        "Wendy",
        "Xander",
        "Yara",
        "Zoe"
      ],
      &start_customer/1
    )
    |> Enum.each(fn {:ok, pid} ->
      Customer.buy_books(pid)
    end)

    # Stop the application
    Process.sleep(60_000)
    Application.stop(:book_shop)
  end

  defp start_customer(name) do
    DynamicSupervisor.start_child(CustomerSupervisor, {Customer.Server, name})
  end
end
