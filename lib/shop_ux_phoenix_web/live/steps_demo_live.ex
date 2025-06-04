defmodule ShopUxPhoenixWeb.StepsDemoLive do
  @moduledoc """
  LiveView for testing Steps component interactions
  """
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Steps
  
  def render(assigns) do
    ~H"""
    <div class="p-8 space-y-8">
      <h1 class="text-2xl font-bold mb-6">Steps 步骤条组件交互测试</h1>
      
      <!-- 基本步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">基本步骤条</h2>
        <div class="text-sm text-gray-600">当前步骤: <%= @basic_current + 1 %></div>
        <.steps 
          id="basic-steps"
          current={@basic_current}
          steps={@basic_steps}
        />
        <div class="space-x-2">
          <button 
            type="button"
            phx-click="basic_prev"
            disabled={@basic_current == 0}
            class="px-4 py-2 bg-gray-500 text-white rounded disabled:opacity-50">
            上一步
          </button>
          <button 
            type="button"
            phx-click="basic_next"
            disabled={@basic_current == length(@basic_steps) - 1}
            class="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50">
            下一步
          </button>
        </div>
      </div>
      
      <!-- 可点击步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">可点击步骤条</h2>
        <div class="text-sm text-gray-600">当前步骤: <%= @clickable_current + 1 %></div>
        <.steps 
          id="clickable-steps"
          current={@clickable_current}
          type="navigation"
          on_change={JS.push("step_change")}
          steps={@clickable_steps}
        />
      </div>
      
      <!-- 带进度的步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">带进度的步骤条</h2>
        <div class="text-sm text-gray-600">当前步骤: <%= @progress_current + 1 %>, 进度: <%= @progress_percent %>%</div>
        <.steps 
          id="progress-steps"
          current={@progress_current}
          percent={@progress_percent}
          steps={@progress_steps}
        />
        <div class="space-x-2">
          <button 
            type="button"
            phx-click="progress_increase"
            class="px-4 py-2 bg-green-500 text-white rounded">
            增加进度
          </button>
          <button 
            type="button"
            phx-click="progress_reset"
            class="px-4 py-2 bg-red-500 text-white rounded">
            重置进度
          </button>
        </div>
      </div>
      
      <!-- 错误状态步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">错误状态步骤条</h2>
        <div class="text-sm text-gray-600">状态: <%= @error_status %></div>
        <.steps 
          id="error-steps"
          current={@error_current}
          status={@error_status}
          steps={@error_steps}
        />
        <div class="space-x-2">
          <button 
            type="button"
            phx-click="set_error"
            class="px-4 py-2 bg-red-500 text-white rounded">
            设置错误
          </button>
          <button 
            type="button"
            phx-click="set_success"
            class="px-4 py-2 bg-green-500 text-white rounded">
            设置成功
          </button>
        </div>
      </div>
      
      <!-- 垂直步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">垂直步骤条</h2>
        <div class="text-sm text-gray-600">当前步骤: <%= @vertical_current + 1 %></div>
        <.steps 
          id="vertical-steps"
          current={@vertical_current}
          direction="vertical"
          steps={@vertical_steps}
          class="w-64"
        />
        <div class="space-x-2">
          <button 
            type="button"
            phx-click="vertical_prev"
            disabled={@vertical_current == 0}
            class="px-4 py-2 bg-gray-500 text-white rounded disabled:opacity-50">
            上一步
          </button>
          <button 
            type="button"
            phx-click="vertical_next"
            disabled={@vertical_current == length(@vertical_steps) - 1}
            class="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50">
            下一步
          </button>
        </div>
      </div>
      
      <!-- 小尺寸步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">小尺寸步骤条</h2>
        <.steps 
          id="small-steps"
          current={1}
          size="small"
          steps={[
            %{title: "完成", status: "finish"},
            %{title: "进行中", status: "process"},
            %{title: "等待", status: "wait"}
          ]}
        />
      </div>
      
      <!-- 点状步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">点状步骤条</h2>
        <.steps 
          id="dot-steps"
          current={1}
          progress_dot={true}
          steps={[
            %{title: "第一步", description: "完成基本信息"},
            %{title: "第二步", description: "确认信息"},
            %{title: "第三步", description: "提交"}
          ]}
        />
      </div>
      
      <!-- 带图标的步骤条 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">带图标的步骤条</h2>
        <.steps 
          id="icon-steps"
          current={1}
          steps={@icon_steps}
        />
      </div>
    </div>
    """
  end
  
  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(:basic_current, 1)
     |> assign(:basic_steps, [
       %{title: "已完成", description: "这是第一步", status: "finish"},
       %{title: "进行中", description: "这是第二步", status: "process"},
       %{title: "等待中", description: "这是第三步", status: "wait"}
     ])
     |> assign(:clickable_current, 0)
     |> assign(:clickable_steps, [
       %{title: "开始", description: "开始流程"},
       %{title: "处理", description: "处理数据"},
       %{title: "完成", description: "流程完成"}
     ])
     |> assign(:progress_current, 1)
     |> assign(:progress_percent, 30)
     |> assign(:progress_steps, [
       %{title: "准备", status: "finish"},
       %{title: "进行中", status: "process"},
       %{title: "完成", status: "wait"}
     ])
     |> assign(:error_current, 1)
     |> assign(:error_status, "error")
     |> assign(:error_steps, [
       %{title: "开始", status: "finish"},
       %{title: "出错了", status: "error"},
       %{title: "等待", status: "wait"}
     ])
     |> assign(:vertical_current, 0)
     |> assign(:vertical_steps, [
       %{title: "第一步", description: "填写基本信息"},
       %{title: "第二步", description: "上传文件"},
       %{title: "第三步", description: "确认提交"},
       %{title: "第四步", description: "完成"}
     ])
     |> assign(:icon_steps, [
       %{
         title: "登录",
         description: "用户登录",
         icon: "user-icon",
         status: "finish"
       },
       %{
         title: "验证",
         description: "身份验证",
         icon: "shield-icon",
         status: "process"
       },
       %{
         title: "完成",
         description: "注册完成",
         icon: "check-icon",
         status: "wait"
       }
     ])}
  end
  
  # 基本步骤条事件
  def handle_event("basic_next", _params, socket) do
    current = socket.assigns.basic_current
    max_step = length(socket.assigns.basic_steps) - 1
    
    new_current = if current < max_step, do: current + 1, else: current
    {:noreply, assign(socket, :basic_current, new_current)}
  end
  
  def handle_event("basic_prev", _params, socket) do
    current = socket.assigns.basic_current
    new_current = if current > 0, do: current - 1, else: current
    {:noreply, assign(socket, :basic_current, new_current)}
  end
  
  # 可点击步骤条事件
  def handle_event("step_change", %{"step" => step_str}, socket) do
    step = String.to_integer(step_str)
    {:noreply, assign(socket, :clickable_current, step)}
  end
  
  # 进度步骤条事件
  def handle_event("progress_increase", _params, socket) do
    current_percent = socket.assigns.progress_percent
    new_percent = min(current_percent + 20, 100)
    
    socket = assign(socket, :progress_percent, new_percent)
    
    # 如果进度达到100%，自动前进到下一步
    socket = if new_percent == 100 do
      current = socket.assigns.progress_current
      max_step = length(socket.assigns.progress_steps) - 1
      new_current = if current < max_step, do: current + 1, else: current
      
      socket
      |> assign(:progress_current, new_current)
      |> assign(:progress_percent, 0)
    else
      socket
    end
    
    {:noreply, socket}
  end
  
  def handle_event("progress_reset", _params, socket) do
    {:noreply, 
     socket
     |> assign(:progress_current, 0)
     |> assign(:progress_percent, 0)}
  end
  
  # 错误状态步骤条事件
  def handle_event("set_error", _params, socket) do
    {:noreply, assign(socket, :error_status, "error")}
  end
  
  def handle_event("set_success", _params, socket) do
    {:noreply, assign(socket, :error_status, "finish")}
  end
  
  # 垂直步骤条事件
  def handle_event("vertical_next", _params, socket) do
    current = socket.assigns.vertical_current
    max_step = length(socket.assigns.vertical_steps) - 1
    
    new_current = if current < max_step, do: current + 1, else: current
    {:noreply, assign(socket, :vertical_current, new_current)}
  end
  
  def handle_event("vertical_prev", _params, socket) do
    current = socket.assigns.vertical_current
    new_current = if current > 0, do: current - 1, else: current
    {:noreply, assign(socket, :vertical_current, new_current)}
  end
end