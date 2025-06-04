# StatusBadge 状态徽章组件

## 组件概述

StatusBadge 组件用于展示各种状态信息，如订单状态、用户状态、审核状态等。它提供了一致的视觉样式来表示不同的状态，支持多种预设状态类型和自定义配置。

## 特性

- 支持多种预设状态类型（成功、警告、错误、处理中等）
- 可自定义颜色和文本
- 支持显示状态点（dot）或完整徽章
- 支持图标前缀
- 响应式设计
- 支持自定义样式
- 内置常见业务状态配置

## API

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| text | string | - | 必填，状态文本 |
| type | string | "default" | 状态类型，可选值见下表 |
| color | string | nil | 自定义颜色，会覆盖 type 的颜色 |
| dot | boolean | false | 是否只显示小圆点 |
| size | string | "medium" | 尺寸，可选值："small", "medium", "large" |
| bordered | boolean | true | 是否显示边框 |
| icon | string | nil | 图标名称（hero-icon） |
| class | string | "" | 自定义 CSS 类 |
| rest | global | - | 其他 HTML 属性 |

### 状态类型 (Type)

| 类型 | 说明 | 颜色 |
|------|------|------|
| default | 默认 | 灰色 |
| success | 成功 | 绿色 |
| processing | 处理中 | 蓝色 |
| warning | 警告 | 黄色 |
| error | 错误 | 红色 |
| info | 信息 | 蓝色 |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| inner_block | 自定义内容，会替换默认的文本显示 |

## 使用示例

### 基础用法

```elixir
<.status_badge text="已完成" type="success" />
<.status_badge text="处理中" type="processing" />
<.status_badge text="已取消" type="error" />
<.status_badge text="待审核" type="warning" />
```

### 带图标

```elixir
<.status_badge 
  text="已发货" 
  type="success" 
  icon="hero-truck" 
/>

<.status_badge 
  text="待付款" 
  type="warning" 
  icon="hero-credit-card" 
/>
```

### 只显示状态点

```elixir
<div class="flex items-center gap-2">
  <.status_badge type="success" dot />
  <span>在线</span>
</div>

<div class="flex items-center gap-2">
  <.status_badge type="error" dot />
  <span>离线</span>
</div>
```

### 自定义颜色

```elixir
<.status_badge text="VIP" color="purple" />
<.status_badge text="热销" color="orange" />
<.status_badge text="新品" color="pink" />
```

### 不同尺寸

```elixir
<.status_badge text="小尺寸" type="info" size="small" />
<.status_badge text="中等尺寸" type="info" size="medium" />
<.status_badge text="大尺寸" type="info" size="large" />
```

### 无边框样式

```elixir
<.status_badge text="标签样式" type="success" bordered={false} />
<.status_badge text="填充样式" type="warning" bordered={false} />
```

### 业务场景示例

#### 订单状态

```elixir
defmodule MyApp.OrderHelpers do
  def order_status_badge(status) do
    {text, type} = case status do
      "pending" -> {"待付款", "warning"}
      "paid" -> {"已付款", "info"}
      "shipped" -> {"已发货", "processing"}
      "completed" -> {"已完成", "success"}
      "cancelled" -> {"已取消", "error"}
      "refunding" -> {"退款中", "warning"}
      _ -> {status, "default"}
    end
    
    assigns = %{text: text, type: type}
    ~H"""
    <.status_badge text={@text} type={@type} />
    """
  end
end
```

#### 用户状态

```elixir
<.status_badge text="正常" type="success" icon="hero-check-circle" />
<.status_badge text="已禁用" type="error" icon="hero-x-circle" />
<.status_badge text="待验证" type="warning" icon="hero-exclamation-circle" />
```

#### 商品状态

```elixir
<.status_badge text="在售" type="success" />
<.status_badge text="缺货" type="error" />
<.status_badge text="下架" type="default" />
<.status_badge text="预售" type="processing" />
```

#### 审核状态

```elixir
<.status_badge text="待审核" type="warning" icon="hero-clock" />
<.status_badge text="审核通过" type="success" icon="hero-check" />
<.status_badge text="审核拒绝" type="error" icon="hero-x-mark" />
```

### 在表格中使用

```elixir
<.table rows={@orders}>
  <:col :let={order} label="订单号">
    <%= order.number %>
  </:col>
  <:col :let={order} label="状态">
    <.status_badge text={order.status_text} type={order.status_type} />
  </:col>
  <:col :let={order} label="金额">
    ¥<%= order.amount %>
  </:col>
</.table>
```

### 组合使用

```elixir
<div class="flex items-center gap-4">
  <.status_badge text="库存" type="info" />
  <span class="text-2xl font-bold">128</span>
  <.status_badge text="-12%" type="error" size="small" />
</div>
```

## 与 Vue 版本的对比

| Vue/Ant Design | Phoenix | 说明 |
|----------------|---------|------|
| `<a-tag>` | `<.status_badge>` | 组件名称 |
| `:color` | `type` 或 `color` | 颜色配置 |
| `v-if` | `:if` | 条件渲染 |
| `icon` slot | `icon` 属性 | 图标配置 |
| `closable` | 不支持 | 使用 Tag 组件实现可关闭功能 |

## 最佳实践

1. **语义化使用**：优先使用 `type` 属性的预设值，它们具有明确的语义
2. **一致性**：在整个应用中保持状态颜色的一致性
3. **可访问性**：确保颜色对比度足够，不要仅依赖颜色传达信息
4. **文本清晰**：状态文本应该简洁明了，避免过长
5. **图标辅助**：适当使用图标可以增强状态的识别度

## 注意事项

1. **颜色对比**：确保文本和背景色有足够的对比度
2. **响应式**：在移动端注意徽章的可读性
3. **国际化**：状态文本应支持多语言
4. **性能**：大量徽章时考虑使用虚拟滚动
5. **一致性**：同一类状态在不同页面应保持相同的样式

## 相关组件

- Tag：可关闭的标签组件
- Badge：数字徽章组件
- Tooltip：可配合使用显示更多信息