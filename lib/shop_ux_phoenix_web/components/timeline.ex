defmodule ShopUxPhoenixWeb.Components.Timeline do
  @moduledoc """
  时间线组件 - 用于展示按时间顺序排列的事件和活动
  
  支持功能：
  - 时间顺序展示（正序/倒序）
  - 多种节点类型和颜色
  - 响应式设计
  - 事件交互
  - 状态支持
  - 自定义内容
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents

  @doc """
  渲染时间线组件
  
  ## 示例
  
      <.timeline 
        id="basic-timeline"
        items={@timeline_items}
      />
      
      <.timeline 
        id="interactive-timeline"
        items={@timeline_items}
        mode="alternate"
        on_item_click="timeline_item_clicked"
      />
  """
  attr :id, :string, required: true
  attr :items, :list, default: []
  attr :reverse, :boolean, default: false
  attr :mode, :string, default: "left", values: ~w(left right alternate)
  attr :pending, :boolean, default: false
  attr :pending_dot, :string, default: nil
  attr :size, :string, default: "medium", values: ~w(small medium large)
  attr :color, :string, default: "primary", values: ~w(primary success warning danger info)
  attr :class, :string, default: ""
  attr :on_item_click, :string, default: nil
  attr :rest, :global

  def timeline(assigns) do
    assigns = 
      assigns
      |> assign(:processed_items, process_items(assigns.items, assigns.reverse))
      |> assign(:is_interactive, !is_nil(assigns.on_item_click))
    
    ~H"""
    <div 
      id={@id}
      class={[
        "timeline relative",
        get_mode_classes(@mode),
        get_size_classes(@size),
        @class
      ]}
      {@rest}
    >
      <%= for {item, index} <- Enum.with_index(@processed_items) do %>
        <div 
          class={[
            "timeline-item relative group",
            get_item_position_classes(@mode, index),
            @is_interactive && "cursor-pointer hover:bg-gray-50 rounded-lg p-2 -m-2 transition-colors"
          ]}
          phx-click={@is_interactive && @on_item_click}
          phx-value-item-id={item[:id]}
          phx-value-index={index}
        >
          <!-- 时间线连接线 -->
          <%= unless is_last_item?(@processed_items, index) do %>
            <div class={[
              "timeline-line absolute bg-gray-200",
              get_line_classes(@mode, @size)
            ]}></div>
          <% end %>
          
          <!-- 时间线节点 -->
          <div class={[
            "timeline-dot absolute flex items-center justify-center border-2 bg-white",
            get_dot_classes(@size),
            get_dot_position_classes(@mode),
            get_color_classes(item[:color] || @color)
          ]}>
            <%= if item[:dot] do %>
              <.icon name={item[:dot]} class={get_icon_size_classes(@size)} />
            <% end %>
          </div>
          
          <!-- 时间线内容 -->
          <div class={[
            "timeline-content",
            get_content_classes(@mode, @size)
          ]}>
            <!-- 时间戳 -->
            <%= if item[:time] do %>
              <div class={[
                "timeline-time text-gray-500 mb-1",
                get_time_size_classes(@size)
              ]}>
                <%= item[:time] %>
              </div>
            <% end %>
            
            <!-- 标题 -->
            <%= if item[:title] do %>
              <div class={[
                "timeline-title font-medium text-gray-900 mb-1",
                get_title_size_classes(@size)
              ]}>
                <%= item[:title] %>
              </div>
            <% end %>
            
            <!-- 描述 -->
            <%= if item[:description] do %>
              <div class={[
                "timeline-description text-gray-600",
                get_description_size_classes(@size)
              ]}>
                <%= item[:description] %>
              </div>
            <% end %>
            
            <!-- 状态标识 -->
            <%= if item[:status] do %>
              <div class={[
                "timeline-status inline-block px-2 py-1 text-xs rounded-full mt-2",
                get_status_classes(item[:status])
              ]}>
                <%= format_status(item[:status]) %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
      
      <!-- 加载状态 -->
      <%= if @pending do %>
        <div class="timeline-item relative">
          <div class={[
            "timeline-dot absolute flex items-center justify-center border-2 bg-white animate-pulse",
            get_dot_classes(@size),
            get_dot_position_classes(@mode),
            "border-gray-300"
          ]}>
            <%= if @pending_dot do %>
              <span class="text-xs text-gray-500"><%= @pending_dot %></span>
            <% else %>
              <div class="w-2 h-2 bg-gray-300 rounded-full animate-pulse"></div>
            <% end %>
          </div>
          
          <div class={[
            "timeline-content",
            get_content_classes(@mode, @size)
          ]}>
            <div class="timeline-title font-medium text-gray-400 animate-pulse">
              加载中...
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # 私有函数

  defp process_items(items, reverse) do
    if reverse do
      Enum.reverse(items)
    else
      items
    end
  end

  defp is_last_item?(items, index) do
    index == length(items) - 1
  end

  defp get_mode_classes(mode) do
    case mode do
      "left" -> "pl-8"
      "right" -> "pr-8"
      "alternate" -> "px-8"
    end
  end

  defp get_size_classes(size) do
    case size do
      "small" -> "text-sm"
      "large" -> "text-base"
      _ -> "text-base"
    end
  end

  defp get_item_position_classes(mode, index) do
    case mode do
      "alternate" when rem(index, 2) == 0 -> "text-left"
      "alternate" -> "text-right"
      "right" -> "text-right"
      _ -> "text-left"
    end
  end

  defp get_line_classes(mode, size) do
    width = case size do
      "small" -> "w-0.5"
      "large" -> "w-1"
      _ -> "w-0.5"
    end
    
    position = case mode do
      "left" -> "left-1.5 top-6 h-full"
      "right" -> "right-1.5 top-6 h-full"
      "alternate" -> "left-1/2 top-6 h-full -translate-x-1/2"
    end
    
    [width, position]
  end

  defp get_dot_classes(size) do
    case size do
      "small" -> "w-3 h-3 rounded-full"
      "large" -> "w-5 h-5 rounded-full"
      _ -> "w-4 h-4 rounded-full"
    end
  end

  defp get_dot_position_classes(mode) do
    case mode do
      "left" -> "left-0 top-1 -translate-x-1/2"
      "right" -> "right-0 top-1 translate-x-1/2"
      "alternate" -> "left-1/2 top-1 -translate-x-1/2"
    end
  end

  defp get_color_classes(color) do
    case color do
      "primary" -> "border-blue-500 text-blue-500"
      "success" -> "border-green-500 text-green-500"
      "warning" -> "border-yellow-500 text-yellow-500"
      "danger" -> "border-red-500 text-red-500"
      "info" -> "border-gray-500 text-gray-500"
      _ -> "border-blue-500 text-blue-500"
    end
  end

  defp get_content_classes(mode, size) do
    margin = case size do
      "small" -> "ml-6"
      "large" -> "ml-8"
      _ -> "ml-6"
    end
    
    case mode do
      "right" -> "mr-6 text-right"
      "alternate" -> "px-6"
      _ -> margin
    end
  end

  defp get_icon_size_classes(size) do
    case size do
      "small" -> "w-2 h-2"
      "large" -> "w-3 h-3"
      _ -> "w-2.5 h-2.5"
    end
  end

  defp get_time_size_classes(size) do
    case size do
      "small" -> "text-xs"
      "large" -> "text-sm"
      _ -> "text-xs"
    end
  end

  defp get_title_size_classes(size) do
    case size do
      "small" -> "text-sm"
      "large" -> "text-lg"
      _ -> "text-base"
    end
  end

  defp get_description_size_classes(size) do
    case size do
      "small" -> "text-xs"
      "large" -> "text-base"
      _ -> "text-sm"
    end
  end

  defp get_status_classes(status) do
    case status do
      "completed" -> "bg-green-100 text-green-800"
      "processing" -> "bg-yellow-100 text-yellow-800"
      "pending" -> "bg-gray-100 text-gray-800"
      "error" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp format_status(status) do
    case status do
      "completed" -> "已完成"
      "processing" -> "进行中"
      "pending" -> "等待中"
      "error" -> "错误"
      _ -> status
    end
  end
end