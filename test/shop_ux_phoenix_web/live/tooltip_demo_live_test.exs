defmodule ShopUxPhoenixWeb.TooltipDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Tooltip Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/tooltip")
      
      assert html =~ "Tooltip 文字提示组件"
      assert has_element?(view, "h1", "Tooltip 文字提示组件")
    end

    test "shows basic tooltip examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      # Check basic examples section
      assert has_element?(view, "h2", "基础用法")
      assert render(view) =~ "悬停查看提示"
      assert render(view) =~ "点击触发"
      assert render(view) =~ "聚焦触发"
    end

    test "shows placement examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "位置")
      # Check for direction buttons
      assert render(view) =~ "上方"
      assert render(view) =~ "下方"
      assert render(view) =~ "左侧"
      assert render(view) =~ "右侧"
    end

    test "shows 12 directions example", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "12个方向")
      # Check for direction indicators
      assert render(view) =~ "TL"
      assert render(view) =~ "Top"
      assert render(view) =~ "TR"
      assert render(view) =~ "LT"
      assert render(view) =~ "RT"
      assert render(view) =~ "Bottom"
    end

    test "shows custom content examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "自定义内容")
      assert render(view) =~ "自定义内容示例"
    end

    test "shows color examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "多彩文字提示")
      # Check for color examples
      assert render(view) =~ "Pink"
      assert render(view) =~ "Blue"
      assert render(view) =~ "Green"
    end

    test "shows controlled tooltip example", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "手动控制显示")
      assert has_element?(view, "button", "点击切换")
      
      # Toggle tooltip visibility
      view
      |> element("button", "点击切换")
      |> render_click()
      
      # Should update visibility state
      assert render(view) =~ "data-visible"
    end

    test "shows delay examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "延迟显示")
      assert render(view) =~ "延迟0.5秒显示"
      assert render(view) =~ "延迟1秒隐藏"
    end

    test "shows disabled tooltip example", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "禁用状态")
      assert render(view) =~ "禁用的提示"
    end

    test "shows practical examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "实际应用场景")
      
      # Form field helper
      assert render(view) =~ "表单字段说明"
      assert render(view) =~ "用户名"
      
      # Icon tooltips
      assert render(view) =~ "图标提示"
      
      # Ellipsis text
      assert render(view) =~ "省略文字提示"
      assert render(view) =~ "这是一段很长的文字"
    end

    test "shows arrow center example", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      assert has_element?(view, "h2", "箭头指向")
      assert render(view) =~ "箭头始终指向中心"
      assert render(view) =~ "data-arrow-point-at-center"
    end

    test "all sections are rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/tooltip")
      
      # Check all section titles
      assert html =~ "基础用法"
      assert html =~ "位置"
      assert html =~ "12个方向"
      assert html =~ "自定义内容"
      assert html =~ "多彩文字提示"
      assert html =~ "手动控制显示"
      assert html =~ "延迟显示"
      assert html =~ "禁用状态"
      assert html =~ "箭头指向"
      assert html =~ "实际应用场景"
    end

    test "interactive tooltip toggle works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/tooltip")
      
      # Initial state
      refute render(view) =~ ~s(data-visible="true")
      
      # Click to show
      view
      |> element("[phx-click=toggle_tooltip]")
      |> render_click()
      
      assert render(view) =~ ~s(data-visible="true")
      
      # Click to hide
      view
      |> element("[phx-click=toggle_tooltip]")
      |> render_click()
      
      refute render(view) =~ ~s(data-visible="true")
    end
  end
end