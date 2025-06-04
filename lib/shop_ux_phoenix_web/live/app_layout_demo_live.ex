defmodule ShopUxPhoenixWeb.AppLayoutDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.BusinessComponents.AppLayout
  
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "AppLayout 应用布局组件")
     |> assign(:current_path, "/dashboard")
     |> assign(:sidebar_collapsed, false)
     |> assign(:current_user, %{
       name: "张三",
       company: "北京云动幸福科技有限公司"
     })
     |> assign(:notifications_count, 5)
     |> assign(:breadcrumbs, [
       %{title: "首页", path: "/"},
       %{title: "仪表盘", path: nil}
     ])
     |> assign(:menu_items, demo_menu_items())
     |> assign(:demo_theme, "light")
     |> assign(:logout_confirm, false)
     |> assign(:mobile_menu_open, false)}
  end
  
  def render(assigns) do
    ~H"""
    <!-- Demo页面本身作为AppLayout -->
    <.app_layout 
      page_title="AppLayout 应用布局组件"
      breadcrumbs={@breadcrumbs}
      current_user={@current_user}
      collapsed={@sidebar_collapsed}
      menu_items={@menu_items}
      current_path={@current_path}
      notifications_count={@notifications_count}
    >
      <div>
        <h1 class="text-2xl font-bold mb-6">AppLayout 应用布局组件</h1>
        
        <div class="space-y-8">
        <!-- 基础布局 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">基础布局</h2>
          <div class="p-6 bg-gray-50 rounded-lg">
            <h3 class="text-lg font-medium mb-4">这是主内容区域</h3>
            <p class="text-gray-600 mb-4">
              AppLayout 提供了一个完整的后台管理系统布局,包含:
            </p>
            <ul class="list-disc list-inside text-gray-600 mb-4">
              <li>可折叠的侧边栏导航</li>
              <li>顶部导航栏和用户信息</li>
              <li>面包屑导航</li>
              <li>主内容区域</li>
              <li>通知徽章</li>
            </ul>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="bg-blue-50 p-4 rounded-lg">
                <h4 class="font-medium text-blue-900">统计卡片 1</h4>
                <p class="text-2xl font-bold text-blue-600">1,234</p>
              </div>
              <div class="bg-green-50 p-4 rounded-lg">
                <h4 class="font-medium text-green-900">统计卡片 2</h4>
                <p class="text-2xl font-bold text-green-600">5,678</p>
              </div>
              <div class="bg-purple-50 p-4 rounded-lg">
                <h4 class="font-medium text-purple-900">统计卡片 3</h4>
                <p class="text-2xl font-bold text-purple-600">9,012</p>
              </div>
            </div>
          </div>
        </section>
        
        <!-- 带搜索框的头部 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">带搜索框的头部</h2>
          <div class="bg-gray-100 p-6 rounded-lg">
            <p class="text-gray-600 mb-4">
              AppLayout 组件的基本用法:
            </p>
            <div class="p-4 bg-gray-900 text-gray-100 rounded-lg font-mono text-sm overflow-x-auto">
              <code class="block">
                &lt;.app_layout 
                  page_title="仪表盘"
                  breadcrumbs=...
                  current_user=...
                  collapsed=false
                  menu_items=...
                  current_path="/dashboard"
                  notifications_count=5
                &gt;
                  &lt;!-- 页面内容 --&gt;
                &lt;/.app_layout&gt;
              </code>
            </div>
          </div>
        </section>
        
        <!-- 自定义菜单 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">自定义菜单</h2>
          <div class="p-6 bg-gray-50 rounded-lg">
            <p class="text-gray-600 mb-4">
              你可以测试以下功能:
            </p>
            <ul class="list-disc list-inside text-gray-600 space-y-2">
              <li>点击顶部的汉堡菜单按钮来折叠/展开侧边栏</li>
              <li>点击菜单项进行导航,观察面包屑和活动状态的变化</li>
              <li>点击带有子菜单的项目来展开/折叠子菜单</li>
              <li>点击通知图标查看通知</li>
              <li>点击退出按钮测试退出确认</li>
            </ul>
          </div>
        </section>
        
        <!-- 响应式布局 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">响应式布局</h2>
          <div class="bg-gray-100 p-4 rounded-lg">
            <p class="text-gray-600 mb-4">
              调整浏览器窗口大小来查看响应式效果.在移动设备上,侧边栏会变成抽屉式菜单.
            </p>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-center">
              <div class="bg-white p-4 rounded">
                <div class="text-gray-500 mb-2">桌面端</div>
                <div class="text-sm">完整侧边栏</div>
              </div>
              <div class="bg-white p-4 rounded">
                <div class="text-gray-500 mb-2">平板端</div>
                <div class="text-sm">可折叠侧边栏</div>
              </div>
              <div class="bg-white p-4 rounded">
                <div class="text-gray-500 mb-2">移动端</div>
                <div class="text-sm">抽屉式菜单</div>
              </div>
            </div>
          </div>
        </section>
        
        <!-- 暗色主题 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">暗色主题</h2>
          <div class="p-6 bg-gray-50 rounded-lg" data-theme={@demo_theme}>
            <p class="text-gray-600 mb-4">
              AppLayout 支持暗色主题,可以通过添加相应的CSS类来实现.
            </p>
            <button 
              phx-click="toggle_theme"
              class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
              切换主题
            </button>
          </div>
        </section>
      </div>
      </div>
    </.app_layout>
    
    <!-- 退出确认对话框 -->
    <div :if={@logout_confirm} class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-sm">
        <h3 class="text-lg font-medium mb-4">确定要退出登录吗?</h3>
        <div class="flex justify-end gap-2">
          <button phx-click="cancel_logout" class="px-4 py-2 text-gray-600 hover:text-gray-800">
            取消
          </button>
          <button phx-click="confirm_logout" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600">
            确定退出
          </button>
        </div>
      </div>
    </div>
    
    <!-- 移动端菜单 -->
    <div :if={@mobile_menu_open} class="fixed inset-0 bg-black bg-opacity-50 z-40" phx-click="close_mobile_menu">
      <div class="fixed left-0 top-0 h-full w-64 bg-white shadow-lg" data-mobile-menu>
        <!-- 移动端菜单内容 -->
        <div class="p-4">
          <h3 class="font-medium mb-4">移动端菜单</h3>
          <!-- 菜单项列表 -->
        </div>
      </div>
    </div>
    """
  end
  
  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply, update(socket, :sidebar_collapsed, &(!&1))}
  end
  
  def handle_event("menu_click", %{"key" => key}, socket) do
    path = find_menu_path(socket.assigns.menu_items, key)
    
    new_breadcrumbs = case key do
      "product-list" -> [
        %{title: "首页", path: "/"},
        %{title: "商品管理", path: "/products"},
        %{title: "商品列表", path: nil}
      ]
      "order-list" -> [
        %{title: "首页", path: "/"},
        %{title: "订单管理", path: "/orders"},
        %{title: "订单列表", path: nil}
      ]
      _ -> socket.assigns.breadcrumbs
    end
    
    {:noreply, 
     socket
     |> assign(:current_path, path || socket.assigns.current_path)
     |> assign(:breadcrumbs, new_breadcrumbs)}
  end
  
  def handle_event("logout", _params, socket) do
    {:noreply, assign(socket, :logout_confirm, true)}
  end
  
  def handle_event("cancel_logout", _params, socket) do
    {:noreply, assign(socket, :logout_confirm, false)}
  end
  
  def handle_event("confirm_logout", _params, socket) do
    {:noreply,
     socket
     |> assign(:logout_confirm, false)
     |> put_flash(:info, "已退出登录")}
  end
  
  def handle_event("show_notifications", _params, socket) do
    {:noreply, put_flash(socket, :info, "显示通知列表")}
  end
  
  def handle_event("toggle_theme", _params, socket) do
    new_theme = if socket.assigns.demo_theme == "light", do: "dark", else: "light"
    {:noreply, assign(socket, :demo_theme, new_theme)}
  end
  
  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, true)}
  end
  
  def handle_event("products", _params, socket) do
    {:noreply, 
     socket
     |> assign(:current_path, "/products")
     |> assign(:breadcrumbs, [
       %{title: "首页", path: "/"},
       %{title: "商品管理", path: nil}
     ])}
  end
  
  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, false)}
  end
  
  defp demo_menu_items do
    [
      %{
        key: "dashboard",
        title: "仪表盘",
        icon: "hero-home",
        path: "/dashboard"
      },
      %{
        key: "products",
        title: "商品管理",
        icon: "hero-shopping-bag",
        children: [
          %{key: "product-list", title: "商品列表", path: "/products"},
          %{key: "product-create", title: "新建商品", path: "/products/new"},
          %{key: "product-categories", title: "商品分类", path: "/products/categories"}
        ]
      },
      %{
        key: "orders",
        title: "订单管理",
        icon: "hero-clipboard-document-list",
        children: [
          %{key: "order-list", title: "订单列表", path: "/orders"},
          %{key: "order-ship", title: "批量发货", path: "/orders/ship"},
          %{key: "order-returns", title: "退货管理", path: "/orders/returns"}
        ]
      },
      %{
        key: "customers",
        title: "客户管理",
        icon: "hero-users",
        path: "/customers"
      },
      %{
        key: "marketing",
        title: "营销中心",
        icon: "hero-megaphone",
        children: [
          %{key: "coupons", title: "优惠券", path: "/marketing/coupons"},
          %{key: "campaigns", title: "活动管理", path: "/marketing/campaigns"}
        ]
      },
      %{
        key: "reports",
        title: "数据报表",
        icon: "hero-chart-bar",
        path: "/reports"
      },
      %{
        key: "settings",
        title: "系统设置",
        icon: "hero-cog-6-tooth",
        path: "/settings"
      }
    ]
  end
  
  defp find_menu_path(items, key) do
    Enum.find_value(items, fn item ->
      if item.key == key do
        item[:path]
      else
        if item[:children] do
          find_menu_path(item.children, key)
        end
      end
    end)
  end
end