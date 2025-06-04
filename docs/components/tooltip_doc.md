# Tooltip 文字提示组件文档

## 组件概述

Tooltip 文字提示组件用于在鼠标悬停时显示额外的信息，常用于解释、提示或补充说明。支持多种方向、触发方式和自定义样式。

## API 参考

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| id | :string | 必需 | 组件唯一标识符 |
| title | :string | "" | 提示内容 |
| placement | :string | "top" | 位置，可选值："top", "top-start", "top-end", "bottom", "bottom-start", "bottom-end", "left", "left-start", "left-end", "right", "right-start", "right-end" |
| trigger | :string | "hover" | 触发方式，可选值："hover", "click", "focus" |
| visible | :boolean | nil | 手动控制显示状态 |
| color | :string | nil | 背景颜色 |
| arrow_point_at_center | :boolean | false | 箭头是否指向目标元素中心 |
| mouse_enter_delay | :integer | 100 | 鼠标移入后延时多少毫秒显示（毫秒） |
| mouse_leave_delay | :integer | 100 | 鼠标移出后延时多少毫秒隐藏（毫秒） |
| overlay_class | :string | "" | 卡片样式类名 |
| overlay_style | :string | "" | 卡片样式 |
| z_index | :integer | 1070 | 设置 Tooltip 的 z-index |
| disabled | :boolean | false | 是否禁用 |
| class | :string | "" | 自定义 CSS 类 |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| inner_block | 触发 Tooltip 显示的元素 |
| content | 自定义提示内容（优先级高于 title 属性） |

## 使用示例

### 基础用法

```elixir
<.tooltip id="basic-tooltip" title="这是一个提示">
  <span>悬停查看提示</span>
</.tooltip>

<.tooltip id="click-tooltip" title="点击触发的提示" trigger="click">
  <.button>点击我</.button>
</.tooltip>
```

### 不同位置

```elixir
<.tooltip id="top-tooltip" title="上方提示" placement="top">
  <.button>上方</.button>
</.tooltip>

<.tooltip id="left-tooltip" title="左侧提示" placement="left">
  <.button>左侧</.button>
</.tooltip>

<.tooltip id="bottom-tooltip" title="下方提示" placement="bottom">
  <.button>下方</.button>
</.tooltip>

<.tooltip id="right-tooltip" title="右侧提示" placement="right">
  <.button>右侧</.button>
</.tooltip>
```

### 12个方向

```elixir
<div class="grid grid-cols-3 gap-2">
  <.tooltip id="tl" title="提示内容" placement="top-start">
    <.button class="w-full">TL</.button>
  </.tooltip>
  
  <.tooltip id="top" title="提示内容" placement="top">
    <.button class="w-full">Top</.button>
  </.tooltip>
  
  <.tooltip id="tr" title="提示内容" placement="top-end">
    <.button class="w-full">TR</.button>
  </.tooltip>
  
  <!-- 更多位置... -->
</div>
```

### 自定义内容

```elixir
<.tooltip id="custom-content">
  <:content>
    <div class="text-sm">
      <p class="font-semibold">自定义标题</p>
      <p class="text-gray-300">这是一段自定义的内容</p>
    </div>
  </:content>
  <.button>复杂内容</.button>
</.tooltip>
```

### 自定义颜色

```elixir
<.tooltip id="pink-tooltip" title="粉色提示" color="#eb2f96">
  <.button>粉色</.button>
</.tooltip>

<.tooltip id="custom-style" title="自定义样式" overlay_class="custom-tooltip">
  <.button>自定义样式</.button>
</.tooltip>
```

### 控制显示

```elixir
defmodule MyLiveView do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tooltip_visible: false)}
  end

  def handle_event("toggle_tooltip", _params, socket) do
    {:noreply, update(socket, :tooltip_visible, &(!&1))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tooltip 
        id="controlled" 
        title="受控的提示" 
        visible={@tooltip_visible}
        trigger="click"
      >
        <.button phx-click="toggle_tooltip">
          点击切换提示
        </.button>
      </.tooltip>
    </div>
    """
  end
end
```

### 延迟显示隐藏

```elixir
<.tooltip 
  id="delay-tooltip" 
  title="延迟显示和隐藏" 
  mouse_enter_delay={1000}
  mouse_leave_delay={1000}
>
  <span>悬停1秒后显示，移开1秒后隐藏</span>
</.tooltip>
```

### 禁用状态

```elixir
<.tooltip id="disabled-tooltip" title="这个提示被禁用了" disabled={true}>
  <span>提示已禁用</span>
</.tooltip>
```

### 箭头指向中心

