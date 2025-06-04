defmodule PetalComponents.Custom.Tabs do
  @moduledoc """
  标签页组件，用于内容分组和切换展示
  
  ## 特性
  - 支持多种样式类型（线条、卡片、药丸）
  - 支持不同尺寸
  - 支持四个方向的标签位置
  - 支持图标
  - 支持禁用状态
  - 可选的切换动画
  - 完整的键盘导航支持
  
  ## 依赖
  - 无外部依赖，样式完全基于 Tailwind CSS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  渲染标签页组件
  
  ## 示例
      <.tabs active_tab="tab1" on_change={JS.push("change_tab")}>
        <:tabs key="tab1" label="标签一">
          内容一
        </:tabs>
        <:tabs key="tab2" label="标签二">
          内容二
        </:tabs>
      </.tabs>
  """
  attr :active_tab, :string, default: nil, doc: "当前激活的标签页key"
  attr :type, :string, values: ~w(line card pills), default: "line", doc: "标签页样式类型"
  attr :size, :string, values: ~w(small medium large), default: "medium", doc: "标签页尺寸"
  attr :position, :string, values: ~w(top right bottom left), default: "top", doc: "标签位置"
  attr :animated, :boolean, default: true, doc: "是否使用动画切换"
  attr :on_change, JS, default: nil, doc: "切换标签页时的回调"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :rest, :global, doc: "其他HTML属性"
  
  slot :tabs, required: true, doc: "标签页内容" do
    attr :key, :string, required: true, doc: "标签页唯一标识"
    attr :label, :string, required: true, doc: "标签页标题"
    attr :disabled, :boolean, doc: "是否禁用"
    attr :icon, :string, doc: "标签图标（SVG或HTML）"
  end
  
  def tabs(assigns) do
    assigns = assign_defaults(assigns)
    
    ~H"""
    <div class={["w-full", @class]} {@rest}>
      <div class={container_classes(@position)}>
        <!-- Tab Headers -->
        <div class={header_classes(@position)} role="tablist">
          <div class={tab_list_classes(@type, @position)}>
            <%= for tab <- @tabs do %>
              <button
                type="button"
                role="tab"
                id={"tab-#{tab.key}"}
                data-tab-key={tab.key}
                aria-selected={to_string(tab.key == @active_tab)}
                aria-disabled={to_string(tab[:disabled] || false)}
                aria-controls={"tabpanel-#{tab.key}"}
                class={tab_button_classes(@type, @size, tab.key == @active_tab, tab[:disabled])}
                phx-click={!tab[:disabled] && @on_change}
                phx-value-tab={!tab[:disabled] && tab.key}
                disabled={tab[:disabled]}
              >
                <%= if tab[:icon] do %>
                  <span class={icon_classes(@size)}>
                    <%= Phoenix.HTML.raw(tab[:icon]) %>
                  </span>
                <% end %>
                <span>
                  <%= tab.label %>
                </span>
              </button>
            <% end %>
          </div>
          <%= if @type == "line" do %>
            <div class={ink_bar_classes()} 
                 data-active-tab={@active_tab}>
            </div>
          <% end %>
        </div>
        
        <!-- Tab Panels -->
        <div class={panels_container_classes(@position)}>
          <%= for tab <- @tabs do %>
            <div
              role="tabpanel"
              id={"tabpanel-#{tab.key}"}
              aria-labelledby={"tab-#{tab.key}"}
              class={[
                tab.key != @active_tab && "hidden",
                @animated && "transition-opacity duration-200"
              ]}
            >
              <%= render_slot(tab) %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
  
  # 默认值处理
  defp assign_defaults(assigns) do
    active_tab = assigns[:active_tab] || get_first_tab_key(assigns.tabs)
    assign(assigns, :active_tab, active_tab)
  end
  
  defp get_first_tab_key(tabs) do
    case tabs do
      [first | _] -> first.key
      _ -> nil
    end
  end
  
  # 容器布局类
  defp container_classes("top"), do: "flex flex-col"
  defp container_classes("bottom"), do: "flex flex-col-reverse"
  defp container_classes("left"), do: "flex flex-row"
  defp container_classes("right"), do: "flex flex-row-reverse"
  
  # 标签头部容器类
  defp header_classes(position) do
    base = "relative"
    
    case position do
      "top" -> "#{base} border-b border-gray-200 dark:border-gray-700"
      "bottom" -> "#{base} border-t border-gray-200 dark:border-gray-700"
      "left" -> "#{base} border-r border-gray-200 dark:border-gray-700 pr-4 min-w-[120px]"
      "right" -> "#{base} border-l border-gray-200 dark:border-gray-700 pl-4 min-w-[120px]"
    end
  end
  
  # 标签列表容器类
  defp tab_list_classes(type, position) when position in ["top", "bottom"] do
    base = "flex items-center"
    
    case type do
      "line" -> "#{base} space-x-8 relative"
      "card" -> "#{base} space-x-1"
      "pills" -> "#{base} space-x-2"
    end
  end
  
  defp tab_list_classes(type, position) when position in ["left", "right"] do
    base = "flex flex-col"
    
    case type do
      "line" -> "#{base} space-y-2 relative"
      "card" -> "#{base} space-y-1"
      "pills" -> "#{base} space-y-2"
    end
  end
  
  # 标签按钮类
  defp tab_button_classes(type, size, active?, disabled?) do
    base = [
      # 基础样式
      "relative flex items-center gap-2 font-medium transition-all duration-200",
      "focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2",
      
      # 尺寸样式
      size_classes(size),
      
      # 类型和状态样式
      type_state_classes(type, active?, disabled?)
    ]
    
    Enum.join(base, " ")
  end
  
  # 尺寸相关类
  defp size_classes("small"), do: "text-sm px-3 py-1.5"
  defp size_classes("medium"), do: "text-sm px-4 py-2"
  defp size_classes("large"), do: "text-base px-6 py-3"
  
  # 图标尺寸类
  defp icon_classes("small"), do: "text-sm"
  defp icon_classes("medium"), do: "text-base"
  defp icon_classes("large"), do: "text-lg"
  
  # 类型和状态组合类
  defp type_state_classes("line", active?, disabled?) do
    cond do
      disabled? -> "text-gray-400 dark:text-gray-600 cursor-not-allowed opacity-50"
      active? -> "text-primary"
      true -> "text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-100"
    end
  end
  
  defp type_state_classes("card", active?, disabled?) do
    cond do
      disabled? -> 
        "border border-gray-300 dark:border-gray-700 bg-gray-100 dark:bg-gray-800 " <>
        "text-gray-400 dark:text-gray-600 cursor-not-allowed opacity-50"
      active? -> 
        "bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 " <>
        "border-b-white dark:border-b-gray-900 text-primary"
      true -> 
        "border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-800 " <>
        "hover:bg-gray-50 dark:hover:bg-gray-700"
    end <> " rounded-t-md"
  end
  
  defp type_state_classes("pills", active?, disabled?) do
    cond do
      disabled? -> 
        "bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-600 " <>
        "cursor-not-allowed opacity-50"
      active? -> 
        "bg-primary text-white"
      true -> 
        "bg-gray-100 dark:bg-gray-800 hover:bg-gray-300 dark:hover:bg-gray-600"
    end <> " rounded-full"
  end
  
  # 内容面板容器类
  defp panels_container_classes(position) when position in ["left", "right"] do
    "flex-1 pl-4"
  end
  defp panels_container_classes(_), do: "mt-4"
  
  # 指示条类（line类型）
  defp ink_bar_classes do
    "absolute bottom-0 h-0.5 bg-primary transition-all duration-300"
  end
end