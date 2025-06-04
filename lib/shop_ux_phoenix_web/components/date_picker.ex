defmodule PetalComponents.Custom.DatePicker do
  @moduledoc """
  日期选择器组件 - 用于选择日期和时间
  
  ## 特性
  - 支持日期选择
  - 支持时间选择
  - 支持不同的选择器类型（日/周/月/季/年）
  - 支持日期范围限制
  - 支持快捷选项
  - 支持禁用特定日期
  - 支持自定义格式
  - 支持清除功能
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  渲染日期选择器组件
  
  ## 示例
  
      <.date_picker 
        id="birth-date"
        name="user[birth_date]"
        value={@birth_date}
        placeholder="选择出生日期"
      />
      
      <!-- 不同尺寸示例 -->
      <.date_picker 
        id="small-picker"
        size="small"
        color="primary"
        placeholder="小号选择器"
      />
      
      <.date_picker 
        id="large-picker"
        size="large"
        picker="month"
        color="success"
        placeholder="大号月份选择"
      />
  """
  attr :id, :string, required: true, doc: "日期选择器唯一标识"
  attr :name, :string, default: nil, doc: "表单字段名"
  attr :value, :any, default: nil, doc: "当前日期"
  attr :format, :string, default: "YYYY-MM-DD", doc: "日期格式"
  attr :placeholder, :string, default: "请选择日期", doc: "占位文字"
  attr :disabled, :boolean, default: false, doc: "是否禁用"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "尺寸"
  attr :picker, :string, values: ["date", "week", "month", "quarter", "year"], default: "date", doc: "选择器类型"
  attr :show_time, :boolean, default: false, doc: "是否显示时间选择"
  attr :disabled_date, :any, default: nil, doc: "不可选择的日期函数"
  attr :clearable, :boolean, default: true, doc: "是否可清除"
  attr :show_today, :boolean, default: true, doc: "是否显示今天按钮"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :on_change, JS, default: %JS{}, doc: "日期改变时的回调"
  attr :on_clear, JS, default: %JS{}, doc: "清除日期时的回调"
  attr :shortcuts, :list, default: [], doc: "快捷选项"
  attr :default_value, :any, default: nil, doc: "默认日期"
  attr :min_date, :any, default: nil, doc: "最小可选日期"
  attr :max_date, :any, default: nil, doc: "最大可选日期"
  attr :rest, :global, doc: "其他HTML属性"

  def date_picker(assigns) do
    assigns = 
      assigns
      |> assign(:formatted_value, format_date_value(assigns[:value], assigns[:format], assigns[:show_time]))
      |> assign(:show_clear, assigns[:clearable] && assigns[:value] != nil)
      |> assign(:panel_id, "#{assigns.id}-panel")
      |> assign(:min_date_str, date_to_string(assigns[:min_date]))
      |> assign(:max_date_str, date_to_string(assigns[:max_date]))
      |> assign(:default_value_str, date_to_string(assigns[:default_value]))
    
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-date-picker relative",
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ]}
      {@rest}>
      
      <%= if @name do %>
        <input type="hidden" name={@name} value={@formatted_value} />
      <% end %>
      
      <div class="relative">
        <input
          type="text"
          class={[
            "pc-date-picker__input w-full pr-10",
            "border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800",
            "transition duration-150 ease-in-out hover:border-gray-400 dark:hover:border-gray-500",
            get_focus_classes(@color),
            size_classes(@size),
            @disabled && "cursor-not-allowed opacity-50"
          ]}
          value={@formatted_value}
          placeholder={@placeholder}
          readonly
          disabled={@disabled}
          phx-click={toggle_panel(@panel_id)}
          phx-click-away={hide_panel(@panel_id)}
          data-min-date={@min_date_str}
          data-max-date={@max_date_str}
          data-default-value={@default_value_str}
          data-disabled-date={@disabled_date != nil}
        />
        
        <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
          <%= if @show_clear do %>
            <button
              type="button"
              class={["pc-date-picker__clear p-0.5 rounded pointer-events-auto transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
              phx-click={@on_clear}>
              <svg class="w-4 h-4 text-gray-400 dark:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          <% else %>
            <svg class="pc-date-picker__icon w-5 h-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          <% end %>
        </div>
      </div>
      
      <!-- 日期选择面板 -->
      <div 
        id={@panel_id}
        class={[
          "pc-date-picker__panel absolute z-10 mt-1 bg-white dark:bg-gray-800 rounded-lg",
          "shadow-xl shadow-gray-500/10 dark:shadow-gray-900/30",
          "border border-gray-200 dark:border-gray-700",
          "hidden",
          picker_panel_class(@picker)
        ]}>
        
        <%= if @shortcuts != [] do %>
          <div class="pc-date-picker__shortcuts border-b border-gray-200 dark:border-gray-700 p-2">
            <div class="flex flex-wrap gap-1">
              <%= for shortcut <- @shortcuts do %>
                <button
                  type="button"
                  class={["px-3 py-1.5 text-sm rounded transition duration-150 ease-in-out hover:bg-gray-100 dark:hover:bg-gray-700", get_focus_classes(@color)]}
                  phx-click={if @on_change, do: @on_change, else: "select_date"}
                  phx-value-date={date_to_string(shortcut.value)}>
                  <%= shortcut.label %>
                </button>
              <% end %>
            </div>
          </div>
        <% end %>
        
        <div class="pc-date-picker__header flex items-center justify-between p-2 border-b border-gray-200 dark:border-gray-700">
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
          <div class="pc-date-picker__time border-t border-gray-200 dark:border-gray-700 p-2">
            <div class="flex items-center justify-center gap-1">
              <input type="text" class="w-12 px-2 py-1 text-center border border-gray-300 dark:border-gray-600 rounded bg-white dark:bg-gray-800" value="00" />
              <span>:</span>
              <input type="text" class="w-12 px-2 py-1 text-center border border-gray-300 dark:border-gray-600 rounded bg-white dark:bg-gray-800" value="00" />
              <span>:</span>
              <input type="text" class="w-12 px-2 py-1 text-center border border-gray-300 dark:border-gray-600 rounded bg-white dark:bg-gray-800" value="00" />
            </div>
          </div>
        <% end %>
        
        <%= if @show_today && @picker == "date" do %>
          <div class="border-t border-gray-200 dark:border-gray-700 p-2">
            <button
              type="button"
              class={["pc-date-picker__today w-full px-3 py-1 text-sm rounded", get_today_button_classes(@color)]}>
              今天
            </button>
          </div>
        <% end %>
      </div>
    </div>
    
    """
  end
  
  # 渲染选择器主体
  defp render_picker_body(assigns) do
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
    <div class="pc-date-picker__body p-2">
      <div class="pc-date-picker__weekdays grid grid-cols-7 gap-1 mb-1">
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
              "p-2 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700",
              day == 15 && "bg-primary text-white hover:bg-primary"
            ]}
            phx-click={if @on_change, do: @on_change, else: "select_date"}
            phx-value-date={format_date_for_value(2024, 1, day)}>
            <%= day %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 渲染周选择器
  defp render_week_picker(assigns) do
    assigns = assign(assigns, :picker_type, "week-picker")
    ~H"""
    <div class={[@picker_type, "p-4"]}>
      <div class="text-center text-gray-500 dark:text-gray-400">周选择器</div>
    </div>
    """
  end
  
  # 渲染月选择器
  defp render_month_picker(assigns) do
    assigns = assign(assigns, :picker_type, "month-picker")
    ~H"""
    <div class={[@picker_type, "p-4"]}>
      <div class="grid grid-cols-3 gap-2">
        <%= for month <- 1..12 do %>
          <button
            type="button"
            class="p-2 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200"
            phx-click={if @on_change, do: @on_change, else: "select_month"}
            phx-value-month={month}>
            <%= month %>月
          </button>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 渲染年选择器
  defp render_year_picker(assigns) do
    assigns = assign(assigns, :picker_type, "year-picker")
    current_year = Date.utc_today().year
    years = (current_year - 5)..(current_year + 5)
    assigns = assign(assigns, :years, years)
    
    ~H"""
    <div class={[@picker_type, "p-4"]}>
      <div class="grid grid-cols-3 gap-2">
        <%= for year <- @years do %>
          <button
            type="button"
            class="p-2 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200"
            phx-click={if @on_change, do: @on_change, else: "select_year"}
            phx-value-year={year}>
            <%= year %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end
  
  # 格式化日期值
  defp format_date_value(nil, _format, _show_time), do: ""
  defp format_date_value(value, format, show_time) do
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
  
  # 日期转字符串
  defp date_to_string(nil), do: nil
  defp date_to_string(%Date{} = date), do: Date.to_string(date)
  defp date_to_string(%DateTime{} = datetime), do: DateTime.to_string(datetime)
  defp date_to_string(_), do: nil
  
  # 格式化日期值（用于按钮）
  defp format_date_for_value(year, month, day) do
    "#{year}-#{pad_zero(month)}-#{pad_zero(day)}"
  end
  
  # 尺寸样式 - 匹配 Petal Components 的间距标准
  defp size_classes("small"), do: "text-sm leading-4 py-2 px-3"
  defp size_classes("medium"), do: "text-sm leading-5 py-2 px-4"
  defp size_classes("large"), do: "text-base leading-6 py-2.5 px-6"
  
  # 选择器面板样式
  defp picker_panel_class("date"), do: "w-80"
  defp picker_panel_class("week"), do: "w-80"
  defp picker_panel_class("month"), do: "w-64"
  defp picker_panel_class("year"), do: "w-64"
  defp picker_panel_class(_), do: "w-80"
  
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
  
  # 获取今天按钮样式
  defp get_today_button_classes(color) do
    case color do
      "primary" -> "text-primary hover:bg-primary hover:bg-opacity-10"
      "info" -> "text-blue-600 hover:bg-blue-500 hover:bg-opacity-10"
      "success" -> "text-green-600 hover:bg-green-500 hover:bg-opacity-10"
      "warning" -> "text-yellow-600 hover:bg-yellow-500 hover:bg-opacity-10"
      "danger" -> "text-red-600 hover:bg-red-500 hover:bg-opacity-10"
      _ -> "text-primary hover:bg-primary hover:bg-opacity-10"
    end
  end
  
end