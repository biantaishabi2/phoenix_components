defmodule PetalComponents.Custom.Progress do
  @moduledoc """
  进度条组件，用于展示操作的当前进度
  
  ## 特性
  - 支持线形和环形两种类型
  - 支持多种状态（normal、active、success、exception）
  - 支持自定义颜色和尺寸
  - 支持格式化进度信息
  - 完整的无障碍支持
  
  ## 依赖
  - 无外部依赖，样式完全基于 Tailwind CSS
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents, only: [icon: 1]
  
  @doc """
  渲染进度条组件
  
  ## 示例
      <.progress percent={30} />
      <.progress percent={50} status="active" />
      <.progress type="circle" percent={75} />
  """
  attr :type, :string, values: ~w(line circle), default: "line", doc: "进度条类型"
  attr :percent, :integer, default: 0, doc: "百分比（0-100）"
  attr :status, :string, values: ~w(normal active success exception), default: "normal", doc: "状态"
  attr :size, :string, values: ~w(small medium large), default: "medium", doc: "尺寸"
  attr :show_info, :boolean, default: true, doc: "是否显示进度数值或状态图标"
  attr :stroke_width, :integer, default: nil, doc: "进度条线的宽度"
  attr :stroke_color, :string, default: nil, doc: "进度条的色彩"
  attr :trail_color, :string, default: nil, doc: "未完成的分段的颜色"
  attr :format_fn, :any, default: nil, doc: "内容的格式化函数"
  attr :width, :integer, default: 120, doc: "环形进度条画布宽度"
  attr :gap_degree, :integer, default: 0, doc: "环形进度条缺口角度"
  attr :gap_position, :string, values: ~w(top bottom left right), default: "top", doc: "环形进度条缺口位置"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :format, doc: "自定义进度信息内容" do
    attr :percent, :integer, doc: "当前百分比"
  end
  
  def progress(assigns) do
    assigns = assign_defaults(assigns)
    
    case assigns.type do
      "line" -> line_progress(assigns)
      "circle" -> circle_progress(assigns)
    end
  end
  
  defp line_progress(assigns) do
    ~H"""
    <div 
      class={["pc-progress", "pc-progress--line", @class]}
      role="progressbar"
      aria-valuenow={@percent}
      aria-valuemin="0"
      aria-valuemax="100"
      aria-label="进度条"
      {@rest}
    >
      <div class="pc-progress__outer">
        <div 
          class={trail_classes(@size, @stroke_width)}
          style={trail_style(@trail_color)}
        >
          <div 
            class={[
              bar_classes(@status, @size, @stroke_width),
              @status == "active" && "progress-active"
            ]}
            style={bar_style(@percent, @stroke_color, @status)}
          >
          </div>
        </div>
      </div>
      <%= if @show_info do %>
        <div class="pc-progress__info">
          <%= render_info(assigns) %>
        </div>
      <% end %>
    </div>
    """
  end
  
  defp circle_progress(assigns) do
    # 计算圆形路径
    radius = (assigns.width - assigns.stroke_width) / 2
    perimeter = 2 * :math.pi() * radius
    gap_offset = if assigns.gap_degree > 0, do: perimeter * assigns.gap_degree / 360, else: 0
    stroke_dasharray = "#{perimeter - gap_offset} #{perimeter}"
    stroke_dashoffset = -gap_offset / 2 + perimeter * (100 - assigns.percent) / 100
    
    # 计算旋转角度
    rotation = gap_position_rotation(assigns.gap_position, assigns.gap_degree)
    
    assigns = 
      assigns
      |> assign(:radius, radius)
      |> assign(:stroke_dasharray, stroke_dasharray)
      |> assign(:stroke_dashoffset, stroke_dashoffset)
      |> assign(:gap_offset, gap_offset)
      |> assign(:rotation, rotation)
    
    ~H"""
    <div 
      class={["pc-progress", "pc-progress--circle", "inline-block", @class]}
      role="progressbar"
      aria-valuenow={@percent}
      aria-valuemin="0"
      aria-valuemax="100"
      aria-label="环形进度条"
      {@rest}
    >
      <svg 
        width={@width} 
        height={@width} 
        viewBox={"0 0 #{@width} #{@width}"}
        class="pc-progress__circle"
      >
        <!-- 背景轨道 -->
        <circle
          cx={@width / 2}
          cy={@width / 2}
          r={@radius}
          fill="none"
          stroke={@trail_color || "#f3f4f6"}
          stroke-width={@stroke_width}
          stroke-dasharray={@stroke_dasharray}
          stroke-dashoffset={-@gap_offset / 2}
          transform={"rotate(#{@rotation} #{@width / 2} #{@width / 2})"}
        />
        <!-- 进度条 -->
        <circle
          cx={@width / 2}
          cy={@width / 2}
          r={@radius}
          fill="none"
          stroke={circle_stroke_color(@stroke_color, @status)}
          stroke-width={@stroke_width}
          stroke-linecap="round"
          stroke-dasharray={@stroke_dasharray}
          stroke-dashoffset={@stroke_dashoffset}
          transform={"rotate(#{@rotation} #{@width / 2} #{@width / 2})"}
          class="transition-all duration-300 ease-in-out"
        />
      </svg>
      <%= if @show_info do %>
        <div class="pc-progress__circle-info">
          <%= render_info(assigns) %>
        </div>
      <% end %>
    </div>
    """
  end
  
  # Helper functions
  
  defp assign_defaults(assigns) do
    percent = max(0, min(100, assigns[:percent] || 0))
    stroke_width = assigns[:stroke_width] || default_stroke_width(assigns[:type], assigns[:size])
    
    assigns
    |> assign(:percent, percent)
    |> assign(:stroke_width, stroke_width)
  end
  
  defp default_stroke_width("line", "small"), do: 6
  defp default_stroke_width("line", "medium"), do: 8
  defp default_stroke_width("line", "large"), do: 10
  defp default_stroke_width("circle", _), do: 6
  defp default_stroke_width(_, _), do: 8
  
  defp trail_classes(size, stroke_width) do
    height_class = cond do
      stroke_width >= 10 -> "h-3"
      stroke_width >= 8 -> "h-2"
      stroke_width >= 6 -> "h-1.5"
      true -> "h-1"
    end
    
    # Override with size if no custom stroke_width
    height_class = if stroke_width == default_stroke_width("line", size) do
      case size do
        "small" -> "h-1"
        "medium" -> "h-2"
        "large" -> "h-3"
        _ -> height_class
      end
    else
      height_class
    end
    
    [
      "relative w-full overflow-hidden rounded-full",
      "bg-gray-200 dark:bg-gray-700",
      height_class
    ]
  end
  
  defp trail_style(nil), do: ""
  defp trail_style(color), do: "background-color: #{color}"
  
  defp bar_classes(status, _size, _stroke_width) do
    base = "absolute inset-y-0 left-0 rounded-full transition-all duration-300"
    
    color_class = case status do
      "success" -> "bg-success"
      "exception" -> "bg-danger"
      _ -> "bg-primary"
    end
    
    [base, color_class]
  end
  
  defp bar_style(percent, nil, status) when status in ["success", "exception"] do
    "width: #{percent}%"
  end
  
  defp bar_style(percent, nil, _status) do
    "width: #{percent}%"
  end
  
  defp bar_style(percent, color, _status) do
    if String.contains?(color, "gradient") do
      "background: #{color}; width: #{percent}%"
    else
      "background-color: #{color}; width: #{percent}%"
    end
  end
  
  defp circle_stroke_color(nil, "success"), do: "#10b981"
  defp circle_stroke_color(nil, "exception"), do: "#ef4444"
  defp circle_stroke_color(nil, _), do: "#6366f1"
  defp circle_stroke_color(color, _), do: color
  
  defp gap_position_rotation("top", gap_degree), do: round(90 + gap_degree / 2)
  defp gap_position_rotation("right", gap_degree), do: round(180 + gap_degree / 2)
  defp gap_position_rotation("bottom", gap_degree), do: round(270 + gap_degree / 2 - 180)
  defp gap_position_rotation("left", gap_degree), do: round(gap_degree / 2)
  
  defp render_info(assigns) do
    cond do
      # 自定义插槽内容优先
      assigns[:format] && assigns[:format] != [] ->
        ~H"""
        <%= render_slot(@format, @percent) %>
        """
        
      # 状态图标
      assigns.status == "success" && assigns.percent == 100 ->
        ~H"""
        <.icon name="hero-check-circle-mini" class="w-5 h-5 text-success" />
        """
        
      assigns.status == "exception" ->
        ~H"""
        <.icon name="hero-x-circle-mini" class="w-5 h-5 text-danger" />
        """
        
      # 格式化函数
      assigns[:format_fn] ->
        ~H"""
        <span class="text-sm font-medium"><%= @format_fn.(@percent) %></span>
        """
        
      # 默认百分比
      true ->
        ~H"""
        <span class="text-sm font-medium"><%= @percent %>%</span>
        """
    end
  end
end