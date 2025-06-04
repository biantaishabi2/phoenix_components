defmodule ShopUxPhoenixWeb.Live.CascaderLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "cascader LiveView interactions" do
    test "basic cascader renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查基础级联选择器渲染
      assert html =~ "基础级联选择器"
      assert html =~ "当前选择: 无"
      assert html =~ "请选择地区"
      
      # 检查级联选择器容器
      assert html =~ "pc-cascader"
      assert html =~ "pc-cascader__trigger"
    end

    test "basic cascader selection works with events", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/cascader")
      
      # 初始状态
      assert html =~ "当前选择: 无"
      
      # 使用render_hook来发送事件
      view
      |> render_hook("basic_change", %{"value" => "zhejiang", "level" => "0"})
      
      assert render(view) =~ "当前选择: zhejiang"
    end

    test "cascader clear functionality works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 先设置一个值
      view
      |> render_hook("basic_change", %{"value" => "zhejiang", "level" => "0"})
      
      assert render(view) =~ "当前选择: zhejiang"
      
      # 清除
      view
      |> render_hook("basic_clear", %{})
      
      assert render(view) =~ "当前选择: 无"
    end

    test "multiple cascader renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查多选级联选择器
      assert html =~ "多选级联选择器"
      assert html =~ "请选择多个地区"
      assert html =~ "multiple-select"
    end

    test "multiple cascader selection works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/cascader")
      
      # 初始状态
      assert html =~ "当前选择: 无"
      
      # 发送多选事件
      view
      |> render_hook("multiple_change", %{"value" => "zhejiang", "level" => "0"})
      
      rendered = render(view)
      assert rendered =~ "zhejiang"
    end

    test "searchable cascader renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查可搜索级联选择器
      assert html =~ "可搜索级联选择器"
      assert html =~ "搜索地区"
    end

    test "searchable cascader selection works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/cascader")
      
      # 初始状态
      assert html =~ "当前选择: 无"
      
      # 发送搜索选择事件
      view
      |> render_hook("searchable_change", %{"value" => "jiangsu", "level" => "0"})
      
      assert render(view) =~ "当前选择: jiangsu"
    end

    test "different sizes display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查不同尺寸
      assert html =~ "小尺寸"
      assert html =~ "中等尺寸"
      assert html =~ "大尺寸"
      
      # 检查对应的CSS类
      assert html =~ "py-2 px-3"    # 小尺寸
      assert html =~ "py-2 px-4"    # 中等尺寸  
      assert html =~ "py-2.5 px-6"  # 大尺寸
    end

    test "disabled cascader renders correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/cascader")
      
      # 检查禁用状态
      assert html =~ "禁用状态"
      assert html =~ "已禁用"
      assert html =~ "opacity-50 cursor-not-allowed"
      
      # 确认禁用的级联选择器存在
      assert has_element?(view, "#disabled-cascader")
    end

    test "non-clearable cascader displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/cascader")
      
      # 检查不可清除选项
      assert html =~ "不可清除"
      
      # 即使有值，也不应该显示清除按钮（因为clearable=false）
      refute has_element?(view, "#no-clear-cascader .clear-button")
    end

    test "custom separator displays correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查自定义分隔符
      assert html =~ "自定义分隔符"
      # 检查分隔符样式（separator=" > "在组件中定义）
      assert html =~ "separator"
    end

    test "show last level only works correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查只显示最后一级
      assert html =~ "只显示最后一级"
      assert html =~ "西湖"
      # 不应该显示完整路径
      refute html =~ "浙江 / 杭州 / 西湖"
    end

    test "cascader dropdown panels are initially hidden", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 下拉面板应该初始隐藏
      assert has_element?(view, "#basic-cascader-dropdown.hidden")
      assert has_element?(view, "#multiple-cascader-dropdown.hidden") 
      assert has_element?(view, "#searchable-cascader-dropdown.hidden")
    end

    test "cascader structure renders correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 检查基本结构元素存在
      assert has_element?(view, ".pc-cascader")
      assert has_element?(view, ".pc-cascader__trigger")
      assert has_element?(view, ".dropdown-panel")
      assert has_element?(view, ".pc-cascader__menu")
    end

    test "cascader displays correct labels", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查选项标签在HTML中正确显示
      assert html =~ "浙江"
      assert html =~ "江苏"
      assert html =~ "杭州"
      assert html =~ "宁波"
    end

    test "cascader displays placeholders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查各种占位符文本
      assert html =~ "请选择地区"
      assert html =~ "请选择多个地区"
      assert html =~ "搜索地区"
      assert html =~ "小尺寸"
      assert html =~ "已禁用"
    end

    test "cascader shows SVG icons", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/cascader")
      
      # 检查SVG图标存在（级联选择器中有下拉箭头和右箭头）
      assert html =~ "<svg"
      assert html =~ "stroke"
    end

    test "toggle dropdown event is handled", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 发送下拉菜单切换事件
      view
      |> render_hook("toggle_dropdown", %{})
      
      # 验证事件处理没有错误
      assert render(view) =~ "基础级联选择器"
    end

    test "search event is handled correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 发送搜索事件
      view
      |> render_hook("search_cascader", %{"value" => "杭州"})
      
      # 验证搜索事件处理没有错误
      assert render(view) =~ "可搜索级联选择器"
    end

    test "multi-level path selection works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 测试多级路径选择
      view
      |> render_hook("basic_change", %{"value" => "zhejiang", "level" => "0"})
      
      assert render(view) =~ "当前选择: zhejiang"
      
      # 选择第二级
      view
      |> render_hook("basic_change", %{"value" => "hangzhou", "level" => "1"})
      
      assert render(view) =~ "当前选择: zhejiang / hangzhou"
    end

    test "cascader has proper ARIA attributes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/cascader")
      
      # 检查ARIA属性和可访问性
      assert has_element?(view, "button[type='button']")
      assert has_element?(view, ".pc-cascader__trigger")
    end
  end
end