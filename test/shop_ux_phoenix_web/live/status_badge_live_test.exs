defmodule ShopUxPhoenixWeb.StatusBadgeLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "StatusBadge Demo LiveView" do
    test "renders status badge demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/status_badge")
      
      assert html =~ "StatusBadge 状态徽章组件"
      assert html =~ "基础用法"
      assert html =~ "状态类型"
    end

    test "displays different status types", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      
      # Check for different status types
      assert html =~ "默认"
      assert html =~ "成功"
      assert html =~ "处理中"
      assert html =~ "警告"
      assert html =~ "错误"
      assert html =~ "信息"
    end

    test "shows status with icons", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "带图标"
      assert html =~ "已发货"
      assert html =~ "待付款"
    end

    test "displays dot mode examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "状态点"
      assert html =~ "在线"
      assert html =~ "离线"
      assert html =~ "忙碌"
    end

    test "shows different sizes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "不同尺寸"
      assert html =~ "小尺寸"
      assert html =~ "中等尺寸"
      assert html =~ "大尺寸"
    end

    test "displays custom colors", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "自定义颜色"
      assert html =~ "VIP"
      assert html =~ "热销"
      assert html =~ "新品"
    end

    test "shows business examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      
      # Order statuses
      assert html =~ "订单状态"
      assert html =~ "待付款"
      assert html =~ "已付款"
      assert html =~ "已发货"
      assert html =~ "已完成"
      assert html =~ "已取消"
      
      # User statuses
      assert html =~ "用户状态"
      assert html =~ "正常"
      assert html =~ "已禁用"
      assert html =~ "待验证"
      
      # Product statuses
      assert html =~ "商品状态"
      assert html =~ "在售"
      assert html =~ "缺货"
      assert html =~ "下架"
      assert html =~ "预售"
    end

    test "displays table integration example", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "表格中使用"
      assert html =~ "订单号"
      assert html =~ "状态"
    end

    test "shows bordered and borderless styles", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "边框样式"
      assert html =~ "有边框"
      assert html =~ "无边框"
    end

    test "displays combination examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "组合使用"
      assert html =~ "库存:"
      assert html =~ "128"
      assert html =~ "-12%"
    end

    test "page has proper styling", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      # Check for grid layouts
      assert html =~ "grid"
      assert html =~ "gap-"
      
      # Check for section styling
      assert html =~ "mb-12" || html =~ "mb-8"
    end

    test "shows审核状态 examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      html = render(view)
      assert html =~ "审核状态"
      assert html =~ "待审核"
      assert html =~ "审核通过"
      assert html =~ "审核拒绝"
    end

    test "all examples render without errors", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/status_badge")
      
      # Simply ensure the page renders completely
      html = render(view)
      assert html =~ "StatusBadge"
      assert html =~ "</div>"
    end
  end
end