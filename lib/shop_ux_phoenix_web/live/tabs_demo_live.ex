defmodule ShopUxPhoenixWeb.TabsDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Tabs
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Tabs 标签页组件")
     |> assign(:basic_active_tab, "tab1")
     |> assign(:icon_active_tab, "home")
     |> assign(:type_line_tab, "line1")
     |> assign(:type_card_tab, "card1")
     |> assign(:type_pills_tab, "pills1")
     |> assign(:controlled_tab, "ctrl-orders")
     |> assign(:position_top_tab, "top1")
     |> assign(:position_right_tab, "right1")
     |> assign(:position_bottom_tab, "bottom1")
     |> assign(:position_left_tab, "left1")
     |> assign(:animated_tab, "anim1")
     |> assign(:no_anim_tab, "noanim1")
     |> assign_demo_data()}
  end

  def handle_event("change_tab", %{"tab" => tab_key}, socket) do
    # 更新对应的标签页状态
    {:noreply, assign(socket, :basic_active_tab, tab_key)}
  end

  def handle_event("set_active_tab", %{"tab" => tab_key}, socket) do
    {:noreply, assign(socket, :controlled_tab, tab_key)}
  end

  defp assign_demo_data(socket) do
    socket
    |> assign(:orders, [
      %{id: 1, order_no: "ORD-2024-001", amount: "$120.00", status: "已发货"},
      %{id: 2, order_no: "ORD-2024-002", amount: "$85.50", status: "处理中"},
      %{id: 3, order_no: "ORD-2024-003", amount: "$200.00", status: "已完成"}
    ])
    |> assign(:products, [
      %{id: 1, name: "产品 A", price: "$50.00", stock: 100},
      %{id: 2, name: "产品 B", price: "$75.00", stock: 50},
      %{id: 3, name: "产品 C", price: "$120.00", stock: 20}
    ])
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">Tabs 标签页组件</h1>
      
      <div class="space-y-12">
        <!-- 基础用法 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">基础用法</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tabs active_tab={@basic_active_tab} on_change={JS.push("change_tab")}>
              <:tabs key="tab1" label="标签一">
                <div class="p-4">
                  <h3 class="text-lg font-semibold mb-2">第一个标签页的内容</h3>
                  <p class="text-gray-600">这是标签一的内容区域。你可以在这里放置任何内容，比如表单、列表或其他组件。</p>
                </div>
              </:tabs>
              <:tabs key="tab2" label="标签二">
                <div class="p-4">
                  <h3 class="text-lg font-semibold mb-2">第二个标签页的内容</h3>
                  <p class="text-gray-600">这是标签二的内容区域。标签页可以帮助你组织和分类信息。</p>
                </div>
              </:tabs>
              <:tabs key="tab3" label="标签三">
                <div class="p-4">
                  <h3 class="text-lg font-semibold mb-2">第三个标签页的内容</h3>
                  <p class="text-gray-600">这是标签三的内容区域。每个标签页的内容都是独立的。</p>
                </div>
              </:tabs>
            </.tabs>
          </div>
        </section>

        <!-- 带图标的标签页 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">带图标的标签页</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tabs active_tab={@icon_active_tab}>
              <:tabs 
                key="home" 
                label="首页"
                icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>)}
              >
                <div class="p-4">
                  <p>首页内容</p>
                </div>
              </:tabs>
              <:tabs 
                key="profile" 
                label="个人资料"
                icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>)}
              >
                <div class="p-4">
                  <p>个人资料内容</p>
                </div>
              </:tabs>
              <:tabs 
                key="settings" 
                label="设置"
                icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /></svg>)}
              >
                <div class="p-4">
                  <p>设置内容</p>
                </div>
              </:tabs>
            </.tabs>
          </div>
        </section>

        <!-- 不同类型 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同类型</h2>
          <div class="space-y-6">
            <!-- 线条风格 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">线条风格（默认）</h3>
              <.tabs type="line" active_tab={@type_line_tab}>
                <:tabs key="line1" label="线条风格1">
                  <div class="p-4">线条风格内容1</div>
                </:tabs>
                <:tabs key="line2" label="线条风格2">
                  <div class="p-4">线条风格内容2</div>
                </:tabs>
              </.tabs>
            </div>

            <!-- 卡片风格 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">卡片风格</h3>
              <.tabs type="card" active_tab={@type_card_tab}>
                <:tabs key="card1" label="卡片风格1">
                  <div class="p-4">卡片风格内容1</div>
                </:tabs>
                <:tabs key="card2" label="卡片风格2">
                  <div class="p-4">卡片风格内容2</div>
                </:tabs>
              </.tabs>
            </div>

            <!-- 药丸风格 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">药丸风格</h3>
              <.tabs type="pills" active_tab={@type_pills_tab}>
                <:tabs key="pills1" label="药丸风格1">
                  <div class="p-4">药丸风格内容1</div>
                </:tabs>
                <:tabs key="pills2" label="药丸风格2">
                  <div class="p-4">药丸风格内容2</div>
                </:tabs>
              </.tabs>
            </div>
          </div>
        </section>

        <!-- 不同尺寸 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同尺寸</h2>
          <div class="space-y-6">
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">小尺寸</h3>
              <.tabs size="small" active_tab="small1">
                <:tabs key="small1" label="小尺寸标签1">
                  <div class="p-4">小尺寸内容</div>
                </:tabs>
                <:tabs key="small2" label="小尺寸标签2">
                  <div class="p-4">小尺寸内容</div>
                </:tabs>
              </.tabs>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">中等尺寸（默认）</h3>
              <.tabs size="medium" active_tab="medium1">
                <:tabs key="medium1" label="中等尺寸标签1">
                  <div class="p-4">中等尺寸内容</div>
                </:tabs>
                <:tabs key="medium2" label="中等尺寸标签2">
                  <div class="p-4">中等尺寸内容</div>
                </:tabs>
              </.tabs>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">大尺寸</h3>
              <.tabs size="large" active_tab="large1">
                <:tabs key="large1" label="大尺寸标签1">
                  <div class="p-4">大尺寸内容</div>
                </:tabs>
                <:tabs key="large2" label="大尺寸标签2">
                  <div class="p-4">大尺寸内容</div>
                </:tabs>
              </.tabs>
            </div>
          </div>
        </section>

        <!-- 禁用状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">禁用状态</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tabs active_tab="enabled1">
              <:tabs key="enabled1" label="可用标签1">
                <div class="p-4">正常内容1</div>
              </:tabs>
              <:tabs key="disabled" label="禁用标签" disabled>
                <div class="p-4">这个标签页被禁用了</div>
              </:tabs>
              <:tabs key="enabled2" label="可用标签2">
                <div class="p-4">正常内容2</div>
              </:tabs>
            </.tabs>
          </div>
        </section>

        <!-- 不同位置 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同位置</h2>
          <div class="space-y-6">
            <!-- 标签在顶部 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">标签在顶部（默认）</h3>
              <.tabs position="top" active_tab={@position_top_tab}>
                <:tabs key="top1" label="顶部标签1">
                  <div class="p-4">顶部位置内容1</div>
                </:tabs>
                <:tabs key="top2" label="顶部标签2">
                  <div class="p-4">顶部位置内容2</div>
                </:tabs>
              </.tabs>
            </div>

            <!-- 标签在右侧 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">标签在右侧</h3>
              <.tabs position="right" active_tab={@position_right_tab}>
                <:tabs key="right1" label="右侧标签1">
                  <div class="p-4">右侧位置内容1</div>
                </:tabs>
                <:tabs key="right2" label="右侧标签2">
                  <div class="p-4">右侧位置内容2</div>
                </:tabs>
              </.tabs>
            </div>

            <!-- 标签在底部 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">标签在底部</h3>
              <.tabs position="bottom" active_tab={@position_bottom_tab}>
                <:tabs key="bottom1" label="底部标签1">
                  <div class="p-4">底部位置内容1</div>
                </:tabs>
                <:tabs key="bottom2" label="底部标签2">
                  <div class="p-4">底部位置内容2</div>
                </:tabs>
              </.tabs>
            </div>

            <!-- 标签在左侧 -->
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">标签在左侧</h3>
              <.tabs position="left" active_tab={@position_left_tab}>
                <:tabs key="left1" label="左侧标签1">
                  <div class="p-4">左侧位置内容1</div>
                </:tabs>
                <:tabs key="left2" label="左侧标签2">
                  <div class="p-4">左侧位置内容2</div>
                </:tabs>
              </.tabs>
            </div>
          </div>
        </section>

        <!-- 动画控制 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">动画控制</h2>
          <div class="space-y-6">
            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">有动画效果（默认）</h3>
              <.tabs animated={true} active_tab={@animated_tab}>
                <:tabs key="anim1" label="动画标签1">
                  <div class="p-4">切换时有淡入淡出效果</div>
                </:tabs>
                <:tabs key="anim2" label="动画标签2">
                  <div class="p-4">平滑过渡</div>
                </:tabs>
              </.tabs>
            </div>

            <div class="bg-white p-6 rounded-lg shadow">
              <h3 class="text-lg font-medium mb-4">无动画效果</h3>
              <.tabs animated={false} active_tab={@no_anim_tab}>
                <:tabs key="noanim1" label="无动画标签1">
                  <div class="p-4">切换时立即显示</div>
                </:tabs>
                <:tabs key="noanim2" label="无动画标签2">
                  <div class="p-4">没有过渡效果</div>
                </:tabs>
              </.tabs>
            </div>
          </div>
        </section>

        <!-- 受控模式 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">受控模式</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="mb-4">
              <p class="text-sm text-gray-600">当前激活: <span class="font-semibold"><%= @controlled_tab %></span></p>
            </div>
            <.tabs active_tab={@controlled_tab} on_change={JS.push("set_active_tab")}>
              <:tabs key="ctrl-orders" label="订单">
                <div class="p-4">订单管理内容</div>
              </:tabs>
              <:tabs key="ctrl-products" label="商品">
                <div class="p-4">商品管理内容</div>
              </:tabs>
              <:tabs key="ctrl-users" label="用户">
                <div class="p-4">用户管理内容</div>
              </:tabs>
            </.tabs>
          </div>
        </section>

        <!-- 复杂示例 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">复杂示例</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tabs type="card" size="large" active_tab="orders">
              <:tabs 
                key="orders" 
                label="订单管理"
                icon={~s(<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" /></svg>)}
              >
                <div class="p-4">
                  <h3 class="text-lg font-semibold mb-4">订单列表</h3>
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">订单号</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">金额</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">状态</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for order <- @orders do %>
                        <tr>
                          <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= order.order_no %></td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= order.amount %></td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= order.status %></td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </:tabs>
              
              <:tabs 
                key="products" 
                label="商品管理"
                icon={~s(<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>)}
              >
                <div class="p-4">
                  <h3 class="text-lg font-semibold mb-4">商品列表</h3>
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">商品名</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">价格</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">库存</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for product <- @products do %>
                        <tr>
                          <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= product.name %></td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= product.price %></td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= product.stock %></td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </:tabs>
              
              <:tabs 
                key="stats" 
                label="统计分析" 
                disabled
                icon={~s(<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" /></svg>)}
              >
                <div class="p-4">统计功能开发中...</div>
              </:tabs>
            </.tabs>
          </div>
        </section>
      </div>
    </div>
    """
  end
end