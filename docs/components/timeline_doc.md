# Timeline 时间线组件

## 概述

Timeline 时间线组件用于展示按时间顺序排列的活动或事件，常用于历史记录、操作日志、流程追踪等场景。

## 特性

- 🕒 **时间顺序展示** - 支持正序和倒序排列
- 📍 **多种节点类型** - 支持点状、图标、自定义节点
- 🎨 **丰富的样式** - 支持不同颜色、尺寸主题
- 📱 **响应式设计** - 适配各种屏幕尺寸
- ⚡ **事件交互** - 支持点击事件处理
- 🔄 **状态支持** - 支持成功、警告、错误等状态
- 📝 **富文本内容** - 支持标题、描述、时间戳等
- 🔗 **可扩展** - 支持自定义内容区域

## 与 Vue 版本对比

| 特性 | Vue 版本 | Phoenix LiveView 版本 |
|------|----------|----------------------|
| 基础时间线 | ✅ | ✅ |
| 自定义节点 | ✅ | ✅ |
| 颜色主题 | ✅ | ✅ |
| 交互事件 | ✅ | ✅ (LiveView 事件) |
| 响应式 | ✅ | ✅ (Tailwind CSS) |
| 无限滚动 | ✅ | ✅ (LiveView 分页) |

## API 参考

### Props

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | `string` | 必需 | 组件唯一标识 |
| `items` | `list` | `[]` | 时间线数据项 |
| `reverse` | `boolean` | `false` | 是否倒序显示 |
| `mode` | `string` | `"left"` | 时间线模式：`left`、`right`、`alternate` |
| `pending` | `boolean` | `false` | 是否显示加载中状态 |
| `pending_dot` | `string` | `nil` | 加载状态的节点内容 |
| `size` | `string` | `"medium"` | 尺寸：`small`、`medium`、`large` |
| `color` | `string` | `"primary"` | 主题色：`primary`、`success`、`warning`、`danger`、`info` |
| `class` | `string` | `""` | 自定义CSS类名 |
| `on_item_click` | `string` | `nil` | 点击时间线项时的事件名 |

### Items 数据结构

```elixir
%{
  id: "unique_id",           # 项目唯一标识
  title: "事件标题",          # 主标题
  description: "详细描述",    # 描述内容
  time: "2024-01-01 12:00",  # 时间戳
  color: "success",          # 节点颜色
  dot: "hero-check",         # 节点图标
  status: "completed",       # 状态标识
  extra: %{}                 # 额外数据
}
```

## 使用示例

### 基础用法

```heex
<.timeline 
  id="basic-timeline"
  items={@timeline_items}
/>
```

### 自定义颜色和尺寸

```heex
<.timeline 
  id="custom-timeline"
  items={@timeline_items}
  color="success"
  size="large"
/>
```

### 交替模式

```heex
<.timeline 
  id="alternate-timeline"
  items={@timeline_items}
  mode="alternate"
/>
```

### 倒序显示

```heex
<.timeline 
  id="reverse-timeline"
  items={@timeline_items}
  reverse={true}
/>
```

### 加载状态

```heex
<.timeline 
  id="loading-timeline"
  items={@timeline_items}
  pending={true}
  pending_dot="加载中..."
/>
```

### 交互事件

```heex
<.timeline 
  id="interactive-timeline"
  items={@timeline_items}
  on_item_click="timeline_item_clicked"
/>
```

## 样式定制

### 默认样式类

```css
.timeline {
  @apply relative pl-8;
}

.timeline-item {
  @apply relative pb-8 last:pb-0;
}

.timeline-dot {
  @apply absolute left-0 top-0 flex items-center justify-center w-3 h-3 rounded-full border-2;
}

.timeline-line {
  @apply absolute left-1.5 top-3 w-0.5 h-full bg-gray-200;
}

.timeline-content {
  @apply ml-6 pt-0;
}
```

### 颜色主题

- **Primary**: 蓝色主题，适用于一般信息
- **Success**: 绿色主题，适用于成功状态
- **Warning**: 橙色主题，适用于警告信息
- **Danger**: 红色主题，适用于错误状态
- **Info**: 灰色主题，适用于中性信息

## 使用场景

1. **操作日志** - 显示用户操作历史
2. **订单状态** - 展示订单处理流程
3. **版本历史** - 显示版本更新记录
4. **消息时间线** - 展示聊天或通知历史
5. **项目里程碑** - 显示项目进展节点
6. **审批流程** - 展示审批历史和状态

## 最佳实践

1. **数据排序** - 确保数据按时间顺序排列
2. **合理分页** - 对于大量数据使用分页加载
3. **状态区分** - 使用不同颜色区分不同状态
4. **信息层次** - 合理使用标题和描述展示信息
5. **交互反馈** - 为可点击项提供明确的视觉反馈
6. **响应式适配** - 在小屏幕上考虑布局调整

## 注意事项

- 时间线项目数量过多时建议使用分页或虚拟滚动
- 自定义图标需确保 Heroicons 中存在对应图标
- 交互事件需要在 LiveView 中定义对应的事件处理器
- 颜色主题需要与项目整体设计保持一致