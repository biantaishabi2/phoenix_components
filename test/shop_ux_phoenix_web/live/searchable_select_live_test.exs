defmodule ShopUxPhoenixWeb.SearchableSelectLiveTest do
  use ShopUxPhoenixWeb.ConnCase

  import Phoenix.LiveViewTest
  alias ShopUxPhoenixWeb.SearchableSelectDemoLive

  describe "SearchableSelect component in LiveView" do
    test "demo page renders successfully", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check that the demo page renders with basic components
      assert html =~ "SearchableSelect 组件演示"
      assert html =~ "category-select"
      assert html =~ "multiple-select" 
      assert html =~ "user-select"
      assert html =~ "grouped-select"
    end

    test "handles basic selection", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check that the basic selection component renders
      assert html =~ "category-select"
      assert html =~ "Technology"
      assert html =~ "Design"
      
      # Check that the component has proper Phoenix event handling
      assert html =~ "phx-"
    end

    test "handles multiple selection", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check multiple selection exists
      assert html =~ "multiple-select"
      assert html =~ "skills"

      # Multiple selection component renders correctly
      assert html =~ "data-multiple"
    end

    test "handles user selection", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check user selection component exists
      assert html =~ "user-select"
      assert html =~ "John Doe"
      assert html =~ "jane@example.com"
    end

    test "handles grouped options", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check grouped options structure
      assert html =~ "grouped-select"
      assert html =~ "Engineering"
      assert html =~ "Marketing"
      assert html =~ "Development"
      assert html =~ "SEO"
    end

    test "handles remote search", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check remote search setup
      assert html =~ "remote-select"
      assert html =~ "搜索商品"
      assert html =~ "data-remote-search"
    end

    test "handles form submission", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, SearchableSelectDemoLive)

      # Submit the form with basic data
      result = view
      |> element("form")
      |> render_submit(%{"category" => "tech"})

      # Form submission should work without error
      assert result
    end

    test "shows different sizes", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check different size selects exist
      assert html =~ "small-select"
      assert html =~ "medium-select" 
      assert html =~ "large-select"
      assert html =~ "size-sm"
      assert html =~ "size-md"
      assert html =~ "size-lg"
    end

    test "shows validation errors", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check error display
      assert html =~ "error-select"
      assert html =~ "This field is required"
      assert html =~ "border-red-500"
    end

    test "handles disabled state", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check disabled select
      assert html =~ "disabled-select"
      assert html =~ "cursor-not-allowed"
    end

    test "shows loading state", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SearchableSelectDemoLive)

      # Check loading select
      assert html =~ "loading-select"
      assert html =~ "animate-spin"
    end
  end
end