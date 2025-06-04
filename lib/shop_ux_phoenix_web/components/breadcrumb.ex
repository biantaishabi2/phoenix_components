defmodule ShopUxPhoenixWeb.Components.Breadcrumb do
  @moduledoc """
  面包屑导航组件，用于显示当前页面在网站层次结构中的位置
  
  ## 特性
  - 支持可点击的导航链接
  - 支持图标显示
  - 支持多种分隔符样式
  - 支持最大显示项数限制
  - 支持响应式设计
  - 支持自定义首页链接
  - 完整的无障碍支持
  
  ## 依赖
  - 无外部依赖
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents
  
  @doc """
  渲染面包屑导航组件
  
  ## 示例
      <.breadcrumb items={[
        %{title: "首页", path: "/"},
        %{title: "产品管理", path: "/products"},
        %{title: "产品列表", path: nil}
      ]} />
  """
  attr :items, :list, default: [], doc: "面包屑项列表"
  attr :separator, :string, default: "chevron", doc: "分隔符类型"
  attr :size, :string, values: ~w(small medium large), default: "medium", doc: "尺寸"
  attr :max_items, :integer, default: nil, doc: "最大显示项数"
  attr :responsive, :boolean, default: false, doc: "是否在移动端隐藏中间项"
  attr :show_home, :boolean, default: true, doc: "是否显示首页链接"
  attr :home_title, :string, default: "首页", doc: "首页显示文字"
  attr :home_path, :string, default: "/", doc: "首页链接地址"
  attr :home_icon, :string, default: "hero-home", doc: "首页图标"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :rest, :global, doc: "其他HTML属性"
  
  def breadcrumb(assigns) do
    assigns = assign_defaults(assigns)
    
    ~H"""
    <nav 
      class={[
        "breadcrumb flex",
        @class
      ]}
      aria-label="Breadcrumb" 
      role="navigation"
      {@rest}
    >
      <ol class={[
        "inline-flex items-center",
        get_spacing_classes(@size)
      ]}>
        <%= if @show_home && @processed_items != [] do %>
          <li class="inline-flex items-center">
            <.link
              href={@home_path}
              class={[
                "inline-flex items-center font-medium hover:text-primary transition-colors duration-150",
                get_text_classes(@size),
                "text-gray-700"
              ]}
              title={@home_title}
            >
              <%= if @home_icon do %>
                <.icon name={@home_icon} class={get_icon_classes(@size) <> " mr-1"} />
              <% end %>
              <%= @home_title %>
            </.link>
            
            <%= if @processed_items != [] do %>
              <.render_separator separator={@separator} size={@size} />
            <% end %>
          </li>
        <% end %>
        
        <%= for {item, index} <- Enum.with_index(@processed_items) do %>
          <li class={[
            "inline-flex items-center",
            @responsive && index > 0 && index < length(@processed_items) - 1 && "hidden md:inline-flex"
          ]}>
            <%= if index > 0 || (@show_home && @processed_items != []) do %>
              <.render_separator separator={@separator} size={@size} />
            <% end %>
            
            <.render_breadcrumb_item 
              item={item} 
              size={@size} 
              is_last={index == length(@processed_items) - 1}
            />
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end
  
  @doc """
  渲染面包屑项
  """
  attr :item, :map, required: true
  attr :size, :string, default: "medium"
  attr :is_last, :boolean, default: false
  
  def render_breadcrumb_item(assigns) do
    ~H"""
    <%= if @item[:path] do %>
      <.link
        href={@item.path}
        class={[
          "inline-flex items-center font-medium hover:text-primary transition-colors duration-150",
          get_text_classes(@size),
          "text-gray-700"
        ]}
        title={@item[:overlay]}
      >
        <%= if @item[:icon] do %>
          <.icon name={@item.icon} class={get_icon_classes(@size) <> " mr-1"} />
        <% end %>
        <%= @item.title %>
      </.link>
    <% else %>
      <span 
        class={[
          "inline-flex items-center font-medium",
          get_text_classes(@size),
          "text-gray-500"
        ]}
        aria-current={@is_last && "page"}
        title={@item[:overlay]}
      >
        <%= if @item[:icon] do %>
          <.icon name={@item.icon} class={get_icon_classes(@size) <> " mr-1"} />
        <% end %>
        <%= @item.title %>
      </span>
    <% end %>
    """
  end
  
  @doc """
  渲染分隔符
  """
  attr :separator, :string, required: true
  attr :size, :string, default: "medium"
  
  def render_separator(assigns) do
    ~H"""
    <%= case @separator do %>
      <% "chevron" -> %>
        <.icon name="hero-chevron-right" class={get_separator_classes(@size) <> " text-gray-400"} />
      <% "slash" -> %>
        <span class={get_separator_classes(@size) <> " text-gray-400 font-medium"}>/</span>
      <% "arrow" -> %>
        <span class={get_separator_classes(@size) <> " text-gray-400 font-medium"}>→</span>
      <% custom_separator -> %>
        <span class={get_separator_classes(@size) <> " text-gray-400 font-medium"}><%= custom_separator %></span>
    <% end %>
    """
  end
  
  defp assign_defaults(assigns) do
    processed_items = process_items(assigns[:items] || [], assigns[:max_items])
    
    assigns
    |> assign(:processed_items, processed_items)
  end
  
  defp process_items(items, max_items) when is_integer(max_items) and max_items > 0 do
    if length(items) <= max_items do
      items
    else
      first_items = Enum.take(items, 1)
      last_items = Enum.take(items, -(max_items - 2))
      ellipsis_item = %{title: "...", path: nil}
      
      first_items ++ [ellipsis_item] ++ last_items
    end
  end
  
  defp process_items(items, _max_items), do: items
  
  defp get_text_classes(size) do
    case size do
      "small" -> "text-xs"
      "medium" -> "text-sm"
      "large" -> "text-base"
      _ -> "text-sm"
    end
  end
  
  defp get_icon_classes(size) do
    case size do
      "small" -> "h-3 w-3"
      "medium" -> "h-4 w-4"
      "large" -> "h-5 w-5"
      _ -> "h-4 w-4"
    end
  end
  
  defp get_spacing_classes(size) do
    case size do
      "small" -> "space-x-1"
      "medium" -> "space-x-2"
      "large" -> "space-x-3"
      _ -> "space-x-2"
    end
  end
  
  defp get_separator_classes(size) do
    base_classes = "mx-1"
    
    icon_classes = case size do
      "small" -> "h-3 w-3"
      "medium" -> "h-4 w-4"
      "large" -> "h-5 w-5"
      _ -> "h-4 w-4"
    end
    
    "#{base_classes} #{icon_classes}"
  end
end