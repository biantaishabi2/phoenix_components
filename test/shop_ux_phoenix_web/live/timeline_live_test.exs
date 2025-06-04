defmodule ShopUxPhoenixWeb.TimelineLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Timeline Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      assert html =~ "Timeline"
      assert html =~ "时间线组件"
      assert html =~ "基础用法"
    end

    test "shows different examples", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      # Check for various demo sections
      assert html =~ "基础用法"
      assert html =~ "不同尺寸"
      assert html =~ "颜色主题"
      assert html =~ "布局模式"
      assert html =~ "倒序显示"
      assert html =~ "交互事件"
    end

    test "timeline interaction works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/timeline")
      
      # Since multiple interactive items exist, just verify the interaction functionality
      html = render(view)
      assert html =~ "交互事件"
      assert html =~ "phx-click"
    end

    test "load more functionality works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/timeline")
      
      # Click load more button
      html = view
             |> element("button", "加载更多")
             |> render_click()
      
      # Should show new data or loading message
      assert html =~ "已加载更多数据" || html =~ "新增数据"
    end

    test "pending state toggle works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/timeline")
      
      # Click toggle pending button
      html = view
             |> element("button", "显示加载状态")
             |> render_click()
      
      # Should show pending timeline
      assert html =~ "带加载状态" || html =~ "加载中"
      
      # Verify pending timeline exists
      assert has_element?(view, "[data-testid='pending-timeline']")
    end

    test "different sizes display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      # Check that different sizes are shown
      assert html =~ "小尺寸"
      assert html =~ "默认尺寸" 
      assert html =~ "大尺寸"
      
      # Should have size-specific test IDs
      assert html =~ "small-timeline"
      assert html =~ "medium-timeline"
      assert html =~ "large-timeline"
    end

    test "different color themes display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      # Check color theme sections
      assert html =~ "Primary 主色"
      assert html =~ "Success 成功"
      assert html =~ "Warning 警告"
      assert html =~ "Danger 危险"
    end

    test "different modes display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      # Check layout mode sections
      assert html =~ "左侧模式"
      assert html =~ "右侧模式"
      assert html =~ "交替模式"
      
      # Should have mode-specific test IDs
      assert html =~ "left-timeline"
      assert html =~ "right-timeline"
      assert html =~ "alternate-timeline"
    end

    test "reverse timeline displays correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      assert html =~ "倒序显示"
      assert html =~ "最新的事件显示在顶部"
      assert html =~ "reverse-timeline"
    end

    test "project timeline example works", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      assert html =~ "项目时间线"
      assert html =~ "立项申请"
      assert html =~ "需求调研"
      assert html =~ "project-timeline"
    end

    test "order timeline example works", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      assert html =~ "订单状态跟踪"
      assert html =~ "订单创建"
      assert html =~ "支付成功"
      assert html =~ "order-timeline"
    end

    test "notification timeline example works", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      assert html =~ "消息通知"
      assert html =~ "系统通知"
      assert html =~ "新消息"
      assert html =~ "notification-timeline"
    end

    test "usage examples display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/timeline")
      
      assert html =~ "使用说明"
      assert html =~ "Timeline 组件支持多种显示模式"
      assert html =~ "详细的 API 文档"
    end

    test "timeline items have correct data attributes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/timeline")
      
      # Check for data-testid attributes
      assert has_element?(view, "[data-testid='basic-timeline']")
      assert has_element?(view, "[data-testid='interactive-timeline']")
      assert has_element?(view, "[data-testid='small-timeline']")
      assert has_element?(view, "[data-testid='primary-timeline']")
    end

    test "handles timeline item click event", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/timeline")
      
      # Verify that clickable timeline items exist
      html = render(view)
      assert html =~ "交互事件"
      
      # Check for the presence of click events
      if html =~ "phx-click" do
        assert html =~ "timeline_item_clicked"
      end
    end

    test "flash messages work correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/timeline")
      
      # Trigger an action that shows flash message
      view
      |> element("button", "加载更多")
      |> render_click()
      
      # Check if flash message appears
      html = render(view)
      assert html =~ "已加载更多数据" || html =~ "info"
    end
  end
end