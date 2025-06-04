defmodule ShopUxPhoenixWeb.StatusBadgeDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.StatusBadge

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "StatusBadge 状态徽章组件")
     |> assign(:orders, [
       %{id: 1, number: "ORD-2024-001", status: "pending", amount: "299.00"},
       %{id: 2, number: "ORD-2024-002", status: "paid", amount: "599.00"},
       %{id: 3, number: "ORD-2024-003", status: "shipped", amount: "1299.00"},
       %{id: 4, number: "ORD-2024-004", status: "completed", amount: "899.00"},
       %{id: 5, number: "ORD-2024-005", status: "cancelled", amount: "199.00"}
     ])}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 w-full">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">StatusBadge 状态徽章组件</h1>
      
      <!-- 基础用法 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础用法</h2>
        <div class="flex flex-wrap gap-3">
          <.status_badge text="默认" />
          <.status_badge text="成功" type="success" />
          <.status_badge text="处理中" type="processing" />
          <.status_badge text="警告" type="warning" />
          <.status_badge text="错误" type="error" />
          <.status_badge text="信息" type="info" />
        </div>
      </section>

      <!-- 状态类型 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">状态类型</h2>
        <p class="text-gray-600 mb-4">组件内置了多种状态类型，每种类型有对应的颜色主题。</p>
        <div class="flex flex-wrap gap-3">
          <.status_badge text="默认 (default)" type="default" />
          <.status_badge text="成功 (success)" type="success" />
          <.status_badge text="处理中 (processing)" type="processing" />
          <.status_badge text="警告 (warning)" type="warning" />
          <.status_badge text="错误 (error)" type="error" />
          <.status_badge text="信息 (info)" type="info" />
        </div>
      </section>

      <!-- 带图标 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">带图标</h2>
        <div class="flex flex-wrap gap-3">
          <.status_badge text="已发货" type="success" icon="hero-truck" />
          <.status_badge text="待付款" type="warning" icon="hero-credit-card" />
          <.status_badge text="处理中" type="processing" icon="hero-arrow-path" />
          <.status_badge text="已完成" type="success" icon="hero-check-circle" />
          <.status_badge text="已取消" type="error" icon="hero-x-circle" />
        </div>
      </section>

      <!-- 状态点 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">状态点</h2>
        <div class="space-y-3">
          <div class="flex items-center gap-2">
            <.status_badge type="success" dot />
            <span>在线</span>
          </div>
          <div class="flex items-center gap-2">
            <.status_badge type="error" dot />
            <span>离线</span>
          </div>
          <div class="flex items-center gap-2">
            <.status_badge type="warning" dot />
            <span>忙碌</span>
          </div>
          <div class="flex items-center gap-2">
            <.status_badge type="processing" dot />
            <span>会议中</span>
          </div>
        </div>
      </section>

      <!-- 不同尺寸 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">不同尺寸</h2>
        <div class="space-y-4">
          <div class="flex items-center gap-3">
            <.status_badge text="小尺寸" type="info" size="small" />
            <.status_badge text="小尺寸" type="success" size="small" icon="hero-check" />
            <.status_badge type="success" dot size="small" />
          </div>
          <div class="flex items-center gap-3">
            <.status_badge text="中等尺寸" type="info" size="medium" />
            <.status_badge text="中等尺寸" type="success" size="medium" icon="hero-check" />
            <.status_badge type="success" dot size="medium" />
          </div>
          <div class="flex items-center gap-3">
            <.status_badge text="大尺寸" type="info" size="large" />
            <.status_badge text="大尺寸" type="success" size="large" icon="hero-check" />
            <.status_badge type="success" dot size="large" />
          </div>
        </div>
      </section>

      <!-- 自定义颜色 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">自定义颜色</h2>
        <div class="flex flex-wrap gap-3">
          <.status_badge text="VIP" color="purple" />
          <.status_badge text="热销" color="orange" />
          <.status_badge text="新品" color="pink" />
          <.status_badge text="限时" color="indigo" />
          <.status_badge text="推荐" color="teal" />
        </div>
      </section>

      <!-- 边框样式 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">边框样式</h2>
        <div class="space-y-4">
          <div>
            <p class="text-sm text-gray-600 mb-2">有边框（默认）</p>
            <div class="flex flex-wrap gap-3">
              <.status_badge text="成功" type="success" />
              <.status_badge text="警告" type="warning" />
              <.status_badge text="错误" type="error" />
            </div>
          </div>
          <div>
            <p class="text-sm text-gray-600 mb-2">无边框</p>
            <div class="flex flex-wrap gap-3">
              <.status_badge text="成功" type="success" bordered={false} />
              <.status_badge text="警告" type="warning" bordered={false} />
              <.status_badge text="错误" type="error" bordered={false} />
            </div>
          </div>
        </div>
      </section>

      <!-- 业务场景示例 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">业务场景示例</h2>
        
        <!-- 订单状态 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-3">订单状态</h3>
          <div class="flex flex-wrap gap-3">
            <%= for status <- ["pending", "paid", "shipped", "completed", "cancelled", "refunding"] do %>
              <.order_status_badge status={status} />
            <% end %>
          </div>
        </div>

        <!-- 用户状态 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-3">用户状态</h3>
          <div class="flex flex-wrap gap-3">
            <%= for status <- ["active", "inactive", "pending"] do %>
              <.user_status_badge status={status} />
            <% end %>
          </div>
        </div>

        <!-- 商品状态 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-3">商品状态</h3>
          <div class="flex flex-wrap gap-3">
            <%= for status <- ["on_sale", "out_of_stock", "off_shelf", "pre_sale"] do %>
              <.product_status_badge status={status} />
            <% end %>
          </div>
        </div>

        <!-- 审核状态 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-3">审核状态</h3>
          <div class="flex flex-wrap gap-3">
            <%= for status <- ["pending", "approved", "rejected"] do %>
              <.review_status_badge status={status} />
            <% end %>
          </div>
        </div>
      </section>

      <!-- 在表格中使用 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">在表格中使用</h2>
        <div class="bg-white rounded-lg shadow overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  订单号
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  状态
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  金额
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for order <- @orders do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= order.number %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <.order_status_badge status={order.status} />
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    ¥<%= order.amount %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 组合使用 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">组合使用</h2>
        <div class="space-y-4">
          <div class="flex items-center gap-4 p-4 bg-white rounded-lg shadow">
            <.status_badge text="库存:" type="info" />
            <span class="text-2xl font-bold">128</span>
            <.status_badge text="-12%" type="error" size="small" />
          </div>
          
          <div class="flex items-center gap-4 p-4 bg-white rounded-lg shadow">
            <.status_badge text="在线用户" type="success" icon="hero-users" />
            <span class="text-xl font-semibold">3,456</span>
            <.status_badge text="+5.2%" type="success" size="small" bordered={false} />
          </div>
          
          <div class="flex items-center gap-4 p-4 bg-white rounded-lg shadow">
            <div class="flex items-center gap-2">
              <.status_badge type="processing" dot />
              <span class="text-gray-600">服务状态</span>
            </div>
            <.status_badge text="运行中" type="processing" />
            <span class="text-sm text-gray-500">已运行 45 天</span>
          </div>
        </div>
      </section>

      <!-- 实际应用示例 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">实际应用示例</h2>
        
        <!-- 产品卡片 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-start mb-4">
              <h3 class="text-lg font-medium">iPhone 15 Pro</h3>
              <.status_badge text="热销" color="orange" size="small" />
            </div>
            <p class="text-gray-600 mb-4">最新款专业级智能手机</p>
            <div class="flex justify-between items-center">
              <span class="text-2xl font-bold">¥8,999</span>
              <.product_status_badge status="on_sale" />
            </div>
          </div>
          
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-start mb-4">
              <h3 class="text-lg font-medium">AirPods Pro</h3>
              <.status_badge text="新品" color="pink" size="small" />
            </div>
            <p class="text-gray-600 mb-4">主动降噪无线耳机</p>
            <div class="flex justify-between items-center">
              <span class="text-2xl font-bold">¥1,999</span>
              <.product_status_badge status="pre_sale" />
            </div>
          </div>
          
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-start mb-4">
              <h3 class="text-lg font-medium">MacBook Air</h3>
              <.status_badge text="限量" color="purple" size="small" />
            </div>
            <p class="text-gray-600 mb-4">轻薄便携笔记本电脑</p>
            <div class="flex justify-between items-center">
              <span class="text-2xl font-bold">¥7,999</span>
              <.product_status_badge status="out_of_stock" />
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end
end