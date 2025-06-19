defmodule BookShopWeb.PageController do
  use BookShopWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
