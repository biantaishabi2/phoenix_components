# FormStorage 表单状态持久化设计文档

## 概述

FormStorage 是一个表单状态持久化解决方案，为 FormBuilder 组件提供自动保存和恢复功能。由于 shop_ux_phoenix 是纯组件库项目，不依赖数据库，采用内存存储 + Session 会话管理的方式实现。

## 设计目标

1. **自动保存**：表单数据自动保存，无需用户手动操作
2. **状态恢复**：页面刷新或重新访问时恢复表单状态
3. **性能优化**：防抖机制避免频繁保存
4. **会话隔离**：不同用户会话间数据隔离
5. **内存管理**：自动清理过期会话，避免内存泄漏

## 架构设计

### 核心组件

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   FormBuilder   │    │   FormStorage    │    │  SessionManager │
│   (LiveView)    │◄──►│   (GenServer)    │◄──►│     (Plug)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  用户交互界面    │    │   内存存储容器    │    │   会话ID管理    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### 存储结构

```elixir
%{
  sessions: %{
    "session_id_1" => %{
      "form_id_1" => %{
        state: %{name: "张三", email: "test@example.com"},
        updated_at: 1703764800000
      },
      "form_id_2" => %{...}
    },
    "session_id_2" => %{...}
  }
}
```

## API 设计

### FormStorage 模块

```elixir
defmodule ShopUxPhoenixWeb.FormStorage do
  @moduledoc "表单状态存储管理器"

  # 启动服务
  def start_link(opts \\ [])
  
  # 保存表单状态
  def save_form_state(session_id, form_id, state)
  
  # 获取表单状态
  def get_form_state(session_id, form_id)
  
  # 删除表单状态
  def delete_form_state(session_id, form_id)
  
  # 清理会话
  def cleanup_session(session_id)
  
  # 获取统计信息
  def get_stats()
end
```

### SessionManager Plug

```elixir
defmodule ShopUxPhoenixWeb.SessionManager do
  @moduledoc "会话管理 Plug"
  
  def init(opts)
  def call(conn, opts)
  
  # 获取或创建会话ID
  def get_session_id(conn)
end
```

### FormBuilder 集成

```elixir
# 新增属性
attr :auto_save, :boolean, default: false
attr :save_debounce, :integer, default: 500

# 新增函数
defp schedule_save(socket)
defp restore_form_state(socket)
defp save_form_state(socket)
```

## 配置选项

```elixir
config :shop_ux_phoenix, ShopUxPhoenixWeb.FormStorage,
  # 会话过期时间（毫秒）
  session_ttl: :timer.minutes(30),
  # 清理间隔时间
  cleanup_interval: :timer.minutes(5),
  # 防抖延迟时间
  save_debounce: 500,
  # 最大会话数量
  max_sessions: 1000
```

## 功能特性

### 1. 自动保存机制

- **触发条件**：表单字段值变化
- **防抖处理**：500ms 内多次变化只保存最后一次
- **异步保存**：不阻塞用户界面交互

### 2. 状态恢复

- **时机**：组件初始化时
- **优先级**：存储状态 > 初始数据 > 默认值
- **容错处理**：恢复失败时使用默认值

### 3. 会话管理

- **会话ID**：使用 Phoenix Session 存储
- **生成策略**：UUID 随机生成
- **有效期**：30分钟无活动自动过期

### 4. 内存管理

- **定期清理**：每5分钟清理过期会话
- **内存监控**：提供内存使用统计
- **容量限制**：最大1000个活跃会话

## 使用示例

### 基本用法

```heex
<.form_builder 
  id="user-form"
  config={@config}
  auto_save={true}
  save_debounce={1000}
/>
```

### 手动控制

```elixir
# 在 LiveView 中
def handle_event("save_form", params, socket) do
  session_id = get_session_id(socket)
  FormStorage.save_form_state(session_id, "user-form", params)
  {:noreply, socket}
end

def handle_event("restore_form", _params, socket) do
  session_id = get_session_id(socket)
  state = FormStorage.get_form_state(session_id, "user-form")
  socket = assign(socket, :form_data, state || %{})
  {:noreply, socket}
end
```

## 性能考虑

### 内存使用

- **单会话大小**：约 1-10KB（取决于表单复杂度）
- **1000会话总计**：约 1-10MB 内存占用
- **清理机制**：自动删除过期数据

### 并发处理

- **GenServer 单点**：简化设计，避免竞态条件
- **异步操作**：保存操作使用 cast，不阻塞
- **读取优化**：get 操作使用 call，保证一致性

## 扩展性

### 未来增强

1. **持久化存储**：支持 Redis 或数据库后端
2. **分布式支持**：多节点间状态同步
3. **压缩存储**：大表单数据压缩
4. **版本控制**：表单状态版本历史
5. **导入导出**：状态数据的备份恢复

### 配置扩展

```elixir
config :shop_ux_phoenix, ShopUxPhoenixWeb.FormStorage,
  backend: :memory,  # :memory | :redis | :database
  compression: false,
  versioning: false,
  export_format: :json
```

## 安全考虑

1. **数据隔离**：会话间数据完全隔离
2. **内存泄漏**：定期清理过期数据
3. **数据验证**：存储前验证数据格式
4. **访问控制**：只能访问自己会话的数据

## 测试策略

1. **单元测试**：FormStorage 各个 API
2. **集成测试**：与 FormBuilder 集成
3. **性能测试**：内存使用和响应时间
4. **并发测试**：多会话同时操作
5. **清理测试**：过期数据清理机制

## 向后兼容

- 新功能通过 `auto_save` 属性控制，默认关闭
- 现有表单无需修改即可正常工作
- 渐进式启用：可以选择性地为特定表单启用