defmodule PetalComponents.Custom.Tag do
  @moduledoc """
  标签组件 - 用于标记和分类的小型标签
  
  ## 特性
  - 多种预设颜色
  - 支持关闭功能
  - 支持图标
  - 可选边框样式
  - 自定义样式支持
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS (用于关闭事件)
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染一个标签组件
  
  ## 示例
  
      <.tag>默认标签</.tag>
      
      <.tag color="success">成功</.tag>
      
      <.tag size="small" color="primary">小号</.tag>
      <.tag size="medium" color="info">中号（默认）</.tag>
      <.tag size="large" color="warning">大号</.tag>
      
      <.tag closable on_close={JS.push("remove_tag")}>
        可关闭
      </.tag>
      
      <.tag color="primary">
        <:icon><.icon name="hero-check-mini" /></:icon>
        带图标
      </.tag>
  """
  attr :color, :string, default: "info", doc: "标签颜色：primary | info | success | danger | warning"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "标签尺寸"
  attr :closable, :boolean, default: false, doc: "是否显示关闭按钮"
  attr :on_close, JS, default: nil, doc: "关闭时触发的JS命令"
  attr :bordered, :boolean, default: true, doc: "是否显示边框"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :rest, :global, doc: "其他HTML属性"
  
  slot :inner_block, required: true, doc: "标签内容"
  slot :icon, doc: "图标插槽"

  def tag(assigns) do
    ~H"""
    <span
      class={[
        "pc-tag",
        tag_base_classes(@size),
        tag_color_classes(@color, @bordered),
        @closable && "pc-tag--closable",
        @class
      ]}
      {@rest}
    >
      <%= if @icon do %>
        <span class="pc-tag__icon inline-flex items-center mr-1">
          <%= render_slot(@icon) %>
        </span>
      <% end %>
      
      <%= render_slot(@inner_block) %>
      
      <%= if @closable do %>
        <button
          type="button"
          class="pc-tag__close ml-1.5 inline-flex items-center justify-center transition duration-150 ease-in-out hover:opacity-80 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
          phx-click={@on_close || JS.push("noop")}
        >
          <svg class="h-3 w-3" fill="currentColor" viewBox="0 0 20 20">
            <path 
              fill-rule="evenodd" 
              d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" 
              clip-rule="evenodd" 
            />
          </svg>
        </button>
      <% end %>
    </span>
    
    <style>
      /* Primary color styles using custom orange #FD8E25 */
      .pc-tag--primary {
        background-color: #FFF4EC;
        color: #C24B14;
        border-color: #FFE4D1;
      }
      
      .pc-tag--primary.pc-tag--borderless {
        border-color: transparent;
      }
      
      /* Dark mode support for primary */
      .dark .pc-tag--primary {
        background-color: rgba(253, 142, 37, 0.1);
        color: #FFA366;
        border-color: rgba(253, 142, 37, 0.3);
      }
    </style>
    """
  end
  
  # 基础样式类 - 匹配 Petal Components 的间距标准
  defp tag_base_classes(size) do
    base = [
      "inline-flex",
      "items-center",
      "rounded-md",
      "font-medium",
      "transition-colors"
    ]
    
    size_classes = case size do
      "small" -> ["text-xs leading-4 px-2 py-1"]
      "medium" -> ["text-sm leading-5 px-2.5 py-1.5"]
      "large" -> ["text-base leading-6 px-3 py-2"]
      _ -> ["text-sm leading-5 px-2.5 py-1.5"]
    end
    
    base ++ size_classes
  end
  
  # 根据颜色和边框返回对应的样式类
  defp tag_color_classes(color, bordered) do
    base_classes = color_map()[color] || color_map()["info"]
    
    color_class = "pc-tag--#{color}"
    
    if bordered do
      [color_class | base_classes]
    else
      # 无边框时移除border相关的类
      [color_class, "pc-tag--borderless" | base_classes |> Enum.reject(&String.contains?(&1, "border"))]
    end
  end
  
  # 颜色映射表
  defp color_map do
    %{
      "primary" => [
        "bg-orange-100",
        "text-orange-800",
        "border",
        "border-orange-200",
        "dark:bg-orange-900/30",
        "dark:text-orange-300",
        "dark:border-orange-700"
      ],
      "info" => [
        "bg-blue-100",
        "text-blue-800",
        "border",
        "border-blue-200",
        "dark:bg-blue-900/30",
        "dark:text-blue-300",
        "dark:border-blue-700"
      ],
      "success" => [
        "bg-green-100",
        "text-green-800",
        "border",
        "border-green-200",
        "dark:bg-green-900/30",
        "dark:text-green-300",
        "dark:border-green-700"
      ],
      "warning" => [
        "bg-yellow-100",
        "text-yellow-800",
        "border",
        "border-yellow-200",
        "dark:bg-yellow-900/30",
        "dark:text-yellow-300",
        "dark:border-yellow-700"
      ],
      "danger" => [
        "bg-red-100",
        "text-red-800",
        "border",
        "border-red-200",
        "dark:bg-red-900/30",
        "dark:text-red-300",
        "dark:border-red-700"
      ]
    }
  end
end