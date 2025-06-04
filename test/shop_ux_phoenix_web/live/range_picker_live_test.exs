defmodule ShopUxPhoenixWeb.Live.RangePickerLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "range picker LiveView interactions" do
    test "basic range selection works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/range-picker")
      
      # 初始状态
      assert html =~ "基础范围: 无"
      
      # 选择开始日期
      view
      |> element("#basic-range button[phx-value-date='2024-01-01'][phx-value-position='start']")
      |> render_click()
      
      assert render(view) =~ "基础范围: 2024-01-01 ~ 无"
      
      # 选择结束日期
      view
      |> element("#basic-range button[phx-value-date='2024-01-31'][phx-value-position='end']")
      |> render_click()
      
      assert render(view) =~ "基础范围: 2024-01-01 ~ 2024-01-31"
    end

    test "clear button works for basic range", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/range-picker")
      
      # 先选择一个范围
      view
      |> element("#basic-range button[phx-value-date='2024-01-01'][phx-value-position='start']")
      |> render_click()
      
      view
      |> element("#basic-range button[phx-value-date='2024-01-31'][phx-value-position='end']")
      |> render_click()
      
      assert render(view) =~ "基础范围: 2024-01-01 ~ 2024-01-31"
      
      # 清除范围
      view
      |> element("#basic-range .pc-range-picker__clear")
      |> render_click()
      
      assert render(view) =~ "基础范围: 无"
    end

    test "preset range selection works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/range-picker")
      
      # 初始状态
      assert html =~ "预设范围: 无"
      
      # 点击"今天"快捷选项
      today = Date.utc_today() |> Date.to_string()
      view
      |> element("#preset-range button", "今天")
      |> render_click()
      
      assert render(view) =~ "预设范围: #{today} ~ #{today}"
    end

    test "preset range shortcuts are visible", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/range-picker")
      
      # 检查快捷选项
      assert html =~ "今天"
      assert html =~ "最近7天"
      assert html =~ "最近30天"
      assert html =~ "本月"
      
      # 检查shortcuts容器
      assert has_element?(view, "#preset-range .pc-range-picker__shortcuts")
    end

    test "time range picker shows time inputs", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/range-picker")
      
      # 初始状态
      assert html =~ "时间范围: 无"
      
      # 检查时间选择器是否显示
      assert html =~ "pc-range-picker__time"
    end

    test "range picker panels are initially hidden", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/range-picker")
      
      # 开始和结束面板应该隐藏
      assert has_element?(view, "#basic-range-start-panel.hidden")
      assert has_element?(view, "#basic-range-end-panel.hidden")
    end

    test "different picker types render correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/range-picker")
      
      # 检查基础日期选择器类型
      assert has_element?(view, "#basic-range .picker-type-date")
    end

    test "range format displays correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/range-picker")
      
      # 选择范围后检查格式
      view
      |> element("#basic-range button[phx-value-date='2024-01-01'][phx-value-position='start']")
      |> render_click()
      
      view
      |> element("#basic-range button[phx-value-date='2024-01-31'][phx-value-position='end']")
      |> render_click()
      
      # 检查显示格式包含分隔符
      assert render(view) =~ "2024-01-01 ~ 2024-01-31"
    end

    test "clear functionality works for all range types", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/range-picker")
      
      # 设置预设范围
      today = Date.utc_today() |> Date.to_string()
      view
      |> element("#preset-range button", "今天")
      |> render_click()
      
      assert render(view) =~ "预设范围: #{today} ~ #{today}"
      
      # 清除预设范围
      view
      |> element("#preset-range .pc-range-picker__clear")
      |> render_click()
      
      assert render(view) =~ "预设范围: 无"
    end

    test "range inputs show correct placeholders", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/range-picker")
      
      # 检查占位符文本
      assert html =~ "开始日期"
      assert html =~ "结束日期"
      assert html =~ "开始时间"
      assert html =~ "结束时间"
    end

    test "range separator is displayed correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/range-picker")
      
      # 检查分隔符
      assert html =~ " ~ "
      
      # 检查分隔符容器
      assert has_element?(view, ".separator")
    end
  end
end