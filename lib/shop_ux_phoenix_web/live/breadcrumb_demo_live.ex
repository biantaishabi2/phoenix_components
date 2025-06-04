defmodule ShopUxPhoenixWeb.BreadcrumbDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.Breadcrumb

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Breadcrumb 面包屑导航组件")
     |> assign(:show_home_example, true)
     |> assign(:current_separator, "chevron")
     |> assign(:current_size, "medium")
     |> assign(:responsive_mode, false)
     |> assign(:basic_items, [
       %{title: "首页", path: "/"},
       %{title: "产品管理", path: "/products"},
       %{title: "产品列表", path: nil}
     ])
     |> assign(:icon_items, [
       %{title: "首页", path: "/", icon: "hero-home"},
       %{title: "商品管理", path: "/products", icon: "hero-shopping-bag"},
       %{title: "商品详情", path: nil, icon: "hero-document-text"}
     ])
     |> assign(:interactive_items, [
       %{title: "首页", path: "/", icon: "hero-home"},
       %{title: "产品管理", path: "/products", icon: "hero-shopping-bag"},
       %{title: "分类管理", path: "/categories", icon: "hero-folder"},
       %{title: "电子产品", path: "/categories/electronics", icon: "hero-cpu-chip"},
       %{title: "手机", path: nil, icon: "hero-device-phone-mobile"}
     ])}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 w-full">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Breadcrumb 面包屑导航组件</h1>
      
      <!-- 基础面包屑 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础面包屑</h2>
        <div class="bg-white p-6 rounded-lg border border-gray-200 mb-4">
          <.breadcrumb items={@basic_items} />
        </div>
        
        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm text-gray-700"><code><%= Phoenix.HTML.raw("&lt;.breadcrumb items={basic_items} /&gt;") %></code></pre>
        </div>
      </section>

      <!-- 带图标的面包屑 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">带图标的面包屑</h2>
        <div class="bg-white p-6 rounded-lg border border-gray-200 mb-4">
          <.breadcrumb items={@icon_items} />
        </div>
        
        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm text-gray-700"><code><%= Phoenix.HTML.raw("&lt;.breadcrumb items={icon_items} /&gt;") %></code></pre>
        </div>
      </section>

      <!-- 不同分隔符 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">不同分隔符</h2>
        
        <div class="space-y-4">
          <!-- Chevron 分隔符 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">Chevron 分隔符 (默认)</h3>
            <.breadcrumb separator="chevron" items={[
              %{title: "首页", path: "/"},
              %{title: "设置", path: "/settings"},
              %{title: "账户设置", path: nil}
            ]} />
          </div>
          
          <!-- Slash 分隔符 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">Slash 分隔符</h3>
            <.breadcrumb separator="slash" items={[
              %{title: "根目录", path: "/files"},
              %{title: "文档", path: "/files/docs"},
              %{title: "项目文档", path: nil}
            ]} />
          </div>
          
          <!-- Arrow 分隔符 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">Arrow 分隔符</h3>
            <.breadcrumb separator="arrow" items={[
              %{title: "首页", path: "/"},
              %{title: "用户管理", path: "/users"},
              %{title: "用户详情", path: nil}
            ]} />
          </div>
          
          <!-- 自定义分隔符 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">自定义分隔符</h3>
            <.breadcrumb separator=">" items={[
              %{title: "首页", path: "/"},
              %{title: "订单管理", path: "/orders"},
              %{title: "订单详情", path: nil}
            ]} />
          </div>
        </div>
      </section>

      <!-- 不同尺寸 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">不同尺寸</h2>
        
        <div class="space-y-4">
          <!-- 小尺寸 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">小尺寸 (Small)</h3>
            <.breadcrumb size="small" items={@icon_items} />
          </div>
          
          <!-- 中等尺寸 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">中等尺寸 (Medium) - 默认</h3>
            <.breadcrumb size="medium" items={@icon_items} />
          </div>
          
          <!-- 大尺寸 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">大尺寸 (Large)</h3>
            <.breadcrumb size="large" items={@icon_items} />
          </div>
        </div>
      </section>

      <!-- 最大显示项数 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">最大显示项数</h2>
        <div class="bg-white p-6 rounded-lg border border-gray-200 mb-4">
          <.breadcrumb max_items={3} items={[
            %{title: "首页", path: "/"},
            %{title: "产品管理", path: "/products"},
            %{title: "分类管理", path: "/products/categories"},
            %{title: "子分类", path: "/products/categories/sub"},
            %{title: "详情页", path: nil}
          ]} />
        </div>
        
        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm text-gray-700"><code><%= Phoenix.HTML.raw("&lt;.breadcrumb max_items={3} items={long_items} /&gt;") %></code></pre>
        </div>
      </section>

      <!-- 响应式面包屑 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">响应式面包屑</h2>
        <p class="text-gray-600 mb-4">在小屏幕设备上，中间项会被隐藏，只显示首末项。</p>
        <div class="bg-white p-6 rounded-lg border border-gray-200 mb-4">
          <.breadcrumb responsive={true} items={[
            %{title: "首页", path: "/"},
            %{title: "商品管理", path: "/products"},
            %{title: "分类管理", path: "/categories"},
            %{title: "分类详情", path: nil}
          ]} />
        </div>
      </section>

      <!-- 首页链接配置 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">首页链接配置</h2>
        
        <div class="space-y-4">
          <!-- 显示首页链接 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">显示首页链接</h3>
            <.breadcrumb 
              show_home={true}
              home_title="控制台"
              home_path="/dashboard"
              home_icon="hero-computer-desktop"
              items={[
                %{title: "系统设置", path: nil}
              ]} 
            />
          </div>
          
          <!-- 隐藏首页链接 -->
          <div class="bg-white p-6 rounded-lg border border-gray-200">
            <h3 class="text-lg font-medium mb-3">隐藏首页链接</h3>
            <.breadcrumb 
              show_home={false}
              items={[
                %{title: "根目录", path: "/"},
                %{title: "当前目录", path: nil}
              ]} 
            />
          </div>
        </div>
      </section>

      <!-- 带提示信息的面包屑 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">带提示信息的面包屑</h2>
        <div class="bg-white p-6 rounded-lg border border-gray-200 mb-4">
          <.breadcrumb items={[
            %{title: "首页", path: "/", overlay: "返回首页"},
            %{title: "产品管理", path: "/products", overlay: "管理所有产品"},
            %{title: "产品详情", path: nil, overlay: "当前查看的产品详情页"}
          ]} />
        </div>
      </section>

      <!-- 交互式示例 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">交互式示例</h2>
        
        <div class="bg-white p-6 rounded-lg border border-gray-200">
          <!-- 控制面板 -->
          <div class="mb-6 p-4 bg-gray-50 rounded-lg">
            <h3 class="text-lg font-medium mb-4">配置选项</h3>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <!-- 分隔符选择 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">分隔符</label>
                <select 
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  phx-change="change_separator"
                  name="separator"
                >
                  <option value="chevron" selected={@current_separator == "chevron"}>Chevron</option>
                  <option value="slash" selected={@current_separator == "slash"}>Slash</option>
                  <option value="arrow" selected={@current_separator == "arrow"}>Arrow</option>
                  <option value=">" selected={@current_separator == ">"}>Custom</option>
                </select>
              </div>
              
              <!-- 尺寸选择 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">尺寸</label>
                <select 
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  phx-change="change_size"
                  name="size"
                >
                  <option value="small" selected={@current_size == "small"}>Small</option>
                  <option value="medium" selected={@current_size == "medium"}>Medium</option>
                  <option value="large" selected={@current_size == "large"}>Large</option>
                </select>
              </div>
              
              <!-- 响应式模式 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">响应式模式</label>
                <div class="flex items-center">
                  <input 
                    type="checkbox" 
                    id="responsive"
                    class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                    phx-click="toggle_responsive"
                    checked={@responsive_mode}
                  />
                  <label for="responsive" class="ml-2 block text-sm text-gray-900">
                    启用响应式
                  </label>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 实时预览 -->
          <div class="border-t pt-4">
            <h3 class="text-lg font-medium mb-3">实时预览</h3>
            <.breadcrumb 
              separator={@current_separator}
              size={@current_size}
              responsive={@responsive_mode}
              items={@interactive_items}
            />
          </div>
        </div>
      </section>

      <!-- 空状态 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">空状态</h2>
        <div class="bg-white p-6 rounded-lg border border-gray-200 mb-4">
          <.breadcrumb items={[]} />
        </div>
        
        <div class="bg-gray-50 p-4 rounded-lg">
          <pre class="text-sm text-gray-700"><code><%= Phoenix.HTML.raw("&lt;.breadcrumb items={[]} /&gt;") %></code></pre>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("change_separator", %{"separator" => separator}, socket) do
    {:noreply, assign(socket, :current_separator, separator)}
  end

  def handle_event("change_size", %{"size" => size}, socket) do
    {:noreply, assign(socket, :current_size, size)}
  end

  def handle_event("toggle_responsive", _params, socket) do
    {:noreply, assign(socket, :responsive_mode, !socket.assigns.responsive_mode)}
  end
end