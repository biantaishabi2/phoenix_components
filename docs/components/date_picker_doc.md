# DatePicker 日期选择器组件

## 概述
DatePicker 组件用于选择日期，支持选择日、周、月、季度、年。当用户需要输入一个日期时，可以使用此组件。

## 何时使用
- 当用户需要输入一个日期时
- 需要限制日期范围时
- 需要快速选择常用日期（如今天、昨天、本周等）

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| id | 日期选择器唯一标识 | string | 必需 | 1.0 |
| name | 表单字段名 | string | - | 1.0 |
| value | 当前日期 | Date/string | nil | 1.0 |
| format | 日期格式 | string | "YYYY-MM-DD" | 1.0 |
| placeholder | 占位文字 | string | "请选择日期" | 1.0 |
| disabled | 是否禁用 | boolean | false | 1.0 |
| size | 尺寸 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| picker | 选择器类型 | string | "date" | 1.0 |
| show_time | 是否显示时间选择 | boolean | false | 1.0 |
| disabled_date | 不可选择的日期 | function | - | 1.0 |
| clearable | 是否可清除 | boolean | true | 1.0 |
| show_today | 是否显示今天按钮 | boolean | true | 1.0 |
| class | 自定义CSS类 | string | "" | 1.0 |
| on_change | 日期改变时的回调 | JS | - | 1.0 |
| on_clear | 清除日期时的回调 | JS | - | 1.0 |
| shortcuts | 快捷选项 | list | [] | 1.0 |
| default_value | 默认日期 | Date/string | - | 1.0 |
| min_date | 最小可选日期 | Date/string | - | 1.0 |
| max_date | 最大可选日期 | Date/string | - | 1.0 |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | text-sm, py-2 px-3 |
| medium | 中等尺寸(默认) | text-sm, py-2 px-4 |
| large | 大尺寸 | text-base, py-2.5 px-6 |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 焦点和选中状态 |
| info | 信息色 | 信息类日期选择器 |
| success | 成功色 | 成功状态日期选择器 |
| warning | 警告色 | 警告状态日期选择器 |
| danger | 危险色 | 错误状态日期选择器 |

### 选择器类型 (picker)
- `"date"` - 日期选择器（默认）
- `"week"` - 周选择器
- `"month"` - 月选择器
- `"quarter"` - 季度选择器
- `"year"` - 年选择器

### 日期格式说明
- `YYYY` - 4位年份
- `MM` - 2位月份
- `DD` - 2位日期
- `HH` - 24小时制小时
- `mm` - 分钟
- `ss` - 秒

## 代码示例

### 基础用法
```heex
<.date_picker 
  id="basic-date"
  name="date"
  placeholder="选择日期"
/>
```

### 带默认值
```heex
<.date_picker 
  id="default-date"
  name="birthday"
  value={~D[2024-01-01]}
  format="YYYY-MM-DD"
/>
```

### 显示时间选择
```heex
<.date_picker 
  id="datetime-picker"
  name="appointment"
  show_time
  format="YYYY-MM-DD HH:mm:ss"
  placeholder="选择日期时间"
/>
```

### 限制日期范围
```heex
<.date_picker 
  id="limited-date"
  name="booking_date"
  min_date={Date.utc_today()}
  max_date={Date.add(Date.utc_today(), 30)}
  placeholder="选择未来30天内的日期"
/>

<!-- 或使用函数限制 -->
<.date_picker 
  id="disabled-weekends"
  name="workday"
  disabled_date={&is_weekend?/1}
  placeholder="选择工作日"
/>
```

### 不同的选择器类型
```heex
<!-- 周选择器 -->
<.date_picker 
  id="week-picker"
  picker="week"
  format="YYYY-[W]WW"
  placeholder="选择周"
/>

<!-- 月选择器 -->
<.date_picker 
  id="month-picker"
  picker="month"
  format="YYYY-MM"
  placeholder="选择月份"
/>

<!-- 年选择器 -->
<.date_picker 
  id="year-picker"
  picker="year"
  format="YYYY"
  placeholder="选择年份"
/>
```

### 快捷选项
```heex
<.date_picker 
  id="shortcuts-date"
  name="report_date"
  shortcuts={[
    %{label: "今天", value: Date.utc_today()},
    %{label: "昨天", value: Date.add(Date.utc_today(), -1)},
    %{label: "一周前", value: Date.add(Date.utc_today(), -7)},
    %{label: "一月前", value: Date.add(Date.utc_today(), -30)}
  ]}
/>
```

### 不同尺寸
```heex
<div class="space-y-4">
  <.date_picker 
    id="small-date"
    size="small"
    placeholder="小尺寸"
  />
  
  <.date_picker 
    id="medium-date"
    size="medium"
    placeholder="中等尺寸（默认）"
  />
  
  <.date_picker 
    id="large-date"
    size="large"
    placeholder="大尺寸"
  />
</div>
```

