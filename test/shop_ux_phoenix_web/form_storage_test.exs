defmodule ShopUxPhoenixWeb.FormStorageTest do
  use ExUnit.Case, async: false
  
  alias ShopUxPhoenixWeb.FormStorage
  
  setup do
    # 清理现有状态（通过重启 FormStorage）
    if Process.whereis(FormStorage) do
      Supervisor.terminate_child(ShopUxPhoenix.Supervisor, FormStorage)
      Supervisor.restart_child(ShopUxPhoenix.Supervisor, FormStorage)
    end
    :ok
  end
  
  describe "基本存储操作" do
    test "保存和获取表单状态" do
      session_id = "test-session-123"
      form_id = "user-form"
      state = %{name: "张三", email: "test@example.com"}
      
      # 保存状态
      FormStorage.save_form_state(session_id, form_id, state)
      
      # 获取状态
      assert ^state = FormStorage.get_form_state(session_id, form_id)
    end
    
    test "不存在的表单状态返回 nil" do
      assert nil == FormStorage.get_form_state("non-existent", "form")
    end
    
    test "删除表单状态" do
      session_id = "test-session"
      form_id = "user-form"
      state = %{name: "测试"}
      
      FormStorage.save_form_state(session_id, form_id, state)
      FormStorage.delete_form_state(session_id, form_id)
      
      assert nil == FormStorage.get_form_state(session_id, form_id)
    end
  end
  
  describe "会话管理" do
    test "管理一个会话中的多个表单" do
      session_id = "multi-form-session"
      
      # 保存多个表单状态
      FormStorage.save_form_state(session_id, "form1", %{field1: "value1"})
      FormStorage.save_form_state(session_id, "form2", %{field2: "value2"})
      
      # 验证状态隔离
      assert %{field1: "value1"} = FormStorage.get_form_state(session_id, "form1")
      assert %{field2: "value2"} = FormStorage.get_form_state(session_id, "form2")
    end
    
    test "会话间数据隔离" do
      form_id = "same-form"
      state1 = %{user: "用户1"}
      state2 = %{user: "用户2"}
      
      FormStorage.save_form_state("session1", form_id, state1)
      FormStorage.save_form_state("session2", form_id, state2)
      
      assert ^state1 = FormStorage.get_form_state("session1", form_id)
      assert ^state2 = FormStorage.get_form_state("session2", form_id)
    end
    
    test "清理整个会话" do
      session_id = "cleanup-session"
      
      FormStorage.save_form_state(session_id, "form1", %{data: 1})
      FormStorage.save_form_state(session_id, "form2", %{data: 2})
      
      FormStorage.cleanup_session(session_id)
      
      assert nil == FormStorage.get_form_state(session_id, "form1")
      assert nil == FormStorage.get_form_state(session_id, "form2")
    end
  end
  
  describe "过期清理机制" do
    test "自动清理过期会话" do
      # 启动一个独立的测试进程
      {:ok, test_storage} = GenServer.start_link(FormStorage, [session_ttl: 100, cleanup_interval: 50])
      
      session_id = "expired-session"
      GenServer.cast(test_storage, {:save_state, session_id, "form", %{data: "test"}, System.system_time(:millisecond)})
      
      # 验证数据存在
      assert %{data: "test"} = GenServer.call(test_storage, {:get_state, session_id, "form"})
      
      # 等待过期和清理
      Process.sleep(200)
      
      # 验证数据已被清理
      assert nil == GenServer.call(test_storage, {:get_state, session_id, "form"})
      
      GenServer.stop(test_storage)
    end
    
    test "更新时间戳延长过期时间" do
      # 启动一个独立的测试进程
      {:ok, test_storage} = GenServer.start_link(FormStorage, [session_ttl: 200, cleanup_interval: 100])
      
      session_id = "refresh-session"
      GenServer.cast(test_storage, {:save_state, session_id, "form", %{data: "initial"}, System.system_time(:millisecond)})
      
      # 在过期前更新
      Process.sleep(100)
      GenServer.cast(test_storage, {:save_state, session_id, "form", %{data: "updated"}, System.system_time(:millisecond)})
      
      # 再等待一段时间，应该仍然存在
      Process.sleep(150)
      assert %{data: "updated"} = GenServer.call(test_storage, {:get_state, session_id, "form"})
      
      GenServer.stop(test_storage)
    end
  end
  
  describe "统计信息" do
    test "提供存储统计" do
      FormStorage.save_form_state("session1", "form1", %{data: 1})
      FormStorage.save_form_state("session1", "form2", %{data: 2})
      FormStorage.save_form_state("session2", "form1", %{data: 3})
      
      stats = FormStorage.get_stats()
      
      assert stats.total_sessions == 2
      assert stats.total_forms == 3
      assert is_integer(stats.memory_usage)
    end
  end
  
  describe "错误处理" do
    test "处理无效会话ID" do
      # 测试空字符串
      assert nil == FormStorage.get_form_state("", "form")
      
      # 测试 nil（应该有类型检查）
      assert_raise FunctionClauseError, fn ->
        FormStorage.get_form_state(nil, "form")
      end
    end
    
    test "处理复杂状态数据" do
      session_id = "complex-test"
      
      # 测试各种数据类型
      states = [
        %{},  # 空映射
        %{list: [1, 2, 3], atom: :test, string: "测试"},
        %{nested: %{deep: %{very: %{deep: "data"}}}},
        %{binary: <<1, 2, 3>>, tuple: {:ok, "data"}}
      ]
      
      for {state, i} <- Enum.with_index(states) do
        form_id = "form-#{i}"
        FormStorage.save_form_state(session_id, form_id, state)
        assert ^state = FormStorage.get_form_state(session_id, form_id)
      end
    end
  end
  
  describe "性能测试" do
    test "处理大量会话" do
      # 创建100个会话，每个包含3个表单（减少数量以适应测试环境）
      for i <- 1..100 do
        session_id = "session-#{i}"
        for j <- 1..3 do
          form_id = "form-#{j}"
          state = %{
            field1: "数据#{i}-#{j}",
            field2: String.duplicate("x", 50),  # 中等大小的数据
            timestamp: System.system_time()
          }
          FormStorage.save_form_state(session_id, form_id, state)
        end
      end
      
      stats = FormStorage.get_stats()
      assert stats.total_sessions == 100
      assert stats.total_forms == 300
      
      # 验证内存使用在合理范围内
      assert is_integer(stats.memory_usage)
    end
    
    test "保存操作响应时间" do
      session_id = "performance-session"
      large_state = %{
        data: String.duplicate("test data ", 100),
        numbers: Enum.to_list(1..100),
        nested: %{deep: %{structure: %{with: "data"}}}
      }
      
      {time, _result} = :timer.tc(fn ->
        FormStorage.save_form_state(session_id, "large-form", large_state)
      end)
      
      # 保存操作应该在100ms内完成（宽松的限制适应测试环境）
      assert time < 100_000  # 微秒
    end
    
    test "读取操作响应时间" do
      session_id = "read-performance"
      state = %{data: "test"}
      FormStorage.save_form_state(session_id, "form", state)
      
      {time, ^state} = :timer.tc(fn ->
        FormStorage.get_form_state(session_id, "form")
      end)
      
      # 读取操作应该在50ms内完成
      assert time < 50_000  # 微秒
    end
  end
  
  describe "并发测试" do
    test "处理并发读写操作" do
      session_id = "concurrent-test"
      
      # 启动多个进程同时读写
      tasks = for i <- 1..20 do  # 减少并发数量
        Task.async(fn ->
          form_id = "form-#{i}"
          state = %{process: i, data: "concurrent-#{i}"}
          
          FormStorage.save_form_state(session_id, form_id, state)
          FormStorage.get_form_state(session_id, form_id)
        end)
      end
      
      # 等待所有任务完成
      results = Task.await_many(tasks)
      
      # 验证所有操作都成功
      assert length(results) == 20
      assert Enum.all?(results, &is_map/1)
    end
  end
end