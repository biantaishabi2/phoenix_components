defmodule ShopUxPhoenixWeb.DropdownLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Dropdown Demo LiveView" do
    test "renders dropdown demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/dropdown")
      
      assert html =~ "Dropdown 下拉菜单组件"
      assert html =~ "基础用法"
      assert html =~ "触发方式"
    end

    test "displays different dropdown examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Check for basic dropdown
      assert render(view) =~ "基础下拉菜单"
      
      # Check for hover trigger
      assert render(view) =~ "悬停触发"
      assert render(view) =~ "hover-dropdown"
      
      # Check for icon dropdown
      assert render(view) =~ "文件操作"
      
      # Check for disabled dropdown
      assert render(view) =~ "已禁用"
    end

    test "dropdown positions are displayed", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "下方左对齐"
      assert html =~ "下方右对齐"
      assert html =~ "上方左对齐"
      assert html =~ "上方右对齐"
      assert html =~ "左侧"
      assert html =~ "右侧"
    end

    test "displays dropdown with dividers and danger items", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "分隔线和危险项"
      assert html =~ "操作菜单"
      assert html =~ "删除"
      assert html =~ "text-red-600" || html =~ "danger"
    end

    test "shows custom content dropdown", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "自定义内容"
      assert html =~ "张三"
      assert html =~ "admin@example.com"
    end

    test "displays table row actions example", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "表格行操作"
      assert html =~ "ORD-001"
      assert html =~ "待发货"
    end

    test "shows navigation bar user menu", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "导航栏用户菜单"
      assert html =~ "控制台"
      assert html =~ "个人资料"
      assert html =~ "退出"
    end

    test "menu actions trigger events", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Test basic menu action
      html = render_click(view, "menu_action", %{"action" => "edit"})
      assert html =~ "操作: edit"
      
      # Test batch export action
      html = render_click(view, "batch_export")
      assert html =~ "操作: 批量导出"
    end

    test "special actions work correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Test view profile
      html = render_click(view, "view_profile")
      # Since these actions update last_action, check if the view updated
      assert html =~ "Dropdown"  # Page should still render
      
      # Test open settings
      _html = render_click(view, "open_settings")
      # Action should be handled
      
      # Test logout
      _html = render_click(view, "logout")
      # Action should be handled
    end

    test "notification message appears and disappears", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      # Initially no notification
      refute render(view) =~ "fixed top-4 right-4 bg-green-500"
      
      # Trigger an action
      render_click(view, "menu_action", %{"action" => "copy"})
      
      # Notification should appear
      html = render(view)
      assert html =~ "操作: copy"
      assert html =~ "fixed top-4 right-4 bg-green-500"
      
      # Wait for notification to clear (simulated by sending the message)
      send(view.pid, :clear_notification)
      
      # Notification should be gone
      refute render(view) =~ "fixed top-4 right-4 bg-green-500"
    end

    test "accessibility attributes are present", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ ~s(role="button")
      assert html =~ ~s(aria-expanded="false")
      assert html =~ ~s(aria-haspopup="true")
      assert html =~ ~s(role="menu")
    end

    test "different trigger types are shown", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      # Click trigger
      assert html =~ "点击触发"
      assert html =~ "phx-click"
      
      # Hover trigger
      assert html =~ "悬停触发"
      assert html =~ "phx-mouseenter"
    end

    test "icon examples render properly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "带图标的菜单"
      assert html =~ "<svg"
      assert html =~ "新建文件"
      assert html =~ "打开文件"
    end

    test "custom styling example works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/dropdown")
      
      html = render(view)
      assert html =~ "自定义样式"
      assert html =~ "深色主题"
      assert html =~ "bg-gray-900"
    end
  end
end