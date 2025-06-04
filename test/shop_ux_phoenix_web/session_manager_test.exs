defmodule ShopUxPhoenixWeb.SessionManagerTest do
  use ShopUxPhoenixWeb.ConnCase
  
  alias ShopUxPhoenixWeb.SessionManager
  
  @session_options [
    store: :cookie,
    key: "_test_key",
    signing_salt: "test_salt"
  ]
  
  defp setup_session(conn) do
    conn
    |> Plug.Session.call(Plug.Session.init(@session_options))
    |> fetch_session()
  end
  
  describe "会话ID管理" do
    test "生成新会话ID" do
      conn = build_conn(:get, "/")
             |> setup_session()
             |> SessionManager.call([])
      
      session_id = get_session(conn, :session_id)
      assert is_binary(session_id)
      assert String.length(session_id) > 0
    end
    
    test "保持现有会话ID" do
      existing_id = "existing-session-123"
      
      conn = build_conn(:get, "/")
             |> setup_session()
             |> put_session(:session_id, existing_id)
             |> SessionManager.call([])
      
      assert ^existing_id = get_session(conn, :session_id)
    end
    
    test "获取会话ID辅助函数" do
      session_id = "helper-test-session"
      
      conn = build_conn(:get, "/")
             |> setup_session()
             |> put_session(:session_id, session_id)
      
      assert ^session_id = SessionManager.get_session_id(conn)
    end
    
    test "辅助函数为无会话的连接返回nil" do
      conn = build_conn(:get, "/")
             |> setup_session()
      
      assert nil == SessionManager.get_session_id(conn)
    end
    
    test "每次调用生成不同的会话ID" do
      conn1 = build_conn(:get, "/") |> setup_session() |> SessionManager.call([])
      conn2 = build_conn(:get, "/") |> setup_session() |> SessionManager.call([])
      
      session_id1 = get_session(conn1, :session_id)
      session_id2 = get_session(conn2, :session_id)
      
      assert session_id1 != session_id2
    end
  end
end