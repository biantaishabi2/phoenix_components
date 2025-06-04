defmodule ShopUxPhoenixWeb.Live.TableLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "table LiveView interactions" do
    test "selection works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/table")
      
      # 初始状态
      assert html =~ "选中: 0 项"
      
      # 选择第一行 - 使用 basic-table 的选择框
      view
      |> element("#basic-table input[type='checkbox'][value='1']")
      |> render_click()
      
      assert render(view) =~ "选中: 1 项"
      
      # 全选 - 使用 basic-table 的全选框
      view
      |> element("#basic-table input[data-select-all]")
      |> render_click()
      
      assert render(view) =~ "选中: 6 项"  # 现在有6个产品
    end

    test "pagination works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/table")
      
      # 初始页面
      assert html =~ "当前页: 1"
      
      # 点击第2页 - 使用更具体的选择器
      view
      |> element("button", "2")
      |> render_click()
      
      assert render(view) =~ "当前页: 2"
    end

    test "sorting works correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/table")
      
      # 初始状态
      assert html =~ "排序:  "
      
      # 点击名称排序 - 使用 basic-table 的排序按钮
      view
      |> element("#basic-table button[phx-click='sort'][phx-value-field='name']")
      |> render_click()
      
      assert render(view) =~ "排序: name asc"
      
      # 再次点击切换排序顺序
      view
      |> element("#basic-table button[phx-click='sort'][phx-value-field='name']")
      |> render_click()
      
      assert render(view) =~ "排序: name desc"
    end
  end

  describe "table LiveView with width and ellipsis features" do
    test "renders column width attributes correctly in LiveView", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/table")
      
      # 检查列宽控制演示部分
      assert html =~ "列宽控制演示"
      
      # 检查数字宽度（像素）
      assert html =~ ~r/style="[^"]*width:\s*60px/
      assert html =~ ~r/style="[^"]*width:\s*200px/
      
      # 检查百分比宽度
      assert html =~ ~r/style="[^"]*width:\s*40%/
      
      # 检查响应式宽度（min/max）
      assert html =~ "响应式宽度演示"
      assert html =~ ~r/min-width:\s*150px/
      assert html =~ ~r/max-width:\s*250px/
    end

    test "renders ellipsis attributes correctly in LiveView", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/table")
      
      # 检查文本省略演示部分
      assert html =~ "文本省略演示"
      
      # 检查 ellipsis CSS 类
      assert html =~ "pc-table__cell--ellipsis"
      
      # 检查 ellipsis 配合宽度使用
      assert html =~ "ellipsis-demo-table"
    end

    test "width and ellipsis work together in LiveView", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/table")
      
      # 在完整功能演示中检查
      assert html =~ "full-feature-table"
      
      # 应该同时有 width 样式和 ellipsis 类
      assert html =~ ~r/style="[^"]*width:\s*180px/
      assert html =~ "pc-table__cell--ellipsis"
    end

    test "LiveView interactions work with width columns", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/table")
      
      # 初始状态检查
      assert html =~ "iPhone 15 Pro Max"
      
      # 使用第二个表格的选择功能（basic-table）
      view
      |> element("#basic-table input[type='checkbox'][value='1']")
      |> render_click()
      
      updated_html = render(view)
      assert updated_html =~ "选中: 1 项"
      # 宽度样式应该保持不变
      assert updated_html =~ ~r/style="[^"]*width:\s*60px/
    end

    test "LiveView interactions work with ellipsis columns", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/table")
      
      # 在基础表格上测试排序功能
      view
      |> element("#basic-table button[phx-click='sort'][phx-value-field='name']")
      |> render_click()
      
      updated_html = render(view)
      assert updated_html =~ "排序: name asc"
      # 省略样式应该保持不变
      assert updated_html =~ "pc-table__cell--ellipsis"
    end

    test "pagination preserves column styling", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/table")
      
      # 检查完整功能演示的分页
      assert html =~ "当前页: 1"
      
      # 切换到第二页 - 使用带有文本 "2" 的按钮
      view
      |> element("button", "2")
      |> render_click()
      
      updated_html = render(view)
      assert updated_html =~ "当前页: 2"
      # 样式在新页面应该保持
      assert updated_html =~ ~r/style="[^"]*width:\s*180px/
      assert updated_html =~ "pc-table__cell--ellipsis"
    end

    test "responsive width behavior in LiveView", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/table")
      
      # 检查响应式宽度演示部分
      assert html =~ "响应式宽度演示"
      assert html =~ "responsive-demo-table"
      
      # 检查响应式宽度属性
      assert html =~ ~r/min-width:\s*150px/
      assert html =~ ~r/max-width:\s*250px/
      assert html =~ ~r/min-width:\s*200px/
    end
  end

  describe "table LiveView with fixed columns" do
    test "renders fixed columns in demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/table")
      
      # 检查固定列演示部分存在
      assert html =~ "固定列演示"
      assert html =~ "左固定列"
      assert html =~ "右固定列"
      assert html =~ "左右固定列组合"
      
      # 检查左固定列表格 (left-fixed-table)
      assert html =~ "left-fixed-table"
      assert html =~ "pc-table__cell--fixed-left"
      
      # 检查右固定列表格 (right-fixed-table)
      assert html =~ "right-fixed-table"
      assert html =~ "pc-table__cell--fixed-right"
      
      # 检查混合固定列表格 (mixed-fixed-table)
      assert html =~ "mixed-fixed-table"
      assert html =~ "pc-table--has-fix-left"
      assert html =~ "pc-table--has-fix-right"
    end

    test "fixed columns have correct styles", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/table")
      
      # 检查固定列的宽度样式
      assert html =~ ~r/style="[^"]*width:\s*60px/
      assert html =~ ~r/style="[^"]*width:\s*180px/
      assert html =~ ~r/style="[^"]*width:\s*100px/
      
      # 检查固定列的位置样式
      assert html =~ ~r/style="[^"]*left:\s*0px/
      assert html =~ ~r/style="[^"]*right:\s*0px/
    end

    test "fixed columns work with other features", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/table")
      
      # 检查完整功能演示表格有固定列
      assert html =~ "full-feature-table"
      assert html =~ "pc-table__cell--fixed-left"
      assert html =~ "pc-table__cell--fixed-right"
      
      # 测试排序功能（在固定列上）
      view
      |> element("#full-feature-table button[phx-click='sort'][phx-value-field='id']")
      |> render_click()
      
      updated_html = render(view)
      assert updated_html =~ "排序: id asc"
      # 固定列样式应该保持
      assert updated_html =~ "pc-table__cell--fixed-left"
      
      # 测试选择功能
      view
      |> element("#full-feature-table input[type='checkbox'][value='1']")
      |> render_click()
      
      updated_html = render(view)
      assert updated_html =~ "选中: 1 项"
      # 固定列样式应该保持
      assert updated_html =~ "pc-table__cell--fixed-right"
    end
  end
end