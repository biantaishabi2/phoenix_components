defmodule ShopUxPhoenixWeb.DropdownDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Dropdown Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/dropdown")
      
      assert html =~ "Dropdown 下拉菜单组件"
      assert has_element?(view, "h1", "Dropdown 下拉菜单组件")
    end

    test "basic dropdown interaction works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Find basic dropdown button
      assert has_element?(view, "[data-dropdown-id]", "基础下拉菜单")
      
      # Check dropdown structure
      assert has_element?(view, "#basic-dropdown-trigger")
      assert has_element?(view, "#basic-dropdown-trigger[aria-expanded=\"false\"]")
      assert has_element?(view, "#basic-dropdown-trigger[aria-haspopup=\"true\"]")
      
      # Menu should exist (hidden by default)
      assert has_element?(view, "#basic-dropdown-menu")
      assert has_element?(view, "#basic-dropdown-menu[data-state=\"closed\"]")
      assert has_element?(view, "[role=\"menuitem\"]", "查看详情")
    end

    test "hover dropdown works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Find hover dropdown
      assert has_element?(view, "[data-dropdown-id=\"hover-dropdown\"]")
      assert has_element?(view, "#hover-dropdown-trigger")
      
      # Hover dropdown should exist (actual hover is handled by Alpine.js)
      assert render(view) =~ "悬停触发"
    end

    test "dropdown with icons renders correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check icon dropdown section
      assert render(view) =~ "带图标的菜单"
      assert render(view) =~ "编辑"
      assert render(view) =~ "删除"
      assert render(view) =~ "<svg"
    end

    test "different positions render", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check position examples
      assert render(view) =~ "不同位置"
      assert render(view) =~ "上方"
      assert render(view) =~ "下方"
      assert render(view) =~ "左侧"
      assert render(view) =~ "右侧"
    end

    test "disabled dropdown cannot be clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Find disabled dropdown
      assert has_element?(view, "[aria-disabled=\"true\"]")
      assert has_element?(view, "#disabled-dropdown-trigger[aria-disabled=\"true\"]")
      
      # Disabled dropdown should have tabindex="-1"
      assert has_element?(view, "#disabled-dropdown-trigger[tabindex=\"-1\"]")
      
      # Menu should remain closed
      assert has_element?(view, "#disabled-dropdown-menu[data-state=\"closed\"]")
    end

    test "danger items have proper styling", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check dropdown exists
      assert has_element?(view, "#actions-dropdown-trigger")
      
      # Check danger item exists with proper styling
      assert has_element?(view, "[role=\"menuitem\"].text-red-600", "删除")
    end

    test "dropdown has click-away handler", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check dropdown exists
      assert has_element?(view, "#basic-dropdown-trigger")
      assert has_element?(view, "#basic-dropdown-menu")
      
      # Check that menu has phx-click-away attribute
      assert render(view) =~ "phx-click-away"
      
      # Menu should be closed by default
      assert has_element?(view, "#basic-dropdown-menu[data-state=\"closed\"]")
    end

    test "batch operations dropdown works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Find batch operations dropdown
      assert has_element?(view, "[data-dropdown-id=\"batch-dropdown\"]", "批量操作")
      assert has_element?(view, "#batch-dropdown-trigger")
      
      # Check menu items exist
      assert has_element?(view, "[role=\"menuitem\"]", "批量导出")
      assert has_element?(view, "[role=\"menuitem\"]", "批量删除")
    end

    test "custom styled dropdown renders", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check custom styles section
      assert render(view) =~ "自定义样式"
      assert render(view) =~ "深色主题"
      assert has_element?(view, ".bg-gray-900")
    end

    test "complex dropdown with user info works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Find user menu dropdown
      assert has_element?(view, "[data-dropdown-id=\"user-dropdown\"]")
      assert has_element?(view, "#user-dropdown-trigger")
      
      # Check custom content
      assert render(view) =~ "张三"
      assert render(view) =~ "admin@example.com"
      assert has_element?(view, "[role=\"menuitem\"]", "个人资料")
      assert has_element?(view, "[role=\"menuitem\"]", "退出登录")
    end

    test "all sections are rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/dropdown")
      
      # Check all section titles
      assert html =~ "基础用法"
      assert html =~ "触发方式"
      assert html =~ "带图标的菜单"
      assert html =~ "不同位置"
      assert html =~ "禁用状态"
      assert html =~ "分隔线和危险项"
      assert html =~ "批量操作"
      assert html =~ "自定义内容"
      assert html =~ "自定义样式"
      assert html =~ "实际应用场景"
    end

    test "menu items have proper event handlers", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check dropdown exists
      assert has_element?(view, "#basic-dropdown-trigger")
      assert has_element?(view, "#basic-dropdown-menu")
      
      # Check menu items have phx-click handlers
      assert has_element?(view, "#basic-dropdown-menu [phx-value-action=\"view\"]")
      assert has_element?(view, "#basic-dropdown-menu [phx-value-action=\"edit\"]")
      assert has_element?(view, "#basic-dropdown-menu [phx-value-action=\"share\"]")
      
      # Click a menu item with server-side handler
      view
      |> element("#basic-dropdown-menu [phx-value-action=\"view\"]")
      |> render_click()
      
      # Check the event was handled (notification shows)
      assert render(view) =~ "操作: view"
    end
  end
end