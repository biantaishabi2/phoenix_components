# FormStorage 测试用例文档

## 测试概述

本文档定义了表单状态持久化功能的完整测试场景，包括单元测试、集成测试和性能测试。

## 1. FormStorage 单元测试

### 1.1 基本存储操作

**测试场景：保存和获取表单状态**
```elixir
test "saves and retrieves form state" do
  session_id = "test-session-123"
  form_id = "user-form"
  state = %{name: "张三", email: "test@example.com"}
  
  # 保存状态
  :ok = FormStorage.save_form_state(session_id, form_id, state)
  
  # 获取状态
  assert ^state = FormStorage.get_form_state(session_id, form_id)
end
```

**测试场景：不存在的表单状态返回 nil**
```elixir
test "returns nil for non-existent form state" do
  assert nil == FormStorage.get_form_state("non-existent", "form")
end
```

**测试场景：删除表单状态**
```elixir
test "deletes form state" do
  session_id = "test-session"
  form_id = "user-form"
  state = %{name: "测试"}
  
  FormStorage.save_form_state(session_id, form_id, state)
  FormStorage.delete_form_state(session_id, form_id)
  
  assert nil == FormStorage.get_form_state(session_id, form_id)
end
```

### 1.2 会话管理

**测试场景：多表单状态管理**
```elixir
test "manages multiple forms in one session" do
  session_id = "multi-form-session"
  
  # 保存多个表单状态
  FormStorage.save_form_state(session_id, "form1", %{field1: "value1"})
  FormStorage.save_form_state(session_id, "form2", %{field2: "value2"})
  
  # 验证状态隔离
  assert %{field1: "value1"} = FormStorage.get_form_state(session_id, "form1")
  assert %{field2: "value2"} = FormStorage.get_form_state(session_id, "form2")
end
```

**测试场景：会话间数据隔离**
```elixir
test "isolates data between sessions" do
  form_id = "same-form"
  state1 = %{user: "用户1"}
  state2 = %{user: "用户2"}
  
  FormStorage.save_form_state("session1", form_id, state1)
  FormStorage.save_form_state("session2", form_id, state2)
  
  assert ^state1 = FormStorage.get_form_state("session1", form_id)
  assert ^state2 = FormStorage.get_form_state("session2", form_id)
end
```

**测试场景：清理整个会话**
```elixir
test "cleans up entire session" do
  session_id = "cleanup-session"
  
  FormStorage.save_form_state(session_id, "form1", %{data: 1})
  FormStorage.save_form_state(session_id, "form2", %{data: 2})
  
  FormStorage.cleanup_session(session_id)
  
  assert nil == FormStorage.get_form_state(session_id, "form1")
  assert nil == FormStorage.get_form_state(session_id, "form2")
end
```

### 1.3 过期清理机制

**测试场景：自动清理过期会话**
```elixir
test "automatically cleans up expired sessions" do
  # 使用短过期时间进行测试
  start_supervised({FormStorage, [session_ttl: 100, cleanup_interval: 50]})
  
  session_id = "expired-session"
  FormStorage.save_form_state(session_id, "form", %{data: "test"})
  
  # 验证数据存在
  assert %{data: "test"} = FormStorage.get_form_state(session_id, "form")
  
  # 等待过期
  Process.sleep(200)
  
  # 验证数据已被清理
  assert nil == FormStorage.get_form_state(session_id, "form")
end
```

**测试场景：更新时间戳延长过期时间**
```elixir
test "updates timestamp extends expiration" do
  start_supervised({FormStorage, [session_ttl: 200, cleanup_interval: 100]})
  
  session_id = "refresh-session"
  FormStorage.save_form_state(session_id, "form", %{data: "initial"})
  
  # 在过期前更新
  Process.sleep(100)
  FormStorage.save_form_state(session_id, "form", %{data: "updated"})
  
  # 再等待一段时间，应该仍然存在
  Process.sleep(150)
  assert %{data: "updated"} = FormStorage.get_form_state(session_id, "form")
end
```

### 1.4 统计信息

**测试场景：获取存储统计**
```elixir
test "provides storage statistics" do
  FormStorage.save_form_state("session1", "form1", %{data: 1})
  FormStorage.save_form_state("session1", "form2", %{data: 2})
  FormStorage.save_form_state("session2", "form1", %{data: 3})
  
  stats = FormStorage.get_stats()
  
  assert stats.total_sessions == 2
  assert stats.total_forms == 3
  assert is_integer(stats.memory_usage)
end
```

## 2. SessionManager 单元测试

### 2.1 会话ID管理

**测试场景：生成新会话ID**
```elixir
test "generates new session ID" do
  conn = build_conn(:get, "/")
  conn = SessionManager.call(conn, [])
  
  session_id = get_session(conn, :session_id)
  assert is_binary(session_id)
  assert String.length(session_id) > 0
end
```

**测试场景：保持现有会话ID**
```elixir
test "preserves existing session ID" do
  existing_id = "existing-session-123"
  
  conn = build_conn(:get, "/")
         |> put_session(:session_id, existing_id)
         |> SessionManager.call([])
  
  assert ^existing_id = get_session(conn, :session_id)
end
```

**测试场景：获取会话ID辅助函数**
```elixir
test "helper function gets session ID" do
  session_id = "helper-test-session"
  
  conn = build_conn(:get, "/")
         |> put_session(:session_id, session_id)
  
  assert ^session_id = SessionManager.get_session_id(conn)
end
```

## 3. FormBuilder 集成测试

### 3.1 自动保存功能

