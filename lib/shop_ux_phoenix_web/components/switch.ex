defmodule PetalComponents.Custom.Switch do
  @moduledoc """
  开关组件，用于在两种状态间切换
  
  ## 特性
  - 支持多种尺寸和颜色
  - 支持加载状态
  - 支持自定义选中/未选中内容
  - 支持禁用状态
  - 完整的键盘和无障碍支持
  
  ## 依赖
  - 无外部依赖
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  渲染开关组件
  
  ## 示例
      <.switch 
        id="notifications"
        checked={@notifications_enabled}
        on_change={JS.push("toggle_notifications")}
      />
  """
  attr :id, :string, required: true, doc: "开关唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :checked, :boolean, default: false, doc: "是否选中"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :size, :string, values: ~w(small medium large), default: "medium", doc: "尺寸"
  attr :color, :string, values: ~w(primary info success warning danger), default: "primary", doc: "颜色主题"
  attr :loading, :boolean, default: false, doc: "加载中状态"
  attr :checked_text, :string, default: nil, doc: "选中时的文本"
  attr :unchecked_text, :string, default: nil, doc: "非选中时的文本"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: nil, doc: "变化时回调"
  attr :rest, :global, doc: "其他HTML属性"
  
  slot :checked_children, doc: "选中时的内容插槽"
  slot :unchecked_children, doc: "非选中时的内容插槽"
  
  def switch(assigns) do
    assigns = assign_defaults(assigns)
    
    ~H"""
    <label class={[
      "relative inline-flex items-center cursor-pointer select-none",
      get_switch_classes(@size, @checked, @disabled, @loading),
      @class
    ]}>
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        disabled={@disabled || @loading}
        role="switch"
        aria-checked={to_string(@checked)}
        class="sr-only"
        phx-click={@on_change}
        {@rest}
      />
      <span class={[
        "relative inline-block rounded-full transition-all duration-200 ease-in-out",
        get_handle_classes(@size, @checked, @color, @disabled),
        @loading && "pointer-events-none",
        "after:content-[''] after:absolute after:bg-white after:rounded-full after:shadow-sm after:transition-all after:duration-200 after:ease-in-out",
        get_after_classes(@size, @checked)
      ]}>
        <span :if={@loading} class={[
          "absolute inset-0 flex items-center justify-center",
          get_loading_icon_classes(@size, @checked)
        ]}>
          <svg class={["animate-spin", get_loading_size(@size)]} viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
        </span>
      </span>
      <span :if={@checked_text || @unchecked_text || @checked_children != [] || @unchecked_children != []} class={[
        "absolute inset-0 flex items-center text-white font-medium transition-opacity duration-200 pointer-events-none",
        get_inner_classes(@size, @checked)
      ]}>
        <%= if @checked do %>
          <%= if @checked_children != [] do %>
            <%= render_slot(@checked_children) %>
          <% else %>
            <%= @checked_text %>
          <% end %>
        <% else %>
          <%= if @unchecked_children != [] do %>
            <%= render_slot(@unchecked_children) %>
          <% else %>
            <%= @unchecked_text %>
          <% end %>
        <% end %>
      </span>
    </label>
    """
  end
  
  defp assign_defaults(assigns) do
    assigns
  end
  
  defp get_switch_classes(_size, _checked, disabled, _loading) do
    if disabled do
      ["cursor-not-allowed", "opacity-50"]
    else
      []
    end
  end
  
  defp get_handle_classes(size, checked, color, disabled) do
    base_classes = ["bg-gray-300"]
    size_classes = get_size_classes(size)
    
    color_classes = if checked && !disabled do
      get_color_classes(color)
    else
      []
    end
    
    hover_classes = unless disabled do
      ["hover:brightness-110"]
    else
      []
    end
    
    focus_classes = ["focus-within:ring-2", "focus-within:ring-primary", "focus-within:ring-offset-2"]
    
    base_classes ++ size_classes ++ color_classes ++ hover_classes ++ focus_classes
  end
  
  defp get_size_classes(size) do
    case size do
      "small" -> ["w-7", "h-4"]
      "medium" -> ["w-11", "h-6"]
      "large" -> ["w-14", "h-7"]
      _ -> ["w-11", "h-6"]
    end
  end
  
  defp get_color_classes(color) do
    case color do
      "primary" -> ["bg-orange-500"]
      "info" -> ["bg-blue-500"]
      "success" -> ["bg-green-500"]
      "warning" -> ["bg-yellow-500"]
      "danger" -> ["bg-red-500"]
      _ -> ["bg-orange-500"]
    end
  end
  
  defp get_after_classes(size, checked) do
    position_classes = case size do
      "small" -> ["after:top-1", "after:left-1", "after:w-3", "after:h-3"]
      "medium" -> ["after:top-1", "after:left-1", "after:w-4", "after:h-4"]
      "large" -> ["after:top-1", "after:left-1", "after:w-5", "after:h-5"]
      _ -> ["after:top-1", "after:left-1", "after:w-4", "after:h-4"]
    end
    
    translate_classes = if checked do
      case size do
        "small" -> ["after:translate-x-3"]
        "medium" -> ["after:translate-x-5"]
        "large" -> ["after:translate-x-7"]
        _ -> ["after:translate-x-5"]
      end
    else
      []
    end
    
    position_classes ++ translate_classes
  end
  
  defp get_inner_classes(size, checked) do
    size_classes = case size do
      "small" -> ["text-[10px]", "px-2"]
      "medium" -> ["text-xs", "px-2"]
      "large" -> ["text-sm", "px-3"]
      _ -> ["text-xs", "px-2"]
    end
    
    position_classes = if checked do
      ["justify-start", "pl-2"]
    else
      ["justify-end", "pr-2"]
    end
    
    size_classes ++ position_classes
  end
  
  defp get_loading_icon_classes(_size, checked) do
    if checked do
      ["text-white"]
    else
      ["text-gray-600"]
    end
  end
  
  defp get_loading_size(size) do
    case size do
      "small" -> "w-2 h-2"
      "medium" -> "w-3 h-3"
      "large" -> "w-4 h-4"
      _ -> "w-3 h-3"
    end
  end
end