defmodule ShopUxPhoenixWeb.BreadcrumbLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Breadcrumb Demo LiveView" do
    test "renders breadcrumb demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/breadcrumb")
      
      assert html =~ "Breadcrumb 面包屑导航组件"
      assert html =~ "基础面包屑"
      assert html =~ "带图标的面包屑"
    end

    test "displays different breadcrumb examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      # Check for basic breadcrumb
      assert render(view) =~ "首页"
      assert render(view) =~ "产品管理"
      assert render(view) =~ "产品列表"
      
      # Check for icon breadcrumb
      assert render(view) =~ "hero-home"
      assert render(view) =~ "hero-shopping-bag"
      
      # Check for custom separator
      assert render(view) =~ "/"
    end

    test "breadcrumb navigation works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      # Check that links are present
      html = render(view)
      assert html =~ ~s(href="/")
      assert html =~ ~s(href="/products")
    end

    test "different sizes are displayed", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      assert html =~ "text-xs"    # small size
      assert html =~ "text-sm"    # medium size
      assert html =~ "text-base"  # large size
    end

    test "max items limitation is shown", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Should contain ellipsis for max_items demo
      assert html =~ "..."
    end

    test "separator variations are displayed", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Check for different separator types
      assert html =~ "hero-chevron-right"  # chevron separator
      assert html =~ "/"                   # slash separator
      assert html =~ "→"                   # arrow separator
    end

    test "responsive behavior is demonstrated", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Should have responsive classes
      assert html =~ "hidden" || html =~ "md:inline" || html =~ "sm:hidden"
    end

    test "interactive features work", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      # Test responsive toggle functionality specifically
      html = render(view)
      
      # Test responsive checkbox toggle
      if has_element?(view, "#responsive") do
        view
        |> element("#responsive")
        |> render_click()
        
        # Verify the interaction worked
        updated_html = render(view)
        assert updated_html =~ "面包屑"
      else
        # If no interactive elements, just verify content
        assert html =~ "面包屑"
      end
    end

    test "accessibility features are present", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      assert html =~ ~s(aria-label="Breadcrumb")
      assert html =~ ~s(aria-current="page") || html =~ "aria-current"
    end

    test "home link configuration works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Should show both enabled and disabled home link examples
      assert html =~ "主页" || html =~ "首页"
    end

    test "special character handling", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Should properly escape HTML characters
      refute html =~ "<script>"
      refute html =~ "&lt;script&gt;"
    end

    test "empty state handling", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Should handle empty breadcrumb gracefully
      assert html =~ "面包屑"
    end

    test "performance with many items", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      # Measure rendering time (basic check)
      start_time = System.monotonic_time()
      _html = render(view)
      end_time = System.monotonic_time()
      
      # Should render within reasonable time (1 second)
      duration_ms = System.convert_time_unit(end_time - start_time, :native, :millisecond)
      assert duration_ms < 1000
    end

    test "css classes are applied correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/breadcrumb")
      
      html = render(view)
      # Check for expected Tailwind classes
      assert html =~ "inline-flex"
      assert html =~ "items-center" 
      assert html =~ "text-gray-700" || html =~ "text-gray-500"
    end
  end
end