defmodule ShopUxPhoenixWeb.ComponentCase do
  @moduledoc """
  This module defines the test case to be used by
  component tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.Component
      import Phoenix.LiveViewTest
      import Phoenix.Component
      
      # Import built-in components
      import ShopUxPhoenixWeb.CoreComponents
      
      # The default endpoint for testing
      @endpoint ShopUxPhoenixWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end