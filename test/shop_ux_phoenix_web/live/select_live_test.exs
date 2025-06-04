defmodule ShopUxPhoenixWeb.Live.SelectLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "select LiveView interactions" do
    test "single select works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/select")
      
      # 初始状态
      assert html =~ "单选值: 无"
      
      # 选择一个选项
      view
      |> element("#single-select .pc-select__option[phx-value-value='beijing']")
      |> render_click()
      
      assert render(view) =~ "单选值: beijing"
    end

    test "clear button works for single select", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/select")
      
      # 先选择一个值
      view
      |> element("#single-select .pc-select__option[phx-value-value='shanghai']")
      |> render_click()
      
      assert render(view) =~ "单选值: shanghai"
      
      # 清除选择
      view
      |> element("#single-select .pc-select__clear")
      |> render_click()
      
      assert render(view) =~ "单选值: 无"
    end

    test "multiple select works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/select")
      
      # 初始状态
      assert html =~ "多选值: 无"
      
      # 选择第一个选项
      view
      |> element("#multiple-select .pc-select__option[phx-value-value='beijing']")
      |> render_click()
      
      assert render(view) =~ "多选值: beijing"
      
      # 选择第二个选项
      view
      |> element("#multiple-select .pc-select__option[phx-value-value='shanghai']")
      |> render_click()
      
      assert render(view) =~ "多选值: beijing, shanghai"
      
      # 取消选择第一个选项
      view
      |> element("#multiple-select .pc-select__option[phx-value-value='beijing']")
      |> render_click()
      
      assert render(view) =~ "多选值: shanghai"
    end

    test "search functionality updates search term", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/select")
      
      # 初始状态
      assert html =~ "搜索词: "
      
      # 输入搜索词
      view
      |> element("#searchable-select .pc-select__search")
      |> render_keyup(%{"value" => "北"})
      
      # 等待 debounce
      Process.sleep(350)
      
      assert render(view) =~ "搜索词: 北"
    end

    test "dropdown panel is initially hidden", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/select")
      
      # 下拉面板应该隐藏
      assert has_element?(view, "#single-select-dropdown.hidden")
    end

    test "grouped options render correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/select")
      
      # 检查分组标签
      assert render(view) =~ "华北"
      assert render(view) =~ "华东"
      
      # 检查分组下的选项
      assert has_element?(view, "#grouped-select .pc-select__option-group")
    end

    test "removing tags in multiple select", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/select")
      
      # 选择多个选项
      view
      |> element("#multiple-select .pc-select__option[phx-value-value='beijing']")
      |> render_click()
      
      view
      |> element("#multiple-select .pc-select__option[phx-value-value='shanghai']")
      |> render_click()
      
      assert render(view) =~ "多选值: beijing, shanghai"
      
      # 通过标签上的删除按钮移除一个选项
      view
      |> element("#multiple-select .pc-select__tag button[phx-value-value='beijing']")
      |> render_click()
      
      assert render(view) =~ "多选值: shanghai"
    end
  end
end