### 禁用状态
```heex
<.date_picker 
  id="disabled-date"
  name="disabled_field"
  value={~D[2024-01-01]}
  disabled
/>
```

### 在表单中使用
```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.date_picker 
    id="birth-date"
    name="user[birth_date]"
    value={@form[:birth_date].value}
    on_change={JS.push("validate")}
    placeholder="出生日期"
  />
  
  <.date_picker 
    id="start-date"
    name="user[start_date]"
    value={@form[:start_date].value}
    show_time
    format="YYYY-MM-DD HH:mm"
    placeholder="开始时间"
  />
  
  <.button type="submit">保存</.button>
</.form>
```

### 处理日期改变
```heex
<.date_picker 
  id="event-date"
  name="event_date"
  on_change={JS.push("date_changed")}
  on_clear={JS.push("date_cleared")}
/>

<!-- 在LiveView中处理 -->
def handle_event("date_changed", %{"value" => date_string}, socket) do
  case Date.from_iso8601(date_string) do
    {:ok, date} ->
      {:noreply, assign(socket, selected_date: date)}
    {:error, _} ->
      {:noreply, socket}
  end
end
```

### 自定义禁用日期逻辑
```elixir
# 在LiveView中定义
defp is_weekend?(date) do
  Date.day_of_week(date) in [6, 7]
end

defp is_holiday?(date) do
  # 检查是否是节假日
  date in @holidays
end

defp is_past_date?(date) do
  Date.compare(date, Date.utc_today()) == :lt
end
```

### 复杂示例：预约系统日期选择
```heex
<div class="appointment-form">
  <h3>选择预约时间</h3>
  
  <.date_picker 
    id="appointment-date"
    name="appointment[date]"
    value={@selected_date}
    min_date={Date.utc_today()}
    max_date={Date.add(Date.utc_today(), 60)}
    disabled_date={&is_fully_booked?/1}
    shortcuts={[
      %{label: "明天", value: Date.add(Date.utc_today(), 1)},
      %{label: "本周末", value: get_this_weekend()},
      %{label: "下周一", value: get_next_monday()}
    ]}
    on_change={JS.push("check_availability")}
    placeholder="选择预约日期"
  />
  
  <%= if @selected_date do %>
    <div class="mt-4">
      <h4>可选时间段</h4>
      <div class="grid grid-cols-4 gap-2">
        <%= for slot <- @available_slots do %>
          <button 
            class={[
              "p-2 border rounded",
              slot.available && "bg-green-50 hover:bg-green-100",
              !slot.available && "bg-gray-100 cursor-not-allowed"
            ]}
            disabled={!slot.available}
            phx-click="select_time"
            phx-value-time={slot.time}>
            <%= slot.time %>
          </button>
        <% end %>
      </div>
    </div>
  <% end %>
</div>
```

## 与Vue版本对比

### 属性映射
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `v-model` | `value` + `on_change` | 双向绑定 |
| `:format` | `format` | 日期格式 |
| `:picker` | `picker` | 选择器类型 |
| `:show-time` | `show_time` | 显示时间 |
| `:disabled-date` | `disabled_date` | 禁用日期函数 |
| `:allow-clear` | `clearable` | 是否可清除 |
| `:default-value` | `default_value` | 默认值 |
| `:ranges` | `shortcuts` | 快捷选项 |

### 迁移示例

Vue代码：
```vue
<a-date-picker
  v-model:value="selectedDate"
  :format="dateFormat"
  :disabled-date="disabledDate"
  show-time
  @change="handleDateChange"
/>
```

Phoenix代码：
```heex
<.date_picker 
  id="my-date"
  value={@selected_date}
  format={@date_format}
  disabled_date={&disabled_date?/1}
  show_time
  on_change={JS.push("handle_date_change")}
/>
```

## 注意事项

1. **日期处理**
   - 使用 Elixir 的 Date/DateTime 模块处理日期
   - 注意时区问题，建议统一使用 UTC
   - 格式化使用 Calendar 或 Timex 库

2. **性能优化**
   - 大量禁用日期时，考虑缓存计算结果
   - 避免在 disabled_date 函数中进行复杂计算

3. **可访问性**
   - 确保键盘导航支持
   - 提供清晰的日期格式提示
   - 支持屏幕阅读器

4. **用户体验**
   - 提供合理的默认值
   - 使用快捷选项提升效率
   - 清晰的错误提示

## 相关组件
- RangePicker 日期范围选择 - 选择日期区间
- TimePicker 时间选择器 - 仅选择时间
- Calendar 日历 - 展示日历视图