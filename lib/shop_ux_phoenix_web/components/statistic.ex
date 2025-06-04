defmodule PetalComponents.Custom.Statistic do
  @moduledoc """
  统计数值组件 - 展示统计数值，用于突出某个或某组数字时使用
  
  ## 特性
  - 支持自定义前缀和后缀
  - 支持数字动画效果
  - 支持不同颜色主题
  - 支持增长率显示
  - 支持自定义精度
  - 支持数字格式化
  - 支持加载状态
  
  ## 依赖
  - Phoenix.Component
  """
  use Phoenix.Component

  @doc """
  渲染统计数值组件
  
  ## 示例
  
      <.statistic 
        id="basic-stat"
        title="用户总数"
        value={112893}
      />
      
      <!-- 不同尺寸示例 -->
      <.statistic 
        id="small-stat"
        size="small"
        title="今日访问"
        value={1205}
        color="primary"
      />
      
      <.statistic 
        id="large-stat"
        size="large"
        title="销售总额"
        value={89652.5}
        precision={2}
        prefix_text="¥"
        color="success"
      />
  """
  attr :id, :string, required: true, doc: "统计数值唯一标识"
  attr :title, :string, default: nil, doc: "数值标题"
  attr :value, :any, required: true, doc: "数值内容"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "统计数值尺寸"
  attr :precision, :integer, default: 0, doc: "精度，保留小数点后位数"
  attr :prefix_text, :string, default: nil, doc: "前缀文本"
  attr :suffix_text, :string, default: nil, doc: "后缀文本"
  attr :value_style, :string, default: "", doc: "数值的样式"
  attr :loading, :boolean, default: false, doc: "加载中状态"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "info", doc: "数值颜色"
  attr :group_separator, :string, default: ",", doc: "千分位分隔符"
  attr :decimal_separator, :string, default: ".", doc: "小数点分隔符"
  attr :animation, :boolean, default: true, doc: "是否开启动画"
  attr :animation_duration, :integer, default: 2000, doc: "动画持续时间(ms)"
  attr :animation_delay, :integer, default: 0, doc: "动画延迟时间(ms)"
  attr :trend, :string, default: nil, doc: "趋势方向"
  attr :trend_color, :boolean, default: true, doc: "趋势颜色"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :rest, :global, doc: "其他HTML属性"

  slot :prefix, doc: "前缀插槽"
  slot :suffix, doc: "后缀插槽"

  def statistic(assigns) do
    assigns = 
      assigns
      |> assign(:formatted_value, format_value(assigns))
      |> assign(:color_classes, get_color_classes(assigns.color))
      |> assign(:trend_classes, get_trend_classes(assigns))
      |> assign(:title_size_class, get_title_size_class(assigns.size))
      |> assign(:value_size_class, get_value_size_class(assigns.size))
      |> assign(:prefix_suffix_size_class, get_prefix_suffix_size_class(assigns.size))
      |> assign(:trend_size_class, get_trend_size_class(assigns.size))
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-statistic font-sans",
        "pc-statistic--#{@color}",
        @class
      ]}
      {if @animation do
        [
          {"data-duration", @animation_duration},
          {"data-delay", @animation_delay}
        ] ++ Map.to_list(@rest)
      else
        Map.to_list(@rest)
      end}>
      
      <!-- 统计标题 -->
      <%= if @title do %>
        <div class={[
          "pc-statistic__title",
          @loading && "text-gray-300 dark:text-gray-600",
          !@loading && "text-gray-500 dark:text-gray-400",
          @title_size_class
        ]}>
          <%= @title %>
        </div>
      <% end %>
      
      <!-- 统计数值 -->
      <div class={[
        "pc-statistic__value flex items-baseline space-x-1",
        @loading && "animate-pulse"
      ]}>
        
        <!-- 前缀 -->
        <%= if @prefix_text || length(@prefix) > 0 do %>
          <div class={[
            "pc-statistic__prefix",
            @prefix_suffix_size_class
          ]}>
            <%= if @prefix_text do %>
              <span><%= @prefix_text %></span>
            <% end %>
            <%= for prefix_slot <- @prefix do %>
              <%= render_slot(prefix_slot) %>
            <% end %>
          </div>
        <% end %>
        
        <!-- 数值主体 -->
        <div class={[
          "pc-statistic__number font-bold",
          @value_size_class,
          @color_classes,
          @value_style,
          @animation && "transition-all duration-150 ease-in-out"
        ]}>
          <%= if @loading do %>
            <div class="bg-gray-200 dark:bg-gray-700 rounded h-8 w-24"></div>
          <% else %>
            <%= @formatted_value %>
          <% end %>
        </div>
        
        <!-- 后缀 -->
        <%= if @suffix_text || length(@suffix) > 0 do %>
          <div class={[
            "pc-statistic__suffix",
            @prefix_suffix_size_class
          ]}>
            <%= if @suffix_text do %>
              <span><%= @suffix_text %></span>
            <% end %>
            <%= for suffix_slot <- @suffix do %>
              <%= render_slot(suffix_slot) %>
            <% end %>
          </div>
        <% end %>
        
        <!-- 趋势指示器 -->
        <%= if @trend do %>
          <div class={[
            "pc-statistic__trend ml-2 flex items-center",
            "pc-statistic__trend--#{@trend}",
            @trend_classes
          ]}>
            <%= case @trend do %>
              <% "up" -> %>
                <svg class={@trend_size_class} fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L11 5.414V17a1 1 0 11-2 0V5.414L4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                </svg>
              <% "down" -> %>
                <svg class={@trend_size_class} fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 10.293a1 1 0 010 1.414l-6 6a1 1 0 01-1.414 0l-6-6a1 1 0 111.414-1.414L9 15.586V3a1 1 0 012 0v12.586l4.293-4.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    
    """
  end
  
  # 格式化数值
  defp format_value(assigns) do
    value = assigns.value
    precision = assigns.precision
    group_separator = assigns.group_separator
    decimal_separator = assigns.decimal_separator
    
    cond do
      is_binary(value) ->
        value
      
      is_number(value) ->
        # 处理精度
        formatted = if precision > 0 do
          :erlang.float_to_binary(value * 1.0, [{:decimals, precision}])
        else
          to_string(trunc(value))
        end
        
        # 替换小数点分隔符
        formatted = if decimal_separator != "." do
          String.replace(formatted, ".", decimal_separator)
        else
          formatted
        end
        
        # 添加千分位分隔符
        if group_separator != "" do
          add_group_separator(formatted, group_separator, decimal_separator)
        else
          formatted
        end
      
      true ->
        to_string(value)
    end
  end
  
  # 添加千分位分隔符
  defp add_group_separator(number_str, separator, decimal_sep) do
    case String.split(number_str, decimal_sep) do
      [integer_part] ->
        add_separator_to_integer(integer_part, separator)
      
      [integer_part, decimal_part] ->
        formatted_integer = add_separator_to_integer(integer_part, separator)
        "#{formatted_integer}#{decimal_sep}#{decimal_part}"
    end
  end
  
  # 为整数部分添加分隔符
  defp add_separator_to_integer(integer_str, separator) do
    # 处理负号
    {sign, abs_str} = if String.starts_with?(integer_str, "-") do
      {"-", String.slice(integer_str, 1..-1//1)}
    else
      {"", integer_str}
    end
    
    # 反转字符串，每3位添加分隔符，再反转回来
    abs_str
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.join/1)
    |> Enum.join(separator)
    |> String.reverse()
    |> then(&"#{sign}#{&1}")
  end
  
  # 获取颜色类
  defp get_color_classes(color) do
    case color do
      "primary" -> "text-primary"
      "info" -> "text-blue-500"
      "success" -> "text-green-500"
      "warning" -> "text-orange-500"
      "danger" -> "text-red-500"
      _ -> "text-blue-500"
    end
  end
  
  # 获取趋势类
  defp get_trend_classes(assigns) do
    if assigns.trend && assigns.trend_color do
      case assigns.trend do
        "up" -> "text-green-500 trend-colored"
        "down" -> "text-red-500 trend-colored"
        _ -> ""
      end
    else
      ""
    end
  end
  
  # 获取标题尺寸类 - 匹配 Petal Components 的间距标准
  defp get_title_size_class(size) do
    case size do
      "small" -> "text-xs mb-0.5"
      "medium" -> "text-sm mb-1"
      "large" -> "text-base mb-1.5"
      _ -> "text-sm mb-1"
    end
  end
  
  # 获取数值尺寸类
  defp get_value_size_class(size) do
    case size do
      "small" -> "text-xl"
      "medium" -> "text-2xl"
      "large" -> "text-3xl"
      _ -> "text-2xl"
    end
  end
  
  # 获取前缀后缀尺寸类
  defp get_prefix_suffix_size_class(size) do
    case size do
      "small" -> "text-sm"
      "medium" -> "text-base"
      "large" -> "text-lg"
      _ -> "text-base"
    end
  end
  
  # 获取趋势图标尺寸类
  defp get_trend_size_class(size) do
    case size do
      "small" -> "w-3 h-3"
      "medium" -> "w-4 h-4"
      "large" -> "w-5 h-5"
      _ -> "w-4 h-4"
    end
  end
end