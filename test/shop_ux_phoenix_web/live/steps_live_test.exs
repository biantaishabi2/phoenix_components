defmodule ShopUxPhoenixWeb.Live.StepsLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "steps LiveView interactions" do
    test "basic steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查基础步骤条渲染
      assert html =~ "基本步骤条"
      assert html =~ "当前步骤: 2"
      assert html =~ "已完成"
      assert html =~ "进行中"
      assert html =~ "等待中"
      
      # 检查步骤条容器
      assert html =~ "pc-steps"
      assert html =~ "pc-steps__item--current"
    end

    test "basic steps navigation works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/steps")
      
      # 初始状态 - 步骤2
      assert html =~ "当前步骤: 2"
      
      # 点击下一步
      view
      |> element("button[phx-click='basic_next']", "下一步")
      |> render_click()
      
      assert render(view) =~ "当前步骤: 3"
      
      # 点击上一步
      view
      |> element("button[phx-click='basic_prev']", "上一步")
      |> render_click()
      
      assert render(view) =~ "当前步骤: 2"
    end

    test "basic steps boundary conditions work", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/steps")
      
      # 先回到第一步
      view
      |> element("button[phx-click='basic_prev']", "上一步")
      |> render_click()
      
      assert render(view) =~ "当前步骤: 1"
      
      # 检查上一步按钮已禁用 - 应该保持在第一步
      assert has_element?(view, "button[phx-click='basic_prev'][disabled]")
      assert render(view) =~ "当前步骤: 1"
      
      # 前进到最后一步
      view
      |> element("button[phx-click='basic_next']", "下一步")
      |> render_click()
      
      view
      |> element("button[phx-click='basic_next']", "下一步")
      |> render_click()
      
      assert render(view) =~ "当前步骤: 3"
      
      # 检查下一步按钮已禁用 - 应该保持在最后一步
      assert has_element?(view, "button[phx-click='basic_next'][disabled]")
      assert render(view) =~ "当前步骤: 3"
    end

    test "clickable steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查可点击步骤条
      assert html =~ "可点击步骤条"
      assert html =~ "pc-steps--navigation"
      assert html =~ "cursor-pointer"
      assert html =~ "开始"
      assert html =~ "处理"
      assert html =~ "完成"
    end

    test "clickable steps navigation works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/steps")
      
      # 检查初始状态
      assert html =~ "可点击步骤条"
      
      # 模拟点击步骤条进行跳转
      view
      |> render_hook("step_change", %{"step" => "2"})
      
      assert render(view) =~ "当前步骤: 3"
      
      # 跳转到第一步
      view
      |> render_hook("step_change", %{"step" => "0"})
      
      assert render(view) =~ "当前步骤: 1"
    end

    test "progress steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查带进度的步骤条
      assert html =~ "带进度的步骤条"
      assert html =~ "进度: 30%"
      assert html =~ "pc-steps__progress"
      assert html =~ "width: 30%"
    end

    test "progress steps interaction works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/steps")
      
      # 初始进度
      assert html =~ "进度: 30%"
      
      # 增加进度
      view
      |> element("button", "增加进度")
      |> render_click()
      
      assert render(view) =~ "进度: 50%"
      
      # 继续增加进度直到100%
      view
      |> element("button", "增加进度")
      |> render_click()
      
      view
      |> element("button", "增加进度")
      |> render_click()
      
      view
      |> element("button", "增加进度")
      |> render_click()
      
      # 应该自动前进到下一步并重置进度
      rendered = render(view)
      assert rendered =~ "当前步骤: 3"
      assert rendered =~ "进度: 0%"
      
      # 重置进度
      view
      |> element("button", "重置进度")
      |> render_click()
      
      rendered = render(view)
      assert rendered =~ "当前步骤: 1"
      assert rendered =~ "进度: 0%"
    end

    test "error status steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查错误状态步骤条
      assert html =~ "错误状态步骤条"
      assert html =~ "状态: error"
      assert html =~ "pc-steps__item--error"
      assert html =~ "出错了"
    end

    test "error status steps interaction works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/steps")
      
      # 初始错误状态
      assert html =~ "状态: error"
      
      # 设置成功状态
      view
      |> element("button", "设置成功")
      |> render_click()
      
      assert render(view) =~ "状态: finish"
      
      # 重新设置错误状态
      view
      |> element("button", "设置错误")
      |> render_click()
      
      assert render(view) =~ "状态: error"
    end

    test "vertical steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查垂直步骤条
      assert html =~ "垂直步骤条"
      assert html =~ "pc-steps--vertical"
      assert html =~ "flex-col"
      assert html =~ "填写基本信息"
      assert html =~ "上传文件"
      assert html =~ "确认提交"
      assert html =~ "完成"
    end

    test "vertical steps navigation works", %{conn: conn} do
      {:ok, view, html} = live(conn, "/test/steps")
      
      # 初始状态 - 垂直步骤条从第1步开始
      assert html =~ "垂直步骤条"
      
      # 点击下一步
      view
      |> element("button[phx-click='vertical_next']", "下一步")
      |> render_click()
      
      assert render(view) =~ "当前步骤: 2"
      
      # 点击上一步
      view
      |> element("button[phx-click='vertical_prev']", "上一步")
      |> render_click()
      
      assert render(view) =~ "当前步骤: 1"
    end

    test "small size steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查小尺寸步骤条
      assert html =~ "小尺寸步骤条"
      assert html =~ "pc-steps--small"
      assert html =~ "w-6 h-6 text-xs"
    end

    test "dot style steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查点状步骤条
      assert html =~ "点状步骤条"
      assert html =~ "pc-steps--dot"
      assert html =~ "w-3 h-3 border-0"
      assert html =~ "完成基本信息"
      assert html =~ "确认信息"
      assert html =~ "提交"
    end

    test "icon steps renders correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查带图标的步骤条
      assert html =~ "带图标的步骤条"
      assert html =~ "登录"
      assert html =~ "验证"
      assert html =~ "完成"
      assert html =~ "用户登录"
      assert html =~ "身份验证"
      assert html =~ "注册完成"
      
      # 检查SVG图标存在
      assert html =~ "<svg"
      assert html =~ "currentColor"
    end

    test "steps display correct status classes", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查各种状态类
      assert html =~ "pc-steps__item--finish"
      assert html =~ "pc-steps__item--process"
      assert html =~ "pc-steps__item--wait"
      assert html =~ "pc-steps__item--error"
    end

    test "steps show proper completion icons", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/steps")
      
      # 检查完成步骤显示勾号图标
      assert has_element?(view, ".pc-steps__item--finish svg")
      
      # 检查错误步骤显示X图标
      assert has_element?(view, ".pc-steps__item--error svg")
    end

    test "steps have proper styling", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查Steps组件正确渲染
      assert html =~ "pc-steps"
      assert html =~ "pc-steps__item"
      assert html =~ "pc-steps__icon"
      # 检查使用Tailwind的primary颜色类
      assert html =~ "bg-primary" || html =~ "text-primary"
    end

    test "steps connectors display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查水平连接线
      assert html =~ "pc-steps__connector"
      assert html =~ "h-px"
      
      # 在垂直步骤条中检查垂直连接线
      assert html =~ "w-px"
    end

    test "steps descriptions display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查步骤描述
      assert html =~ "pc-steps__description"
      assert html =~ "这是第一步"
      assert html =~ "这是第二步"
      assert html =~ "这是第三步"
    end

    test "disabled buttons work correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/steps")
      
      # 移动到第一步，检查上一步按钮禁用
      view
      |> element("button[phx-click='basic_prev']", "上一步")
      |> render_click()
      
      # 检查上一步按钮禁用状态
      assert has_element?(view, "button[disabled]:fl-contains('上一步')")
      
      # 移动到最后一步
      view
      |> element("button[phx-click='basic_next']", "下一步")
      |> render_click()
      
      view
      |> element("button[phx-click='basic_next']", "下一步")
      |> render_click()
      
      # 检查下一步按钮禁用状态
      assert has_element?(view, "button[disabled]:fl-contains('下一步')")
    end

    test "steps numbers display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查步骤编号显示
      assert html =~ "pc-steps__number"
      # 注意：由于不同的步骤条有不同的编号，检查存在即可
    end

    test "custom CSS classes are applied", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/steps")
      
      # 检查垂直步骤条的自定义类
      assert has_element?(view, ".w-64")
    end

    test "responsive design elements are present", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查响应式设计相关类
      assert html =~ "pc-steps--responsive"
      assert html =~ "flex"
      assert html =~ "items-start"
    end

    test "all step types render without errors", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/test/steps")
      
      # 确保页面完全渲染没有错误
      assert render(view) =~ "Steps 步骤条组件交互测试"
      
      # 检查所有主要组件都存在
      assert has_element?(view, "#basic-steps")
      assert has_element?(view, "#clickable-steps")
      assert has_element?(view, "#progress-steps")
      assert has_element?(view, "#error-steps")
      assert has_element?(view, "#vertical-steps")
      assert has_element?(view, "#small-steps")
      assert has_element?(view, "#dot-steps")
      assert has_element?(view, "#icon-steps")
    end

    test "step content areas display correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查步骤内容区域
      assert html =~ "pc-steps__content"
      assert html =~ "pc-steps__title"
      assert html =~ "flex-1"
      assert html =~ "ml-3"
    end

    test "step icon wrapper displays correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/test/steps")
      
      # 检查步骤图标包装器
      assert html =~ "pc-steps__icon-wrapper"
      assert html =~ "pc-steps__icon"
      assert html =~ "rounded-full"
      assert html =~ "border-2"
      assert html =~ "transition-all"
    end
  end
end