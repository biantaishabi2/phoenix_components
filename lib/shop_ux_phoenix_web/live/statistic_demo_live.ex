defmodule ShopUxPhoenixWeb.StatisticDemoLive do
  @moduledoc """
  LiveView for testing Statistic component interactions
  """
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Statistic
  
  def render(assigns) do
    ~H"""
    <div class="p-8 space-y-8">
      <h1 class="text-2xl font-bold mb-6">Statistic 统计数值组件交互测试</h1>
      
      <!-- 基本统计数值 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">基本统计数值</h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="total-users"
              title="总用户"
              value={@total_users}
              color="info"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="active-users"
              title="活跃用户"
              value={@active_users}
              color="success"
              trend="up"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="monthly-revenue"
              title="本月收入"
              value={@monthly_revenue}
              precision={2}
              prefix_text="¥"
              color="warning"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="conversion-rate"
              title="转化率"
              value={@conversion_rate}
              precision={1}
              suffix_text="%"
              color="info"
            />
          </div>
        </div>
      </div>
      
      <!-- 实时数据模拟 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">实时数据模拟</h2>
        <div class="flex space-x-4 mb-4">
          <button 
            type="button"
            phx-click="start_realtime"
            disabled={@realtime_active}
            class="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50">
            开始实时更新
          </button>
          <button 
            type="button"
            phx-click="stop_realtime"
            disabled={!@realtime_active}
            class="px-4 py-2 bg-red-500 text-white rounded disabled:opacity-50">
            停止实时更新
          </button>
          <button 
            type="button"
            phx-click="manual_update"
            class="px-4 py-2 bg-green-500 text-white rounded">
            手动更新
          </button>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="realtime-visitors"
              title="实时访问"
              value={@realtime_visitors}
              color="info"
              animation={true}
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="realtime-orders"
              title="实时订单"
              value={@realtime_orders}
              color="success"
              trend={@orders_trend}
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="realtime-revenue"
              title="实时收入"
              value={@realtime_revenue}
              precision={2}
              prefix_text="¥"
              color="info"
              trend={@revenue_trend}
            />
          </div>
        </div>
      </div>
      
      <!-- 加载状态演示 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">加载状态演示</h2>
        <div class="flex space-x-4 mb-4">
          <button 
            type="button"
            phx-click="toggle_loading"
            class="px-4 py-2 bg-purple-500 text-white rounded">
            切换加载状态
          </button>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="loading-stat-1"
              title="数据加载中"
              value={@loading_value_1}
              loading={@is_loading}
              color="info"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="loading-stat-2"
              title="处理中"
              value={@loading_value_2}
              loading={@is_loading}
              color="info"
            />
          </div>
        </div>
      </div>
      
      <!-- 不同颜色主题 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">不同颜色主题</h2>
        <div class="grid grid-cols-2 md:grid-cols-6 gap-4">
          <%= for {color, value, title, idx} <- [
            {"info", 1234, "默认", 1},
            {"info", 5678, "主要", 2},
            {"success", 9012, "成功", 3},
            {"warning", 3456, "警告", 4},
            {"danger", 7890, "危险", 5},
            {"info", 2468, "信息", 6}
          ] do %>
            <div class="bg-white p-4 rounded-lg shadow">
              <.statistic 
                id={"color-#{color}-#{idx}"}
                title={title}
                value={value}
                color={color}
              />
            </div>
          <% end %>
        </div>
      </div>
      
      <!-- 前缀后缀演示 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">前缀后缀演示</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="prefix-suffix-demo"
              title="温度"
              value={25}
              suffix_text="°C"
              color="info"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="currency-demo"
              title="账户余额"
              value={12345.67}
              precision={2}
              prefix_text="$"
              color="success"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic id="slot-demo" title="评分" value={4.5} color="warning">
              <:prefix>
                <svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                </svg>
              </:prefix>
              <:suffix>
                <span class="text-gray-500 text-sm">/ 5.0</span>
              </:suffix>
            </.statistic>
          </div>
        </div>
      </div>
      
      <!-- 趋势指示器 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">趋势指示器</h2>
        <div class="flex space-x-4 mb-4">
          <button 
            type="button"
            phx-click="change_trend"
            phx-value-type="up"
            class="px-4 py-2 bg-green-500 text-white rounded">
            设置上升趋势
          </button>
          <button 
            type="button"
            phx-click="change_trend"
            phx-value-type="down"
            class="px-4 py-2 bg-red-500 text-white rounded">
            设置下降趋势
          </button>
          <button 
            type="button"
            phx-click="change_trend"
            phx-value-type="none"
            class="px-4 py-2 bg-gray-500 text-white rounded">
            无趋势
          </button>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="trend-demo-1"
              title="销售额"
              value={@trend_value_1}
              prefix_text="¥"
              trend={@current_trend}
              color="info"
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <.statistic 
              id="trend-demo-2"
              title="用户增长"
              value={@trend_value_2}
              suffix_text="%"
              trend={@current_trend}
              trend_color={true}
              color="success"
            />
          </div>
        </div>
      </div>
      
      <!-- 精度演示 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">精度演示</h2>
        <div class="flex space-x-4 mb-4">
          <button 
            type="button"
            phx-click="change_precision"
            phx-value-precision="0"
            class="px-3 py-1 bg-blue-500 text-white rounded text-sm">
            0位小数
          </button>
          <button 
            type="button"
            phx-click="change_precision"
            phx-value-precision="1"
            class="px-3 py-1 bg-blue-500 text-white rounded text-sm">
            1位小数
          </button>
          <button 
            type="button"
            phx-click="change_precision"
            phx-value-precision="2"
            class="px-3 py-1 bg-blue-500 text-white rounded text-sm">
            2位小数
          </button>
          <button 
            type="button"
            phx-click="change_precision"
            phx-value-precision="3"
            class="px-3 py-1 bg-blue-500 text-white rounded text-sm">
            3位小数
          </button>
        </div>
        
        <div class="bg-white p-6 rounded-lg shadow max-w-md">
          <.statistic 
            id="precision-demo"
            title="精度演示 (π值)"
            value={@precision_value}
            precision={@current_precision}
            color="info"
          />
        </div>
      </div>
    </div>
    """
  end
  
  def mount(_params, _session, socket) do
    # 初始化定时器引用
    if connected?(socket) do
      Process.send_after(self(), :update_realtime, 2000)
    end
    
    {:ok, 
     socket
     |> assign(:total_users, 40689)
     |> assign(:active_users, 6560)
     |> assign(:monthly_revenue, 98765.43)
     |> assign(:conversion_rate, 82.5)
     |> assign(:realtime_visitors, 234)
     |> assign(:realtime_orders, 42)
     |> assign(:realtime_revenue, 5678.90)
     |> assign(:orders_trend, "up")
     |> assign(:revenue_trend, "up")
     |> assign(:realtime_active, false)
     |> assign(:timer_ref, nil)
     |> assign(:is_loading, false)
     |> assign(:loading_value_1, 1234)
     |> assign(:loading_value_2, 5678)
     |> assign(:current_trend, "up")
     |> assign(:trend_value_1, 123456)
     |> assign(:trend_value_2, 15.8)
     |> assign(:precision_value, 3.141592653589793)
     |> assign(:current_precision, 2)}
  end
  
  # 开始实时更新
  def handle_event("start_realtime", _params, socket) do
    if socket.assigns.timer_ref do
      Process.cancel_timer(socket.assigns.timer_ref)
    end
    
    timer_ref = Process.send_after(self(), :update_realtime, 1000)
    
    {:noreply, 
     socket
     |> assign(:realtime_active, true)
     |> assign(:timer_ref, timer_ref)}
  end
  
  # 停止实时更新
  def handle_event("stop_realtime", _params, socket) do
    if socket.assigns.timer_ref do
      Process.cancel_timer(socket.assigns.timer_ref)
    end
    
    {:noreply, 
     socket
     |> assign(:realtime_active, false)
     |> assign(:timer_ref, nil)}
  end
  
  # 手动更新数据
  def handle_event("manual_update", _params, socket) do
    {:noreply, update_realtime_data(socket)}
  end
  
  # 切换加载状态
  def handle_event("toggle_loading", _params, socket) do
    {:noreply, assign(socket, :is_loading, !socket.assigns.is_loading)}
  end
  
  # 改变趋势
  def handle_event("change_trend", %{"type" => type}, socket) do
    trend = case type do
      "up" -> "up"
      "down" -> "down"
      "none" -> nil
      _ -> socket.assigns.current_trend
    end
    
    {:noreply, assign(socket, :current_trend, trend)}
  end
  
  # 改变精度
  def handle_event("change_precision", %{"precision" => precision_str}, socket) do
    precision = String.to_integer(precision_str)
    {:noreply, assign(socket, :current_precision, precision)}
  end
  
  # 实时数据更新定时器
  def handle_info(:update_realtime, socket) do
    socket = update_realtime_data(socket)
    
    # 如果仍然激活，继续定时器
    timer_ref = if socket.assigns.realtime_active do
      Process.send_after(self(), :update_realtime, 1000 + :rand.uniform(2000))
    else
      nil
    end
    
    {:noreply, assign(socket, :timer_ref, timer_ref)}
  end
  
  # 更新实时数据
  defp update_realtime_data(socket) do
    # 随机变化访问者数量
    visitors_change = :rand.uniform(20) - 10
    new_visitors = max(0, socket.assigns.realtime_visitors + visitors_change)
    
    # 随机变化订单数量
    orders_change = :rand.uniform(6) - 3
    new_orders = max(0, socket.assigns.realtime_orders + orders_change)
    orders_trend = if orders_change > 0, do: "up", else: "down"
    
    # 随机变化收入
    revenue_change = (:rand.uniform(2000) - 1000) / 100
    new_revenue = max(0, socket.assigns.realtime_revenue + revenue_change)
    revenue_trend = if revenue_change > 0, do: "up", else: "down"
    
    socket
    |> assign(:realtime_visitors, new_visitors)
    |> assign(:realtime_orders, new_orders)
    |> assign(:realtime_revenue, new_revenue)
    |> assign(:orders_trend, orders_trend)
    |> assign(:revenue_trend, revenue_trend)
  end
end