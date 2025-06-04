defmodule ShopUxPhoenixWeb.Live.DatePickerLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "date picker LiveView interactions" do
    test "calendar panel is initially hidden", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/date-picker")
      
      # 初始状态 - 面板应该隐藏
      assert html =~ "面板状态: 关闭"
      assert has_element?(view, "#test-date-picker-panel")
      assert html =~ ~s(class="pc-date-picker__panel) && html =~ ~s(hidden)
    end

    test "selecting a date updates the value", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/date-picker")
      
      # 初始状态
      assert html =~ "选中日期: 无"
      
      # 模拟选择日期
      view
      |> element("button[phx-value-date='2024-01-15']")
      |> render_click()
      
      # 检查日期是否更新
      assert render(view) =~ "选中日期: 2024-01-15"
    end

    test "clearing date works when clearable", %{conn: conn} do
      # 先设置一个日期
      {:ok, view, _html} = live(conn, "/test/date-picker")
      
      # 选择一个日期
      view
      |> element("button[phx-value-date='2024-01-15']") 
      |> render_click()
      
      assert render(view) =~ "选中日期: 2024-01-15"
      
      # 点击清除按钮
      view
      |> element(".pc-date-picker__clear")
      |> render_click()
      
      assert render(view) =~ "选中日期: 无"
    end

    test "shortcuts work correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/date-picker")
      
      # 应该显示快捷选项
      assert html =~ "今天"
      assert html =~ "昨天"
      assert html =~ "一周前"
      
      # 点击今天快捷选项 - 使用更具体的选择器
      today = Date.utc_today()
      
      view
      |> element(".pc-date-picker__shortcuts button", "今天")
      |> render_click()
      
      assert render(view) =~ "选中日期: #{Date.to_string(today)}"
    end

    test "month navigation buttons are present", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/date-picker")
      
      # 检查导航按钮存在
      assert has_element?(view, ".pc-date-picker__header button")
      
      # 检查月份显示
      assert render(view) =~ "2024年1月"
    end

    test "today button is shown by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/date-picker")
      
      # 检查今天按钮
      assert has_element?(view, ".pc-date-picker__today")
      assert render(view) =~ "今天"
    end
  end
end