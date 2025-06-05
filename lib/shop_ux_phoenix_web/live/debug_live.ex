defmodule ShopUxPhoenixWeb.DebugLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0, connected: connected?(socket))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8" id="debug-container" phx-hook="StopReload">
      <h1 class="text-2xl font-bold mb-4">LiveView 调试页面</h1>
      
      <div class="mb-4">
        <p class="mb-2">连接状态: <span class={if @connected, do: "text-green-600", else: "text-red-600"}><%= if @connected, do: "已连接", else: "未连接" %></span></p>
        <p class="mb-2">计数器: <%= @count %></p>
      </div>
      
      <button 
        phx-click="increment"
        class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
      >
        点击我 (计数 +1)
      </button>
      
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-2">WebSocket调试信息：</h2>
        <div id="ws-debug" phx-update="ignore" class="bg-gray-100 p-4 rounded">
          <pre id="debug-output">检测中...</pre>
        </div>
      </div>
      
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-2">请在浏览器控制台执行以下命令进行调试：</h2>
        <pre class="bg-gray-100 p-4 rounded text-sm">
          // 查看 LiveSocket 状态
          window.liveSocket

          // 检查连接状态
          window.liveSocket.isConnected()

          // 启用调试日志
          window.liveSocket.enableDebug()

          // 查看 WebSocket URL
          window.liveSocket.endpointURL()

          // 手动连接（如果未连接）
          window.liveSocket.connect()
        </pre>
      </div>
      
      <script>
        // 等待页面加载后执行调试
        if (typeof window !== 'undefined') {
          window.addEventListener('DOMContentLoaded', () => {
            setTimeout(() => {
              const debugEl = document.getElementById('debug-output');
              if (!debugEl) {
                console.error('Debug element not found');
                return;
              }
              
              let debugInfo = '';
              
              // 检查是否有app.js加载
              const scripts = Array.from(document.getElementsByTagName('script'));
              const appJsScript = scripts.find(s => s.src && s.src.includes('app.js'));
              debugInfo += `app.js脚本标签: ${appJsScript ? appJsScript.src : '未找到'}\n`;
              
              // 检查LiveSocket
              if (typeof window.liveSocket !== 'undefined') {
                debugInfo += `LiveSocket存在: ✓\n`;
                try {
                  debugInfo += `连接状态: ${window.liveSocket.isConnected() ? '已连接' : '未连接'}\n`;
                  // 检查socket的内部属性
                  debugInfo += `Socket对象类型: ${typeof window.liveSocket}\n`;
                  debugInfo += `Socket属性: ${Object.keys(window.liveSocket).join(', ')}\n`;
                  
                  // 检查transport
                  if (window.liveSocket.socket) {
                    debugInfo += `Transport存在: ✓\n`;
                    debugInfo += `Transport状态: ${window.liveSocket.socket.connectionState ? window.liveSocket.socket.connectionState() : 'N/A'}\n`;
                    // 获取WebSocket URL
                    if (window.liveSocket.socket.endPointURL) {
                      debugInfo += `WebSocket URL: ${window.liveSocket.socket.endPointURL()}\n`;
                    }
                    // 检查连接尝试
                    debugInfo += `协议: ${window.liveSocket.socket.protocol || 'N/A'}\n`;
                    debugInfo += `传输类型: ${window.liveSocket.socket.transport || 'N/A'}\n`;
                  }
                  
                  // 检查是否有enableDebug方法
                  if (typeof window.liveSocket.enableDebug === 'function') {
                    window.liveSocket.enableDebug();
                    debugInfo += `调试模式已启用\n`;
                  }
                } catch (e) {
                  debugInfo += `LiveSocket错误: ${e.message}\n`;
                  debugInfo += `错误堆栈: ${e.stack}\n`;
                }
              } else {
                debugInfo += `LiveSocket未找到!\n`;
                debugInfo += `window对象: ${typeof window}\n`;
                debugInfo += `Phoenix: ${typeof Phoenix}\n`;
                debugInfo += `LiveView: ${typeof Phoenix?.LiveView}\n`;
              }
              
              debugInfo += `\n当前页面URL: ${window.location.href}\n`;
              debugInfo += `协议: ${window.location.protocol}\n`;
              debugInfo += `主机: ${window.location.host}\n`;
              
              debugEl.textContent = debugInfo;
              
              // 防止页面不停刷新
              if (window.stopReload) {
                console.log('Stopping reload loop');
                return;
              }
              window.stopReload = true;
              
            }, 500);
          });
        }
      </script>
      
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-2">WebSocket连接测试：</h2>
        <button onclick="testWebSocket()" class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
          测试WebSocket连接
        </button>
        <pre id="ws-test-result" class="mt-2 bg-gray-100 p-4 rounded text-sm"></pre>
      </div>
      
      <script>
        function testWebSocket() {
          const resultEl = document.getElementById('ws-test-result');
          let result = '开始WebSocket连接测试...\n';
          
          // 测试WSS连接
          const wsUrl = 'wss://phoenix.biantaishabi.org/live/websocket?vsn=2.0.0';
          result += `尝试连接: ${wsUrl}\n`;
          
          try {
            const ws = new WebSocket(wsUrl);
            
            ws.onopen = () => {
              result += '✓ WebSocket连接成功!\n';
              resultEl.textContent = result;
              ws.close();
            };
            
            ws.onerror = (e) => {
              result += `✗ WebSocket连接失败: ${e}\n`;
              resultEl.textContent = result;
            };
            
            ws.onclose = (e) => {
              result += `WebSocket关闭: code=${e.code}, reason=${e.reason}\n`;
              resultEl.textContent = result;
            };
            
          } catch (e) {
            result += `✗ 创建WebSocket失败: ${e.message}\n`;
            resultEl.textContent = result;
          }
        }
      </script>
      
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-2">可能的解决方案：</h2>
        <ul class="list-disc list-inside space-y-2">
          <li>检查浏览器控制台是否有错误信息</li>
          <li>检查网络选项卡中的 WebSocket 连接</li>
          <li>确保访问地址正确（如果通过代理访问可能有问题）</li>
          <li>尝试直接访问 <a href="http://localhost:4010/debug" class="text-blue-600 underline">http://localhost:4010/debug</a></li>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end
end