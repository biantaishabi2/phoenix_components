defmodule ShopUxPhoenixWeb.DropdownDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.CoreComponents
  import PetalComponents.Custom.Dropdown
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dropdown 下拉菜单组件")
     |> assign(:selected_item, nil)
     |> assign(:last_action, nil)
     |> assign(:show_notification, false)}
  end

  def handle_event("menu_action", %{"action" => action}, socket) do
    socket = 
      socket
      |> assign(:last_action, action)
      |> assign(:show_notification, true)
      |> clear_notification()
    
    {:noreply, socket}
  end

  def handle_event("view_profile", _params, socket) do
    {:noreply, assign(socket, :last_action, "查看个人资料")}
  end

  def handle_event("open_settings", _params, socket) do
    {:noreply, assign(socket, :last_action, "打开设置")}
  end

  def handle_event("logout", _params, socket) do
    {:noreply, assign(socket, :last_action, "退出登录")}
  end

  def handle_event("batch_export", _params, socket) do
    {:noreply, assign(socket, :last_action, "批量导出")}
  end

  def handle_event("batch_delete", _params, socket) do
    {:noreply, assign(socket, :last_action, "批量删除")}
  end

  def handle_event("clear_notification", _params, socket) do
    {:noreply, assign(socket, :show_notification, false)}
  end

  defp clear_notification(socket) do
    if socket.assigns.show_notification do
      Process.send_after(self(), :clear_notification, 3000)
    end
    socket
  end

  def handle_info(:clear_notification, socket) do
    {:noreply, assign(socket, :show_notification, false)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">Dropdown 下拉菜单组件</h1>
      
      <!-- 通知消息 -->
      <div :if={@show_notification} 
           class="fixed top-4 right-4 bg-green-500 text-white px-4 py-2 rounded shadow-lg z-50 transition-opacity duration-300">
        操作: <%= @last_action %>
      </div>
      
      <div class="space-y-12">
        <!-- 基础用法 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">基础用法</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown id="basic-dropdown">
              <:trigger>
                <.button>
                  基础下拉菜单
                  <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                </.button>
              </:trigger>
              <:items key="view" label="查看详情" on_click={JS.push("menu_action", value: %{action: "view"})} />
              <:items key="edit" label="编辑" on_click={JS.push("menu_action", value: %{action: "edit"})} />
              <:items key="share" label="分享" on_click={JS.push("menu_action", value: %{action: "share"})} />
            </.dropdown>
          </div>
        </section>

        <!-- 触发方式 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">触发方式</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">点击触发（默认）</h3>
              <.dropdown id="click-dropdown">
                <:trigger>
                  <.button>
                    点击我
                    <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                  </.button>
                </:trigger>
                <:items key="option1" label="选项 1" on_click={JS.push("menu_action", value: %{action: "option1"})} />
                <:items key="option2" label="选项 2" on_click={JS.push("menu_action", value: %{action: "option2"})} />
              </.dropdown>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">悬停触发</h3>
              <.dropdown id="hover-dropdown" trigger_type="hover">
                <:trigger>
                  <span class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md cursor-pointer hover:bg-gray-50">
                    悬停我
                    <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                  </span>
                </:trigger>
                <:items key="hover1" label="悬停选项 1" on_click={JS.push("menu_action", value: %{action: "hover1"})} />
                <:items key="hover2" label="悬停选项 2" on_click={JS.push("menu_action", value: %{action: "hover2"})} />
              </.dropdown>
            </div>
          </div>
        </section>

        <!-- 带图标的菜单 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">带图标的菜单</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown id="icon-dropdown">
              <:trigger>
                <.button>
                  文件操作
                  <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                </.button>
              </:trigger>
              <:items key="new" label="新建文件" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>)} on_click={JS.push("menu_action", value: %{action: "new"})} />
              <:items key="open" label="打开文件" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg>)} on_click={JS.push("menu_action", value: %{action: "open"})} />
              <:items key="save" label="保存" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" /></svg>)} on_click={JS.push("menu_action", value: %{action: "save"})} />
            </.dropdown>
          </div>
        </section>

        <!-- 不同位置 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同位置</h2>
          <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
            <div class="bg-white p-6 rounded-lg shadow text-center">
              <.dropdown id="bottom-start-dropdown" position="bottom-start">
                <:trigger>
                  <.button>下方左对齐</.button>
                </:trigger>
                <:items key="item1" label="菜单项 1" />
                <:items key="item2" label="菜单项 2" />
              </.dropdown>
            </div>

            <div class="bg-white p-6 rounded-lg shadow text-center">
              <.dropdown id="bottom-end-dropdown" position="bottom-end">
                <:trigger>
                  <.button>下方右对齐</.button>
                </:trigger>
                <:items key="item1" label="菜单项 1" />
                <:items key="item2" label="菜单项 2" />
              </.dropdown>
            </div>

            <div class="bg-white p-6 rounded-lg shadow text-center">
              <.dropdown id="top-start-dropdown" position="top-start">
                <:trigger>
                  <.button>上方左对齐</.button>
                </:trigger>
                <:items key="item1" label="菜单项 1" />
                <:items key="item2" label="菜单项 2" />
              </.dropdown>
            </div>

            <div class="bg-white p-6 rounded-lg shadow text-center">
              <.dropdown id="top-end-dropdown" position="top-end">
                <:trigger>
                  <.button>上方右对齐</.button>
                </:trigger>
                <:items key="item1" label="菜单项 1" />
                <:items key="item2" label="菜单项 2" />
              </.dropdown>
            </div>

            <div class="bg-white p-6 rounded-lg shadow text-center">
              <.dropdown id="left-dropdown" position="left">
                <:trigger>
                  <.button>左侧</.button>
                </:trigger>
                <:items key="item1" label="菜单项 1" />
                <:items key="item2" label="菜单项 2" />
              </.dropdown>
            </div>

            <div class="bg-white p-6 rounded-lg shadow text-center">
              <.dropdown id="right-dropdown" position="right">
                <:trigger>
                  <.button>右侧</.button>
                </:trigger>
                <:items key="item1" label="菜单项 1" />
                <:items key="item2" label="菜单项 2" />
              </.dropdown>
            </div>
          </div>
        </section>

        <!-- 禁用状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">禁用状态</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown id="disabled-dropdown" disabled>
              <:trigger>
                <.button disabled>已禁用</.button>
              </:trigger>
              <:items key="item1" label="菜单项 1" />
              <:items key="item2" label="菜单项 2" />
            </.dropdown>
          </div>
        </section>

        <!-- 分隔线和危险项 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">分隔线和危险项</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown id="actions-dropdown">
              <:trigger>
                <.button>
                  操作菜单
                  <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                </.button>
              </:trigger>
              <:items key="copy" label="复制" on_click={JS.push("menu_action", value: %{action: "copy"})} />
              <:items key="paste" label="粘贴" on_click={JS.push("menu_action", value: %{action: "paste"})} />
              <:items divider />
              <:items key="archive" label="归档" on_click={JS.push("menu_action", value: %{action: "archive"})} />
              <:items key="export" label="导出" disabled />
              <:items divider />
              <:items key="delete" label="删除" danger on_click={JS.push("menu_action", value: %{action: "delete"})} />
            </.dropdown>
          </div>
        </section>

        <!-- 批量操作 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">批量操作</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown id="batch-dropdown">
              <:trigger>
                <.button>
                  批量操作
                  <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                </.button>
              </:trigger>
              <:items key="export" label="批量导出" on_click={JS.push("batch_export")} />
              <:items key="archive" label="批量归档" on_click={JS.push("menu_action", value: %{action: "batch_archive"})} />
              <:items key="move" label="批量移动" on_click={JS.push("menu_action", value: %{action: "batch_move"})} />
              <:items divider />
              <:items key="delete" label="批量删除" danger on_click={JS.push("batch_delete")} />
            </.dropdown>
          </div>
        </section>

        <!-- 自定义内容 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">自定义内容</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown id="user-dropdown" menu_class="w-64">
              <:trigger>
                <button class="flex items-center space-x-2 px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50">
                  <img src="https://ui-avatars.com/api/?name=Zhang+San&background=6366f1&color=fff" 
                       class="w-8 h-8 rounded-full" />
                  <span>张三</span>
                  <.icon name="hero-chevron-down-mini" class="w-4 h-4" />
                </button>
              </:trigger>
              <:items>
                <div class="px-4 py-3 border-b border-gray-200">
                  <div class="flex items-center">
                    <img src="https://ui-avatars.com/api/?name=Zhang+San&background=6366f1&color=fff" 
                         class="w-10 h-10 rounded-full mr-3" />
                    <div>
                      <div class="font-medium text-gray-900">张三</div>
                      <div class="text-sm text-gray-500">admin@example.com</div>
                    </div>
                  </div>
                </div>
              </:items>
              <:items key="profile" label="个人资料" on_click={JS.push("view_profile")} />
              <:items key="settings" label="设置" on_click={JS.push("open_settings")} />
              <:items divider />
              <:items key="logout" label="退出登录" on_click={JS.push("logout")} />
            </.dropdown>
          </div>
        </section>

        <!-- 自定义样式 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">自定义样式</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.dropdown 
              id="custom-dropdown"
              menu_class="bg-gray-900 text-white border-gray-700"
            >
              <:trigger>
                <.button>
                  深色主题
                  <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
                </.button>
              </:trigger>
              <:items key="item1" label="深色菜单项 1" on_click={JS.push("menu_action", value: %{action: "dark1"})} />
              <:items key="item2" label="深色菜单项 2" on_click={JS.push("menu_action", value: %{action: "dark2"})} />
              <:items divider />
              <:items key="item3" label="深色菜单项 3" on_click={JS.push("menu_action", value: %{action: "dark3"})} />
            </.dropdown>
          </div>
        </section>

        <!-- 实际应用场景 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">实际应用场景</h2>
          
          <!-- 表格行操作 -->
          <div class="mb-6">
            <h3 class="text-lg font-medium mb-3">表格行操作</h3>
            <div class="bg-white p-6 rounded-lg shadow">
              <table class="min-w-full divide-y divide-gray-200">
                <thead>
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">订单号</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">状态</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">金额</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">ORD-001</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">待发货</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">¥128.00</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <.dropdown id="row-dropdown-1" position="bottom-end">
                        <:trigger>
                          <button class="p-1 rounded hover:bg-gray-100">
                            <.icon name="hero-ellipsis-horizontal" class="w-5 h-5" />
                          </button>
                        </:trigger>
                        <:items key="view" label="查看详情" on_click={JS.push("menu_action", value: %{action: "view_order"})} />
                        <:items key="ship" label="发货" on_click={JS.push("menu_action", value: %{action: "ship_order"})} />
                        <:items divider />
                        <:items key="cancel" label="取消订单" danger on_click={JS.push("menu_action", value: %{action: "cancel_order"})} />
                      </.dropdown>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- 导航栏用户菜单 -->
          <div>
            <h3 class="text-lg font-medium mb-3">导航栏用户菜单</h3>
            <div class="bg-gray-800 p-4 rounded-lg shadow">
              <nav class="flex justify-between items-center">
                <div class="text-white font-bold text-xl">Logo</div>
                <.dropdown id="nav-user-dropdown" position="bottom-end" menu_class="w-56">
                  <:trigger>
                    <button class="flex items-center space-x-2 text-white hover:text-gray-300">
                      <img src="https://ui-avatars.com/api/?name=User&background=4f46e5&color=fff" 
                           class="w-8 h-8 rounded-full" />
                      <span>用户名</span>
                      <.icon name="hero-chevron-down-mini" class="w-4 h-4" />
                    </button>
                  </:trigger>
                  <:items key="dashboard" label="控制台" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>)} on_click={JS.push("menu_action", value: %{action: "dashboard"})} />
                  <:items key="profile" label="个人资料" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>)} on_click={JS.push("menu_action", value: %{action: "profile"})} />
                  <:items key="settings" label="设置" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /></svg>)} on_click={JS.push("menu_action", value: %{action: "settings"})} />
                  <:items divider />
                  <:items key="logout" label="退出" icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" /></svg>)} on_click={JS.push("menu_action", value: %{action: "logout"})} />
                </.dropdown>
              </nav>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end
end