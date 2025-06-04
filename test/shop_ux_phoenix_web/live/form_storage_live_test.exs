defmodule ShopUxPhoenixWeb.FormStorageLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest
  
  alias ShopUxPhoenixWeb.FormStorage
  
  describe "FormBuilder 自动保存 LiveView 集成" do
    
    test "表单状态自动保存和恢复", %{conn: conn} do
      session_id = "test-auto-save-session"
      form_id = "auto-save-form"
      
      # 设置会话
      conn = conn
             |> setup_test_session()
             |> put_session(:session_id, session_id)
      
      # 清理之前的状态
      FormStorage.delete_form_state(session_id, form_id)
      
      # 启动 LiveView
      {:ok, view, html} = live(conn, ~p"/test_form")
      
      # 验证初始状态
      assert html =~ "自动保存表单测试"
      assert html =~ session_id
      
      # 模拟用户输入
      form_data = %{
        "name" => "张三",
        "email" => "zhangsan@test.com",
        "description" => "这是一个测试描述"
      }
      
      # 触发表单变化事件
      view
      |> element("form")
      |> render_change(form_data)
      
      # 等待防抖保存完成
      Process.sleep(400)
      
      # 验证数据已保存到存储
      saved_state = FormStorage.get_form_state(session_id, form_id)
      assert saved_state["name"] == "张三"
      assert saved_state["email"] == "zhangsan@test.com"
      assert saved_state["description"] == "这是一个测试描述"
    end
    
    test "表单提交时清理保存状态", %{conn: conn} do
      session_id = "test-submit-session"
      form_id = "auto-save-form"
      
      conn = conn
             |> setup_test_session()
             |> put_session(:session_id, session_id)
      
      # 预先保存一些状态
      FormStorage.save_form_state(session_id, form_id, %{"name" => "预存数据"})
      
      {:ok, view, _html} = live(conn, ~p"/test_form")
      
      # 提交表单
      view
      |> element("form")
      |> render_submit(%{"name" => "提交数据"})
      
      # 验证状态已被清理
      assert nil == FormStorage.get_form_state(session_id, form_id)
    end
    
    test "清除表单功能", %{conn: conn} do
      session_id = "test-clear-session"
      form_id = "auto-save-form"
      
      conn = conn
             |> setup_test_session()
             |> put_session(:session_id, session_id)
      
      # 预先保存状态
      FormStorage.save_form_state(session_id, form_id, %{"name" => "待清除数据"})
      
      {:ok, view, _html} = live(conn, ~p"/test_form")
      
      # 点击清除按钮
      view
      |> element("button", "清除表单")
      |> render_click()
      
      # 验证状态已被清理
      assert nil == FormStorage.get_form_state(session_id, form_id)
      
      # 验证页面显示已更新
      html = render(view)
      assert html =~ "最后保存: cleared"
    end
    
    test "防抖机制正确工作", %{conn: conn} do
      session_id = "test-debounce-session"
      form_id = "auto-save-form"
      
      conn = conn
             |> setup_test_session()
             |> put_session(:session_id, session_id)
      
      FormStorage.delete_form_state(session_id, form_id)
      
      {:ok, view, _html} = live(conn, ~p"/test_form")
      
      # 快速连续触发变化
      view |> element("form") |> render_change(%{"name" => "第一次"})
      view |> element("form") |> render_change(%{"name" => "第二次"})
      view |> element("form") |> render_change(%{"name" => "第三次"})
      
      # 在防抖时间内，应该没有保存
      Process.sleep(100)
      assert nil == FormStorage.get_form_state(session_id, form_id)
      
      # 等待防抖完成
      Process.sleep(300)
      
      # 现在应该保存了最后的值
      saved_state = FormStorage.get_form_state(session_id, form_id)
      assert saved_state["name"] == "第三次"
    end
    
    test "页面重新加载后恢复状态", %{conn: conn} do
      session_id = "test-restore-session"
      form_id = "auto-save-form"
      
      # 预先保存状态
      existing_data = %{
        "name" => "恢复的姓名",
        "email" => "restore@test.com",
        "description" => "恢复的描述"
      }
      FormStorage.save_form_state(session_id, form_id, existing_data)
      
      conn = conn
             |> setup_test_session()
             |> put_session(:session_id, session_id)
      
      # 加载页面，应该恢复状态
      {:ok, _view, html} = live(conn, ~p"/test_form")
      
      # 验证表单包含恢复的数据
      assert html =~ "恢复的姓名"
      assert html =~ "restore@test.com"
      assert html =~ "恢复的描述"
    end
  end
  
  # 辅助函数：设置测试会话
  defp setup_test_session(conn) do
    conn
    |> Plug.Session.call(Plug.Session.init([
      store: :cookie,
      key: "_test_key",
      signing_salt: "test_salt"
    ]))
    |> fetch_session()
  end
end