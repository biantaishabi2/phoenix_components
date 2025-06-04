defmodule PetalComponents.Custom.Tooltip do
  @moduledoc """
  Tooltip 文字提示组件，用于鼠标悬停时显示额外信息
  
  ## 特性
  - 支持12个方向的定位
  - 支持多种触发方式（hover、click、focus）
  - 支持自定义内容和样式
  - 支持延迟显示/隐藏
  - 完整的无障碍支持
  
  ## 依赖
  - 需要在 app.js 中添加 Tooltip Hook
  """
  use Phoenix.Component
  
  @doc """
  渲染文字提示组件
  
  ## 示例
      <.tooltip id="tip1" title="这是一个提示">
        <span>悬停查看提示</span>
      </.tooltip>
      
      <.tooltip id="tip2" placement="bottom" trigger="click">
        <:content>
          <div>自定义内容</div>
        </:content>
        <button>点击显示</button>
      </.tooltip>
  """
  attr :id, :string, required: true, doc: "组件唯一标识符"
  attr :title, :string, default: "", doc: "提示内容"
  attr :placement, :string, 
    default: "top",
    values: ~w(top top-start top-end bottom bottom-start bottom-end left left-start left-end right right-start right-end),
    doc: "提示框位置"
  attr :trigger, :string, 
    default: "hover",
    values: ~w(hover click focus),
    doc: "触发方式"
  attr :visible, :boolean, default: nil, doc: "手动控制显示状态"
  attr :color, :string, default: nil, doc: "背景颜色"
  attr :arrow_point_at_center, :boolean, default: false, doc: "箭头是否指向目标元素中心"
  attr :mouse_enter_delay, :integer, default: 100, doc: "鼠标移入后延时多少毫秒显示"
  attr :mouse_leave_delay, :integer, default: 100, doc: "鼠标移出后延时多少毫秒隐藏"
  attr :overlay_class, :string, default: "", doc: "卡片样式类名"
  attr :overlay_style, :string, default: "", doc: "卡片样式"
  attr :z_index, :integer, default: 1070, doc: "设置 Tooltip 的 z-index"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :inner_block, required: true, doc: "触发 Tooltip 显示的元素"
  slot :content, doc: "自定义提示内容（优先级高于 title 属性）"
  
  def tooltip(assigns) do
    ~H"""
    <div 
      id={@id}
      class={["pc-tooltip-container inline-block", @class]}
      data-tooltip-container
      phx-hook="Tooltip"
      data-placement={@placement}
      data-trigger={@trigger}
      data-visible={to_string(@visible)}
      data-color={@color}
      data-arrow-point-at-center={to_string(@arrow_point_at_center)}
      data-mouse-enter-delay={@mouse_enter_delay}
      data-mouse-leave-delay={@mouse_leave_delay}
      data-z-index={@z_index}
      data-disabled={to_string(@disabled)}
      {@rest}
    >
      <!-- 触发元素 -->
      <div 
        data-tooltip-trigger
        aria-describedby={"#{@id}-content"}
        class="inline-block"
      >
        <%= render_slot(@inner_block) %>
      </div>
      
      <!-- Tooltip 内容（初始隐藏） -->
      <div
        id={"#{@id}-content"}
        role="tooltip"
        class={[
          "pc-tooltip-content",
          "absolute invisible opacity-0 z-[var(--tooltip-z-index)]",
          "transition-all duration-200",
          @overlay_class
        ]}
        style={"#{@overlay_style}; --tooltip-z-index: #{@z_index}"}
        data-tooltip-content
      >
        <!-- 箭头 -->
        <div class="pc-tooltip-arrow absolute w-0 h-0" data-tooltip-arrow></div>
        
        <!-- 内容区域 -->
        <div class={[
          "pc-tooltip-inner",
          "px-2 py-1.5 text-sm text-white rounded",
          "shadow-lg max-w-sm",
          tooltip_bg_class(@color)
        ]}>
          <%= if @content && @content != [] do %>
            <%= render_slot(@content) %>
          <% else %>
            <%= @title %>
          <% end %>
        </div>
      </div>
    </div>
    
    <style>
      .pc-tooltip-content {
        pointer-events: none;
      }
      
      .pc-tooltip-content.visible {
        visibility: visible;
        opacity: 1;
        pointer-events: auto;
      }
      
      /* 默认背景色 */
      .pc-tooltip-inner {
        background-color: rgba(0, 0, 0, 0.85);
      }
      
      /* 箭头样式 */
      .pc-tooltip-arrow {
        border-style: solid;
        border-color: transparent;
      }
      
      /* 上方箭头 */
      .pc-tooltip-content[data-placement^="top"] .pc-tooltip-arrow {
        bottom: -4px;
        border-width: 4px 4px 0;
        border-top-color: rgba(0, 0, 0, 0.85);
      }
      
      /* 下方箭头 */
      .pc-tooltip-content[data-placement^="bottom"] .pc-tooltip-arrow {
        top: -4px;
        border-width: 0 4px 4px;
        border-bottom-color: rgba(0, 0, 0, 0.85);
      }
      
      /* 左侧箭头 */
      .pc-tooltip-content[data-placement^="left"] .pc-tooltip-arrow {
        right: -4px;
        border-width: 4px 0 4px 4px;
        border-left-color: rgba(0, 0, 0, 0.85);
      }
      
      /* 右侧箭头 */
      .pc-tooltip-content[data-placement^="right"] .pc-tooltip-arrow {
        left: -4px;
        border-width: 4px 4px 4px 0;
        border-right-color: rgba(0, 0, 0, 0.85);
      }
      
      /* 自定义颜色的箭头 */
      .pc-tooltip-content[data-color] .pc-tooltip-arrow {
        border-color: transparent;
      }
      
      .pc-tooltip-content[data-color][data-placement^="top"] .pc-tooltip-arrow {
        border-top-color: var(--tooltip-bg-color);
      }
      
      .pc-tooltip-content[data-color][data-placement^="bottom"] .pc-tooltip-arrow {
        border-bottom-color: var(--tooltip-bg-color);
      }
      
      .pc-tooltip-content[data-color][data-placement^="left"] .pc-tooltip-arrow {
        border-left-color: var(--tooltip-bg-color);
      }
      
      .pc-tooltip-content[data-color][data-placement^="right"] .pc-tooltip-arrow {
        border-right-color: var(--tooltip-bg-color);
      }
    </style>
    """
  end
  
  # Helper functions
  
  defp tooltip_bg_class(nil), do: ""
  defp tooltip_bg_class(color) do
    # 如果是自定义颜色，通过 style 属性设置
    if String.starts_with?(color, "#") || String.starts_with?(color, "rgb") do
      "!bg-[var(--tooltip-bg-color)]"
    else
      # 预定义的颜色类
      case color do
        "blue" -> "!bg-blue-500"
        "green" -> "!bg-green-500"
        "red" -> "!bg-red-500"
        "yellow" -> "!bg-yellow-500"
        "purple" -> "!bg-purple-500"
        "pink" -> "!bg-pink-500"
        "gray" -> "!bg-gray-600"
        _ -> ""
      end
    end
  end
end