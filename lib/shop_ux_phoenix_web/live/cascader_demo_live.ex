defmodule ShopUxPhoenixWeb.CascaderDemoLive do
  @moduledoc """
  测试 Cascader 组件的 LiveView
  """
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Cascader

  def mount(_params, _session, socket) do
    area_options = [
      %{
        value: "zhejiang",
        label: "浙江",
        children: [
          %{
            value: "hangzhou",
            label: "杭州",
            children: [
              %{value: "xihu", label: "西湖"},
              %{value: "yuhang", label: "余杭"}
            ]
          },
          %{value: "ningbo", label: "宁波"}
        ]
      },
      %{
        value: "jiangsu",
        label: "江苏",
        children: [
          %{value: "nanjing", label: "南京"},
          %{value: "suzhou", label: "苏州"}
        ]
      }
    ]

    socket =
      assign(socket,
        basic_value: nil,
        multiple_values: [],
        searchable_value: nil,
        area_options: area_options
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 space-y-8">
      <h1 class="text-2xl font-bold">Cascader 组件测试</h1>
      
      <!-- 基础级联选择器 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">基础级联选择器</h2>
        <.cascader 
          id="basic-cascader"
          options={@area_options}
          value={@basic_value}
          placeholder="请选择地区"
          on_change={JS.push("basic_change")}
          on_clear={JS.push("basic_clear")}
        />
        <p class="text-sm text-gray-600">
          当前选择: <%= format_value(@basic_value) %>
        </p>
      </div>
      
      <!-- 多选级联选择器 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">多选级联选择器</h2>
        <.cascader 
          id="multiple-cascader"
          options={@area_options}
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
      
      <!-- 可搜索级联选择器 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">可搜索级联选择器</h2>
        <.cascader 
          id="searchable-cascader"
          options={@area_options}
          value={@searchable_value}
          searchable={true}
          placeholder="搜索地区"
          on_change={JS.push("searchable_change")}
          on_clear={JS.push("searchable_clear")}
        />
        <p class="text-sm text-gray-600">
          当前选择: <%= format_value(@searchable_value) %>
        </p>
      </div>
      
      <!-- 不同尺寸的级联选择器 -->
      <div class="space-y-4">
        <h2 class="text-lg font-semibold">不同尺寸</h2>
        
        <div class="space-y-2">
          <h3 class="text-sm font-medium">小尺寸</h3>
          <.cascader 
            id="small-cascader"
            options={@area_options}
            size="small"
            placeholder="小尺寸"
          />
        </div>
        
        <div class="space-y-2">
          <h3 class="text-sm font-medium">中等尺寸（默认）</h3>
          <.cascader 
            id="medium-cascader"
            options={@area_options}
            size="medium"
            placeholder="中等尺寸"
          />
        </div>
        
        <div class="space-y-2">
          <h3 class="text-sm font-medium">大尺寸</h3>
          <.cascader 
            id="large-cascader"
            options={@area_options}
            size="large"
            placeholder="大尺寸"
          />
        </div>
      </div>
      
      <!-- 禁用状态 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">禁用状态</h2>
        <.cascader 
          id="disabled-cascader"
          options={@area_options}
          disabled={true}
          placeholder="已禁用"
        />
      </div>
      
      <!-- 不可清除 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">不可清除</h2>
        <.cascader 
          id="no-clear-cascader"
          options={@area_options}
          value={["zhejiang", "hangzhou"]}
          clearable={false}
          placeholder="不可清除"
        />
      </div>
      
      <!-- 自定义分隔符 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">自定义分隔符</h2>
        <.cascader 
          id="custom-separator"
          options={@area_options}
          value={["zhejiang", "hangzhou", "xihu"]}
          separator=" > "
          placeholder="自定义分隔符"
        />
      </div>
      
      <!-- 只显示最后一级 -->
      <div class="space-y-2">
        <h2 class="text-lg font-semibold">只显示最后一级</h2>
        <.cascader 
          id="show-last-level"
          options={@area_options}
          value={["zhejiang", "hangzhou", "xihu"]}
          show_all_levels={false}
          placeholder="只显示最后一级"
        />
      </div>
    </div>
    """
  end

  def handle_event("basic_change", %{"value" => value, "level" => level}, socket) do
    current_value = socket.assigns.basic_value || []
    new_value = Enum.take(current_value, String.to_integer(level)) ++ [value]
    {:noreply, assign(socket, basic_value: new_value)}
  end

  def handle_event("basic_clear", _params, socket) do
    {:noreply, assign(socket, basic_value: nil)}
  end

  def handle_event("multiple_change", %{"value" => value, "level" => level}, socket) do
    current_values = socket.assigns.multiple_values
    current_value = []  # 简化处理，每次选择创建新的路径
    new_value = Enum.take(current_value, String.to_integer(level)) ++ [value]
    
    # 检查是否已存在相同的路径
    new_values = 
      if new_value in current_values do
        List.delete(current_values, new_value)
      else
        current_values ++ [new_value]
      end
    
    {:noreply, assign(socket, multiple_values: new_values)}
  end

  def handle_event("multiple_clear", _params, socket) do
    {:noreply, assign(socket, multiple_values: [])}
  end

  def handle_event("searchable_change", %{"value" => value, "level" => level}, socket) do
    current_value = socket.assigns.searchable_value || []
    new_value = Enum.take(current_value, String.to_integer(level)) ++ [value]
    {:noreply, assign(socket, searchable_value: new_value)}
  end

  def handle_event("searchable_clear", _params, socket) do
    {:noreply, assign(socket, searchable_value: nil)}
  end

  def handle_event("search_cascader", %{"value" => _search_term}, socket) do
    # 这里可以实现搜索逻辑，暂时不做处理
    {:noreply, socket}
  end

  def handle_event("toggle_dropdown", _params, socket) do
    # 处理下拉菜单切换事件
    {:noreply, socket}
  end

  defp format_value(nil), do: "无"
  defp format_value([]), do: "无"
  defp format_value(value) when is_list(value) do
    Enum.join(value, " / ")
  end

  defp format_multiple_values([]), do: "无"
  defp format_multiple_values(values) when is_list(values) do
    values
    |> Enum.map(fn value -> Enum.join(value, " / ") end)
    |> Enum.join(", ")
  end
end