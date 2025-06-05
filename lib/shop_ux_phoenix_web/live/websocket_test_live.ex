defmodule ShopUxPhoenixWeb.WebSocketTestLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0, ws_status: "checking...", connected: connected?(socket))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-8">
      <h1 class="text-2xl font-bold mb-4">WebSocket 连接测试</h1>
      
      <div class="bg-gray-100 p-4 rounded mb-4">
        <p>WebSocket 状态: <span class="font-bold" id="ws-status"><%= @ws_status %></span></p>
        <p>LiveView 连接状态: <%= if @connected, do: "已连接", else: "未连接" %></p>
        <p>计数器: <%= @count %></p>
      </div>
      
      <button phx-click="increment" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
        点击测试 (+1)
      </button>
      
      <div class="mt-8">
        <h2 class="text-xl font-bold mb-2">调试信息</h2>
        <div class="bg-gray-100 p-4 rounded">
          <p>LiveSocket URL: <span id="live-url"></span></p>
          <p>WebSocket 状态: <span id="socket-state"></span></p>
        </div>
      </div>
      
      <script>
        // 延迟执行，确保LiveSocket已初始化
        setTimeout(() => {
          if (window.liveSocket) {
            const url = window.liveSocket.endPointURL ? window.liveSocket.endPointURL() : 'N/A';
            document.getElementById('live-url').textContent = url;
            
            const connected = window.liveSocket.isConnected ? window.liveSocket.isConnected() : false;
            document.getElementById('socket-state').textContent = connected ? '已连接' : '未连接';
            
            // 打印调试信息到控制台
            console.log('LiveSocket:', window.liveSocket);
            console.log('LiveSocket URL:', url);
            console.log('Is Connected:', connected);
          }
        }, 100);
        
        // 监听 WebSocket 状态
        document.addEventListener('phx:live_socket:connect', () => {
          document.getElementById('ws-status').textContent = '已连接';
          document.getElementById('ws-status').style.color = 'green';
          if (document.getElementById('socket-state')) {
            document.getElementById('socket-state').textContent = '已连接';
          }
        });
        
        document.addEventListener('phx:live_socket:disconnect', () => {
          document.getElementById('ws-status').textContent = '未连接';
          document.getElementById('ws-status').style.color = 'red';
          if (document.getElementById('socket-state')) {
            document.getElementById('socket-state').textContent = '未连接';
          }
        });
      </script>
    </div>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end
end