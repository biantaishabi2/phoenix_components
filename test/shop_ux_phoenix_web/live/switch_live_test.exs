defmodule ShopUxPhoenixWeb.SwitchLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Switch Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/switch")
      
      assert html =~ "Switch 开关组件"
      assert has_element?(view, "h1", "Switch 开关组件")
    end

    test "basic switch toggles", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Initial state should be off
      assert render(view) =~ "状态：关闭"
      
      # Click to toggle
      view
      |> element("#basic-switch")
      |> render_click()
      
      # Should now be on
      assert render(view) =~ "状态：开启"
    end

    test "switch with text renders correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      assert has_element?(view, "#text-switch")
      # Check for text content
      assert render(view) =~ "开"
    end

    test "different sizes render", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      assert has_element?(view, "#small-switch")
      assert has_element?(view, "#medium-switch")
      assert has_element?(view, "#large-switch")
    end

    test "different colors render", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      assert has_element?(view, "#primary-switch")
      assert has_element?(view, "#info-switch")
      assert has_element?(view, "#success-switch")
      assert has_element?(view, "#warning-switch")
      assert has_element?(view, "#danger-switch")
    end

    test "disabled switches render", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      assert has_element?(view, "#disabled-off")
      assert has_element?(view, "#disabled-on")
    end

    test "loading state works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Click loading switch
      view
      |> element("#loading-switch")
      |> render_click()
      
      # Should show loading state (the class is on the label, not the input)
      assert render(view) =~ "pointer-events-none"
    end

    test "notification switch toggles", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Initial state
      assert has_element?(view, "#notification-switch[checked]")
      
      # Toggle off
      view
      |> element("#notification-switch")
      |> render_click()
      
      # Should be unchecked now
      refute has_element?(view, "#notification-switch[checked]")
    end

    test "form submission works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Submit form with checkbox values
      view
      |> form("form", %{
        "form" => %{
          "enable_specs" => "true",
          "is_active" => "true",
          "allow_comments" => "true"
        }
      })
      |> render_submit()
      
      # Should show form data
      assert render(view) =~ "表单数据："
      assert render(view) =~ "表单已提交"
    end

    test "auto save switch toggles", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Initial state should be off
      refute has_element?(view, "#auto-save-switch[checked]")
      
      # Toggle on
      view
      |> element("#auto-save-switch")
      |> render_click()
      
      # Should be checked now
      assert has_element?(view, "#auto-save-switch[checked]")
    end

    test "dark mode switch toggles", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Initial state should be off
      refute has_element?(view, "#dark-mode-switch[checked]")
      
      # Toggle on
      view
      |> element("#dark-mode-switch")
      |> render_click()
      
      # Should be checked now
      assert has_element?(view, "#dark-mode-switch[checked]")
    end

    test "airplane mode switch toggles", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/switch")
      
      # Initial state should be off
      refute has_element?(view, "#airplane-mode-switch[checked]")
      
      # Toggle on
      view
      |> element("#airplane-mode-switch")
      |> render_click()
      
      # Should be checked now
      assert has_element?(view, "#airplane-mode-switch[checked]")
    end

    test "all sections are rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/switch")
      
      # Check all section titles
      assert html =~ "基础用法"
      assert html =~ "带文字和图标"
      assert html =~ "不同尺寸"
      assert html =~ "不同颜色主题"
      assert html =~ "禁用状态"
      assert html =~ "加载状态"
      assert html =~ "实际应用场景"
      assert html =~ "在表单中使用"
      assert html =~ "与 Checkbox 的对比"
    end

    test "switch vs checkbox comparison shows", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/switch")
      
      # Should show both switch and checkbox
      assert has_element?(view, "#switch-demo-1")
      assert has_element?(view, "#checkbox-demo-1")
      assert html =~ "用于触发状态改变"
      assert html =~ "用于在表单中标记选择"
    end
  end
end