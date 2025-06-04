# Progress 进度条组件文档

## 组件概述

Progress 进度条组件用于展示操作的当前进度，常用于文件上传、数据处理、密码强度等场景。支持线形和环形两种类型，以及多种状态样式。

## API 参考

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| type | :string | "line" | 进度条类型，可选值："line", "circle" |
| percent | :integer | 0 | 百分比（0-100） |
| status | :string | "normal" | 状态，可选值："normal", "active", "success", "exception" |
| size | :string | "medium" | 尺寸，可选值："small", "medium", "large" |
| show_info | :boolean | true | 是否显示进度数值或状态图标 |
| stroke_width | :integer | 线形：8，环形：6 | 进度条线的宽度（像素） |
| stroke_color | :string | nil | 进度条的色彩，会覆盖 status 状态下的默认颜色 |
| trail_color | :string | nil | 未完成的分段的颜色 |
| format_fn | :function | nil | 内容的格式化函数，接收 percent 参数 |
| width | :integer | 120 | 环形进度条画布宽度（像素），仅 type="circle" 时有效 |
| gap_degree | :integer | 0 | 环形进度条缺口角度，可取值 0 ~ 360，仅 type="circle" 时有效 |
| gap_position | :string | "top" | 环形进度条缺口位置，可选值："top", "bottom", "left", "right" |
| class | :string | "" | 自定义 CSS 类 |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| format | 自定义进度信息内容（优先级高于 format 函数） |

## 使用示例

### 基础用法

```elixir
<.progress percent={30} />

<.progress percent={50} status="active" />

<.progress percent={70} status="exception" />

<.progress percent={100} status="success" />
```

### 不显示进度信息

```elixir
<.progress percent={75} show_info={false} />
```

### 自定义颜色

```elixir
<.progress percent={50} stroke_color="#87d068" />

<.progress percent={30} stroke_color="#ff4d4f" trail_color="#ffe58f" />
```

### 不同尺寸

```elixir
<.progress percent={30} size="small" />
<.progress percent={30} size="medium" />
<.progress percent={30} size="large" />
```

### 自定义格式化

```elixir
<.progress percent={90} format_fn={fn percent -> "#{percent} Days" end} />

<.progress percent={60} format_fn={fn _percent -> "Loading" end} />
```

### 使用插槽自定义内容

```elixir
<.progress percent={80}>
  <:format :let={percent}>
    <span class="text-sm font-medium">
      <%= if percent >= 80 do %>
        <.icon name="hero-check-circle-mini" class="w-4 h-4 text-success" />
      <% else %>
        <%= percent %>%
      <% end %>
    </span>
  </:format>
</.progress>
```

### 环形进度条

```elixir
<.progress type="circle" percent={75} />

<.progress type="circle" percent={100} status="success" />

<.progress type="circle" percent={70} status="exception" />
```

### 环形进度条尺寸

```elixir
<.progress type="circle" percent={30} width={80} />

<.progress type="circle" percent={30} width={120} />

<.progress type="circle" percent={30} width={160} />
```

### 环形进度条缺口

```elixir
<.progress type="circle" percent={75} gap_degree={90} gap_position="bottom" />

<.progress type="circle" percent={75} gap_degree={180} gap_position="left" />
```

### 动态进度示例

```elixir
defmodule MyLiveView do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, 100)
    {:ok, assign(socket, percent: 0)}
  end

  def handle_info(:tick, socket) do
    percent = min(socket.assigns.percent + 1, 100)
    
    if percent < 100 do
      Process.send_after(self(), :tick, 100)
    end
    
    {:noreply, assign(socket, percent: percent)}
  end

  def render(assigns) do
    ~H"""
    <.progress percent={@percent} status={progress_status(@percent)} />
    """
  end

  defp progress_status(percent) when percent < 100, do: "active"
  defp progress_status(100), do: "success"
end
```

### 密码强度指示器

```elixir
def password_strength_indicator(assigns) do
  ~H"""
  <div>
    <.input type="password" field={@form[:password]} phx-change="check_password" />
    <.progress 
      percent={@password_strength} 
      status={password_status(@password_strength)}
      format={&password_text/1}
    />
  </div>
  """
end

defp password_status(strength) when strength < 40, do: "exception"
defp password_status(strength) when strength < 70, do: "normal"
defp password_status(_), do: "success"

defp password_text(strength) when strength < 40, do: "弱"
defp password_text(strength) when strength < 70, do: "中"
defp password_text(_), do: "强"
```

