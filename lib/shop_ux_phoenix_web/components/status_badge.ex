defmodule ShopUxPhoenixWeb.Components.StatusBadge do
  @moduledoc """
  状态徽章组件 - 用于展示各种状态信息
  
  ## 特性
  - 支持多种预设状态类型
  - 可自定义颜色和文本
  - 支持显示状态点（dot）或完整徽章
  - 支持图标前缀
  - 响应式设计
  - 内置常见业务状态配置
  
  ## 依赖
  - 无外部依赖，完全使用 Tailwind CSS
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents

  @doc """
  渲染状态徽章
  
  ## 示例
  
      <.status_badge text="已完成" type="success" />
      
      <.status_badge 
        text="处理中" 
        type="processing"
        icon="hero-arrow-path"
      />
      
      <.status_badge type="error" dot />
  """
  attr :text, :string, default: nil, doc: "状态文本"
  attr :type, :string, default: "default", 
    values: ~w(default success processing warning error info),
    doc: "状态类型"
  attr :color, :string, default: nil, doc: "自定义颜色，会覆盖 type 的颜色"
  attr :dot, :boolean, default: false, doc: "是否只显示小圆点"
  attr :size, :string, default: "medium",
    values: ~w(small medium large),
    doc: "尺寸"
  attr :bordered, :boolean, default: true, doc: "是否显示边框"
  attr :icon, :string, default: nil, doc: "图标名称"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :inner_block, doc: "自定义内容"

  def status_badge(assigns) do
    text_size_class = get_text_size_class(assigns.size)
    
    assigns = 
      assigns
      |> assign(:badge_classes, get_badge_classes(assigns))
      |> assign(:dot_classes, get_dot_classes(assigns))
      |> assign(:icon_classes, get_icon_classes(assigns.size))
      |> assign(:text_size_class, text_size_class)
    
    ~H"""
    <%= if @dot do %>
      <span
        class={[@dot_classes, @class]}
        {@rest}
      ></span>
    <% else %>
      <span
        class={[@badge_classes, @class]}
        {@rest}
      >
        <%= if @icon do %>
          <.icon name={@icon} class={@icon_classes} />
        <% end %>
        
        <%= if @inner_block != [] do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <%= @text %>
        <% end %>
      </span>
    <% end %>
    """
  end

  @doc """
  订单状态徽章辅助函数
  """
  def order_status_badge(assigns) do
    {text, type} = case assigns[:status] do
      "pending" -> {"待付款", "warning"}
      "paid" -> {"已付款", "info"}
      "shipped" -> {"已发货", "processing"}
      "completed" -> {"已完成", "success"}
      "cancelled" -> {"已取消", "error"}
      "refunding" -> {"退款中", "warning"}
      "refunded" -> {"已退款", "default"}
      status -> {status || "未知", "default"}
    end
    
    assigns = 
      assigns
      |> Map.put(:text, text)
      |> Map.put(:type, type)
      |> Map.put_new(:size, "medium")
    
    ~H"""
    <.status_badge text={@text} type={@type} size={@size} />
    """
  end

  @doc """
  用户状态徽章辅助函数
  """
  def user_status_badge(assigns) do
    {text, type, icon} = case assigns[:status] do
      "active" -> {"正常", "success", "hero-check-circle"}
      "inactive" -> {"已禁用", "error", "hero-x-circle"}
      "pending" -> {"待验证", "warning", "hero-exclamation-circle"}
      status -> {status || "未知", "default", nil}
    end
    
    assigns = 
      assigns
      |> Map.put(:text, text)
      |> Map.put(:type, type)
      |> Map.put(:icon, icon)
      |> Map.put_new(:size, "medium")
    
    ~H"""
    <.status_badge text={@text} type={@type} icon={@icon} size={@size} />
    """
  end

  @doc """
  商品状态徽章辅助函数
  """
  def product_status_badge(assigns) do
    {text, type} = case assigns[:status] do
      "on_sale" -> {"在售", "success"}
      "out_of_stock" -> {"缺货", "error"}
      "off_shelf" -> {"下架", "default"}
      "pre_sale" -> {"预售", "processing"}
      status -> {status || "未知", "default"}
    end
    
    assigns = 
      assigns
      |> Map.put(:text, text)
      |> Map.put(:type, type)
      |> Map.put_new(:size, "medium")
    
    ~H"""
    <.status_badge text={@text} type={@type} size={@size} />
    """
  end

  @doc """
  审核状态徽章辅助函数
  """
  def review_status_badge(assigns) do
    {text, type, icon} = case assigns[:status] do
      "pending" -> {"待审核", "warning", "hero-clock"}
      "approved" -> {"审核通过", "success", "hero-check"}
      "rejected" -> {"审核拒绝", "error", "hero-x-mark"}
      status -> {status || "未知", "default", nil}
    end
    
    assigns = 
      assigns
      |> Map.put(:text, text)
      |> Map.put(:type, type)
      |> Map.put(:icon, icon)
      |> Map.put_new(:size, "medium")
    
    ~H"""
    <.status_badge text={@text} type={@type} icon={@icon} size={@size} />
    """
  end

  # 私有函数

  defp get_badge_classes(assigns) do
    base_classes = [
      "inline-flex items-center gap-1",
      get_padding_classes(assigns.size),
      get_text_size_class(assigns.size),
      "rounded-full",
      "font-medium",
      "transition-colors duration-200"
    ]
    
    color_classes = if assigns.color do
      get_custom_color_classes(assigns.color, assigns.bordered)
    else
      get_type_color_classes(assigns.type, assigns.bordered)
    end
    
    border_classes = if assigns.bordered do
      ["border"]
    else
      []
    end
    
    base_classes ++ color_classes ++ border_classes
  end

  defp get_dot_classes(assigns) do
    base_classes = [
      "inline-block",
      "rounded-full",
      get_dot_size_classes(assigns.size)
    ]
    
    color_classes = if assigns.color do
      ["bg-#{assigns.color}-500"]
    else
      get_dot_color_classes(assigns.type)
    end
    
    base_classes ++ color_classes
  end

  defp get_padding_classes(size) do
    case size do
      "small" -> "px-2 py-0.5"
      "medium" -> "px-3 py-1"
      "large" -> "px-4 py-1.5"
      _ -> "px-3 py-1"
    end
  end

  defp get_text_size_class(size) do
    case size do
      "small" -> "text-xs"
      "medium" -> "text-sm"
      "large" -> "text-base"
      _ -> "text-sm"
    end
  end

  defp get_icon_classes(size) do
    case size do
      "small" -> "w-3 h-3"
      "medium" -> "w-4 h-4"
      "large" -> "w-5 h-5"
      _ -> "w-4 h-4"
    end
  end

  defp get_dot_size_classes(size) do
    case size do
      "small" -> "w-2 h-2"
      "medium" -> "w-2.5 h-2.5"
      "large" -> "w-3 h-3"
      _ -> "w-2.5 h-2.5"
    end
  end

  defp get_type_color_classes(type, bordered) do
    case type do
      "success" when bordered ->
        ["bg-green-50", "text-green-700", "border-green-200", "hover:bg-green-100"]
      "success" ->
        ["bg-green-100", "text-green-700", "hover:bg-green-200"]
        
      "processing" when bordered ->
        ["bg-blue-50", "text-blue-700", "border-blue-200", "hover:bg-blue-100"]
      "processing" ->
        ["bg-blue-100", "text-blue-700", "hover:bg-blue-200"]
        
      "warning" when bordered ->
        ["bg-yellow-50", "text-yellow-700", "border-yellow-200", "hover:bg-yellow-100"]
      "warning" ->
        ["bg-yellow-100", "text-yellow-700", "hover:bg-yellow-200"]
        
      "error" when bordered ->
        ["bg-red-50", "text-red-700", "border-red-200", "hover:bg-red-100"]
      "error" ->
        ["bg-red-100", "text-red-700", "hover:bg-red-200"]
        
      "info" when bordered ->
        ["bg-blue-50", "text-blue-700", "border-blue-200", "hover:bg-blue-100"]
      "info" ->
        ["bg-blue-100", "text-blue-700", "hover:bg-blue-200"]
        
      _ when bordered ->
        ["bg-gray-50", "text-gray-700", "border-gray-200", "hover:bg-gray-100"]
      _ ->
        ["bg-gray-100", "text-gray-700", "hover:bg-gray-200"]
    end
  end

  defp get_custom_color_classes(color, bordered) when bordered do
    [
      "bg-#{color}-50",
      "text-#{color}-700",
      "border-#{color}-200",
      "hover:bg-#{color}-100"
    ]
  end

  defp get_custom_color_classes(color, _bordered) do
    [
      "bg-#{color}-100",
      "text-#{color}-700",
      "hover:bg-#{color}-200"
    ]
  end

  defp get_dot_color_classes(type) do
    case type do
      "success" -> ["bg-green-500"]
      "processing" -> ["bg-blue-500"]
      "warning" -> ["bg-yellow-500"]
      "error" -> ["bg-red-500"]
      "info" -> ["bg-blue-400"]
      _ -> ["bg-gray-500"]
    end
  end
end