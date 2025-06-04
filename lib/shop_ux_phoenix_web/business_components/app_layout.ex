defmodule ShopUxPhoenixWeb.BusinessComponents.AppLayout do
  @moduledoc """
  应用布局组件，提供完整的后台管理系统布局
  
  包含：
  - 侧边栏导航 (AppSidebar)
  - 顶部导航栏 (AppHeader)
  - 面包屑导航 (Breadcrumb)
  - 主内容区域 (MainContent)
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents
  alias Phoenix.LiveView.JS
  
  @doc """
  渲染应用布局
  
  ## 示例
      <.app_layout 
        page_title="仪表盘"
        breadcrumbs={@breadcrumbs}
        current_user={@current_user}
      >
        <!-- 页面内容 -->
      </.app_layout>
  """
  attr :page_title, :string, default: "", doc: "页面标题"
  attr :breadcrumbs, :list, default: [], doc: "面包屑导航项"
  attr :current_user, :map, default: nil, doc: "当前用户信息"
  attr :collapsed, :boolean, default: false, doc: "侧边栏是否折叠"
  attr :menu_items, :list, default: nil, doc: "菜单项列表"
  attr :current_path, :string, default: "", doc: "当前路径"
  attr :notifications_count, :integer, default: 0, doc: "通知数量"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :inner_block, required: true, doc: "主内容区域"
  
  def app_layout(assigns) do
    # 确保必要的属性有默认值
    assigns = 
      assigns
      |> assign_new(:menu_items, fn -> default_menu_items() end)
      |> assign_new(:current_user, fn -> nil end)
      |> assign_new(:breadcrumbs, fn -> [] end)
      |> assign_new(:collapsed, fn -> false end)
      |> assign_new(:current_path, fn -> "" end)
      |> assign_new(:notifications_count, fn -> 0 end)
      |> assign_new(:page_title, fn -> "" end)
      |> assign_new(:class, fn -> "" end)
    
    ~H"""
    <div class={["app-layout min-h-screen bg-gray-50", @class]} data-app-layout {@rest}>
      <!-- 侧边栏 -->
      <.app_sidebar
        collapsed={@collapsed}
        menu_items={@menu_items}
        current_path={@current_path}
      />
      
      <!-- 主内容区 -->
      <div class={[
        "app-layout__main transition-all duration-200",
        @collapsed && "ml-20" || "ml-64"
      ]}>
        <!-- 顶部栏 -->
        <.app_header
          title={@page_title}
          current_user={@current_user}
          notifications_count={@notifications_count}
          on_toggle_sidebar={JS.push("toggle_sidebar")}
        />
        
        <!-- 内容区 -->
        <div class="app-layout__content px-4 sm:px-6 lg:px-8 py-8">
          <!-- 面包屑 -->
          <.breadcrumb items={@breadcrumbs} class="mb-6" />
          
          <!-- 主内容 -->
          <.main_content>
            <%= render_slot(@inner_block) %>
          </.main_content>
        </div>
      </div>
    </div>
    """
  end
  
  @doc """
  侧边栏组件
  """
  attr :collapsed, :boolean, default: false, doc: "是否折叠"
  attr :menu_items, :list, default: [], doc: "菜单项列表"
  attr :current_path, :string, default: "", doc: "当前路径"
  attr :logo_url, :string, default: "/images/logo.svg", doc: "Logo 图片路径"
  attr :collapsed_logo_url, :string, default: "/images/logo-icon.svg", doc: "折叠时的 Logo"
  
  def app_sidebar(assigns) do
    assigns = assign_new(assigns, :menu_items, fn -> [] end)
    
    ~H"""
    <aside
      class={[
        "app-sidebar fixed left-0 top-0 z-40 h-screen transition-all duration-200",
        "bg-white border-r border-gray-200",
        @collapsed && "w-20" || "w-64"
      ]}
      data-app-sidebar
      data-sidebar-collapsed={if @collapsed, do: "true"}
    >
      <!-- Logo -->
      <div class="flex h-16 items-center justify-center border-b border-gray-200">
        <a href="/" class="flex items-center">
          <%= if @collapsed do %>
            <img src={@collapsed_logo_url} alt="Logo" class="h-8 w-8" />
          <% else %>
            <img src={@logo_url} alt="Logo" class="h-8" />
          <% end %>
        </a>
      </div>
      
      <!-- 菜单 -->
      <nav class="flex-1 space-y-1 px-2 py-4">
        <%= for item <- (@menu_items || []) do %>
          <.menu_item item={item} collapsed={@collapsed} current_path={@current_path} />
        <% end %>
      </nav>
    </aside>
    """
  end
  
  @doc """
  顶部导航栏组件
  """
  attr :title, :string, default: "", doc: "系统标题"
  attr :current_user, :map, default: nil, doc: "当前用户信息"
  attr :notifications_count, :integer, default: 0, doc: "通知数量"
  attr :on_toggle_sidebar, :any, default: nil, doc: "切换侧边栏回调"
  
  def app_header(assigns) do
    ~H"""
    <header
      class="app-header sticky top-0 z-30 flex h-16 items-center gap-4 border-b border-gray-200 bg-white px-4 sm:px-6"
      data-app-header
    >
      <!-- 汉堡菜单按钮 -->
      <button
        :if={@on_toggle_sidebar}
        type="button"
        class="text-gray-500 hover:text-gray-600"
        phx-click={@on_toggle_sidebar}
      >
        <span class="sr-only">切换侧边栏</span>
        <.icon name="hero-bars-3" class="h-6 w-6" />
      </button>
      
      <!-- 移动端菜单按钮 -->
      <button
        type="button"
        class="text-gray-500 hover:text-gray-600 md:hidden"
        phx-click="toggle_mobile_menu"
      >
        <span class="sr-only">切换移动端菜单</span>
        <.icon name="hero-bars-3" class="h-6 w-6" />
      </button>
      
      <!-- 标题 -->
      <h1 class="flex-1 text-lg font-semibold text-gray-900">
        <%= @title %>
      </h1>
      
      <!-- 用户信息区 -->
      <div class="flex items-center gap-4">
        <!-- 公司名称 -->
        <span :if={@current_user && @current_user.company} class="hidden sm:block text-sm text-gray-600">
          <%= @current_user.company %>
        </span>
        
        <!-- 通知 -->
        <button
          type="button"
          class="relative text-gray-500 hover:text-gray-600"
          phx-click="show_notifications"
        >
          <span class="sr-only">查看通知</span>
          <.icon name="hero-bell" class="h-6 w-6" />
          <span
            :if={@notifications_count > 0}
            class="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs text-white"
            data-notification-badge
          >
            <%= @notifications_count %>
          </span>
        </button>
        
        <!-- 用户菜单 -->
        <div class="relative" :if={@current_user}>
          <button class="flex items-center gap-2 text-sm text-gray-700 hover:text-gray-900">
            <span><%= @current_user.name %></span>
            <.icon name="hero-chevron-down" class="h-4 w-4" />
          </button>
          <!-- 简化的下拉菜单 -->
          <div class="absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 hidden">
            <div class="py-1">
              <.link href="/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                个人资料
              </.link>
              <.link href="/settings" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                设置
              </.link>
              <button
                type="button"
                phx-click="logout"
                class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
              >
                退出登录
              </button>
            </div>
          </div>
        </div>
        
        <!-- 退出按钮（用于测试或无用户信息时） -->
        <button
          type="button"
          phx-click="logout"
          class="text-gray-500 hover:text-gray-600"
        >
          <span class="sr-only">退出登录</span>
          <.icon name="hero-arrow-right-on-rectangle" class="h-6 w-6" />
        </button>
      </div>
    </header>
    """
  end
  
  @doc """
  面包屑导航组件
  """
  attr :items, :list, default: [], doc: "面包屑项列表"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  
  def breadcrumb(assigns) do
    ~H"""
    <nav class={["flex", @class]} aria-label="Breadcrumb" data-breadcrumb>
      <ol class="inline-flex items-center space-x-1 md:space-x-3">
        <%= for {item, index} <- Enum.with_index(@items) do %>
          <li class="inline-flex items-center" data-breadcrumb-item>
            <%= if index > 0 do %>
              <.icon name="hero-chevron-right" class="mx-1 h-4 w-4 text-gray-400" />
            <% end %>
            
            <%= if item[:path] do %>
              <.link
                href={item.path}
                class="inline-flex items-center text-sm font-medium text-gray-700 hover:text-primary"
              >
                <%= item.title %>
              </.link>
            <% else %>
              <span class="text-sm font-medium text-gray-500">
                <%= item.title %>
              </span>
            <% end %>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end
  
  @doc """
  主内容容器组件
  """
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  slot :inner_block, required: true, doc: "内容"
  
  def main_content(assigns) do
    ~H"""
    <main
      class={[
        "main-content",
        "bg-white rounded-lg shadow",
        "p-6",
        @class
      ]}
      data-main-content
    >
      <%= render_slot(@inner_block) %>
    </main>
    """
  end
  
  # Private components
  
  defp menu_item(assigns) do
    ~H"""
    <div>
      <%= if @item[:children] do %>
        <!-- 有子菜单的项 -->
        <button
          type="button"
          class={[
            "group flex w-full items-center rounded-md px-2 py-2 text-sm font-medium",
            "text-gray-900 hover:bg-gray-100 hover:text-gray-900",
            is_active?(@current_path, @item) && "bg-gray-100"
          ]}
          phx-click={JS.toggle(to: "#submenu-#{@item.key}") |> JS.push("menu_click", value: %{key: @item.key})}
          data-menu-item={@item.key}
          data-has-children
          data-active={is_active?(@current_path, @item)}
        >
          <.icon :if={@item[:icon]} name={@item.icon} class="mr-3 h-5 w-5 flex-shrink-0" />
          <span :if={!@collapsed} class="flex-1"><%= @item.title %></span>
          <.icon
            :if={!@collapsed}
            name="hero-chevron-down"
            class="ml-auto h-5 w-5 transition-transform group-data-[expanded]:rotate-180"
          />
        </button>
        
        <!-- 子菜单 -->
        <div
          :if={!@collapsed}
          id={"submenu-#{@item.key}"}
          class="hidden space-y-1"
          data-submenu={@item.key}
          data-expanded={if is_active?(@current_path, @item), do: "true"}
        >
          <%= for child <- @item.children do %>
            <button
              type="button"
              phx-click="menu_click"
              phx-value-key={child.key}
              class={[
                "group flex w-full items-center rounded-md py-2 pl-11 pr-2 text-sm font-medium text-left",
                "text-gray-600 hover:bg-gray-100 hover:text-gray-900",
                @current_path == child.path && "bg-gray-100 text-gray-900"
              ]}
              data-menu-item={child.key}
            >
              <%= child.title %>
            </button>
          <% end %>
        </div>
      <% else %>
        <!-- 无子菜单的项 -->
        <button
          type="button"
          phx-click="menu_click"
          phx-value-key={@item.key}
          class={[
            "group flex w-full items-center rounded-md px-2 py-2 text-sm font-medium text-left",
            "text-gray-900 hover:bg-gray-100 hover:text-gray-900",
            @current_path == @item.path && "bg-gray-100 menu-item-active",
            is_active?(@current_path, @item) && "bg-gray-100 menu-item-active"
          ]}
          data-menu-item={@item.key}
          data-active={@current_path == @item.path}
        >
          <.icon :if={@item[:icon]} name={@item.icon} class="mr-3 h-5 w-5 flex-shrink-0" />
          <span :if={!@collapsed}><%= @item.title %></span>
        </button>
      <% end %>
    </div>
    """
  end
  
  # Helper functions
  
  defp is_active?(current_path, item) do
    if item[:children] do
      Enum.any?(item.children, &(&1.path == current_path))
    else
      item[:path] == current_path
    end
  end
  
  defp default_menu_items do
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
          %{key: "product-create", title: "新建商品", path: "/products/new"}
        ]
      },
      %{
        key: "orders",
        title: "订单管理",
        icon: "hero-clipboard-document-list",
        children: [
          %{key: "order-list", title: "订单列表", path: "/orders"},
          %{key: "order-ship", title: "批量发货", path: "/orders/ship"}
        ]
      },
      %{
        key: "settings",
        title: "系统设置",
        icon: "hero-cog-6-tooth",
        path: "/settings"
      }
    ]
  end
end