defmodule ShopUxPhoenixWeb.TreeSelectDemoLive do
  @moduledoc """
  测试 TreeSelect 组件的 LiveView
  """
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.TreeSelect

  def mount(_params, _session, socket) do
    tree_data = [
      %{
        title: "浙江省",
        key: "zhejiang",
        children: [
          %{
            title: "杭州市",
            key: "hangzhou", 
            children: [
              %{title: "西湖区", key: "xihu"},
              %{title: "余杭区", key: "yuhang"}
            ]
          },
          %{title: "宁波市", key: "ningbo"}
        ]
      },
      %{
        title: "江苏省",
        key: "jiangsu",
        children: [
          %{title: "南京市", key: "nanjing"},
          %{title: "苏州市", key: "suzhou"}
        ]
      }
    ]

    socket =
      assign(socket,
        basic_value: nil,
        multiple_values: [],
        checkable_values: [],
        searchable_value: nil,
        tree_data: tree_data,
        expanded_keys: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 space-y-8">
      <h1 class="text-2xl font-bold">TreeSelect 组件测试</h1>
      
      <!-- 基础树选择器 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">基础树选择器</h2>
        <.tree_select 
          id="basic-tree"
          tree_data={@tree_data}
          value={@basic_value}
          placeholder="请选择地区"
          on_change={JS.push("basic_change")}
          on_clear={JS.push("basic_clear")}
        />
        <p class="text-sm text-gray-600">
          当前选择: <%= format_value(@basic_value) %>
        </p>
      </div>
      
      <!-- 多选树选择器 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">多选树选择器</h2>
        <.tree_select 
          id="multiple-tree"
          tree_data={@tree_data}
          value={@multiple_values}
          multiple={true}
          placeholder="请选择多个地区"
          on_change={JS.push("multiple_change")}
          on_clear={JS.push("multiple_clear")}
        />
        <p class="text-sm text-gray-600">
          当前选择: <%= format_multiple_values(@multiple_values) %>
        </p>
      </div>
      
      <!-- 复选框模式 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">复选框模式</h2>
        <.tree_select 
          id="checkable-tree"
          tree_data={@tree_data}
          value={@checkable_values}
          checkable={true}
          multiple={true}
          placeholder="复选框模式选择"
          on_check={JS.push("checkable_change")}
          on_clear={JS.push("checkable_clear")}
        />
        <p class="text-sm text-gray-600">
          当前选择: <%= format_multiple_values(@checkable_values) %>
        </p>
      </div>
      
      <!-- 可搜索树选择器 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">可搜索树选择器</h2>
        <.tree_select 
          id="searchable-tree"
          tree_data={@tree_data}
          value={@searchable_value}
          show_search={true}
          search_placeholder="搜索地区"
          on_change={JS.push("searchable_change")}
          on_search={JS.push("tree_search")}
          on_clear={JS.push("searchable_clear")}
        />
        <p class="text-sm text-gray-600">
          当前选择: <%= format_value(@searchable_value) %>
        </p>
      </div>
      
      <!-- 默认展开所有节点 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">默认展开所有节点</h2>
        <.tree_select 
          id="expanded-tree"
          tree_data={@tree_data}
          tree_default_expand_all={true}
          placeholder="默认展开所有"
        />
      </div>
      
      <!-- 特定展开节点 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">特定展开节点</h2>
        <.tree_select 
          id="specific-expanded"
          tree_data={@tree_data}
          tree_default_expanded_keys={["zhejiang"]}
          placeholder="展开浙江省"
        />
      </div>
      
      <!-- 不同尺寸 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">不同尺寸</h2>
        
        <div class="space-y-2">
          <h3 class="text-sm font-medium">小尺寸</h3>
          <.tree_select 
            id="small-tree"
            tree_data={@tree_data}
            size="small"
            placeholder="小尺寸"
          />
        </div>
        
        <div class="space-y-2">
          <h3 class="text-sm font-medium">中等尺寸（默认）</h3>
          <.tree_select 
            id="medium-tree"
            tree_data={@tree_data}
            size="medium"
            placeholder="中等尺寸"
          />
        </div>
        
        <div class="space-y-2">
          <h3 class="text-sm font-medium">大尺寸</h3>
          <.tree_select 
            id="large-tree"
            tree_data={@tree_data}
            size="large"
            placeholder="大尺寸"
          />
        </div>
      </div>
      
      <!-- 禁用状态 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">禁用状态</h2>
        <.tree_select 
          id="disabled-tree"
          tree_data={@tree_data}
          disabled={true}
          placeholder="已禁用"
        />
      </div>
      
      <!-- 限制标签数量 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">限制标签数量</h2>
        <.tree_select 
          id="limited-tags"
          tree_data={@tree_data}
          value={["zhejiang", "jiangsu", "hangzhou"]}
          multiple={true}
          max_tag_count={2}
          max_tag_placeholder="+ {count} 项"
          placeholder="最多显示2个标签"
        />
      </div>
      
      <!-- 不可清除 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">不可清除</h2>
        <.tree_select 
          id="no-clear"
          tree_data={@tree_data}
          value="hangzhou"
          allow_clear={false}
          placeholder="不可清除"
        />
      </div>
    </div>
    """
  end

  def handle_event("basic_change", %{"key" => key, "title" => _title, "selected" => selected_str}, socket) do
    selected = selected_str == "true"
    new_value = if selected, do: key, else: nil
    {:noreply, assign(socket, basic_value: new_value)}
  end

  def handle_event("basic_clear", _params, socket) do
    {:noreply, assign(socket, basic_value: nil)}
  end

  def handle_event("multiple_change", %{"key" => key, "selected" => selected_str}, socket) do
    selected = selected_str == "true"
    current_values = socket.assigns.multiple_values
    
    new_values = 
      if selected do
        if key in current_values do
          current_values
        else
          current_values ++ [key]
        end
      else
        List.delete(current_values, key)
      end
    
    {:noreply, assign(socket, multiple_values: new_values)}
  end

  def handle_event("multiple_clear", _params, socket) do
    {:noreply, assign(socket, multiple_values: [])}
  end

  def handle_event("checkable_change", %{"key" => key, "checked" => checked_str}, socket) do
    checked = checked_str == "true"
    current_values = socket.assigns.checkable_values
    
    new_values = 
      if checked do
        if key in current_values do
          current_values
        else
          current_values ++ [key]
        end
      else
        List.delete(current_values, key)
      end
    
    {:noreply, assign(socket, checkable_values: new_values)}
  end

  def handle_event("checkable_clear", _params, socket) do
    {:noreply, assign(socket, checkable_values: [])}
  end

  def handle_event("searchable_change", %{"key" => key, "selected" => selected_str}, socket) do
    selected = selected_str == "true"
    new_value = if selected, do: key, else: nil
    {:noreply, assign(socket, searchable_value: new_value)}
  end

  def handle_event("searchable_clear", _params, socket) do
    {:noreply, assign(socket, searchable_value: nil)}
  end

  def handle_event("tree_search", %{"value" => _search_term}, socket) do
    # 这里可以实现搜索逻辑，暂时不做处理
    {:noreply, socket}
  end

  def handle_event("select_tree_node", params, socket) do
    # 默认的树节点选择处理
    handle_event("basic_change", params, socket)
  end

  def handle_event("check_tree_node", params, socket) do
    # 默认的复选框点击处理
    handle_event("checkable_change", params, socket)
  end

  def handle_event("toggle_tree_node", %{"key" => key, "expanded" => expanded_str}, socket) do
    expanded = expanded_str == "true"
    current_expanded = socket.assigns.expanded_keys
    
    new_expanded = 
      if expanded do
        if key in current_expanded do
          current_expanded
        else
          current_expanded ++ [key]
        end
      else
        List.delete(current_expanded, key)
      end
    
    {:noreply, assign(socket, expanded_keys: new_expanded)}
  end

  defp format_value(nil), do: "无"
  defp format_value(value) when is_binary(value) do
    # 硬编码树数据用于显示，实际应用中应该从assigns中获取
    tree_data = [
      %{
        title: "浙江省",
        key: "zhejiang",
        children: [
          %{title: "杭州市", key: "hangzhou", children: [%{title: "西湖区", key: "xihu"}, %{title: "余杭区", key: "yuhang"}]},
          %{title: "宁波市", key: "ningbo"}
        ]
      },
      %{
        title: "江苏省",
        key: "jiangsu",
        children: [%{title: "南京市", key: "nanjing"}, %{title: "苏州市", key: "suzhou"}]
      }
    ]
    get_title_by_key(value, tree_data) || value
  end
  defp format_value(value), do: to_string(value)

  defp format_multiple_values([]), do: "无"
  defp format_multiple_values(values) when is_list(values) do
    # 硬编码树数据用于显示
    tree_data = [
      %{
        title: "浙江省",
        key: "zhejiang",
        children: [
          %{title: "杭州市", key: "hangzhou", children: [%{title: "西湖区", key: "xihu"}, %{title: "余杭区", key: "yuhang"}]},
          %{title: "宁波市", key: "ningbo"}
        ]
      },
      %{
        title: "江苏省", 
        key: "jiangsu",
        children: [%{title: "南京市", key: "nanjing"}, %{title: "苏州市", key: "suzhou"}]
      }
    ]
    values
    |> Enum.map(fn value -> get_title_by_key(value, tree_data) || value end)
    |> Enum.join(", ")
  end

  defp get_title_by_key(key, tree_data) do
    find_node_title(tree_data, key)
  end

  defp find_node_title([], _key), do: nil
  defp find_node_title([node | rest], key) do
    if node.key == key do
      node.title
    else
      case find_node_title(node[:children] || [], key) do
        nil -> find_node_title(rest, key)
        title -> title
      end
    end
  end
end