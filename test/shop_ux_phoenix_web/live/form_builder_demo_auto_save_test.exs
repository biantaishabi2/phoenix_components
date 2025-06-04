defmodule ShopUxPhoenixWeb.FormBuilderDemoAutoSaveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest
  
  alias ShopUxPhoenixWeb.FormStorage
  
  describe "FormBuilder Demo 自动保存功能" do
    test "demo 页面包含自动保存部分", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # 验证自动保存部分存在
      assert html =~ "自动保存功能"
      assert html =~ "实时自动保存演示"
      assert html =~ "会话ID:"
      assert html =~ "auto-save-demo-form"
      assert html =~ "发布文章"
      assert html =~ "清除草稿"
    end
    
    test "自动保存表单字段正确渲染", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # 验证自动保存表单包含预期字段
      assert html =~ "文章标题"
      assert html =~ "作者"
      assert html =~ "文章内容"
      assert html =~ "分类"
      assert html =~ "立即发布"
      assert html =~ "开始写作吧，内容会自动保存..."
    end
    
    test "自动保存表单变化事件", %{conn: conn} do
      session_id = "demo-auto-save-test"
      
      conn = conn
             |> Plug.Test.init_test_session(%{})
             |> put_session(:session_id, session_id)
      
      # 清理之前的状态
      FormStorage.delete_form_state(session_id, "auto-save-demo-form")
      
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      # 验证初始状态
      assert html =~ "尚未保存"
      
      # 模拟表单输入
      form_data = %{
        "title" => "我的第一篇文章",
        "author" => "测试作者",
        "content" => "这是文章内容...",
        "category" => "tech"
      }
      
      # 触发自动保存表单变化
      view
      |> element("#auto-save-demo-form form")
      |> render_change(form_data)
      
      # 等待防抖保存完成
      Process.sleep(1100)
      
      # 验证数据已保存
      saved_data = FormStorage.get_form_state(session_id, "auto-save-demo-form")
      assert saved_data["title"] == "我的第一篇文章"
      assert saved_data["author"] == "测试作者"
    end
    
    test "自动保存表单提交事件", %{conn: conn} do
      session_id = "demo-submit-test"
      
      conn = conn
             |> Plug.Test.init_test_session(%{})
             |> put_session(:session_id, session_id)
      
      # 预先保存一些数据
      FormStorage.save_form_state(session_id, "auto-save-demo-form", %{"title" => "草稿文章"})
      
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # 提交表单
      view
      |> element("#auto-save-demo-form form")
      |> render_submit(%{
        "title" => "发布的文章",
        "content" => "发布内容"
      })
      
      # 验证状态已被清理
      assert nil == FormStorage.get_form_state(session_id, "auto-save-demo-form")
      
      # 验证成功消息
      assert render(view) =~ "表单提交成功，自动保存已清理！"
    end
    
    test "清除草稿功能", %{conn: conn} do
      session_id = "demo-clear-test"
      
      conn = conn
             |> Plug.Test.init_test_session(%{})
             |> put_session(:session_id, session_id)
      
      # 预先保存数据
      FormStorage.save_form_state(session_id, "auto-save-demo-form", %{
        "title" => "待清除的草稿",
        "content" => "草稿内容"
      })
      
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # 点击清除草稿按钮
      view
      |> element("button", "🗑️ 清除草稿")
      |> render_click()
      
      # 验证数据已被清理
      assert nil == FormStorage.get_form_state(session_id, "auto-save-demo-form")
      
      # 验证成功消息
      assert render(view) =~ "自动保存数据已清理！"
    end
    
    test "页面刷新后恢复自动保存数据", %{conn: conn} do
      session_id = "demo-restore-test"
      
      # 预先保存数据
      existing_data = %{
        "title" => "恢复的文章标题",
        "author" => "恢复的作者",
        "content" => "恢复的文章内容",
        "category" => "life"
      }
      FormStorage.save_form_state(session_id, "auto-save-demo-form", existing_data)
      
      conn = conn
             |> Plug.Test.init_test_session(%{})
             |> put_session(:session_id, session_id)
      
      # 加载页面
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # 验证数据已恢复到表单中
      assert html =~ "恢复的文章标题"
      assert html =~ "恢复的作者"
      assert html =~ "恢复的文章内容"
    end
    
    test "自动保存状态指示器", %{conn: conn} do
      session_id = "demo-indicator-test"
      
      conn = conn
             |> Plug.Test.init_test_session(%{})
             |> put_session(:session_id, session_id)
      
      FormStorage.delete_form_state(session_id, "auto-save-demo-form")
      
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      # 初始状态应该显示"尚未保存"
      assert html =~ "尚未保存"
      assert html =~ "bg-gray-400"
      
      # 触发表单变化
      view
      |> element("#auto-save-demo-form form")
      |> render_change(%{"title" => "测试标题"})
      
      # 等待自动保存完成
      Process.sleep(1100)
      
      # 验证保存状态更新
      updated_html = render(view)
      assert updated_html =~ "最后保存:"
      assert updated_html =~ "bg-blue-500"
    end
  end
end