**测试场景：启用自动保存的表单**
```elixir
test "form with auto_save enabled" do
  assigns = %{
    config: %{fields: [%{type: "input", name: "name", label: "姓名"}]},
    auto_save: true
  }
  
  html = rendered_to_string(~H"""
    <.form_builder id="auto-save-form" config={@config} auto_save={@auto_save} />
  """)
  
  assert html =~ "auto-save-form"
  # 验证包含自动保存相关的 JavaScript 或 LiveView 事件
end
```

**测试场景：恢复表单状态**
```elixir
test "restores form state on mount", %{conn: conn} do
  session_id = "restore-test-session"
  form_id = "restore-form"
  saved_state = %{name: "恢复的数据", email: "restore@test.com"}
  
  # 预先保存状态
  FormStorage.save_form_state(session_id, form_id, saved_state)
  
  # 设置会话
  conn = put_session(conn, :session_id, session_id)
  
  {:ok, _view, html} = live(conn, "/components/form_builder")
  
  # 验证表单包含恢复的数据
  assert html =~ "恢复的数据"
  assert html =~ "restore@test.com"
end
```

### 3.2 LiveView 交互测试

**测试场景：表单变化触发保存**
```elixir
test "form changes trigger auto-save", %{conn: conn} do
  session_id = "auto-save-test"
  conn = put_session(conn, :session_id, session_id)
  
  {:ok, view, _html} = live(conn, "/components/form_builder")
  
  # 模拟表单字段变化
  view
  |> form("#auto-save-form")
  |> render_change(%{name: "自动保存测试"})
  
  # 等待防抖延迟
  Process.sleep(600)
  
  # 验证状态已保存
  state = FormStorage.get_form_state(session_id, "auto-save-form")
  assert state.name == "自动保存测试"
end
```

**测试场景：防抖机制**
```elixir
test "debounces rapid changes", %{conn: conn} do
  session_id = "debounce-test"
  conn = put_session(conn, :session_id, session_id)
  
  {:ok, view, _html} = live(conn, "/components/form_builder")
  
  # 快速连续变化
  view |> form("#auto-save-form") |> render_change(%{name: "变化1"})
  view |> form("#auto-save-form") |> render_change(%{name: "变化2"})
  view |> form("#auto-save-form") |> render_change(%{name: "最终变化"})
  
  # 在防抖时间内验证未保存
  Process.sleep(300)
  assert nil == FormStorage.get_form_state(session_id, "auto-save-form")
  
  # 等待防抖完成
  Process.sleep(300)
  
  # 验证只保存了最后的变化
  state = FormStorage.get_form_state(session_id, "auto-save-form")
  assert state.name == "最终变化"
end
```

## 4. 性能测试

### 4.1 内存使用测试

**测试场景：大量会话内存测试**
```elixir
test "handles many sessions efficiently" do
  # 创建1000个会话，每个包含3个表单
  for i <- 1..1000 do
    session_id = "session-#{i}"
    for j <- 1..3 do
      form_id = "form-#{j}"
      state = %{
        field1: "数据#{i}-#{j}",
        field2: String.duplicate("x", 100),  # 较大的数据
        timestamp: System.system_time()
      }
      FormStorage.save_form_state(session_id, form_id, state)
    end
  end
  
  stats = FormStorage.get_stats()
  assert stats.total_sessions == 1000
  assert stats.total_forms == 3000
  
  # 验证内存使用在合理范围内（<50MB）
  assert stats.memory_usage < 50 * 1024 * 1024
end
```

### 4.2 响应时间测试

**测试场景：保存操作响应时间**
```elixir
test "save operations are fast" do
  session_id = "performance-session"
  large_state = %{
    data: String.duplicate("test data ", 1000),
    numbers: Enum.to_list(1..1000),
    nested: %{deep: %{structure: %{with: "data"}}}
  }
  
  {time, :ok} = :timer.tc(fn ->
    FormStorage.save_form_state(session_id, "large-form", large_state)
  end)
  
  # 保存操作应该在10ms内完成
  assert time < 10_000  # 微秒
end
```

**测试场景：读取操作响应时间**
```elixir
test "get operations are fast" do
  session_id = "read-performance"
  state = %{data: "test"}
  FormStorage.save_form_state(session_id, "form", state)
  
  {time, ^state} = :timer.tc(fn ->
    FormStorage.get_form_state(session_id, "form")
  end)
  
  # 读取操作应该在5ms内完成
  assert time < 5_000  # 微秒
end
```

## 5. 错误处理测试

### 5.1 异常输入处理

**测试场景：无效会话ID**
```elixir
test "handles invalid session IDs gracefully" do
  # 测试空字符串
  assert nil == FormStorage.get_form_state("", "form")
  
  # 测试 nil（应该有类型检查）
  assert_raise FunctionClauseError, fn ->
    FormStorage.get_form_state(nil, "form")
  end
end
```

**测试场景：无效状态数据**
```elixir
test "handles complex state data" do
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
    :ok = FormStorage.save_form_state(session_id, form_id, state)
    assert ^state = FormStorage.get_form_state(session_id, form_id)
  end
end
```

## 6. 并发测试

**测试场景：并发读写操作**
```elixir
test "handles concurrent operations" do
  session_id = "concurrent-test"
  
  # 启动多个进程同时读写
  tasks = for i <- 1..50 do
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
  assert length(results) == 50
  assert Enum.all?(results, &is_map/1)
end
```

## 测试数据清理

```elixir
setup do
  # 每个测试前清理状态
  if Process.whereis(FormStorage) do
    GenServer.stop(FormStorage)
  end
  
  start_supervised!(FormStorage)
  :ok
end
```

## 性能基准

- **保存操作**：< 10ms
- **读取操作**：< 5ms  
- **内存使用**：1000会话 < 50MB
- **并发处理**：50个并发操作正常工作
- **过期清理**：5分钟清理周期正常