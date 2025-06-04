defmodule ShopUxPhoenixWeb.SelectDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Select

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       single_value: nil,
       multiple_values: [],
       options: [
         %{value: "beijing", label: "北京"},
         %{value: "shanghai", label: "上海"},
         %{value: "guangzhou", label: "广州"},
         %{value: "shenzhen", label: "深圳"}
       ],
       grouped_options: [
         %{
           label: "华北",
           options: [
             %{value: "beijing", label: "北京"},
             %{value: "tianjin", label: "天津"}
           ]
         },
         %{
           label: "华东",
           options: [
             %{value: "shanghai", label: "上海"},
             %{value: "nanjing", label: "南京"}
           ]
         }
       ],
       search_term: ""
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p id="single-value-info">
        单选值: <%= @single_value || "无" %>
      </p>
      <p id="multiple-values-info">
        多选值: <%= if @multiple_values == [], do: "无", else: Enum.join(@multiple_values, ", ") %>
      </p>
      <p id="search-info">
        搜索词: <%= @search_term %>
      </p>
      
      <h3>单选测试</h3>
      <.select 
        id="single-select"
        options={@options}
        value={@single_value}
        on_change={JS.push("select_single")}
        on_clear={JS.push("clear_single")}
        clearable
        placeholder="请选择城市"
      />
      
      <h3>多选测试</h3>
      <.select 
        id="multiple-select"
        options={@options}
        value={@multiple_values}
        multiple
        on_change={JS.push("select_multiple")}
        placeholder="请选择多个城市"
      />
      
      <h3>搜索测试</h3>
      <.select 
        id="searchable-select"
        options={@options}
        searchable
        on_search={JS.push("search_options")}
        placeholder="搜索城市"
      />
      
      <h3>分组测试</h3>
      <.select 
        id="grouped-select"
        options={@grouped_options}
        placeholder="选择地区"
      />
    </div>
    """
  end

  def handle_event("select_single", %{"value" => value}, socket) do
    {:noreply, assign(socket, single_value: value)}
  end

  def handle_event("clear_single", _params, socket) do
    {:noreply, assign(socket, single_value: nil)}
  end

  def handle_event("select_multiple", %{"value" => value}, socket) do
    current_values = socket.assigns.multiple_values
    new_values = 
      if value in current_values do
        List.delete(current_values, value)
      else
        current_values ++ [value]
      end
    {:noreply, assign(socket, multiple_values: new_values)}
  end

  def handle_event("search_options", %{"value" => search_term}, socket) do
    {:noreply, assign(socket, search_term: search_term)}
  end
end