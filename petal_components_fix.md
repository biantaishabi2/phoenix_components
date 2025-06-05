# PetalComponents 演示页面修复指南

## 问题分析

### 1. 编译错误
- **错误信息**: `undefined function label/1`
- **原因**: PetalComponents 库中不存在 `<.label>` 组件
- **影响**: 导致页面无法编译，LiveView 进程启动失败

### 2. JSON 编码错误
- **错误信息**: `Jason.EncodeError: invalid byte 0xE6`
- **原因**: 中文字符在 HTML 属性中的编码问题
- **影响**: WebSocket 消息序列化失败，导致连接断开

### 3. 性能问题
- **问题**: `DateTime.utc_now()` 在 render 函数中调用
- **影响**: 每次渲染都会产生不同的结果，可能触发不必要的重新渲染

### 4. 循环重连原因
- LiveView 进程因编译错误无法启动
- 客户端尝试连接失败后自动重试
- 形成无限重连循环

## 修复方案

### 1. 移除不存在的组件
将所有 `<.label>` 替换为普通的 HTML 元素或使用 PetalComponents 中存在的组件：

```elixir
# 错误的写法
<.label>文件上传</.label>

# 正确的写法
<p class="text-sm font-medium text-gray-700 mb-2">文件上传</p>
```

### 2. 修复时间显示
将 `DateTime.utc_now()` 移到 assigns 中：

```elixir
# mount 函数中
{:ok, assign(socket,
  current_time: DateTime.utc_now() |> DateTime.to_string(),
  # ... 其他 assigns
)}

# handle_event 中更新时间
def handle_event("test_connection", _params, socket) do
  current_time = DateTime.utc_now() |> DateTime.to_string()
  {:noreply, 
   socket
   |> assign(:current_time, current_time)
   |> put_flash(:info, "WebSocket 连接正常！")}
end

# render 函数中使用
<%= @current_time %>
```

### 3. 确保中文字符正确编码
- 使用 UTF-8 编码保存文件
- 避免在 HTML 属性中直接使用中文（如果必须使用，确保正确转义）

### 4. 使用修复后的版本
我已创建了修复后的版本：`petal_components_demo_live_fixed.ex`

要使用修复版本，请：

1. 备份原文件：
```bash
cp lib/shop_ux_phoenix_web/live/petal_components_demo_live.ex lib/shop_ux_phoenix_web/live/petal_components_demo_live.ex.bak
```

2. 替换为修复版本：
```bash
cp lib/shop_ux_phoenix_web/live/petal_components_demo_live_fixed.ex lib/shop_ux_phoenix_web/live/petal_components_demo_live.ex
```

3. 或者更新路由使用修复版本：
```elixir
# 在 router.ex 中
live "/demo/petal", PetalComponentsDemoLiveFixed
```

## 预防措施

1. **使用正确的组件**：查阅 PetalComponents 文档，确保使用的组件存在
2. **避免在 render 中使用动态值**：将动态内容放到 assigns 中
3. **测试中文内容**：确保所有中文内容都能正确显示和传输
4. **监控日志**：定期检查服务器日志，及时发现和修复错误

## 验证修复

修复后，你应该能看到：
1. 页面正常加载，不再无限重连
2. 点击"测试连接"按钮能正常响应
3. 服务器日志中不再出现编译错误和编码错误