```elixir
<.tooltip 
  id="arrow-center" 
  title="箭头指向元素中心" 
  arrow_point_at_center={true}
  placement="top-start"
>
  <.button class="w-40">很长的按钮</.button>
</.tooltip>
```

## 实际应用场景

### 表单字段说明

```elixir
<.form for={@form} phx-change="validate" phx-submit="save">
  <div class="mb-4">
    <label class="flex items-center gap-1">
      用户名
      <.tooltip id="username-tip" title="用户名必须是3-20个字符，只能包含字母、数字和下划线">
        <.icon name="hero-question-mark-circle" class="w-4 h-4 text-gray-400" />
      </.tooltip>
    </label>
    <.input field={@form[:username]} type="text" />
  </div>
</div>
```

### 操作按钮提示

```elixir
<div class="flex gap-2">
  <.tooltip id="edit-tip" title="编辑">
    <.button variant="ghost" size="sm">
      <.icon name="hero-pencil" class="w-4 h-4" />
    </.button>
  </.tooltip>
  
  <.tooltip id="delete-tip" title="删除" placement="bottom">
    <.button variant="ghost" size="sm" class="text-red-500">
      <.icon name="hero-trash" class="w-4 h-4" />
    </.button>
  </.tooltip>
</div>
```

### 文本省略提示

```elixir
def text_with_tooltip(assigns) do
  ~H"""
  <.tooltip id={@id} title={@text} disabled={String.length(@text) <= @max_length}>
    <span class="truncate max-w-xs">
      <%= if String.length(@text) > @max_length do %>
        <%= String.slice(@text, 0, @max_length) <> "..." %>
      <% else %>
        <%= @text %>
      <% end %>
    </span>
  </.tooltip>
  """
end
```

### 状态指示器

```elixir
<div class="flex items-center gap-2">
  <.tooltip id="online" title="在线">
    <div class="w-3 h-3 bg-green-500 rounded-full"></div>
  </.tooltip>
  
  <.tooltip id="busy" title="忙碌">
    <div class="w-3 h-3 bg-yellow-500 rounded-full"></div>
  </.tooltip>
  
  <.tooltip id="offline" title="离线">
    <div class="w-3 h-3 bg-gray-400 rounded-full"></div>
  </.tooltip>
</div>
```

## 样式定制

### 自定义主题

```css
/* 深色主题 */
.dark-tooltip {
  @apply bg-gray-900 text-white;
}

.dark-tooltip .tooltip-arrow {
  @apply border-gray-900;
}

/* 渐变背景 */
.gradient-tooltip {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

### 动画效果

```css
@keyframes tooltip-fade-in {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.tooltip-content {
  animation: tooltip-fade-in 0.2s ease-out;
}
```

## 与 Vue 版本的对比

| 特性 | Vue (Ant Design) | Phoenix |
|------|------------------|----------|
| 位置 | placement 属性 | placement 属性 |
| 触发方式 | trigger 属性 | trigger 属性 |
| 自定义内容 | slot | content 插槽 |
| 延迟 | mouseEnterDelay/mouseLeaveDelay | mouse_enter_delay/mouse_leave_delay |
| 控制显示 | v-model:visible | visible + 事件处理 |
| 箭头位置 | arrowPointAtCenter | arrow_point_at_center |

## 实现细节

### 定位算法

组件使用 JavaScript 钩子来计算提示框的位置：

```javascript
Hooks.Tooltip = {
  mounted() {
    this.setupTooltip();
  },
  
  updated() {
    this.setupTooltip();
  },
  
  setupTooltip() {
    const trigger = this.el.querySelector('[data-tooltip-trigger]');
    const content = this.el.querySelector('[data-tooltip-content]');
    const placement = this.el.dataset.placement || 'top';
    
    // 计算位置逻辑...
  }
}
```

### 无障碍性

- 使用 `role="tooltip"` 标记提示内容
- 通过 `aria-describedby` 关联触发元素和提示内容
- 支持键盘导航（focus 触发）
- 提供适当的 ARIA 属性

## 注意事项

1. **唯一 ID**: 每个 Tooltip 必须有唯一的 id
2. **性能**: 大量 Tooltip 时考虑使用单例模式
3. **移动端**: 移动设备上 hover 触发可能不工作，建议使用 click
4. **内容更新**: 动态内容需要触发组件更新
5. **z-index**: 确保 Tooltip 的 z-index 高于其他浮层组件

## 常见问题

### Tooltip 不显示？
检查是否设置了唯一的 id，以及触发元素是否正确渲染。

### 位置不正确？
确保父容器没有 `overflow: hidden`，可能需要调整 z-index。

### 如何在表格中使用？
建议使用单例模式，避免创建过多 DOM 元素。

### 如何自定义动画？
通过 overlay_class 添加自定义类，然后定义 CSS 动画。