defmodule PetalComponents.Custom.Steps do
  @moduledoc """
  步骤条组件 - 引导用户按照流程完成任务的导航条
  
  ## 特性
  - 支持水平和垂直两种方向
  - 支持多种步骤状态（等待、进行中、完成、错误）
  - 支持自定义图标
  - 支持描述文字
  - 支持点击跳转
  - 支持进度条显示
  - 支持自定义样式
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染步骤条组件
  
  ## 示例
  
      <.steps 
        id="basic-steps"
        current={1}
        steps={@steps}
      />
      
      <!-- 不同尺寸示例 -->
      <.steps 
        id="small-steps"
        size="small"
        current={1}
        color="primary"
        steps={[
          %{title: "步骤一", description: "描述信息"},
          %{title: "步骤二", description: "描述信息"},
          %{title: "步骤三", description: "描述信息"}
        ]}
      />
      
      <.steps 
        id="large-steps"
        size="large"
        direction="vertical"
        current={0}
        color="success"
        steps={@workflow_steps}
      />
  """
  attr :id, :string, required: true, doc: "步骤条唯一标识"
  attr :current, :integer, default: 0, doc: "指定当前步骤，从0开始计数"
  attr :direction, :string, values: ["horizontal", "vertical"], default: "horizontal", doc: "指定步骤条方向"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "指定大小"
  attr :status, :string, values: ["wait", "process", "finish", "error"], default: "process", doc: "指定当前步骤状态"
  attr :initial, :integer, default: 0, doc: "起始序号，从0开始计数"
  attr :label_placement, :string, values: ["horizontal", "vertical"], default: "horizontal", doc: "指定标签放置位置"
  attr :progress_dot, :boolean, default: false, doc: "点状步骤条"
  attr :responsive, :boolean, default: true, doc: "响应式"
  attr :type, :string, values: ["default", "navigation"], default: "default", doc: "步骤条类型"
  attr :percent, :integer, default: nil, doc: "当前process步骤显示的进度条进度"
  attr :steps, :list, default: [], doc: "步骤数据"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "步骤条颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: %JS{}, doc: "点击切换步骤时触发"
  attr :rest, :global, doc: "其他HTML属性"

  def steps(assigns) do
    assigns = 
      assigns
      |> assign(:steps_with_index, Enum.with_index(assigns.steps))
      |> assign(:is_clickable, assigns.type == "navigation")
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-steps",
        "pc-steps--#{@color}",
        "pc-steps--#{@direction}",
        "pc-steps--#{@size}",
        "pc-steps--status-#{@status}",
        @progress_dot && "pc-steps--dot",
        @responsive && "pc-steps--responsive",
        @type == "navigation" && "pc-steps--navigation",
        @class
      ]}
      {@rest}>
      
      <div class={[
        "pc-steps__wrapper",
        @direction == "horizontal" && "flex items-start",
        @direction == "vertical" && "flex flex-col"
      ]}>
        <%= for {step, index} <- @steps_with_index do %>
          <%= render_step(assigns, step, index) %>
        <% end %>
      </div>
    </div>
    
    """
  end
  
  # 渲染单个步骤
  defp render_step(assigns, step, index) do
    step_status = get_step_status(assigns, step, index)
    is_current = index == assigns.current
    is_clickable = assigns.is_clickable
    
    assigns = 
      assigns
      |> assign(:step, step)
      |> assign(:step_index, index)
      |> assign(:step_status, step_status)
      |> assign(:is_current, is_current)
      |> assign(:is_clickable, is_clickable)
      |> assign(:step_number, index + 1 + assigns.initial)
      |> assign(:is_last_step, index == length(assigns.steps) - 1)
    
    ~H"""
    <div class={[
      "pc-steps__item",
      "pc-steps__item--#{@step_status}",
      @is_current && "pc-steps__item--current",
      @direction == "horizontal" && "flex-1 flex items-start",
      @direction == "vertical" && "flex items-start mb-4 last:mb-0"
    ]}>
      
      <!-- 步骤图标和连接线 -->
      <div class={[
        "pc-steps__icon-wrapper flex items-center",
        @direction == "vertical" && "flex-col items-center mr-4"
      ]}>
        
        <!-- 步骤图标 -->
        <div 
          class={[
            "pc-steps__icon flex items-center justify-center rounded-full border-2 transition duration-150 ease-in-out",
            @size == "small" && "w-6 h-6 text-xs leading-4",
            @size == "medium" && "w-8 h-8 text-sm leading-5",
            @size == "large" && "w-10 h-10 text-base leading-6",
            @progress_dot && "w-3 h-3 border-0",
            @is_clickable && "cursor-pointer hover:opacity-80",
            @is_clickable && "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2",
            get_icon_classes(@step_status, @color)
          ]}
          tabindex={@is_clickable && "0"}
          phx-click={@is_clickable && @on_change}
          phx-value-step={@step_index}>
          
          <%= cond do %>
            <% @step[:icon] -> %>
              <%= if is_binary(@step.icon) do %>
                <span class={@step.icon}></span>
              <% else %>
                <%= @step.icon %>
              <% end %>
            <% @step_status == "finish" -> %>
              <!-- 完成状态显示勾号 -->
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
              </svg>
            <% @step_status == "error" -> %>
              <!-- 错误状态显示X号 -->
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            <% @progress_dot -> %>
              <!-- 点状步骤条不显示数字 -->
            <% true -> %>
              <!-- 默认显示步骤数字 -->
              <span class="pc-steps__number"><%= @step_number %></span>
          <% end %>
        </div>
        
        <!-- 进度条（仅当前步骤且有百分比时显示） -->
        <%= if @is_current && @percent && @step_status == "process" do %>
          <div class="pc-steps__progress mt-2 w-full bg-gray-200 rounded-full h-1">
            <div 
              class="bg-primary h-1 rounded-full transition-all duration-150"
              style={"width: #{@percent}%"}>
            </div>
          </div>
        <% end %>
        
        <!-- 垂直连接线 -->
        <%= if @direction == "vertical" && !@is_last_step do %>
          <div class={[
            "pc-steps__connector mt-2 w-px bg-gray-300 dark:bg-gray-600",
            @size == "small" && "h-8",
            @size == "medium" && "h-12",
            @size == "large" && "h-16"
          ]}></div>
        <% end %>
      </div>
      
      <!-- 步骤内容 -->
      <div class={[
        "pc-steps__content flex-1",
        @direction == "horizontal" && if(@size == "small", do: "ml-2", else: "ml-3"),
        @direction == "vertical" && "flex-1"
      ]}>
        
        <!-- 步骤标题 -->
        <div class={[
          "pc-steps__title font-medium",
          @size == "small" && "text-sm leading-5",
          @size == "medium" && "text-base leading-6",
          @size == "large" && "text-lg leading-7",
          get_title_color(@step_status)
        ]}>
          <%= @step[:title] || @step["title"] %>
        </div>
        
        <!-- 步骤描述 -->
        <%= if @step[:description] || @step["description"] do %>
          <div class={[
            "pc-steps__description mt-1 text-gray-500 dark:text-gray-400",
            @size == "small" && "text-xs leading-4",
            @size == "medium" && "text-sm leading-5",
            @size == "large" && "text-base leading-6"
          ]}>
            <%= @step[:description] || @step["description"] %>
          </div>
        <% end %>
      </div>
      
      <!-- 水平连接线 -->
      <%= if @direction == "horizontal" && !@is_last_step do %>
        <div class={[
          "pc-steps__connector flex-1 h-px bg-gray-300 dark:bg-gray-600 mt-4 mx-4",
          @size == "small" && "mt-3",
          @size == "medium" && "mt-4",
          @size == "large" && "mt-5"
        ]}></div>
      <% end %>
    </div>
    """
  end
  
  # 获取步骤状态
  defp get_step_status(assigns, step, index) do
    cond do
      # 如果步骤本身定义了状态，优先使用
      step[:status] || step["status"] ->
        step[:status] || step["status"]
      
      # 如果是当前步骤，使用组件状态
      index == assigns.current ->
        assigns.status
      
      # 如果是已完成的步骤
      index < assigns.current ->
        "finish"
      
      # 如果是等待的步骤
      true ->
        "wait"
    end
  end
  
  # 获取标题颜色类
  defp get_title_color(status) do
    case status do
      "finish" -> "text-gray-900 dark:text-gray-100"
      "process" -> "text-gray-900 dark:text-gray-100"
      "error" -> "text-red-500 dark:text-red-400"
      "wait" -> "text-gray-400 dark:text-gray-500"
      _ -> "text-gray-900 dark:text-gray-100"
    end
  end
  
  # 获取步骤图标样式
  defp get_icon_classes(status, color) do
    case status do
      "finish" -> get_active_icon_classes(color)
      "process" -> get_active_icon_classes(color)
      "error" -> "bg-red-500 border-red-500 text-white"
      "wait" -> "bg-gray-50 dark:bg-gray-800 border-gray-300 dark:border-gray-600 text-gray-400 dark:text-gray-500"
      _ -> "bg-gray-50 dark:bg-gray-800 border-gray-300 dark:border-gray-600 text-gray-400 dark:text-gray-500"
    end
  end
  
  # 获取激活状态的图标样式
  defp get_active_icon_classes(color) do
    case color do
      "primary" -> "bg-primary border-primary text-white"
      "info" -> "bg-blue-500 border-blue-500 text-white"
      "success" -> "bg-green-500 border-green-500 text-white"
      "warning" -> "bg-yellow-500 border-yellow-500 text-white"
      "danger" -> "bg-red-500 border-red-500 text-white"
      _ -> "bg-primary border-primary text-white"
    end
  end
end