defmodule ShopUxPhoenixWeb.SimpleDebugLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0, connected: connected?(socket))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-2xl font-bold mb-4">简单调试页面</h1>
      
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
    </div>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end
end