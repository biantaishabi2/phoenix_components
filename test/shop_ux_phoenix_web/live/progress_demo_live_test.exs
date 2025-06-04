defmodule ShopUxPhoenixWeb.ProgressDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Progress Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/progress")
      
      assert html =~ "Progress 进度条组件"
      assert has_element?(view, "h1", "Progress 进度条组件")
    end

    test "shows basic progress examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      # Check basic examples section
      assert has_element?(view, "h2", "基础用法")
      assert has_element?(view, "[role=\"progressbar\"]")
      
      # Should have different status examples
      assert render(view) =~ "普通状态"
      assert render(view) =~ "激活状态"
      assert render(view) =~ "成功状态"
      assert render(view) =~ "异常状态"
    end

    test "shows different sizes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "不同尺寸")
      assert render(view) =~ "小尺寸"
      assert render(view) =~ "中等尺寸"
      assert render(view) =~ "大尺寸"
    end

    test "shows circle progress examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "环形进度条")
      assert has_element?(view, "svg")
      assert has_element?(view, "circle")
    end

    test "shows dynamic progress animation", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      # Find start button for dynamic progress
      assert has_element?(view, "button", "开始")
      
      # Click start button
      view
      |> element("[phx-click=\"start_progress\"]")
      |> render_click()
      
      # Should show reset button
      assert has_element?(view, "[phx-click=\"reset_progress\"]")
    end

    test "shows password strength indicator", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "密码强度指示器")
      assert has_element?(view, "input[type=\"password\"]")
      
      # Initial state should show "弱" since password_strength is 0
      
      # Type weak password
      view
      |> element("#password-form")
      |> render_change(password: %{value: "123"})
      
      # Get fresh render of the view
      html = render(view)
      
      # The password strength should show "弱"
      assert html =~ "弱"
      
      # Type medium password  
      view
      |> element("#password-form")
      |> render_change(password: %{value: "abc123"})
      
      assert render(view) =~ "中"
      
      # Type strong password
      view
      |> element("#password-form")
      |> render_change(password: %{value: "Abc123!@#"})
      
      assert render(view) =~ "强"
    end

    test "shows custom format examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "自定义格式")
      assert render(view) =~ "Days"
      assert render(view) =~ "完成"
    end

    test "shows custom colors", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "自定义颜色")
      # Check for inline styles with custom colors
      assert render(view) =~ "background-color: #87d068"
      assert render(view) =~ "background-color: #ff4d4f"
    end

    test "shows progress without info", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "不显示进度数值")
    end

    test "shows circle progress with gaps", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "环形进度条缺口")
      assert render(view) =~ "缺口在底部"
      assert render(view) =~ "缺口在左侧"
    end

    test "shows practical examples", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "实际应用场景")
      assert render(view) =~ "文件上传"
      assert render(view) =~ "批量操作"
      assert render(view) =~ "步骤进度"
    end

    test "shows gradient progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/progress")
      
      assert has_element?(view, "h2", "渐变色进度条")
      assert render(view) =~ "linear-gradient"
    end

    test "all sections are rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/progress")
      
      # Check all section titles
      assert html =~ "基础用法"
      assert html =~ "不同状态"
      assert html =~ "不同尺寸"
      assert html =~ "不显示进度数值"
      assert html =~ "自定义颜色"
      assert html =~ "自定义格式"
      assert html =~ "环形进度条"
      assert html =~ "环形尺寸"
      assert html =~ "环形进度条缺口"
      assert html =~ "动态进度"
      assert html =~ "密码强度指示器"
      assert html =~ "渐变色进度条"
      assert html =~ "实际应用场景"
    end
  end
end