### 文件上传进度

```elixir
def file_upload_progress(assigns) do
  ~H"""
  <div :for={entry <- @uploads.avatar.entries}>
    <.progress 
      percent={entry.progress} 
      status={if entry.progress < 100, do: "active", else: "success"}
    />
    <p class="text-sm text-gray-600"><%= entry.client_name %></p>
  </div>
  """
end
```

### 批量操作进度

```elixir
<div class="space-y-4">
  <h3 class="font-medium">批量导入进度</h3>
  <.progress 
    percent={@import_progress} 
    status="active"
    format={fn percent -> "已处理 #{@processed_count}/#{@total_count} 条" end}
  />
  <div :if={@import_progress == 100} class="text-success">
    <.icon name="hero-check-circle" class="w-5 h-5 inline" />
    导入完成！
  </div>
</div>
```

## 样式定制

### 自定义渐变色

```elixir
<.progress 
  percent={80} 
  stroke_color="linear-gradient(to right, #108ee9, #87d068)"
/>
```

### 分段进度条

```elixir
def segmented_progress(assigns) do
  ~H"""
  <div class="relative">
    <.progress percent={@percent} show_info={false} />
    <div class="absolute inset-0 flex">
      <div :for={i <- 1..5} class="flex-1 border-r-2 border-white"></div>
    </div>
  </div>
  """
end
```

## 实际应用场景

### 多步骤表单进度

```elixir
<div class="mb-6">
  <div class="flex justify-between mb-2">
    <span class="text-sm text-gray-600">第 <%= @current_step %> 步，共 <%= @total_steps %> 步</span>
    <span class="text-sm font-medium"><%= @progress %>%</span>
  </div>
  <.progress 
    percent={@progress} 
    show_info={false}
    status={if @current_step == @total_steps, do: "success", else: "active"}
  />
</div>
```

### 系统资源监控

```elixir
<div class="space-y-4">
  <div>
    <div class="flex justify-between mb-1">
      <span>CPU 使用率</span>
      <span><%= @cpu_usage %>%</span>
    </div>
    <.progress 
      percent={@cpu_usage} 
      status={cpu_status(@cpu_usage)}
      stroke_color={cpu_color(@cpu_usage)}
    />
  </div>
  
  <div>
    <div class="flex justify-between mb-1">
      <span>内存使用率</span>
      <span><%= @memory_usage %>%</span>
    </div>
    <.progress 
      percent={@memory_usage} 
      status={memory_status(@memory_usage)}
    />
  </div>
</div>
```

## 与 Vue 版本的对比

| 特性 | Vue (Ant Design) | Phoenix |
|------|------------------|----------|
| 类型 | type="line/circle/dashboard" | type="line/circle" |
| 状态 | status="normal/active/success/exception" | 相同 |
| 格式化 | :format 函数 | format 函数或插槽 |
| 渐变色 | :strokeColor 对象 | stroke_color 字符串 |
| 分段显示 | :percent=[30, 50] | 需自定义实现 |
| 动画 | 内置过渡动画 | CSS transition |

## 注意事项

1. **百分比范围**: percent 值应在 0-100 之间，超出范围会自动修正
2. **环形进度条**: 在小尺寸容器中使用时，建议调整 width 属性
3. **性能优化**: 频繁更新进度时，建议使用防抖或节流
4. **无障碍性**: 组件自动添加了 role="progressbar" 和相关 ARIA 属性
5. **响应式设计**: 进度条会自动适应容器宽度

## 常见问题

### 如何实现步进式进度条？
可以结合定时器逐步增加 percent 值，或在特定事件触发时更新。

### 如何实现分段彩色进度条？
使用 CSS 渐变或叠加多个进度条实现。

### 环形进度条如何居中文字？
文字会自动居中显示，可通过 format 插槽自定义样式。

### 如何实现反向进度条？
设置 `dir="rtl"` 属性或使用 CSS transform。