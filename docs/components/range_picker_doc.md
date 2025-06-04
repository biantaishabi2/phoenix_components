# RangePicker 范围选择器组件

## 概述
日期范围选择器，用于选择一个时间范围。

## 何时使用
- 需要选择日期范围时
- 查询时间段内的数据
- 设置有效期范围
- 活动时间段选择

## 特性
- 支持日期范围选择
- 支持时间范围选择  
- 支持不同的选择器类型（日/周/月/季/年）
- 支持快捷选项（今天、本周、本月等）
- 支持禁用特定日期
- 支持自定义格式
- 支持清除功能
- 支持预设范围

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| id | 选择器唯一标识 | string | 必填 |
| name | 表单字段名 | string | nil |
| value | 当前选中的日期范围 [开始日期, 结束日期] | list | nil |
| format | 日期格式 | string | "YYYY-MM-DD" |
| separator | 范围分隔符 | string | " ~ " |
| placeholder | 占位文字 | list | ["开始日期", "结束日期"] |
| disabled | 是否禁用 | boolean | false |
| size | 尺寸 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| picker | 选择器类型 | string (date/week/month/quarter/year) | "date" |
| show_time | 是否显示时间选择 | boolean | false |
| disabled_date | 不可选择的日期函数 | function | nil |
| clearable | 是否可清除 | boolean | true |
| ranges | 预设时间范围 | list | [] |
| class | 自定义CSS类 | string | "" |
| on_change | 日期改变时的回调 | JS | %JS{} |
| on_clear | 清除日期时的回调 | JS | %JS{} |
| rest | 其他HTML属性 | global | - |

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
| info | 信息色 | 信息类组件 |
| success | 成功色 | 成功状态组件 |
| warning | 警告色 | 警告状态组件 |
| danger | 危险色 | 错误状态组件 |

### 示例

#### 基本使用
```heex
<.range_picker 
  id="date-range"
  name="date_range"
  placeholder={["开始日期", "结束日期"]}
/>
```

#### 带时间的范围选择
```heex
<.range_picker 
  id="datetime-range"
  show_time={true}
  format="YYYY-MM-DD HH:mm:ss"
  placeholder={["开始时间", "结束时间"]}
/>
```

#### 预设范围
```heex
<.range_picker 
  id="preset-range"
  ranges={[
    %{label: "今天", value: [Date.utc_today(), Date.utc_today()]},
    %{label: "最近7天", value: [Date.add(Date.utc_today(), -6), Date.utc_today()]},
    %{label: "最近30天", value: [Date.add(Date.utc_today(), -29), Date.utc_today()]},
    %{label: "本月", value: [Date.beginning_of_month(Date.utc_today()), Date.end_of_month(Date.utc_today())]}
  ]}
/>
```

#### 不同选择器类型
```heex
<!-- 周选择器 -->
<.range_picker 
  id="week-range"
  picker="week"
  placeholder={["开始周", "结束周"]}
/>

<!-- 月选择器 -->
<.range_picker 
  id="month-range"
  picker="month"
  placeholder={["开始月", "结束月"]}
/>

<!-- 年选择器 -->
<.range_picker 
  id="year-range"
  picker="year"
  placeholder={["开始年", "结束年"]}
/>
```

#### 禁用日期
```heex
<.range_picker 
  id="disabled-range"
  disabled_date={fn date -> Date.compare(date, Date.utc_today()) == :gt end}
/>
```

#### 自定义分隔符和格式
```heex
<.range_picker 
  id="custom-range"
  format="YYYY年MM月DD日"
  separator=" 至 "
  placeholder={["开始日期", "结束日期"]}
/>
```

#### 事件处理
```heex
<.range_picker 
  id="event-range"
  on_change={JS.push("date_range_changed")}
  on_clear={JS.push("date_range_cleared")}
/>
```

## 设计规范
- 参考 Ant Design RangePicker 组件
- 支持键盘导航
- 支持快捷键操作
- 响应式设计
- 无障碍访问支持

## 与DatePicker的区别
- RangePicker选择的是日期范围，返回[开始日期, 结束日期]
- DatePicker选择的是单个日期
- RangePicker有两个输入框和范围分隔符
- RangePicker支持预设范围快捷选项

## 注意事项
- 开始日期不能大于结束日期
- 清除操作会同时清除开始和结束日期
- 时间格式需要和show_time属性保持一致
- 预设范围的值必须是有效的日期范围数组