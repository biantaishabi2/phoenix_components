defmodule PetalComponents.Custom.TreeSelect do
  @moduledoc """
  树选择器组件 - 树型选择控件，可以像Select一样选择，也可以像TreeNode一样展开、收起、选择
  
  ## 特性
  - 支持树形数据展示
  - 支持单选和多选
  - 支持搜索过滤
  - 支持异步加载数据
  - 支持节点禁用
  - 支持复选框模式
  - 支持自定义节点渲染
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染树选择器组件
  
  ## 示例
  
      <.tree_select 
        id="basic-tree"
        tree_data={@tree_data}
        placeholder="请选择节点"
      />
      
      <!-- 不同尺寸示例 -->
      <.tree_select 
        id="small-tree"
        size="small"
        color="primary"
        tree_data={@department_tree}
        placeholder="小号树选择"
      />
      
      <.tree_select 
        id="large-tree"
        size="large"
        multiple
        checkable
        color="success"
        tree_data={@organization_tree}
        placeholder="大号多选树"
      />
  """
  attr :id, :string, required: true, doc: "选择器唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :value, :any, default: nil, doc: "当前选中的值"
  attr :tree_data, :list, default: [], doc: "树形数据源"
  attr :placeholder, :string, default: "请选择", doc: "选择框默认文字"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :multiple, :boolean, default: false, doc: "支持多选"
  attr :checkable, :boolean, default: false, doc: "节点前添加复选框"
  attr :show_search, :boolean, default: false, doc: "是否显示搜索框"
  attr :search_placeholder, :string, default: "搜索", doc: "搜索框占位符"
  attr :tree_default_expand_all, :boolean, default: false, doc: "默认展开所有树节点"
  attr :tree_default_expanded_keys, :list, default: [], doc: "默认展开的树节点"
  attr :tree_checkable, :boolean, default: false, doc: "显示复选框"
  attr :tree_check_strictly, :boolean, default: false, doc: "checkable状态下节点选择完全受控"
  attr :tree_selectable, :boolean, default: true, doc: "是否可选中"
  attr :drop_down_style, :string, default: "", doc: "下拉菜单的样式"
  attr :max_tag_count, :integer, default: nil, doc: "最多显示多少个tag"
  attr :max_tag_placeholder, :string, default: "+ {count} ...", doc: "隐藏tag时显示的内容"
  attr :tree_node_filter_prop, :string, default: "title", doc: "输入项过滤对应的treeNode属性"
  attr :tree_node_label_prop, :string, default: "title", doc: "作为显示的prop设置"
  attr :allow_clear, :boolean, default: true, doc: "显示清除按钮"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "选择框大小"
  attr :field_names, :map, default: %{title: "title", key: "key", children: "children"}, doc: "自定义字段名"
  attr :load_data, :any, default: nil, doc: "异步加载数据的函数"
  attr :filter_tree_node, :any, default: false, doc: "是否根据输入项进行筛选"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: %JS{}, doc: "选中树节点时调用"
  attr :on_search, JS, default: %JS{}, doc: "文本框值变化时回调"
  attr :on_tree_expand, JS, default: %JS{}, doc: "展开/收起节点时触发"
  attr :on_select, JS, default: %JS{}, doc: "点击树节点触发"
  attr :on_check, JS, default: %JS{}, doc: "点击复选框触发"
  attr :on_clear, JS, default: %JS{}, doc: "清除时触发"
  attr :rest, :global, doc: "其他HTML属性"

  def tree_select(assigns) do
    assigns = 
      assigns
      |> assign(:display_text, get_display_text(assigns))
      |> assign(:show_clear, assigns[:allow_clear] && has_value?(assigns[:value]))
      |> assign(:dropdown_id, "#{assigns.id}-dropdown")
      |> assign(:expanded_keys, get_expanded_keys(assigns))
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-tree-select relative",
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
            "pc-tree-select__trigger w-full flex items-center justify-between",
            "border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-left",
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
            <%= if @multiple && @value && is_list(@value) && length(@value) > 0 do %>
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
                class={["pc-tree-select__clear p-0.5 rounded transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
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
            "tree-dropdown-panel absolute z-10 mt-1 bg-white dark:bg-gray-800 rounded-md",
            "shadow-xl shadow-gray-500/10 dark:shadow-gray-900/30",
            "border border-gray-200 dark:border-gray-700 max-h-60 overflow-hidden",
            "hidden"
          ]}
          style={@drop_down_style}>
          
          <%= if @show_search do %>
            <div class="p-2 border-b border-gray-200 dark:border-gray-700">
              <input
                type="text"
                class={["pc-tree-select__search w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md transition duration-150 ease-in-out dark:bg-gray-800 dark:text-gray-200", get_focus_classes(@color)]}
                placeholder={@search_placeholder}
                phx-keyup={@on_search}
                phx-debounce="300"
              />
            </div>
          <% end %>
          
          <div class={[
            "tree-container p-2 max-h-48 overflow-y-auto",
            @tree_check_strictly && "tree-check-strictly"
          ]}>
            <%= render_tree_nodes(assigns, @tree_data, 0) %>
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
        <input type="hidden" name={"#{@name}[]"} value={value} />
      <% end %>
      """
    else
      value_str = if assigns.value, do: to_string(assigns.value), else: ""
      assigns = assign(assigns, :value_str, value_str)
      ~H"""
      <input type="hidden" name={@name} value={@value_str} />
      """
    end
  end
  
  # 渲染多选标签
  defp render_tags(assigns) do
    values = if is_list(assigns.value), do: assigns.value, else: []
    display_values = if assigns.max_tag_count && length(values) > assigns.max_tag_count do
      Enum.take(values, assigns.max_tag_count)
    else
      values
    end
    
    hidden_count = if assigns.max_tag_count && length(values) > assigns.max_tag_count do
      length(values) - assigns.max_tag_count
    else
      0
    end
    
    assigns = assigns |> assign(:display_values, display_values) |> assign(:hidden_count, hidden_count)
    
    ~H"""
    <div class="flex flex-wrap gap-1">
      <%= for value <- @display_values do %>
        <% display = get_node_display_text(value, @tree_data, @field_names, @tree_node_label_prop) %>
        <span class="tag inline-flex items-center gap-1 px-2 py-0.5 bg-gray-100 dark:bg-gray-700 text-sm rounded">
          <%= display %>
          <button
            type="button"
            class="hover:text-gray-700 dark:hover:text-gray-300"
            phx-click={if @on_change, do: @on_change, else: "remove_tree_tag"}
            phx-value-value={value}>
            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </span>
      <% end %>
      
      <%= if @hidden_count > 0 do %>
        <span class="max-tag-placeholder px-2 py-0.5 bg-gray-200 dark:bg-gray-600 text-sm rounded">
          <%= String.replace(@max_tag_placeholder, "{count}", to_string(@hidden_count)) %>
        </span>
      <% end %>
    </div>
    """
  end
  
  # 渲染树节点
  defp render_tree_nodes(assigns, nodes, level) do
    assigns = 
      assigns
      |> assign(:nodes, nodes)
      |> assign(:level, level)
    
    if nodes && length(nodes) > 0 do
      ~H"""
      <%= for node <- @nodes do %>
        <%= render_tree_node(assigns, node, @level) %>
      <% end %>
      """
    else
      ~H"""
      <div class="text-gray-500 dark:text-gray-400 text-sm p-2">暂无数据</div>
      """
    end
  end
  
  # 渲染单个树节点
  defp render_tree_node(assigns, node, level) do
    field_names = assigns.field_names
    key = Map.get(node, String.to_atom(field_names.key), node[:key])
    title = Map.get(node, String.to_atom(field_names.title), node[:title])
    children = Map.get(node, String.to_atom(field_names.children), node[:children])
    disabled = Map.get(node, :disabled, false)
    
    has_children = children && length(children) > 0
    is_expanded = key in assigns.expanded_keys
    is_selected = is_node_selected?(key, assigns.value, assigns.multiple)
    
    assigns = 
      assigns
      |> assign(:node_key, key)
      |> assign(:node_title, title)
      |> assign(:node_children, children)
      |> assign(:has_children, has_children)
      |> assign(:is_expanded, is_expanded)
      |> assign(:is_selected, is_selected)
      |> assign(:is_disabled, disabled)
      |> assign(:node_level, level)
    
    ~H"""
    <div class="pc-tree-select__node">
      <div 
        class={[
          "pc-tree-select__node-content flex items-center gap-1 px-2 py-1.5 transition duration-150 ease-in-out hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer",
          "rounded text-sm",
          @is_selected && get_selected_classes(@color),
          @is_disabled && "node-disabled opacity-50 cursor-not-allowed"
        ]}
        style={"padding-left: #{(@node_level * 20) + 8}px"}
        phx-click={unless @is_disabled, do: if(@on_select, do: @on_select, else: "select_tree_node")}
        phx-value-key={@node_key}
        phx-value-title={@node_title}
        phx-value-selected={!@is_selected}>
        
        <!-- 展开/收起图标 -->
        <%= if @has_children do %>
          <button
            type="button"
            class={["pc-tree-select__expand p-0.5 rounded transition duration-150 ease-in-out hover:bg-gray-200 dark:hover:bg-gray-600", get_focus_classes(@color)]}
            phx-click={if @on_tree_expand, do: @on_tree_expand, else: "toggle_tree_node"}
            phx-value-key={@node_key}
            phx-value-expanded={!@is_expanded}>
            <svg class={[
              "w-3 h-3 transition-transform",
              @is_expanded && "transform rotate-90"
            ]} fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
            </svg>
          </button>
        <% else %>
          <div class="w-4 h-4"></div>
        <% end %>
        
        <!-- 复选框 -->
        <%= if @checkable || @tree_checkable do %>
          <input 
            type="checkbox"
            class="pc-tree-select__checkbox"
            checked={@is_selected}
            phx-click={if @on_check, do: @on_check, else: "check_tree_node"}
            phx-value-key={@node_key}
            phx-value-checked={!@is_selected}
          />
        <% end %>
        
        <!-- 节点标题 -->
        <span class="flex-1 truncate dark:text-gray-200">
          <%= @node_title %>
        </span>
      </div>
      
      <!-- 子节点 -->
      <%= if @has_children && @is_expanded do %>
        <div class={[
          "tree-children",
          @tree_default_expand_all && "tree-expanded"
        ]}>
          <%= render_tree_nodes(assigns, @node_children, @node_level + 1) %>
        </div>
      <% end %>
    </div>
    """
  end
  
  # 获取显示文本
  defp get_display_text(assigns) do
    case assigns.value do
      nil -> nil
      value when assigns.multiple and is_list(value) ->
        if length(value) > 0 do
          first_display = get_node_display_text(List.first(value), assigns.tree_data, assigns.field_names, assigns.tree_node_label_prop)
          if length(value) == 1 do
            first_display
          else
            "#{first_display} (+#{length(value) - 1})"
          end
        else
          nil
        end
      value ->
        get_node_display_text(value, assigns.tree_data, assigns.field_names, assigns.tree_node_label_prop)
    end
  end
  
  # 获取节点显示文本
  defp get_node_display_text(key, tree_data, field_names, label_prop) do
    case find_node_by_key(tree_data, key, field_names) do
      nil -> to_string(key)
      node ->
        Map.get(node, String.to_atom(label_prop), Map.get(node, String.to_atom(field_names.title), to_string(key)))
    end
  end
  
  # 根据key查找节点
  defp find_node_by_key(nodes, target_key, field_names) do
    Enum.find_value(nodes, fn node ->
      key = Map.get(node, String.to_atom(field_names.key), node[:key])
      if key == target_key do
        node
      else
        children = Map.get(node, String.to_atom(field_names.children), node[:children])
        if children && length(children) > 0 do
          find_node_by_key(children, target_key, field_names)
        else
          nil
        end
      end
    end)
  end
  
  # 获取展开的节点键列表
  defp get_expanded_keys(assigns) do
    cond do
      assigns.tree_default_expand_all ->
        get_all_parent_keys(assigns.tree_data, assigns.field_names)
      assigns.tree_default_expanded_keys && length(assigns.tree_default_expanded_keys) > 0 ->
        assigns.tree_default_expanded_keys
      true ->
        []
    end
  end
  
  # 获取所有父节点的key
  defp get_all_parent_keys(nodes, field_names) do
    Enum.flat_map(nodes, fn node ->
      children = Map.get(node, String.to_atom(field_names.children), node[:children])
      key = Map.get(node, String.to_atom(field_names.key), node[:key])
      
      if children && length(children) > 0 do
        [key | get_all_parent_keys(children, field_names)]
      else
        []
      end
    end)
  end
  
  # 判断节点是否被选中
  defp is_node_selected?(key, value, multiple) do
    cond do
      multiple && is_list(value) -> key in value
      multiple -> false
      true -> value == key
    end
  end
  
  # 检查是否有值
  defp has_value?(nil), do: false
  defp has_value?([]), do: false
  defp has_value?(value) when is_list(value), do: length(value) > 0
  defp has_value?(_), do: true
  
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
      "primary" -> "bg-primary bg-opacity-10 text-primary dark:bg-opacity-20"
      "info" -> "bg-blue-500 bg-opacity-10 text-blue-600 dark:bg-opacity-20"
      "success" -> "bg-green-500 bg-opacity-10 text-green-600 dark:bg-opacity-20"
      "warning" -> "bg-yellow-500 bg-opacity-10 text-yellow-600 dark:bg-opacity-20"
      "danger" -> "bg-red-500 bg-opacity-10 text-red-600 dark:bg-opacity-20"
      _ -> "bg-primary bg-opacity-10 text-primary dark:bg-opacity-20"
    end
  end
  
end