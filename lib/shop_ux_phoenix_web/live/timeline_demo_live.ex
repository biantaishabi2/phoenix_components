defmodule ShopUxPhoenixWeb.TimelineDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.Timeline

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Timeline 时间线组件")
     |> assign(:basic_items, get_basic_timeline_items())
     |> assign(:project_timeline, get_project_timeline())
     |> assign(:order_timeline, get_order_timeline())
     |> assign(:notification_timeline, get_notification_timeline())
     |> assign(:selected_item, nil)
     |> assign(:show_pending, false)}
  end

  def handle_event("timeline_item_clicked", %{"item-id" => item_id, "index" => index}, socket) do
    IO.puts("Timeline item clicked: #{item_id} at index #{index}")
    
    selected_item = %{
      id: item_id,
      index: String.to_integer(index),
      clicked_at: DateTime.utc_now() |> DateTime.to_string()
    }
    
    {:noreply, 
     socket
     |> assign(:selected_item, selected_item)
     |> put_flash(:info, "点击了时间线项目: #{item_id}")}
  end

  def handle_event("toggle_pending", _params, socket) do
    {:noreply, assign(socket, :show_pending, !socket.assigns.show_pending)}
  end

  def handle_event("load_more", _params, socket) do
    # 模拟加载更多数据
    new_items = [
      %{
        id: "new-1",
        title: "新增数据",
        description: "这是新加载的时间线数据",
        time: "2024-03-01 16:00",
        color: "info",
        dot: "hero-plus",
        status: "completed"
      }
    ]
    
    updated_items = socket.assigns.basic_items ++ new_items
    
    {:noreply,
     socket
     |> assign(:basic_items, updated_items)
     |> put_flash(:info, "已加载更多数据")}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 max-w-7xl mx-auto">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Timeline 时间线组件</h1>
      
      <!-- 基础用法 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础用法</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.timeline 
            id="basic-timeline"
            items={@basic_items}
            data-testid="basic-timeline"
          />
          
          <div class="mt-4 flex gap-2">
            <.button phx-click="load_more">
              加载更多
            </.button>
            <.button phx-click="toggle_pending">
              <%= if @show_pending, do: "隐藏", else: "显示" %>加载状态
            </.button>
          </div>
          
          <%= if @show_pending do %>
            <div class="mt-6">
              <h3 class="text-lg font-medium mb-2">带加载状态</h3>
              <.timeline 
                id="pending-timeline"
                items={@basic_items}
                pending={true}
                pending_dot="加载中..."
                data-testid="pending-timeline"
              />
            </div>
          <% end %>
        </div>
      </section>

      <!-- 不同尺寸 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">不同尺寸</h2>
        <div class="bg-white p-6 rounded-lg shadow space-y-6">
          <div>
            <h3 class="text-lg font-medium mb-3">小尺寸</h3>
            <.timeline 
              id="small-timeline"
              items={Enum.take(@basic_items, 2)}
              size="small"
              data-testid="small-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">默认尺寸</h3>
            <.timeline 
              id="medium-timeline"
              items={Enum.take(@basic_items, 2)}
              size="medium"
              data-testid="medium-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">大尺寸</h3>
            <.timeline 
              id="large-timeline"
              items={Enum.take(@basic_items, 2)}
              size="large"
              data-testid="large-timeline"
            />
          </div>
        </div>
      </section>

      <!-- 不同颜色主题 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">颜色主题</h2>
        <div class="bg-white p-6 rounded-lg shadow grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-medium mb-3">Primary 主色</h3>
            <.timeline 
              id="primary-timeline"
              items={Enum.take(@basic_items, 2)}
              color="primary"
              data-testid="primary-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">Success 成功</h3>
            <.timeline 
              id="success-timeline"
              items={Enum.take(@basic_items, 2)}
              color="success"
              data-testid="success-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">Warning 警告</h3>
            <.timeline 
              id="warning-timeline"
              items={Enum.take(@basic_items, 2)}
              color="warning"
              data-testid="warning-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">Danger 危险</h3>
            <.timeline 
              id="danger-timeline"
              items={Enum.take(@basic_items, 2)}
              color="danger"
              data-testid="danger-timeline"
            />
          </div>
        </div>
      </section>

      <!-- 不同模式 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">布局模式</h2>
        <div class="bg-white p-6 rounded-lg shadow space-y-8">
          <div>
            <h3 class="text-lg font-medium mb-3">左侧模式（默认）</h3>
            <.timeline 
              id="left-timeline"
              items={Enum.take(@basic_items, 3)}
              mode="left"
              data-testid="left-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">右侧模式</h3>
            <.timeline 
              id="right-timeline"
              items={Enum.take(@basic_items, 3)}
              mode="right"
              data-testid="right-timeline"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">交替模式</h3>
            <.timeline 
              id="alternate-timeline"
              items={Enum.take(@basic_items, 4)}
              mode="alternate"
              data-testid="alternate-timeline"
            />
          </div>
        </div>
      </section>

      <!-- 倒序显示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">倒序显示</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <p class="text-gray-600 mb-4">最新的事件显示在顶部</p>
          <.timeline 
            id="reverse-timeline"
            items={@basic_items}
            reverse={true}
            data-testid="reverse-timeline"
          />
        </div>
      </section>

      <!-- 交互事件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">交互事件</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <p class="text-gray-600 mb-4">点击时间线项目查看详情</p>
          <.timeline 
            id="interactive-timeline"
            items={@basic_items}
            on_item_click="timeline_item_clicked"
            data-testid="interactive-timeline"
          />
          
          <%= if @selected_item do %>
            <div class="mt-4 p-4 bg-blue-50 rounded-lg">
              <h4 class="font-medium text-blue-900">已选择项目</h4>
              <p class="text-blue-700">
                ID: <%= @selected_item.id %>, 
                索引: <%= @selected_item.index %>, 
                点击时间: <%= @selected_item.clicked_at %>
              </p>
            </div>
          <% end %>
        </div>
      </section>

      <!-- 项目时间线示例 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">项目时间线</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.timeline 
            id="project-timeline"
            items={@project_timeline}
            size="large"
            data-testid="project-timeline"
          />
        </div>
      </section>

      <!-- 订单状态时间线 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">订单状态跟踪</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.timeline 
            id="order-timeline"
            items={@order_timeline}
            mode="left"
            data-testid="order-timeline"
          />
        </div>
      </section>

      <!-- 通知时间线 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">消息通知</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.timeline 
            id="notification-timeline"
            items={@notification_timeline}
            size="small"
            reverse={true}
            data-testid="notification-timeline"
          />
        </div>
      </section>

      <!-- 使用说明 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">使用说明</h2>
        <div class="bg-gray-100 p-6 rounded-lg">
          <p class="text-gray-700 mb-4">
            Timeline 组件支持多种显示模式、颜色主题和交互方式。
            可以通过 items 属性传入时间线数据，支持自定义图标、颜色和状态。
          </p>
          <p class="text-gray-700">
            详细的 API 文档和使用示例请参考组件文档。
          </p>
        </div>
      </section>
    </div>
    """
  end

  # 私有函数

  defp get_basic_timeline_items do
    [
      %{
        id: "1",
        title: "项目启动",
        description: "项目正式启动，团队成员开始需求分析和技术调研",
        time: "2024-01-01 09:00",
        color: "success",
        dot: "hero-play",
        status: "completed"
      },
      %{
        id: "2",
        title: "设计评审",
        description: "完成UI/UX设计稿，通过设计评审会议",
        time: "2024-01-15 14:30",
        color: "primary",
        dot: "hero-eye",
        status: "completed"
      },
      %{
        id: "3",
        title: "开发阶段",
        description: "前端和后端开发工作正在并行进行",
        time: "2024-02-01 10:00",
        color: "warning",
        dot: "hero-code-bracket",
        status: "processing"
      },
      %{
        id: "4",
        title: "测试准备",
        description: "准备测试环境和测试用例",
        time: "2024-02-15 11:00",
        color: "info",
        dot: "hero-beaker",
        status: "pending"
      }
    ]
  end

  defp get_project_timeline do
    [
      %{
        id: "p1",
        title: "立项申请",
        description: "提交项目立项申请，获得管理层批准",
        time: "2023-12-01 09:00",
        color: "success",
        dot: "hero-document-check",
        status: "completed"
      },
      %{
        id: "p2",
        title: "需求调研",
        description: "深入调研用户需求，形成需求文档",
        time: "2023-12-15 14:00",
        color: "success",
        dot: "hero-magnifying-glass",
        status: "completed"
      },
      %{
        id: "p3",
        title: "技术选型",
        description: "确定技术栈和架构设计方案",
        time: "2024-01-05 10:30",
        color: "success",
        dot: "hero-cog-6-tooth",
        status: "completed"
      },
      %{
        id: "p4",
        title: "原型设计",
        description: "制作产品原型，验证核心功能流程",
        time: "2024-01-20 16:00",
        color: "success",
        dot: "hero-cube",
        status: "completed"
      },
      %{
        id: "p5",
        title: "详细设计",
        description: "完成详细的技术设计和数据库设计",
        time: "2024-02-01 11:15",
        color: "warning",
        dot: "hero-document-text",
        status: "processing"
      }
    ]
  end

  defp get_order_timeline do
    [
      %{
        id: "o1",
        title: "订单创建",
        description: "客户成功提交订单，等待支付",
        time: "2024-03-01 10:30",
        color: "info",
        dot: "hero-shopping-cart",
        status: "completed"
      },
      %{
        id: "o2",
        title: "支付成功",
        description: "客户完成在线支付，订单进入处理队列",
        time: "2024-03-01 10:35",
        color: "success",
        dot: "hero-credit-card",
        status: "completed"
      },
      %{
        id: "o3",
        title: "商品备货",
        description: "仓库开始拣货打包，准备发货",
        time: "2024-03-01 15:20",
        color: "success",
        dot: "hero-cube",
        status: "completed"
      },
      %{
        id: "o4",
        title: "订单发货",
        description: "商品已发货，快递单号：SF1234567890",
        time: "2024-03-02 09:15",
        color: "warning",
        dot: "hero-truck",
        status: "processing"
      },
      %{
        id: "o5",
        title: "配送中",
        description: "商品正在配送途中，预计明日送达",
        time: "2024-03-02 18:30",
        color: "warning",
        dot: "hero-map-pin",
        status: "processing"
      }
    ]
  end

  defp get_notification_timeline do
    [
      %{
        id: "n1",
        title: "系统通知",
        description: "您的账户密码已成功修改",
        time: "刚刚",
        color: "success",
        dot: "hero-shield-check",
        status: "completed"
      },
      %{
        id: "n2",
        title: "新消息",
        description: "张三评论了您的文章",
        time: "5分钟前",
        color: "primary",
        dot: "hero-chat-bubble-left",
        status: "completed"
      },
      %{
        id: "n3",
        title: "系统更新",
        description: "系统将在今晚22:00进行维护升级",
        time: "1小时前",
        color: "warning",
        dot: "hero-exclamation-triangle",
        status: "pending"
      },
      %{
        id: "n4",
        title: "活动提醒",
        description: "双十一活动即将开始，记得参与！",
        time: "今天 09:00",
        color: "info",
        dot: "hero-gift",
        status: "completed"
      }
    ]
  end
end