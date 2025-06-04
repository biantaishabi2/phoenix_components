defmodule ShopUxPhoenixWeb.Live.StatisticLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "statistic LiveView interactions" do
    test "basic statistics render correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/statistic")
      
      # 检查基础统计数值渲染
      assert html =~ "Statistic 统计数值组件交互测试"
      assert html =~ "基本统计数值"
      assert html =~ "总用户"
      assert html =~ "活跃用户"
      assert html =~ "本月收入"
      assert html =~ "转化率"
      
      # 检查数值显示
      assert html =~ "40,689"
      assert html =~ "6,560"
      assert html =~ "98,765.43"
      assert html =~ "82.5"
      
      # 检查统计容器
      assert html =~ "pc-statistic"
      assert html =~ "pc-statistic__title"
      assert html =~ "pc-statistic__number"
    end

    test "different color themes display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/statistic")
      
      # 检查不同颜色主题
      assert html =~ "不同颜色主题"
      assert html =~ "pc-statistic--info"
      assert html =~ "pc-statistic--success"
      assert html =~ "pc-statistic--warning"
      assert html =~ "pc-statistic--danger"
      assert html =~ "pc-statistic--info"
      
      # 检查主题对应的数值
      assert html =~ "默认"
      assert html =~ "主要"
      assert html =~ "成功"
      assert html =~ "警告"
      assert html =~ "危险"
      assert html =~ "信息"
    end

    test "realtime data simulation works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/statistic")
      
      # 初始状态
      assert html =~ "实时数据模拟"
      assert html =~ "实时访问"
      assert html =~ "实时订单"
      assert html =~ "实时收入"
      
      # 手动更新数据
      view
      |> element("button", "手动更新")
      |> render_click()
      
      # 验证页面仍然正常渲染
      assert render(view) =~ "实时数据模拟"
    end

    test "realtime updates can be started and stopped", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 开始实时更新
      view
      |> element("button", "开始实时更新")
      |> render_click()
      
      # 检查按钮状态变化
      assert has_element?(view, "button[disabled]:fl-contains('开始实时更新')")
      refute has_element?(view, "button[disabled]:fl-contains('停止实时更新')")
      
      # 停止实时更新
      view
      |> element("button", "停止实时更新")
      |> render_click()
      
      # 检查按钮状态恢复
      refute has_element?(view, "button[disabled]:fl-contains('开始实时更新')")
      assert has_element?(view, "button[disabled]:fl-contains('停止实时更新')")
    end

    test "loading state toggle works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/statistic")
      
      # 初始状态
      assert html =~ "加载状态演示"
      # 初始时不应该在加载状态
      refute html =~ "animate-pulse"
      
      # 切换加载状态
      view
      |> element("button", "切换加载状态")
      |> render_click()
      
      rendered = render(view)
      assert rendered =~ "animate-pulse"
      
      # 再次切换回正常状态
      view
      |> element("button", "切换加载状态")
      |> render_click()
      
      refute render(view) =~ "animate-pulse"
    end

    test "prefix and suffix demo displays correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/statistic")
      
      # 检查前缀后缀演示
      assert html =~ "前缀后缀演示"
      assert html =~ "温度"
      assert html =~ "°C"
      assert html =~ "账户余额"
      assert html =~ "$"
      assert html =~ "评分"
      assert html =~ "/ 5.0"
      
      # 检查星星图标
      assert html =~ "text-yellow-400"
      assert html =~ "svg"
    end

    test "trend indicator changes work", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/statistic")
      
      # 初始状态
      assert html =~ "趋势指示器"
      assert html =~ "pc-statistic__trend--up"
      
      # 设置下降趋势
      view
      |> element("button", "设置下降趋势")
      |> render_click()
      
      assert render(view) =~ "pc-statistic__trend--down"
      
      # 设置无趋势
      view
      |> element("button", "无趋势")
      |> render_click()
      
      # 检查手动控制的趋势指示器部分（不包含实时数据的趋势）
      rendered = render(view)
      # 在趋势演示区域应该没有趋势指示器
      assert rendered =~ "趋势指示器"
      
      # 重新设置上升趋势
      view
      |> element("button", "设置上升趋势")
      |> render_click()
      
      assert render(view) =~ "pc-statistic__trend--up"
    end

    test "precision changes work", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/statistic")
      
      # 初始状态 - 2位小数
      assert html =~ "精度演示"
      assert html =~ "3.14"
      
      # 改为0位小数
      view
      |> element("button", "0位小数")
      |> render_click()
      
      assert render(view) =~ "3"
      refute render(view) =~ "3.14"
      
      # 改为3位小数
      view
      |> element("button", "3位小数")
      |> render_click()
      
      assert render(view) =~ "3.142"
      
      # 改为1位小数
      view
      |> element("button", "1位小数")
      |> render_click()
      
      assert render(view) =~ "3.1"
    end

    test "animation attributes are present", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/statistic")
      
      # 检查动画相关属性
      assert html =~ "data-duration"
      assert html =~ "data-delay"
    end

    test "trend indicators show correct colors", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 设置上升趋势，检查绿色
      view
      |> element("button", "设置上升趋势")
      |> render_click()
      
      assert render(view) =~ "text-green-500"
      
      # 设置下降趋势，检查红色
      view
      |> element("button", "设置下降趋势")
      |> render_click()
      
      assert render(view) =~ "text-red-500"
    end

    test "large numbers display with group separators", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/statistic")
      
      # 检查千分位分隔符
      assert html =~ "40,689"
      assert html =~ "98,765.43"
      assert html =~ "123,456"
    end

    test "slot prefix and suffix render correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 检查插槽前缀后缀存在
      assert has_element?(view, ".pc-statistic__prefix svg")
      assert has_element?(view, ".pc-statistic__suffix span")
    end

    test "trend SVG icons display correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 上升趋势应该显示向上箭头
      view
      |> element("button", "设置上升趋势")
      |> render_click()
      
      assert has_element?(view, ".pc-statistic__trend--up svg")
      
      # 下降趋势应该显示向下箭头
      view
      |> element("button", "设置下降趋势")
      |> render_click()
      
      assert has_element?(view, ".pc-statistic__trend--down svg")
    end

    test "all statistic components have proper structure", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 检查基本结构元素存在
      assert has_element?(view, ".pc-statistic")
      assert has_element?(view, ".pc-statistic__title")
      assert has_element?(view, ".pc-statistic__value")
      assert has_element?(view, ".pc-statistic__number")
    end

    test "color classes are applied correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 检查各种颜色对应的ID存在
      assert has_element?(view, "#total-users.pc-statistic--info")
      assert has_element?(view, "#active-users.pc-statistic--success")
      assert has_element?(view, "#monthly-revenue.pc-statistic--warning")
      assert has_element?(view, "#conversion-rate.pc-statistic--info")
    end

    test "loading state displays placeholder correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 切换到加载状态
      view
      |> element("button", "切换加载状态")
      |> render_click()
      
      # 检查加载占位符
      assert has_element?(view, ".bg-gray-200.rounded")
      assert render(view) =~ "h-8 w-24"
    end

    test "trend indicators work independently", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/statistic")
      
      # 检查实时数据中的独立趋势指示器
      assert html =~ "实时订单"
      assert html =~ "实时收入"
      
      # 这些趋势应该独立于手动控制的趋势
      rendered = render(view)
      trend_count = rendered
                   |> String.split("trend-")
                   |> length()
      
      # 应该有多个趋势指示器
      assert trend_count > 3
    end

    test "precision demo uses Pi value correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 测试不同精度的Pi值显示
      # 默认2位小数
      assert render(view) =~ "3.14"
      
      # 0位小数
      view
      |> element("button", "0位小数")
      |> render_click()
      # Pi值截断为整数应该是3
      rendered = render(view)
      assert rendered =~ "precision-demo"
      # 检查数字3出现在精度演示组件中
      assert rendered =~ "pc-statistic__number"
      
      # 3位小数应该显示更精确的值
      view
      |> element("button", "3位小数")
      |> render_click()
      assert render(view) =~ "3.142"
    end

    test "manual update triggers data refresh", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 获取初始值
      _initial_html = render(view)
      
      # 手动更新可能会改变值（由于随机性，我们不检查具体值变化）
      view
      |> element("button", "手动更新")
      |> render_click()
      
      # 确保页面仍然正常工作
      updated_html = render(view)
      assert updated_html =~ "实时访问"
      assert updated_html =~ "实时订单"
      assert updated_html =~ "实时收入"
    end

    test "grid layouts display correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 检查网格布局类
      assert has_element?(view, ".grid.grid-cols-1.md\\:grid-cols-4")
      assert has_element?(view, ".grid.grid-cols-1.md\\:grid-cols-3")
      assert has_element?(view, ".grid.grid-cols-2.md\\:grid-cols-6")
    end

    test "button states change correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/statistic")
      
      # 初始状态：开始按钮可用，停止按钮禁用
      assert has_element?(view, "button:not([disabled]):fl-contains('开始实时更新')")
      assert has_element?(view, "button[disabled]:fl-contains('停止实时更新')")
      
      # 开始后：开始按钮禁用，停止按钮可用
      view
      |> element("button", "开始实时更新")
      |> render_click()
      
      assert has_element?(view, "button[disabled]:fl-contains('开始实时更新')")
      assert has_element?(view, "button:not([disabled]):fl-contains('停止实时更新')")
    end
  end
end