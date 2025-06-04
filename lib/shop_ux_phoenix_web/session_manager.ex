defmodule ShopUxPhoenixWeb.SessionManager do
  @moduledoc """
  会话管理 Plug - 自动生成和管理用户会话ID
  
  功能：
  - 自动为每个用户生成唯一会话ID
  - 在用户会话中保持会话ID
  - 提供会话ID访问的辅助函数
  """
  
  import Plug.Conn
  
  @session_key :session_id
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    session_id = get_session(conn, @session_key) || generate_session_id()
    put_session(conn, @session_key, session_id)
  end
  
  @doc """
  获取当前连接的会话ID
  """
  def get_session_id(conn) do
    get_session(conn, @session_key)
  end
  
  # 生成新的会话ID
  defp generate_session_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end