defmodule PetalComponents.Custom.Cascader do
  @moduledoc """
  级联选择器组件 - 用于从关联数据集合中进行选择
  
  ## 特性
  - 支持多级数据展示
  - 支持单选和多选
  - 支持搜索功能
  - 支持自定义字段名
  - 支持动态加载数据
  - 支持禁用状态
  - 支持清除功能
  - 支持自定义显示格式
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染级联选择器组件
  
  ## 示例
  
      <.cascader 
        id="area-select"
        options={@area_options}
        placeholder="请选择地区"
      />
      
      <!-- 不同尺寸示例 -->
      <.cascader 
        id="small-cascader"
        size="small"
        color="primary"
        options={@simple_data}
        placeholder="小号级联"
      />
      
      <.cascader 
        id="large-cascader"
        size="large"
        multiple
        color="info"
        options={@complex_data}
        placeholder="大号多选级联"
      />
  """
  attr :id, :string, required: true, doc: "选择器唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :value, :list, default: nil, doc: "当前选中的值路径"
  attr :options, :list, default: [], doc: "可选项数据源"
  attr :placeholder, :string, default: "请选择", doc: "占位文字"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :multiple, :boolean, default: false, doc: "是否多选"
  attr :searchable, :boolean, default: false, doc: "是否可搜索"
  attr :clearable, :boolean, default: true, doc: "是否可清除"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "尺寸"
  attr :expand_trigger, :string, values: ["click", "hover"], default: "click", doc: "次级菜单的展开方式"
  attr :change_on_select, :boolean, default: false, doc: "是否允许选择任意一级选项"
  attr :show_all_levels, :boolean, default: true, doc: "是否显示完整路径"
  attr :separator, :string, default: " / ", doc: "分隔符"
  attr :field_names, :map, default: %{label: "label", value: "value", children: "children"}, doc: "自定义字段名"
  attr :load_data, :any, default: nil, doc: "动态加载数据的函数"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: %JS{}, doc: "选中值改变时的回调"
  attr :on_clear, JS, default: %JS{}, doc: "清除选中值时的回调"
  attr :rest, :global, doc: "其他HTML属性"

  def cascader(assigns) do
    assigns = 
      assigns
      |> assign(:display_text, get_display_text(assigns))
      |> assign(:show_clear, assigns[:clearable] && has_value?(assigns[:value]))
      |> assign(:dropdown_id, "#{assigns.id}-dropdown")
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-cascader relative",
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ]}
      {@rest}>
      
      <%= if @name do %>
        <%= render_hidden_inputs(assigns) %>
      <% end %>
      
      <div class="relative">
        <button
          type="button"
          class={[
            "pc-cascader__trigger w-full flex items-center justify-between",
            "border border-gray-300 dark:border-gray-600 rounded-md",
            "bg-white dark:bg-gray-800 text-left",
            "transition duration-150 ease-in-out hover:border-gray-400 dark:hover:border-gray-500",
            get_focus_classes(@color),
            size_classes(@size),
            @disabled && "cursor-not-allowed opacity-50",
            @multiple && "multiple-select"
          ]}
          disabled={@disabled}
          phx-click={toggle_dropdown(@dropdown_id)}
          phx-click-away={hide_dropdown(@dropdown_id)}>
          
          <div class="flex-1 flex items-center">
            <%= if @multiple && @value && length(@value) > 0 do %>
              <%= render_tags(assigns) %>
            <% else %>
              <span class={[
                "block truncate",
                !@display_text && "text-gray-400 dark:text-gray-500"
              ]}>
                <%= @display_text || @placeholder %>
              </span>
            <% end %>
          </div>
          
          <div class="flex items-center gap-1">
            <%= if @show_clear do %>
              <button
                type="button"
                class={["pc-cascader__clear p-0.5 rounded transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
                phx-click={@on_clear}
                phx-click-away={hide_dropdown(@dropdown_id)}>
                <svg class="w-4 h-4 text-gray-400 dark:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>
            <% end %>
            
            <svg class="w-5 h-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </button>
        
        <!-- 下拉菜单 -->
        <div 
          id={@dropdown_id}
          class={[
            "dropdown-panel absolute z-10 mt-1 bg-white dark:bg-gray-800 rounded-md",
            "shadow-xl shadow-gray-500/10 dark:shadow-gray-900/30",
            "border border-gray-200 dark:border-gray-700 max-h-60 overflow-hidden",
            "hidden"
          ]}>
          
          <%= if @searchable do %>
            <div class="p-2 border-b border-gray-200 dark:border-gray-700">
              <input
                type="text"
                class={["pc-cascader__search w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100", get_focus_classes(@color)]}
                placeholder="搜索..."
                phx-keyup="search_cascader"
                phx-debounce="300"
              />
            </div>
          <% end %>
          
          <div class="pc-cascader__menu flex">
            <%= render_cascader_menu(assigns) %>
          </div>
        </div>
      </div>
    </div>
    
    """
  end
  
  # 渲染隐藏的表单输入
  defp render_hidden_inputs(assigns) do
    if assigns.multiple do
      ~H"""
      <%= for value_path <- (@value || []) do %>
        <%= for value <- value_path do %>
          <input type="hidden" name={"#{@name}[]"} value={value} />
        <% end %>
      <% end %>
      """
    else
      value_str = if assigns.value, do: Enum.join(assigns.value || [], ","), else: ""
      assigns = assign(assigns, :value_str, value_str)
      ~H"""
      <input type="hidden" name={@name} value={@value_str} />
      """
    end
  end
  
  # 渲染多选标签
  defp render_tags(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-1">
      <%= for value_path <- @value do %>
        <% display = get_path_display_text(value_path, @options, @field_names, @show_all_levels, @separator) %>
        <span class="tag inline-flex items-center gap-1 px-2 py-0.5 bg-gray-100 dark:bg-gray-700 text-sm rounded">
          <%= display %>
          <button
            type="button"
            class="hover:text-gray-700 dark:hover:text-gray-300"
            phx-click={if @on_change, do: @on_change, else: "remove_cascader_tag"}
            phx-value-path={Enum.join(value_path, ",")}>
            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </span>
      <% end %>
    </div>
    """
  end
  
  # 渲染级联菜单
  defp render_cascader_menu(assigns) do
    levels = build_menu_levels(assigns.options, assigns.value || [], assigns.field_names)
    assigns = assign(assigns, :levels, levels)
    
    ~H"""
    <%= for {level_options, level_index} <- Enum.with_index(@levels) do %>
      <div class={[
        "pc-cascader__level border-r border-gray-200 dark:border-gray-700 last:border-r-0",
        "min-w-32 max-w-48"
      ]}>
        <%= for option <- level_options do %>
          <%= render_cascader_option(assigns, option, level_index) %>
        <% end %>
      </div>
    <% end %>
    """
  end
  
  # 渲染级联选项
  defp render_cascader_option(assigns, option, level_index) do
    field_names = assigns.field_names
    value = Map.get(option, String.to_atom(field_names.value), option[:value])
    label = Map.get(option, String.to_atom(field_names.label), option[:label])
    children = Map.get(option, String.to_atom(field_names.children), option[:children])
    
    current_path = Enum.take(assigns.value || [], level_index + 1)
    is_selected = length(current_path) > level_index && Enum.at(current_path, level_index) == value
    has_children = children && length(children) > 0
    
    assigns = 
      assigns
      |> assign(:option_value, value)
      |> assign(:option_label, label)
      |> assign(:has_children, has_children)
      |> assign(:is_selected, is_selected)
      |> assign(:level_index, level_index)
    
    ~H"""
    <div
      class={[
        "pc-cascader__option px-4 py-2 cursor-pointer transition duration-150 ease-in-out hover:bg-gray-50 dark:hover:bg-gray-700 flex items-center justify-between",
        @is_selected && get_selected_classes(@color)
      ]}
      phx-click={if @on_change, do: @on_change, else: "select_cascader_option"}
      phx-value-value={@option_value}
      phx-value-level={@level_index}
      phx-mouseenter={@expand_trigger == "hover" && "expand_cascader_option"}
      phx-value-expand-value={@option_value}
      phx-value-expand-level={@level_index}>
      
      <span class="flex-1 text-gray-900 dark:text-gray-100"><%= @option_label %></span>
      
      <%= if @has_children do %>
        <svg class="w-4 h-4 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      <% end %>
    </div>
    """
  end
  
  # 获取显示文本
  defp get_display_text(assigns) do
    case assigns.value do
      nil -> nil
      [] -> nil
      value_path when is_list(value_path) ->
        get_path_display_text(value_path, assigns.options, assigns.field_names, assigns.show_all_levels, assigns.separator)
      _ -> nil
    end
  end
  
  # 获取路径显示文本
  defp get_path_display_text(value_path, options, field_names, show_all_levels, separator) do
    labels = get_path_labels(value_path, options, field_names)
    
    if show_all_levels do
      Enum.join(labels, separator)
    else
      List.last(labels) || ""
    end
  end
  
  # 获取路径标签
  defp get_path_labels([], _options, _field_names), do: []
  defp get_path_labels([value | rest], options, field_names) do
    case find_option_by_value(options, value, field_names) do
      nil -> []
      option ->
        label = Map.get(option, String.to_atom(field_names.label), option[:label])
        children = Map.get(option, String.to_atom(field_names.children), option[:children])
        [label | get_path_labels(rest, children || [], field_names)]
    end
  end
  
  # 根据值查找选项
  defp find_option_by_value(options, target_value, field_names) do
    Enum.find(options, fn option ->
      value = Map.get(option, String.to_atom(field_names.value), option[:value])
      value == target_value
    end)
  end
  
  # 构建菜单层级
  defp build_menu_levels(options, current_value, field_names) do
    build_levels_recursive(options, current_value, field_names, [])
    |> Enum.reverse()
  end
  
  defp build_levels_recursive(options, [], _field_names, acc) do
    if options != [], do: [options | acc], else: acc
  end
  
  defp build_levels_recursive(options, [current | rest], field_names, acc) do
    new_acc = [options | acc]
    
    case find_option_by_value(options, current, field_names) do
      nil -> new_acc
      option ->
        children = Map.get(option, String.to_atom(field_names.children), option[:children])
        if children && length(children) > 0 do
          build_levels_recursive(children, rest, field_names, new_acc)
        else
          new_acc
        end
    end
  end
  
  # 检查是否有值
  defp has_value?(nil), do: false
  defp has_value?([]), do: false
  defp has_value?(value) when is_list(value), do: true
  defp has_value?(_), do: false
  
  # 尺寸样式 - 匹配 Petal Components 的间距标准
  defp size_classes("small"), do: "text-sm leading-4 py-2 px-3"
  defp size_classes("medium"), do: "text-sm leading-5 py-2 px-4"
  defp size_classes("large"), do: "text-base leading-6 py-2.5 px-6"
  
  # JS命令：切换下拉菜单
  defp toggle_dropdown(id) do
    JS.toggle(
      to: "##{id}",
      in: {"transition ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"},
      out: {"transition ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end
  
  # JS命令：隐藏下拉菜单
  defp hide_dropdown(id) do
    JS.hide(
      to: "##{id}",
      transition: {"transition ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end
  
  # 获取焦点样式
  defp get_focus_classes(color) do
    case color do
      "primary" -> "focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary focus:ring-offset-2"
      "info" -> "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 focus:ring-offset-2"
      "success" -> "focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 focus:ring-offset-2"
      "warning" -> "focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 focus:ring-offset-2"
      "danger" -> "focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 focus:ring-offset-2"
      _ -> "focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary focus:ring-offset-2"
    end
  end
  
  # 获取选中项样式
  defp get_selected_classes(color) do
    case color do
      "primary" -> "bg-primary bg-opacity-10 text-primary"
      "info" -> "bg-blue-500 bg-opacity-10 text-blue-600"
      "success" -> "bg-green-500 bg-opacity-10 text-green-600"
      "warning" -> "bg-yellow-500 bg-opacity-10 text-yellow-600"
      "danger" -> "bg-red-500 bg-opacity-10 text-red-600"
      _ -> "bg-primary bg-opacity-10 text-primary"
    end
  end
  
end