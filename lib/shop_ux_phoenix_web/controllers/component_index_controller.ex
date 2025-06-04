defmodule ShopUxPhoenixWeb.ComponentIndexController do
  use ShopUxPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end