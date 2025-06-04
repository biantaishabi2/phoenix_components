# LiveView 点击事件调试指南

## 问题描述
组件展示页面的点击事件无响应，但测试却能通过。

## 调试步骤

### 1. 检查浏览器控制台
打开浏览器开发者工具（F12），在控制台中运行以下命令：

```javascript
// 检查 LiveSocket 是否加载
console.log('LiveSocket available:', !!window.liveSocket);

// 检查 WebSocket 连接状态
console.log('WebSocket connected:', window.liveSocket?.isConnected());

// 启用调试模式
window.liveSocket?.enableDebug();

// 检查是否有错误
// 查看 Network 选项卡中的 WebSocket 连接
```

### 2. 测试页面
访问以下测试页面，检查点击事件是否正常工作：

- `/debug` - 调试页面，显示 WebSocket 状态和事件日志
- `/minimal` - 最小化测试页面，只有一个计数器按钮
- `/components/showcase` - 组件展示页面

### 3. 常见问题检查

#### A. JavaScript 错误
- 打开控制台查看是否有红色错误信息
- 特别注意是否有关于 `topbar` 或其他依赖的错误

#### B. CSRF Token
- 检查页面源代码中是否有 `<meta name="csrf-token">` 标签
- 检查 token 是否正确传递给 LiveSocket

#### C. WebSocket 连接
- 在 Network 选项卡中查看 WebSocket 连接
- 确认连接地址是否正确（应该是 `/live/websocket`）
- 查看 WebSocket 消息是否正常发送和接收

#### D. LiveView 生命周期
- 检查服务器日志，看是否有 mount 或 handle_event 的错误
- 使用 `IO.inspect` 在事件处理函数中打印日志

### 4. 比较测试环境和运行环境

测试环境中，LiveView 使用特殊的测试适配器，不需要真实的 WebSocket 连接。这可能是测试通过但实际运行失败的原因。

### 5. 可能的解决方案

1. **清理并重新编译资源**
   ```bash
   cd shop_ux_phoenix
   rm -rf _build deps node_modules
   mix deps.get
   mix compile
   cd assets && npm install
   ```

2. **检查 app.js 加载顺序**
   确保 LiveSocket 在所有 DOM 内容加载完成后再连接

3. **检查路由配置**
   确认 `/live` 路由正确配置在 endpoint.ex 中

4. **检查 CSP 策略**
   如果有内容安全策略，确保允许 WebSocket 连接

### 6. 进一步调试

如果以上步骤都无法解决问题，可以：

1. 在 `app.js` 中添加更多日志：
   ```javascript
   console.log('LiveSocket connecting...');
   liveSocket.connect();
   console.log('LiveSocket connected');
   ```

2. 在 LiveView 模块中添加日志：
   ```elixir
   def handle_event(event, params, socket) do
     IO.inspect({event, params}, label: "Received event")
     # ... 处理逻辑
   end
   ```

3. 检查网络代理或防火墙是否阻止了 WebSocket 连接

### 7. 临时解决方案

如果需要紧急展示，可以考虑：
- 使用传统的 HTTP 请求代替 LiveView
- 使用 JavaScript 直接处理点击事件
- 部署到生产环境测试（有时开发环境的配置问题）