defmodule ShopUxPhoenixWeb.TabsDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Tabs Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/tabs")
      
      assert html =~ "Tabs 标签页组件"
      assert has_element?(view, "h1", "Tabs 标签页组件")
    end

    test "basic tabs switching works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      # Initial state - first tab should be active
      assert has_element?(view, "#tabpanel-tab1", "第一个标签页的内容")
      
      # Click second tab
      view
      |> element("#tab-tab2")
      |> render_click()
      
      # Second tab should now be active
      assert has_element?(view, "#tabpanel-tab2", "第二个标签页的内容")
    end

    test "tabs with icons render correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      assert has_element?(view, "[data-tab-key=\"home\"]")
      assert has_element?(view, "[data-tab-key=\"profile\"]")
      assert has_element?(view, "[data-tab-key=\"settings\"]")
    end

    test "different tab types render", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      # Should have sections for different types
      assert render(view) =~ "线条风格"
      assert render(view) =~ "卡片风格"
      assert render(view) =~ "药丸风格"
    end

    test "different sizes render", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      assert render(view) =~ "小尺寸"
      assert render(view) =~ "中等尺寸"
      assert render(view) =~ "大尺寸"
    end

    test "disabled tab cannot be clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      # Find the disabled tab section
      assert has_element?(view, "[aria-disabled=\"true\"]")
    end

    test "controlled tabs update correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      # Initial state
      assert has_element?(view, ".text-gray-600", "当前激活:")
      
      # Click products tab
      view
      |> element("#tab-ctrl-products")
      |> render_click()
      
      # Products tab should be active
      assert has_element?(view, "[aria-selected=\"true\"]", "商品")
    end

    test "different positions render correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      assert render(view) =~ "标签在顶部"
      assert render(view) =~ "标签在右侧"
      assert render(view) =~ "标签在底部"
      assert render(view) =~ "标签在左侧"
    end

    test "animated vs non-animated tabs", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      # Should have section for animation demo
      assert render(view) =~ "动画效果"
      assert render(view) =~ "无动画效果"
    end

    test "complex example with tables works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tabs")
      
      # Check complex example section
      assert render(view) =~ "复杂示例"
      assert render(view) =~ "订单管理"
      assert render(view) =~ "商品管理"
      assert render(view) =~ "统计分析"
    end

    test "all sections are rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/tabs")
      
      # Check all section titles
      assert html =~ "基础用法"
      assert html =~ "带图标的标签页"
      assert html =~ "不同类型"
      assert html =~ "不同尺寸"
      assert html =~ "禁用状态"
      assert html =~ "不同位置"
      assert html =~ "动画控制"
      assert html =~ "受控模式"
      assert html =~ "复杂示例"
    end
  end
end