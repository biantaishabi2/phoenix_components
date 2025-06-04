defmodule PetalComponents.Custom.Dropdown do
  @moduledoc """
  下拉菜单组件，提供灵活的菜单选项展示
  
  ## 特性
  - 支持点击和悬停触发
  - 支持多种位置定位
  - 支持图标、分隔线、危险项等
  - 完整的键盘导航支持
  - 无障碍性支持
  
  ## 依赖
  - 无外部依赖，样式完全基于 Tailwind CSS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  渲染下拉菜单组件
  
  ## 示例
      <.dropdown>
        <:trigger>
          <.button>操作</.button>
        </:trigger>
        <:items>
          <:item key="edit" label="编辑" on_click={JS.push("edit")} />
          <:item key="delete" label="删除" danger on_click={JS.push("delete")} />
        </:items>
      </.dropdown>
  """
  attr :id, :string, default: nil, doc: "下拉菜单的唯一标识符"
  attr :trigger_type, :string, values: ~w(click hover), default: "click", doc: "触发方式"
  attr :position, :string, 
    values: ~w(bottom-start bottom-end top-start top-end left right), 
    default: "bottom-start", 
    doc: "菜单位置"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :arrow, :boolean, default: false, doc: "是否显示箭头"
  attr :offset, :integer, default: 4, doc: "菜单与触发器的间距"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :menu_class, :string, default: "", doc: "菜单容器的自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :trigger, required: true, doc: "触发器内容"
  slot :items, required: true, doc: "菜单内容" do
    attr :key, :string, doc: "菜单项唯一标识"
    attr :label, :string, doc: "菜单项文本"
    attr :icon, :string, doc: "菜单项图标"
    attr :disabled, :boolean, doc: "是否禁用"
    attr :divider, :boolean, doc: "是否为分隔线"
    attr :danger, :boolean, doc: "是否为危险操作"
    attr :on_click, JS, doc: "点击事件"
  end
  
  def dropdown(assigns) do
    assigns = assign_defaults(assigns)
    
    ~H"""
    <div 
      class={["relative inline-block", @class]}
      data-dropdown-id={@id}
      {@rest}
    >
      <!-- Trigger -->
      <div
        id={"#{@id}-trigger"}
        class={trigger_classes(@disabled)}
        role="button"
        aria-expanded="false"
        aria-haspopup="true"
        aria-controls={"#{@id}-menu"}
        aria-disabled={to_string(@disabled)}
        tabindex={if @disabled, do: "-1", else: "0"}
        {trigger_events(@id, @trigger_type, @disabled)}
      >
        <%= render_slot(@trigger) %>
      </div>
      
      <!-- Menu -->
      <div
        id={"#{@id}-menu"}
        class={menu_classes(@position, @menu_class)}
        role="menu"
        aria-labelledby={"#{@id}-trigger"}
        data-state="closed"
        style="display: none;"
        phx-click-away={hide_dropdown(@id)}
        phx-window-keydown={hide_dropdown(@id)}
        phx-key="Escape"
      >
        <%= if @arrow do %>
          <div class={arrow_classes(@position)} data-popper-arrow></div>
        <% end %>
        
        <div class="py-1">
          <%= for item <- @items do %>
            <%= if item[:divider] do %>
              <hr class="my-1 border-t border-gray-200 dark:border-gray-700" role="separator" />
            <% else %>
              <%= if item[:key] do %>
                <button
                  type="button"
                  role="menuitem"
                  class={item_classes(item[:danger], item[:disabled])}
                  aria-disabled={to_string(item[:disabled] || false)}
                  disabled={item[:disabled]}
                  phx-click={!item[:disabled] && compose_click_handler(@id, item[:on_click])}
                  phx-value-action={item[:key]}
                  tabindex="-1"
                >
                  <%= if item[:icon] do %>
                    <span class="mr-3 flex-shrink-0">
                      <%= Phoenix.HTML.raw(item[:icon]) %>
                    </span>
                  <% end %>
                  <span class="flex-grow">
                    <%= item[:label] %>
                  </span>
                </button>
              <% else %>
                <!-- Custom content -->
                <%= render_slot(item) %>
              <% end %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
  
  # Helper functions
  
  defp assign_defaults(assigns) do
    id = assigns[:id] || "dropdown-#{:erlang.unique_integer([:positive])}"
    assign(assigns, :id, id)
  end
  
  defp trigger_classes(disabled) do
    base = "inline-flex items-center"
    
    if disabled do
      "#{base} opacity-50 cursor-not-allowed"
    else
      "#{base} cursor-pointer"
    end
  end
  
  defp trigger_events(id, trigger, disabled) do
    if disabled do
      []
    else
      case trigger do
        "click" -> 
          [
            "phx-click": toggle_dropdown(id)
          ]
        "hover" -> 
          [
            "phx-mouseenter": show_dropdown(id),
            "phx-mouseleave": hide_dropdown_delayed(id)
          ]
      end
    end
  end
  
  defp menu_classes(position, custom_class) do
    base = [
      "absolute z-50",
      "min-w-[180px] max-w-[320px]",
      "bg-white dark:bg-gray-800",
      "border border-gray-200 dark:border-gray-700",
      "rounded-md shadow-lg",
      "overflow-hidden",
      "transition-all duration-200",
      position_classes(position),
      custom_class
    ]
    
    Enum.join(base, " ")
  end
  
  defp position_classes("bottom-start"), do: "top-full left-0 mt-1"
  defp position_classes("bottom-end"), do: "top-full right-0 mt-1"
  defp position_classes("top-start"), do: "bottom-full left-0 mb-1"
  defp position_classes("top-end"), do: "bottom-full right-0 mb-1"
  defp position_classes("left"), do: "right-full top-0 mr-1"
  defp position_classes("right"), do: "left-full top-0 ml-1"
  
  defp arrow_classes(position) do
    base = "absolute w-2 h-2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 transform rotate-45"
    
    case position do
      "bottom-start" -> "#{base} -top-1 left-4 border-b-0 border-r-0"
      "bottom-end" -> "#{base} -top-1 right-4 border-b-0 border-r-0"
      "top-start" -> "#{base} -bottom-1 left-4 border-t-0 border-l-0"
      "top-end" -> "#{base} -bottom-1 right-4 border-t-0 border-l-0"
      "left" -> "#{base} top-4 -right-1 border-l-0 border-t-0"
      "right" -> "#{base} top-4 -left-1 border-r-0 border-b-0"
    end
  end
  
  defp item_classes(danger, disabled) do
    base = [
      "w-full px-4 py-2",
      "text-sm text-left",
      "flex items-center",
      "transition-colors duration-150"
    ]
    
    state_classes = cond do
      disabled ->
        "text-gray-400 dark:text-gray-600 cursor-not-allowed opacity-50"
      danger ->
        "text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"
      true ->
        "text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
    end
    
    Enum.join(base ++ [state_classes], " ")
  end
  
  # JavaScript commands
  
  defp toggle_dropdown(id) do
    JS.toggle(
      to: "##{id}-menu",
      in: {
        "transition ease-out duration-100",
        "opacity-0 scale-95",
        "opacity-100 scale-100"
      },
      out: {
        "transition ease-in duration-75",
        "opacity-100 scale-100",
        "opacity-0 scale-95"
      }
    )
    |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: "##{id}-trigger")
    |> JS.toggle_attribute({"data-state", "open", "closed"}, to: "##{id}-menu")
  end
  
  defp show_dropdown(id) do
    JS.show(
      to: "##{id}-menu",
      transition: {
        "transition ease-out duration-100",
        "opacity-0 scale-95",
        "opacity-100 scale-100"
      }
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: "##{id}-trigger")
    |> JS.set_attribute({"data-state", "open"}, to: "##{id}-menu")
  end
  
  defp hide_dropdown(id) do
    JS.hide(
      to: "##{id}-menu",
      transition: {
        "transition ease-in duration-75",
        "opacity-100 scale-100",
        "opacity-0 scale-95"
      }
    )
    |> JS.set_attribute({"aria-expanded", "false"}, to: "##{id}-trigger")
    |> JS.set_attribute({"data-state", "closed"}, to: "##{id}-menu")
  end
  
  defp hide_dropdown_delayed(id) do
    JS.hide(
      to: "##{id}-menu",
      transition: {
        "transition ease-in duration-75",
        "opacity-100 scale-100",
        "opacity-0 scale-95"
      },
      time: 300
    )
    |> JS.set_attribute({"aria-expanded", "false"}, to: "##{id}-trigger")
    |> JS.set_attribute({"data-state", "closed"}, to: "##{id}-menu")
  end
  
  defp compose_click_handler(dropdown_id, on_click) do
    base_js = hide_dropdown(dropdown_id)
    
    case on_click do
      %JS{} = custom_js -> 
        # Combine the operations from both JS structs
        %JS{ops: base_js.ops ++ custom_js.ops}
      nil -> 
        base_js
      _ -> 
        base_js
    end
  end
end