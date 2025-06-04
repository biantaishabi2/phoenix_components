defmodule ShopUxPhoenixWeb.DebugLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0, connected: connected?(socket))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
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