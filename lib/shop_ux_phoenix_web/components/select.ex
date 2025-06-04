defmodule PetalComponents.Custom.Select do
  @moduledoc """
  选择器组件 - 下拉选择器
  
  ## 特性
  - 支持单选和多选
  - 支持搜索过滤
  - 支持分组选项
  - 支持清除功能
  - 支持自定义创建选项
  - 支持远程搜索
  - 支持禁用状态
  - 支持不同尺寸
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染选择器组件
  
  ## 示例
  
      <.select 
        id="city-select"
        name="city"
        options={[
          %{value: "bj", label: "北京"},
          %{value: "sh", label: "上海"}
        ]}
        placeholder="请选择城市"
      />
      
      <!-- 不同尺寸示例 -->
      <.select 
        id="small-select"
        size="small"
        color="primary"
        options={@cities}
        placeholder="小号选择器"
      />
      
      <.select 
        id="large-select"
        size="large"
        multiple
        searchable
        color="success"
        options={@departments}
        placeholder="大号多选搜索"
      />
  """
  attr :id, :string, required: true, doc: "选择器唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :value, :any, default: nil, doc: "当前选中的值"
  attr :options, :list, default: [], doc: "选项数据"
  attr :placeholder, :string, default: "请选择", doc: "占位文字"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :multiple, :boolean, default: false, doc: "是否多选"
  attr :searchable, :boolean, default: false, doc: "是否可搜索"
  attr :clearable, :boolean, default: false, doc: "是否可清除"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "尺寸"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: %JS{}, doc: "选中值改变时的回调"
  attr :on_search, JS, default: %JS{}, doc: "搜索文本改变时的回调"
  attr :on_clear, JS, default: %JS{}, doc: "清除选中值时的回调"
  attr :loading, :boolean, default: false, doc: "是否加载中"
  attr :max_tag_count, :integer, default: nil, doc: "多选时最多显示的tag数"
  attr :dropdown_class, :string, default: "", doc: "下拉菜单的className"
  attr :dropdown_style, :string, default: "", doc: "下拉菜单的style"
  attr :allow_create, :boolean, default: false, doc: "是否允许创建新选项"
  attr :rest, :global, doc: "其他HTML属性"

  def select(assigns) do
    assigns = 
      assigns
      |> assign(:selected_labels, get_selected_labels(assigns))
      |> assign(:show_clear, assigns[:clearable] && has_value?(assigns[:value]))
      |> assign(:dropdown_id, "#{assigns.id}-dropdown")
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-select relative",
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
            "pc-select__trigger w-full flex items-center justify-between",
            "border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800",
            "transition duration-150 ease-in-out hover:border-gray-400 dark:hover:border-gray-500",
            get_focus_classes(@color),
            size_classes(@size),
            @disabled && "cursor-not-allowed opacity-50"
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
                !@selected_labels && "text-gray-400 dark:text-gray-500"
              ]}>
                <%= @selected_labels || @placeholder %>
              </span>
            <% end %>
          </div>
          
          <div class="flex items-center gap-1">
            <%= if @show_clear do %>
              <button
                type="button"
                class={["pc-select__clear p-0.5 rounded transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
                phx-click={@on_clear}
                phx-click-away={hide_dropdown(@dropdown_id)}>
                <svg class="w-4 h-4 text-gray-400 dark:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>
            <% end %>
            
            <%= if @loading do %>
              <div class="pc-select__loading animate-spin">
                <svg class="w-4 h-4 text-gray-400 dark:text-gray-500" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              </div>
            <% else %>
              <svg class="w-5 h-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            <% end %>
          </div>
        </button>
        
        <!-- 下拉菜单 -->
        <div 
          id={@dropdown_id}
          class={[
            "pc-select__dropdown absolute z-10 mt-1 w-full bg-white dark:bg-gray-800 rounded-md",
            "shadow-xl shadow-gray-500/10 dark:shadow-gray-900/30",
            "border border-gray-200 dark:border-gray-700 max-h-60 overflow-auto",
            "hidden",
            @dropdown_class
          ]}
          style={@dropdown_style}>
          
          <%= if @searchable do %>
            <div class="pc-select__search-wrapper p-2 border-b border-gray-200 dark:border-gray-700">
              <input
                type="text"
                class={["pc-select__search w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 transition duration-150 ease-in-out", get_focus_classes(@color)]}
                placeholder="搜索..."
                phx-keyup={@on_search}
                phx-debounce="300"
              />
            </div>
          <% end %>
          
          <%= if @allow_create && @searchable do %>
            <div class="pc-select__create-option p-2 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer border-b border-gray-200 dark:border-gray-700">
              <span class="text-sm text-primary dark:text-primary-light">按回车创建新选项</span>
            </div>
          <% end %>
          
          <div class="pc-select__options">
            <%= render_options(assigns) %>
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
      <%= for value <- (@value || []) do %>
        <input type="hidden" name={@name} value={value} />
      <% end %>
      """
    else
      ~H"""
      <input type="hidden" name={@name} value={@value} />
      """
    end
  end
  
  # 渲染多选标签
  defp render_tags(assigns) do
    values = assigns.value || []
    max_count = assigns[:max_tag_count]
    
    {display_values, rest_count} = 
      if max_count && length(values) > max_count do
        {Enum.take(values, max_count), length(values) - max_count}
      else
        {values, 0}
      end
    
    assigns = 
      assigns
      |> assign(:display_values, display_values)
      |> assign(:rest_count, rest_count)
    
    ~H"""
    <div class="flex flex-wrap gap-1">
      <%= for value <- @display_values do %>
        <% label = get_option_label(@options, value) %>
        <span class="pc-select__tag inline-flex items-center gap-1 px-2 py-0.5 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 text-sm rounded">
          <%= label %>
          <button
            type="button"
            class="hover:text-gray-700"
            phx-click={if @on_change, do: @on_change, else: "remove_tag"}
            phx-value-value={value}>
            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </span>
      <% end %>
      
      <%= if @rest_count > 0 do %>
        <span class="pc-select__tag inline-flex items-center px-2 py-0.5 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 text-sm rounded">
          +<%= @rest_count %>
        </span>
      <% end %>
    </div>
    """
  end
  
  # 渲染选项列表
  defp render_options(assigns) do
    ~H"""
    <%= for option <- @options do %>
      <%= if option[:options] do %>
        <!-- 分组 -->
        <div class="pc-select__option-group">
          <div class="pc-select__group-label px-3 py-2 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">
            <%= option.label %>
          </div>
          <%= for sub_option <- option.options do %>
            <%= render_option(assigns, sub_option) %>
          <% end %>
        </div>
      <% else %>
        <!-- 单个选项 -->
        <%= render_option(assigns, option) %>
      <% end %>
    <% end %>
    """
  end
  
  # 渲染单个选项
  defp render_option(assigns, option) do
    selected = is_selected?(assigns.value, option.value, assigns.multiple)
    
    assigns = 
      assigns
      |> assign(:option, option)
      |> assign(:selected, selected)
    
    ~H"""
    <div
      class={[
        "pc-select__option px-4 py-2 cursor-pointer transition duration-150 ease-in-out hover:bg-gray-50 dark:hover:bg-gray-700",
        @selected && get_selected_classes(@color),
        @option[:disabled] && "pc-select__option--disabled opacity-50 cursor-not-allowed"
      ]}
      phx-click={if @on_change, do: @on_change, else: "select_option"}
      phx-value-value={@option.value}>
      
      <div class="flex items-center justify-between">
        <span><%= @option.label %></span>
        <%= if @selected do %>
          <svg class="w-4 h-4 text-primary dark:text-primary-light" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 获取选中项的标签
  defp get_selected_labels(assigns) do
    case assigns[:value] do
      nil -> nil
      [] -> nil
      value when is_list(value) ->
        labels = Enum.map(value, &get_option_label(assigns[:options], &1))
        Enum.join(labels, ", ")
      value ->
        get_option_label(assigns[:options], value)
    end
  end
  
  # 获取选项标签
  defp get_option_label(options, value) do
    find_option_label(options, value) || value
  end
  
  defp find_option_label(options, value) do
    Enum.find_value(options, fn
      %{options: sub_options} ->
        find_option_label(sub_options, value)
      %{value: ^value, label: label} ->
        label
      _ ->
        nil
    end)
  end
  
  # 检查是否有值
  defp has_value?(nil), do: false
  defp has_value?([]), do: false
  defp has_value?(_), do: true
  
  # 检查选项是否被选中
  defp is_selected?(current_value, option_value, true) do
    current_value && option_value in current_value
  end
  defp is_selected?(current_value, option_value, false) do
    current_value == option_value
  end
  
  # 尺寸样式 - 匹配 Petal Components 的间距标准
  defp size_classes("small"), do: "text-sm leading-4 py-2 px-3"
  defp size_classes("medium"), do: "text-sm leading-5 py-2 px-4"
  defp size_classes("large"), do: "text-base leading-6 py-2.5 px-6"
  
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
      "primary" -> "pc-select__option--selected bg-primary bg-opacity-10 dark:bg-opacity-20 text-primary"
      "info" -> "pc-select__option--selected bg-blue-500 bg-opacity-10 dark:bg-opacity-20 text-blue-600 dark:text-blue-400"
      "success" -> "pc-select__option--selected bg-green-500 bg-opacity-10 dark:bg-opacity-20 text-green-600 dark:text-green-400"
      "warning" -> "pc-select__option--selected bg-yellow-500 bg-opacity-10 dark:bg-opacity-20 text-yellow-600 dark:text-yellow-400"
      "danger" -> "pc-select__option--selected bg-red-500 bg-opacity-10 dark:bg-opacity-20 text-red-600 dark:text-red-400"
      _ -> "pc-select__option--selected bg-primary bg-opacity-10 dark:bg-opacity-20 text-primary"
    end
  end
  
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
  
end