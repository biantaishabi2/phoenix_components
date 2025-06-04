defmodule ShopUxPhoenixWeb.FormStorage do
  @moduledoc """
  表单状态存储管理器 - 使用内存存储表单状态
  
  支持功能：
  - 表单状态的自动保存和恢复
  - 防抖机制避免频繁保存
  - 会话隔离和过期清理
  - 支持多种存储策略
  """
  
  use GenServer
  
  @default_cleanup_interval :timer.minutes(5)
  @default_session_ttl :timer.minutes(30)
  
  # Client API
  
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @doc """
  保存表单状态
  """
  def save_form_state(session_id, form_id, state) when is_binary(session_id) and is_binary(form_id) do
    GenServer.cast(__MODULE__, {:save_state, session_id, form_id, state, System.system_time(:millisecond)})
  end
  
  @doc """
  获取表单状态
  """
  def get_form_state(session_id, form_id) when is_binary(session_id) and is_binary(form_id) do
    GenServer.call(__MODULE__, {:get_state, session_id, form_id})
  end
  
  @doc """
  删除表单状态
  """
  def delete_form_state(session_id, form_id) when is_binary(session_id) and is_binary(form_id) do
    GenServer.cast(__MODULE__, {:delete_state, session_id, form_id})
  end
  
  @doc """
  清理会话
  """
  def cleanup_session(session_id) when is_binary(session_id) do
    GenServer.cast(__MODULE__, {:cleanup_session, session_id})
  end
  
  @doc """
  获取存储统计信息
  """
  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end
  
  # Server Callbacks
  
  @impl true
  def init(opts) do
    cleanup_interval = Keyword.get(opts, :cleanup_interval, @default_cleanup_interval)
    session_ttl = Keyword.get(opts, :session_ttl, @default_session_ttl)
    
    # 定时清理过期会话
    :timer.send_interval(cleanup_interval, :cleanup_expired)
    
    {:ok, %{
      sessions: %{},
      session_ttl: session_ttl,
      cleanup_interval: cleanup_interval
    }}
  end
  
  @impl true
  def handle_cast({:save_state, session_id, form_id, state, timestamp}, %{sessions: sessions} = storage) do
    # 更新会话中的表单状态
    session_data = Map.get(sessions, session_id, %{})
    form_data = %{
      state: state,
      updated_at: timestamp
    }
    
    updated_session = Map.put(session_data, form_id, form_data)
    updated_sessions = Map.put(sessions, session_id, updated_session)
    
    {:noreply, %{storage | sessions: updated_sessions}}
  end
  
  @impl true
  def handle_cast({:delete_state, session_id, form_id}, %{sessions: sessions} = storage) do
    updated_sessions = case Map.get(sessions, session_id) do
      nil -> sessions
      session_data ->
        updated_session = Map.delete(session_data, form_id)
        if map_size(updated_session) == 0 do
          Map.delete(sessions, session_id)
        else
          Map.put(sessions, session_id, updated_session)
        end
    end
    
    {:noreply, %{storage | sessions: updated_sessions}}
  end
  
  @impl true
  def handle_cast({:cleanup_session, session_id}, %{sessions: sessions} = storage) do
    updated_sessions = Map.delete(sessions, session_id)
    {:noreply, %{storage | sessions: updated_sessions}}
  end
  
  @impl true
  def handle_call({:get_state, session_id, form_id}, _from, %{sessions: sessions} = storage) do
    result = case get_in(sessions, [session_id, form_id]) do
      nil -> nil
      %{state: state} -> state
    end
    
    {:reply, result, storage}
  end
  
  @impl true
  def handle_call(:get_stats, _from, %{sessions: sessions} = storage) do
    stats = %{
      total_sessions: map_size(sessions),
      total_forms: Enum.sum(Enum.map(sessions, fn {_id, session} -> map_size(session) end)),
      memory_usage: :erlang.memory(:total)
    }
    
    {:reply, stats, storage}
  end
  
  @impl true
  def handle_info(:cleanup_expired, %{sessions: sessions, session_ttl: ttl} = storage) do
    current_time = System.system_time(:millisecond)
    cutoff_time = current_time - ttl
    
    # 清理过期的表单状态
    updated_sessions = sessions
    |> Enum.map(fn {session_id, session_data} ->
      # 过滤出未过期的表单
      active_forms = session_data
      |> Enum.filter(fn {_form_id, %{updated_at: updated_at}} ->
        updated_at > cutoff_time
      end)
      |> Enum.into(%{})
      
      {session_id, active_forms}
    end)
    |> Enum.reject(fn {_session_id, session_data} -> map_size(session_data) == 0 end)
    |> Enum.into(%{})
    
    {:noreply, %{storage | sessions: updated_sessions}}
  end
end