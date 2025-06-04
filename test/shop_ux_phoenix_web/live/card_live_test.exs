defmodule ShopUxPhoenixWeb.CardLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Card Demo LiveView" do
    test "renders card demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/card")
      
      assert html =~ "Card 卡片组件"
      assert html =~ "基础用法"
      assert html =~ "不同尺寸"
    end

    test "displays different card examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      # Check for basic card
      assert render(view) =~ "基础卡片"
      
      # Check for bordered card
      assert render(view) =~ "无边框"
      
      # Check for hoverable card
      assert render(view) =~ "可悬停"
      
      # Check for loading card
      assert render(view) =~ "加载状态"
    end

    test "shows different card sizes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "小尺寸"
      assert html =~ "中等尺寸"
      assert html =~ "大尺寸"
    end

    test "displays card with extra content", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "额外内容"
      assert html =~ "更多"
      # 设置 button is in the extra content section
      assert html =~ "订单信息"
    end

    test "shows card with actions", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "操作区域"
      assert html =~ "编辑"
      assert html =~ "删除"
      assert html =~ "分享"
    end

    test "displays card with cover image", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "封面卡片"
      assert html =~ "<img"
      assert html =~ "产品图片"
    end

    test "shows nested cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "嵌套卡片"
      assert html =~ "父卡片"
      assert html =~ "子卡片"
    end

    test "displays loading states", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "加载状态"
      # Initially loading_demo is false, so we click to toggle it
      html = render_click(view, "toggle_loading")
      assert html =~ "animate-pulse"
    end

    test "shows real-world examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      # Dashboard cards
      assert html =~ "今日订单"
      assert html =~ "营业额"
      assert html =~ "新增用户"
      
      # Order detail card
      assert html =~ "订单详情"
      assert html =~ "收货信息"
      assert html =~ "商品信息"
    end

    test "demonstrates custom styling", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "自定义样式"
      assert html =~ "bg-gradient-to-r"
    end

    test "shows grid layout with cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "grid"
      assert html =~ "gap-4" || html =~ "gap-6"
    end

    test "displays form inside card", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "表单卡片" || html =~ "基本信息"
      assert html =~ "保存"
      assert html =~ "取消"
    end

    test "shows list inside card", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      html = render(view)
      assert html =~ "最新订单" || html =~ "列表"
      assert html =~ "查看全部"
    end

    test "card interactions work", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/card")
      
      # Test if page renders without errors
      html = render(view)
      assert html =~ "Card"
      
      # Cards should be interactive (hoverable ones should have hover classes)
      assert html =~ "hover:" || html =~ "transition"
    end
  end
end