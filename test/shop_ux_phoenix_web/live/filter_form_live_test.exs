defmodule ShopUxPhoenixWeb.FilterFormLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "FilterForm Live Demo" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/filter_form")
      
      assert html =~ "FilterForm 筛选表单组件"
      assert has_element?(view, "h1", "FilterForm 筛选表单组件")
    end

    test "shows basic filter form", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 检查基础表单
      assert has_element?(view, "[data-filter-form]")
      assert has_element?(view, "input[type='search']")
      assert has_element?(view, "button", "搜索")
      assert has_element?(view, "button", "重置")
    end

    test "handles search action", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 提交表单（触发 phx-submit 事件）
      view
      |> element("#basic-filter")
      |> render_submit(%{"filters" => %{"basic_search" => "test"}})
      
      # 检查搜索结果显示
      assert render(view) =~ "搜索条件已更新"
    end

    test "handles reset action", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 使用特定表单的重置按钮
      view
      |> element("#basic-filter button[phx-click='reset']")
      |> render_click()
      
      # 检查重置结果
      assert render(view) =~ "筛选条件已重置"
    end

    test "shows different field types", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 检查不同的字段类型
      assert has_element?(view, "input[type='text']")
      assert has_element?(view, "input[type='search']")
      assert has_element?(view, "select")
      assert has_element?(view, "input[type='date']")
      assert has_element?(view, "input[type='number']")
      assert has_element?(view, "input[type='checkbox']")
    end

    test "shows collapsible filter form", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 找到可折叠的表单
      assert has_element?(view, "[data-collapsible-filter]")
      
      # 点击展开/折叠按钮
      view
      |> element("[phx-click='toggle_filter']")
      |> render_click()
      
      # 检查表单是否折叠
      assert has_element?(view, "[data-collapsed='true']")
    end

    test "shows responsive layout", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 检查响应式布局类（检查页面中是否有网格布局）
      assert render(view) =~ "grid"
    end

    test "handles export action", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/filter_form")
      
      # 点击导出按钮
      view
      |> element("#custom-actions-filter button[phx-click='export']")
      |> render_click()
      
      # 检查导出提示
      assert render(view) =~ "正在导出数据"
    end
  end
end