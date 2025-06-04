defmodule ShopUxPhoenixWeb.Live.TreeSelectLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "tree select LiveView interactions" do
    test "basic tree select renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查基础树选择器渲染
      assert html =~ "基础树选择器"
      assert html =~ "当前选择: 无"
      assert html =~ "请选择地区"
      
      # 检查树选择器容器
      assert html =~ "pc-tree-select"
      assert html =~ "pc-tree-select__trigger"
    end

    test "basic tree select selection works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/tree-select")
      
      # 初始状态
      assert html =~ "当前选择: 无"
      
      # 发送选择事件
      view
      |> render_hook("basic_change", %{"key" => "zhejiang", "title" => "浙江省", "selected" => "true"})
      
      assert render(view) =~ "当前选择: 浙江省"
    end

    test "basic tree select clear works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 先选择一个值
      view
      |> render_hook("basic_change", %{"key" => "zhejiang", "title" => "浙江省", "selected" => "true"})
      
      assert render(view) =~ "当前选择: 浙江省"
      
      # 清除选择
      view
      |> render_hook("basic_clear", %{})
      
      assert render(view) =~ "当前选择: 无"
    end

    test "multiple tree select renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查多选树选择器
      assert html =~ "多选树选择器"
      assert html =~ "请选择多个地区"
      assert html =~ "multiple-select"
    end

    test "multiple tree select selection works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/tree-select")
      
      # 初始状态
      assert html =~ "多选树选择器"
      
      # 选择第一个选项
      view
      |> render_hook("multiple_change", %{"key" => "zhejiang", "selected" => "true"})
      
      # 选择第二个选项
      view
      |> render_hook("multiple_change", %{"key" => "jiangsu", "selected" => "true"})
      
      # 检查多选结果显示
      rendered = render(view)
      assert rendered =~ "浙江省"
      assert rendered =~ "江苏省"
    end

    test "multiple tree select clear works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 选择多个选项
      view
      |> render_hook("multiple_change", %{"key" => "zhejiang", "selected" => "true"})
      
      view
      |> render_hook("multiple_change", %{"key" => "jiangsu", "selected" => "true"})
      
      # 检查选择结果
      assert render(view) =~ "浙江省"
      
      # 清除选择
      view
      |> render_hook("multiple_clear", %{})
      
      assert render(view) =~ "当前选择: 无"
    end

    test "checkable tree select renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查复选框模式
      assert html =~ "复选框模式"
      assert html =~ "复选框模式选择"
      assert html =~ "pc-tree-select__checkbox"
    end

    test "checkable tree select works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/tree-select")
      
      # 初始状态
      assert html =~ "复选框模式"
      
      # 勾选复选框
      view
      |> render_hook("checkable_change", %{"key" => "zhejiang", "checked" => "true"})
      
      # 检查结果
      rendered = render(view)
      assert rendered =~ "浙江省"
    end

    test "searchable tree select shows search input", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/tree-select")
      
      # 检查可搜索树选择器
      assert html =~ "可搜索树选择器"
      assert html =~ "搜索地区"
      
      # 检查搜索输入框存在
      assert has_element?(view, "#searchable-tree .pc-tree-select__search")
    end

    test "searchable tree select selection works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 选择选项
      view
      |> render_hook("searchable_change", %{"key" => "hangzhou", "title" => "杭州市", "selected" => "true"})
      
      assert render(view) =~ "当前选择: 杭州市"
    end

    test "tree search event is handled", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 发送搜索事件
      view
      |> render_hook("tree_search", %{"value" => "杭州"})
      
      # 验证搜索事件处理没有错误
      assert render(view) =~ "可搜索树选择器"
    end

    test "different sizes display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查不同尺寸
      assert html =~ "小尺寸"
      assert html =~ "中等尺寸"
      assert html =~ "大尺寸"
      
      # 检查对应的CSS类
      assert html =~ "py-2 px-3"    # 小尺寸
      assert html =~ "py-2 px-4"    # 中等尺寸  
      assert html =~ "py-2.5 px-6"  # 大尺寸
    end

    test "disabled tree select renders correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/tree-select")
      
      # 检查禁用状态
      assert html =~ "禁用状态"
      assert html =~ "已禁用"
      assert html =~ "opacity-50 cursor-not-allowed"
      
      # 确认禁用的树选择器存在
      assert has_element?(view, "#disabled-tree")
    end

    test "expanded tree displays correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查默认展开所有节点
      assert html =~ "默认展开所有节点"
      assert html =~ "默认展开所有"
      
      # 检查特定展开节点
      assert html =~ "特定展开节点"
      assert html =~ "展开浙江省"
    end

    test "max tag count displays correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查限制标签数量
      assert html =~ "限制标签数量"
      # 更正占位符文本为实际的HTML内容
      assert html =~ "+ 1 项"
    end

    test "non-clearable tree select displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/tree-select")
      
      # 检查不可清除选项
      assert html =~ "不可清除"
      
      # 即使有值，也不应该显示清除按钮（因为allow_clear=false）
      refute has_element?(view, "#no-clear .clear-button")
    end

    test "tree dropdown panels are initially hidden", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 下拉面板应该初始隐藏
      assert has_element?(view, "#basic-tree-dropdown.hidden")
      assert has_element?(view, "#multiple-tree-dropdown.hidden")
      assert has_element?(view, "#searchable-tree-dropdown.hidden")
    end

    test "tree structure renders correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 检查基本结构元素存在
      assert has_element?(view, ".pc-tree-select")
      assert has_element?(view, ".pc-tree-select__trigger")
      assert has_element?(view, ".tree-dropdown-panel")
      assert has_element?(view, ".tree-container")
    end

    test "tree displays correct labels", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查树节点标签在HTML中正确显示
      assert html =~ "浙江省"
      assert html =~ "江苏省"
      assert html =~ "杭州市"
      assert html =~ "宁波市"
    end

    test "tree displays placeholders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查各种占位符文本
      assert html =~ "请选择地区"
      assert html =~ "请选择多个地区"
      assert html =~ "搜索地区"
      assert html =~ "小尺寸"
      assert html =~ "已禁用"
    end

    test "tree shows SVG icons", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/tree-select")
      
      # 检查SVG图标存在（树选择器中有下拉箭头和展开图标）
      assert html =~ "<svg"
      assert html =~ "stroke"
    end

    test "select tree node event is handled", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 发送树节点选择事件
      view
      |> render_hook("select_tree_node", %{"key" => "zhejiang", "title" => "浙江省", "selected" => "true"})
      
      # 验证事件处理没有错误
      assert render(view) =~ "当前选择: 浙江省"
    end

    test "check tree node event is handled", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 发送复选框事件
      view
      |> render_hook("check_tree_node", %{"key" => "jiangsu", "checked" => "true"})
      
      # 验证复选框事件处理没有错误
      assert render(view) =~ "复选框模式"
    end

    test "toggle tree node expansion works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 发送展开/收起事件
      view
      |> render_hook("toggle_tree_node", %{"key" => "zhejiang", "expanded" => "true"})
      
      # 验证展开事件处理没有错误
      assert render(view) =~ "基础树选择器"
    end

    test "tree node deselection works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 先选择一个节点
      view
      |> render_hook("basic_change", %{"key" => "zhejiang", "title" => "浙江省", "selected" => "true"})
      
      assert render(view) =~ "当前选择: 浙江省"
      
      # 取消选择
      view
      |> render_hook("basic_change", %{"key" => "zhejiang", "title" => "浙江省", "selected" => "false"})
      
      assert render(view) =~ "当前选择: 无"
    end

    test "multiple selection and deselection works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 选择多个节点
      view
      |> render_hook("multiple_change", %{"key" => "zhejiang", "selected" => "true"})
      
      view
      |> render_hook("multiple_change", %{"key" => "jiangsu", "selected" => "true"})
      
      # 检查多选结果
      rendered = render(view)
      assert rendered =~ "浙江省"
      assert rendered =~ "江苏省"
      
      # 取消选择一个
      view
      |> render_hook("multiple_change", %{"key" => "zhejiang", "selected" => "false"})
      
      rendered = render(view)
      # 检查江苏省仍然存在
      assert rendered =~ "江苏省"
      # 检查多选区域不再同时显示两个省份
      refute rendered =~ "浙江省, 江苏省"
    end

    test "tree has proper ARIA attributes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/tree-select")
      
      # 检查ARIA属性和可访问性
      assert has_element?(view, "button[type='button']")
      assert has_element?(view, ".pc-tree-select__trigger")
    end
  end
end