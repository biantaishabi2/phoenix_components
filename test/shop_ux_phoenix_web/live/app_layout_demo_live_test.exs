defmodule ShopUxPhoenixWeb.AppLayoutDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "AppLayout Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/app_layout")
      
      assert html =~ "AppLayout 应用布局组件"
      assert has_element?(view, "h1", "AppLayout 应用布局组件")
    end

    test "shows basic layout structure", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查基本布局元素
      assert has_element?(view, "[data-app-layout]")
      assert has_element?(view, "[data-app-sidebar]")
      assert has_element?(view, "[data-app-header]")
      assert has_element?(view, "[data-breadcrumb]")
      assert has_element?(view, "[data-main-content]")
    end

    test "shows sidebar state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查侧边栏存在
      assert has_element?(view, "[data-app-sidebar]")
      assert render(view) =~ "仪表盘"
      assert render(view) =~ "商品管理"
    end

    test "shows menu navigation", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查菜单项
      assert has_element?(view, "[data-menu-item='dashboard']")
      assert has_element?(view, "[data-menu-item='products']")
      assert has_element?(view, "[data-menu-item='orders']")
      assert has_element?(view, "[data-menu-item='settings']")
      
      # 检查子菜单
      assert render(view) =~ "商品列表"
      assert render(view) =~ "新建商品"
      assert render(view) =~ "订单列表"
      assert render(view) =~ "批量发货"
    end

    test "shows breadcrumbs", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查面包屑存在
      assert has_element?(view, "[data-breadcrumb]")
      assert has_element?(view, "[data-breadcrumb-item]")
    end

    test "shows user information", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查用户信息
      assert render(view) =~ "张三"
      assert render(view) =~ "示例科技有限公司"
    end

    test "shows notification badge", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查通知徽章
      assert has_element?(view, "[data-notification-badge]")
      assert render(view) =~ "5" # 通知数量
    end

    test "shows logout functionality", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查退出按钮存在
      assert render(view) =~ "退出登录"
    end

    test "shows responsive layout info", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查响应式说明
      assert render(view) =~ "桌面端"
      assert render(view) =~ "平板端"
      assert render(view) =~ "移动端"
    end

    test "shows menu items", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查菜单项存在
      assert has_element?(view, "[data-menu-item='dashboard']")
      assert has_element?(view, "[data-menu-item='products']")
      assert has_element?(view, "[data-menu-item='orders']")
    end

    test "shows submenus", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查子菜单存在
      assert has_element?(view, "[data-has-children]")
      assert render(view) =~ "商品列表"
      assert render(view) =~ "新建商品"
    end

    test "shows different layout examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查不同的示例区域
      assert has_element?(view, "h2", "基础布局")
      assert has_element?(view, "h2", "带搜索框的头部")
      assert has_element?(view, "h2", "自定义菜单")
      assert has_element?(view, "h2", "响应式布局")
    end

    test "shows dark mode toggle", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/app_layout")
      
      # 检查暗色模式切换
      assert has_element?(view, "[phx-click=toggle_theme]")
      
      # 切换暗色模式
      view
      |> element("[phx-click=toggle_theme]")
      |> render_click()
      
      assert has_element?(view, "[data-theme='dark']")
    end
  end
end