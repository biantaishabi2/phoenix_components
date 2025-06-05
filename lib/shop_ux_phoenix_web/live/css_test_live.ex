defmodule ShopUxPhoenixWeb.CssTestLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-4">CSS 测试页面</h1>
      
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-2">静态资源路径信息：</h2>
        <pre class="bg-gray-100 p-4 rounded">
静态资源路径: <%= ~p"/assets/app.css" %>
当前 Socket: <%= inspect(@socket.host_uri) %>
        </pre>
      </div>
      
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-2">测试 Tailwind CSS：</h2>
        <div class="bg-blue-500 text-white p-4 rounded">
          如果这个框是蓝色的，说明 Tailwind CSS 已加载
        </div>
      </div>
      
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-2">测试 PetalComponents CSS：</h2>
        <button class="pc-button pc-button--primary">
          如果这个按钮有样式，说明 PetalComponents CSS 已加载
        </button>
        
        <div class="mt-4 p-4 bg-gray-100 rounded">
          <p class="text-sm mb-2">按钮应该具有的样式：</p>
          <ul class="text-xs">
            <li>- 橙色背景 (primary color)</li>
            <li>- 白色文字</li>
            <li>- 圆角边框</li>
            <li>- 内边距</li>
          </ul>
        </div>
        
        <div class="mt-4">
          <p class="text-sm mb-2">测试内联样式（应该是橙色按钮）：</p>
          <button style="display: inline-flex; align-items: center; justify-content: center; border-radius: 0.375rem; border-width: 1px; background-color: #FD8E25; color: white; padding: 0.5rem 1rem;">
            内联样式按钮
          </button>
        </div>
      </div>
      
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-2">直接链接测试：</h2>
        <p>
          <a href="/assets/app.css" target="_blank" class="text-blue-600 underline">
            点击查看 CSS 文件
          </a>
        </p>
      </div>
    </div>
    """
  end
end