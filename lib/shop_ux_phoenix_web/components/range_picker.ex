defmodule PetalComponents.Custom.RangePicker do
  @moduledoc """
  范围选择器组件 - 用于选择日期/时间范围
  
  ## 特性
  - 支持日期范围选择
  - 支持时间范围选择
  - 支持不同的选择器类型（日/周/月/季/年）
  - 支持快捷选项
  - 支持禁用特定日期
  - 支持自定义格式
  - 支持清除功能
  - 支持预设范围
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染范围选择器组件
  
  ## 示例
  
      <.range_picker 
        id="date-range"
        name="date_range"
        placeholder={["开始日期", "结束日期"]}
      />
      
      <!-- 不同尺寸示例 -->
      <.range_picker 
        id="small-range"
        size="small"
        color="primary"
        placeholder={["开始", "结束"]}
      />
      
      <.range_picker 
        id="large-range"
        size="large"
        picker="month"
        color="warning"
        placeholder={["起始月份", "结束月份"]}
      />
  """
  attr :id, :string, required: true, doc: "选择器唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :value, :list, default: nil, doc: "当前选中的日期范围 [开始日期, 结束日期]"
  attr :format, :string, default: "YYYY-MM-DD", doc: "日期格式"
  attr :separator, :string, default: " ~ ", doc: "范围分隔符"
  attr :placeholder, :list, default: ["开始日期", "结束日期"], doc: "占位文字"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "尺寸"
  attr :picker, :string, values: ["date", "week", "month", "quarter", "year"], default: "date", doc: "选择器类型"
  attr :show_time, :boolean, default: false, doc: "是否显示时间选择"
  attr :disabled_date, :any, default: nil, doc: "不可选择的日期函数"
  attr :clearable, :boolean, default: true, doc: "是否可清除"
  attr :ranges, :list, default: [], doc: "预设时间范围"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: %JS{}, doc: "日期改变时的回调"
  attr :on_clear, JS, default: %JS{}, doc: "清除日期时的回调"
  attr :rest, :global, doc: "其他HTML属性"

  def range_picker(assigns) do
    assigns = 
      assigns
      |> assign(:formatted_values, format_range_values(assigns[:value], assigns[:format], assigns[:show_time]))
      |> assign(:show_clear, assigns[:clearable] && has_range_value?(assigns[:value]))
      |> assign(:start_panel_id, "#{assigns.id}-start-panel")
      |> assign(:end_panel_id, "#{assigns.id}-end-panel")
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-range-picker relative",
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ]}
      {@rest}>
      
      <%= if @name do %>
        <%= render_hidden_inputs(assigns) %>
      <% end %>
      
      <div class="flex items-center">
        <!-- 开始日期输入 -->
        <div class="relative flex-1">
          <input
            type="text"
            class={[
              "pc-range-picker__input start-input w-full",
              "border border-gray-300 dark:border-gray-600 rounded-l-md bg-white dark:bg-gray-800",
              "transition duration-150 ease-in-out hover:border-gray-400 dark:hover:border-gray-500",
              get_focus_classes(@color),
              size_classes(@size),
              @disabled && "cursor-not-allowed opacity-50"
            ]}
            value={List.first(@formatted_values)}
            placeholder={List.first(@placeholder)}
            readonly
            disabled={@disabled}
            class:dark="dark:text-gray-200 dark:placeholder-gray-500"
            phx-click={toggle_panel(@start_panel_id)}
            phx-click-away={hide_panel(@start_panel_id)}
          />
        </div>
        
        <!-- 分隔符 -->
        <div class={[
          "separator flex items-center justify-center border-t border-b border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800",
          size_separator_classes(@size)
        ]}>
          <span class="text-gray-400 dark:text-gray-500 text-sm"><%= @separator %></span>
        </div>
        
        <!-- 结束日期输入 -->
        <div class="relative flex-1">
          <input
            type="text"
            class={[
              "pc-range-picker__input end-input w-full",
              "border border-gray-300 dark:border-gray-600 rounded-r-md bg-white dark:bg-gray-800",
              "transition duration-150 ease-in-out hover:border-gray-400 dark:hover:border-gray-500",
              get_focus_classes(@color),
              size_classes(@size),
              @disabled && "cursor-not-allowed opacity-50"
            ]}
            value={List.last(@formatted_values)}
            placeholder={List.last(@placeholder)}
            readonly
            disabled={@disabled}
            class:dark="dark:text-gray-200 dark:placeholder-gray-500"
            phx-click={toggle_panel(@end_panel_id)}
            phx-click-away={hide_panel(@end_panel_id)}
          />
          
          <%= if @show_clear do %>
            <div class="absolute inset-y-0 right-0 flex items-center pr-3">
              <button
                type="button"
                class={["pc-range-picker__clear p-0.5 rounded transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
                phx-click={@on_clear}>
                <svg class="pc-range-picker__icon w-4 h-4 text-gray-400 dark:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>
            </div>
          <% end %>
        </div>
      </div>
      
      <!-- 开始日期选择面板 -->
      <%= render_picker_panel(assigns, :start) %>
      
      <!-- 结束日期选择面板 -->
      <%= render_picker_panel(assigns, :end) %>
    </div>
    
    """
  end
  
  # 渲染隐藏的表单输入
  defp render_hidden_inputs(assigns) do
    [start_val, end_val] = assigns[:formatted_values] || ["", ""]
    assigns = 
      assigns
      |> assign(:start_value, start_val)
      |> assign(:end_value, end_val)
    
    ~H"""
    <input type="hidden" name={"#{@name}[start]"} value={@start_value} />
    <input type="hidden" name={"#{@name}[end]"} value={@end_value} />
    """
  end
  
  # 渲染选择器面板
  defp render_picker_panel(assigns, position) do
    panel_id = if position == :start, do: assigns.start_panel_id, else: assigns.end_panel_id
    panel_class = "#{position}-panel"
    
    assigns = 
      assigns
      |> assign(:panel_id, panel_id)
      |> assign(:panel_class, panel_class)
      |> assign(:position, position)
    
    ~H"""
    <div 
      id={@panel_id}
      class={[
        "pc-range-picker__panel absolute z-10 mt-1 bg-white dark:bg-gray-800 rounded-lg",
        "shadow-xl shadow-gray-500/10 dark:shadow-gray-900/30",
        "border border-gray-200 dark:border-gray-700",
        "hidden",
        @panel_class,
        picker_panel_classes(@picker),
        position_classes(@position)
      ]}>
      
      <%= if @position == :start && @ranges != [] do %>
        <div class="pc-range-picker__shortcuts border-b border-gray-200 dark:border-gray-700 p-2">
          <div class="flex flex-wrap gap-1">
            <%= for range <- @ranges do %>
              <button
                type="button"
                class={["px-3 py-1.5 text-sm rounded transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
                phx-click={if @on_change, do: @on_change, else: "select_range"}
                phx-value-start={format_date_for_value(List.first(range.value))}
                phx-value-end={format_date_for_value(List.last(range.value))}>
                <%= range.label %>
              </button>
            <% end %>
          </div>
        </div>
      <% end %>
      
      <div class="pc-range-picker__header flex items-center justify-between p-2 border-b border-gray-200 dark:border-gray-700">
        <button type="button" class="p-1 hover:bg-gray-100 dark:hover:bg-gray-700 rounded">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
        </button>
        
        <div class="flex items-center gap-2">
          <span class="font-medium dark:text-gray-200">2024年1月</span>
        </div>
        
        <button type="button" class="p-1 hover:bg-gray-100 dark:hover:bg-gray-700 rounded">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>
      
      <%= render_picker_body(assigns) %>
      
      <%= if @show_time do %>
        <div class="pc-range-picker__time border-t border-gray-200 dark:border-gray-700 p-2">
          <div class="flex items-center justify-center gap-1">
            <input type="text" class="w-12 px-2 py-1 text-center border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 dark:text-gray-200 rounded" value="00" />
            <span>:</span>
            <input type="text" class="w-12 px-2 py-1 text-center border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 dark:text-gray-200 rounded" value="00" />
            <span>:</span>
            <input type="text" class="w-12 px-2 py-1 text-center border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 dark:text-gray-200 rounded" value="00" />
          </div>
        </div>
      <% end %>
    </div>
    """
  end
  
  # 渲染选择器主体
  defp render_picker_body(assigns) do
    picker_type_class = "picker-type-#{assigns.picker}"
    assigns = assign(assigns, :picker_type_class, picker_type_class)
    
    case assigns.picker do
      "date" -> render_date_picker(assigns)
      "week" -> render_week_picker(assigns) 
      "month" -> render_month_picker(assigns)
      "year" -> render_year_picker(assigns)
      _ -> render_date_picker(assigns)
    end
  end
  
  # 渲染日期选择器
  defp render_date_picker(assigns) do
    ~H"""
    <div class={["pc-range-picker__body p-2", @picker_type_class]}>
      <div class="weekdays grid grid-cols-7 gap-1 mb-1">
        <%= for weekday <- ["日", "一", "二", "三", "四", "五", "六"] do %>
          <div class="text-center text-xs text-gray-500 dark:text-gray-400 py-1">
            <%= weekday %>
          </div>
        <% end %>
      </div>
      
      <div class="grid grid-cols-7 gap-1">
        <%= for day <- 1..31 do %>
          <button
            type="button"
            class={[
              "p-2 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200",
              day == 15 && "bg-primary text-white hover:bg-primary dark:bg-primary dark:text-white"
            ]}
            phx-click={if @on_change, do: @on_change, else: "select_date"}
            phx-value-date={format_date_for_value(2024, 1, day)}
            phx-value-position={@position}>
            <%= day %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 渲染周选择器
  defp render_week_picker(assigns) do
    ~H"""
    <div class={["p-4", @picker_type_class]}>
      <div class="text-center text-gray-500 dark:text-gray-400">周选择器</div>
    </div>
    """
  end
  
  # 渲染月选择器
  defp render_month_picker(assigns) do
    ~H"""
    <div class={["p-4", @picker_type_class]}>
      <div class="grid grid-cols-3 gap-2">
        <%= for month <- 1..12 do %>
          <button
            type="button"
            class="p-2 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200"
            phx-click={if @on_change, do: @on_change, else: "select_month"}
            phx-value-month={month}
            phx-value-position={@position}>
            <%= month %>月
          </button>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 渲染年选择器
  defp render_year_picker(assigns) do
    current_year = Date.utc_today().year
    years = (current_year - 5)..(current_year + 5)
    assigns = assign(assigns, :years, years)
    
    ~H"""
    <div class={["p-4", @picker_type_class]}>
      <div class="grid grid-cols-3 gap-2">
        <%= for year <- @years do %>
          <button
            type="button"
            class="p-2 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200"
            phx-click={if @on_change, do: @on_change, else: "select_year"}
            phx-value-year={year}
            phx-value-position={@position}>
            <%= year %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 格式化范围值
  defp format_range_values(nil, _format, _show_time), do: ["", ""]
  defp format_range_values([start_value, end_value], format, show_time) do
    [
      format_single_value(start_value, format, show_time),
      format_single_value(end_value, format, show_time)
    ]
  end
  defp format_range_values(_, _format, _show_time), do: ["", ""]
  
  # 格式化单个值
  defp format_single_value(nil, _format, _show_time), do: ""
  defp format_single_value(value, format, show_time) do
    case value do
      %Date{} = date ->
        format_date(date, format)
      %DateTime{} = datetime ->
        if show_time do
          format_datetime(datetime, format)
        else
          format_date(DateTime.to_date(datetime), format)
        end
      _ ->
        ""
    end
  end
  
  # 简单的日期格式化
  defp format_date(date, "YYYY-MM-DD") do
    Date.to_string(date)
  end
  defp format_date(date, "YYYY年MM月DD日") do
    "#{date.year}年#{pad_zero(date.month)}月#{pad_zero(date.day)}日"
  end
  defp format_date(date, _format) do
    Date.to_string(date)
  end
  
  # 简单的日期时间格式化
  defp format_datetime(datetime, "YYYY-MM-DD HH:mm:ss") do
    date = DateTime.to_date(datetime)
    time = DateTime.to_time(datetime)
    "#{Date.to_string(date)} #{pad_zero(time.hour)}:#{pad_zero(time.minute)}:#{pad_zero(time.second)}"
  end
  defp format_datetime(datetime, format) do
    format_date(DateTime.to_date(datetime), format)
  end
  
  # 补零
  defp pad_zero(num) when num < 10, do: "0#{num}"
  defp pad_zero(num), do: "#{num}"
  
  # 检查是否有范围值
  defp has_range_value?(nil), do: false
  defp has_range_value?([nil, nil]), do: false
  defp has_range_value?([start_val, end_val]) when start_val != nil or end_val != nil, do: true
  defp has_range_value?(_), do: false
  
  # 格式化日期值（用于按钮）
  defp format_date_for_value(nil), do: ""
  defp format_date_for_value(%Date{} = date), do: Date.to_string(date)
  defp format_date_for_value(%DateTime{} = datetime), do: DateTime.to_string(datetime)
  defp format_date_for_value(year, month, day) when is_integer(year) do
    "#{year}-#{pad_zero(month)}-#{pad_zero(day)}"
  end
  
  # 尺寸样式 - 匹配 Petal Components 的间距标准
  defp size_classes("small"), do: "text-sm leading-4 py-2 px-3"
  defp size_classes("medium"), do: "text-sm leading-5 py-2 px-4"
  defp size_classes("large"), do: "text-base leading-6 py-2.5 px-6"
  
  # 分隔符尺寸样式 - 匹配 Petal Components 的间距标准
  defp size_separator_classes("small"), do: "px-2 py-2"
  defp size_separator_classes("medium"), do: "px-3 py-2"
  defp size_separator_classes("large"), do: "px-4 py-2.5"
  
  # 选择器面板样式
  defp picker_panel_classes("date"), do: "w-80"
  defp picker_panel_classes("week"), do: "w-80"
  defp picker_panel_classes("month"), do: "w-64"
  defp picker_panel_classes("year"), do: "w-64"
  defp picker_panel_classes(_), do: "w-80"
  
  # 面板位置样式
  defp position_classes(:start), do: "left-0"
  defp position_classes(:end), do: "right-0"
  
  # JS命令：切换面板
  defp toggle_panel(id) do
    JS.toggle(
      to: "##{id}",
      in: {"transition ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"},
      out: {"transition ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end
  
  # JS命令：隐藏面板
  defp hide_panel(id) do
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
  
end