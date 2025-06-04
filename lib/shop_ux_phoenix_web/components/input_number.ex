defmodule PetalComponents.Custom.InputNumber do
  @moduledoc """
  数字输入框组件，提供更好的数字输入体验
  
  ## 特性
  - 支持最小值和最大值限制
  - 支持精度控制
  - 支持步进器按钮
  - 支持格式化显示
  - 支持键盘快捷键
  - 支持前缀和后缀插槽
  
  ## 依赖
  - 无外部依赖
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  渲染数字输入框组件
  
  ## 示例
      <.input_number 
        id="price"
        value={99.99}
        min={0}
        precision={2}
      >
        <:prefix>¥</:prefix>
      </.input_number>
  """
  attr :id, :string, required: true, doc: "输入框唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :value, :any, default: nil, doc: "当前值"
  attr :min, :any, default: nil, doc: "最小值"
  attr :max, :any, default: nil, doc: "最大值"
  attr :step, :any, default: 1, doc: "每次改变步数"
  attr :precision, :integer, default: nil, doc: "数值精度（小数位数）"
  attr :placeholder, :string, default: "", doc: "占位文字"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :readonly, :boolean, default: false, doc: "是否只读"
  attr :size, :string, values: ~w(small medium large), default: "medium", doc: "尺寸"
  attr :color, :string, values: ~w(primary info success warning danger), default: "primary", doc: "颜色主题"
  attr :controls, :boolean, default: true, doc: "是否显示增减按钮"
  attr :keyboard, :boolean, default: true, doc: "是否启用键盘快捷键"
  attr :formatter, :any, default: nil, doc: "格式化显示函数"
  attr :parser, :any, default: nil, doc: "解析输入值函数"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: nil, doc: "值改变时的回调"
  attr :on_focus, JS, default: nil, doc: "获得焦点时的回调"
  attr :on_blur, JS, default: nil, doc: "失去焦点时的回调"
  attr :rest, :global, doc: "其他HTML属性"
  
  slot :prefix, doc: "前缀图标或文字"
  slot :suffix, doc: "后缀图标或文字"
  
  def input_number(assigns) do
    assigns = assign_defaults(assigns)
    
    ~H"""
    <div class={[
      "inline-block relative",
      @disabled && "cursor-not-allowed opacity-50",
      @class
    ]}>
      <div class="relative flex items-center">
        <span :if={@prefix != []} class="flex items-center px-3 text-gray-500 pr-0">
          <%= render_slot(@prefix) %>
        </span>
        
        <div class="relative flex-1">
          <input
            type="number"
            id={@id}
            name={@name}
            value={@value}
            min={@min}
            max={@max}
            step={@step}
            placeholder={@placeholder}
            disabled={@disabled}
            readonly={@readonly}
            role="spinbutton"
            aria-valuemin={@min}
            aria-valuemax={@max}
            aria-valuenow={@value}
            data-precision={@precision}
            data-keyboard={unless @keyboard, do: "false"}
            data-formatter={@formatter && "true"}
            data-parser={@parser && "true"}
            phx-change={@on_change}
            phx-focus={@on_focus}
            phx-blur={@on_blur}
            phx-hook="InputNumber"
            class={[
              get_input_classes(@size, @color, @disabled, @controls),
              "[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
            ]}
            {@rest}
          />
        </div>
        
        <span :if={@suffix != []} class="flex items-center px-3 text-gray-500 pl-0">
          <%= render_slot(@suffix) %>
        </span>
        
        <div :if={@controls && !@disabled} class={[
          "absolute top-1 bottom-1 right-1 flex flex-col border-l border-gray-300",
          get_control_size_classes(@size)
        ]}>
          <button
            type="button"
            class={[
              "flex-1 flex items-center justify-center cursor-pointer transition-colors duration-150",
              "hover:bg-gray-100 active:bg-gray-200 border-b border-gray-300",
              @disabled && "cursor-not-allowed opacity-50 hover:bg-transparent"
            ]}
            aria-label="Increase"
            phx-click={increase_value(@id, @step, @max)}
            tabindex="-1"
            disabled={@disabled}
          >
            <span class="text-gray-400 hover:text-gray-600">
              <.icon name="hero-chevron-up" class="w-3 h-3" />
            </span>
          </button>
          <button
            type="button"
            class={[
              "flex-1 flex items-center justify-center cursor-pointer transition-colors duration-150",
              "hover:bg-gray-100 active:bg-gray-200",
              @disabled && "cursor-not-allowed opacity-50 hover:bg-transparent"
            ]}
            aria-label="Decrease"
            phx-click={decrease_value(@id, @step, @min)}
            tabindex="-1"
            disabled={@disabled}
          >
            <span class="text-gray-400 hover:text-gray-600">
              <.icon name="hero-chevron-down" class="w-3 h-3" />
            </span>
          </button>
        </div>
      </div>
    </div>
    """
  end
  
  defp assign_defaults(assigns) do
    assigns
  end
  
  defp get_control_size_classes(size) do
    case size do
      "small" -> "w-5"
      "medium" -> "w-6"
      "large" -> "w-7"
      _ -> "w-6"
    end
  end
  
  defp get_input_classes(size, color, disabled, controls) do
    base_classes = [
      "w-full",
      "border",
      "rounded-md",
      "transition-colors",
      "duration-150"
    ]
    
    size_classes = case size do
      "small" -> ["h-8", "px-3", "text-sm"]
      "medium" -> ["h-10", "px-4", "text-sm"]
      "large" -> ["h-12", "px-6", "text-base"]
      _ -> ["h-10", "px-4", "text-sm"]
    end
    
    padding_classes = if controls do
      case size do
        "small" -> ["pr-6"]
        "medium" -> ["pr-8"]
        "large" -> ["pr-9"]
        _ -> ["pr-8"]
      end
    else
      []
    end
    
    state_classes = if disabled do
      ["bg-gray-50", "border-gray-300", "text-gray-500", "cursor-not-allowed"]
    else
      ["bg-white", "border-gray-300", "text-gray-900", "hover:border-gray-400"]
    end
    
    focus_classes = unless disabled do
      get_focus_classes(color)
    else
      []
    end
    
    Enum.join(base_classes ++ size_classes ++ padding_classes ++ state_classes ++ focus_classes, " ")
  end
  
  defp get_focus_classes(color) do
    case color do
      "primary" -> ["focus:outline-none", "focus:ring-2", "focus:ring-primary", "focus:ring-offset-2", "focus:border-primary"]
      "info" -> ["focus:outline-none", "focus:ring-2", "focus:ring-blue-500", "focus:ring-offset-2", "focus:border-blue-500"]
      "success" -> ["focus:outline-none", "focus:ring-2", "focus:ring-green-500", "focus:ring-offset-2", "focus:border-green-500"]
      "warning" -> ["focus:outline-none", "focus:ring-2", "focus:ring-yellow-500", "focus:ring-offset-2", "focus:border-yellow-500"]
      "danger" -> ["focus:outline-none", "focus:ring-2", "focus:ring-red-500", "focus:ring-offset-2", "focus:border-red-500"]
      _ -> ["focus:outline-none", "focus:ring-2", "focus:ring-primary", "focus:ring-offset-2", "focus:border-primary"]
    end
  end
  
  defp increase_value(id, step, max) do
    JS.dispatch("pc:input-number:increase", 
      detail: %{id: id, step: step, max: max}
    )
  end
  
  defp decrease_value(id, step, min) do
    JS.dispatch("pc:input-number:decrease", 
      detail: %{id: id, step: step, min: min}
    )
  end
  
  defp icon(assigns) do
    ~H"""
    <svg class={@class} fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <%= case @name do %>
        <% "hero-chevron-up" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" />
        <% "hero-chevron-down" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        <% _ -> %>
          <circle cx="12" cy="12" r="10" />
      <% end %>
    </svg>
    """
  end
end