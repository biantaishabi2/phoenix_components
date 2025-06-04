# Tag 标签组件

## 概述
用于标记和分类的小型标签组件。Tag组件是一个轻量级的标记元素，常用于显示状态、分类、属性等信息。

## 何时使用
- 标记事物的属性和维度
- 进行分类和筛选的标识
- 显示状态信息（如：已完成、进行中、已过期）
- 作为紧凑的信息展示方式

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| color | 标签颜色 | string | "default" | 1.0 |
| size | 标签尺寸 | string | "medium" | 1.0 |
| closable | 是否可关闭 | boolean | false | 1.0 |
| on_close | 关闭时的回调 | JS | nil | 1.0 |
| icon | 标签图标 | slot | nil | 1.0 |
| bordered | 是否有边框 | boolean | true | 1.0 |
| class | 自定义CSS类 | string | "" | 1.0 |

### 颜色值
| 值 | 说明 | 对应颜色 |
|----|------|---------|
| default | 默认灰色 | gray |
| primary | 主色 | #FD8E25 |
| success | 成功 | green |
| danger | 危险/错误 | red |
| warning | 警告 | yellow |
| info | 信息 | blue |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | text-xs, px-2 py-1 |
| medium | 中等尺寸(默认) | text-sm, px-3 py-1 |
| large | 大尺寸 | text-base, px-4 py-1.5 |

## 代码示例

### 基本使用
```heex
<.tag>标签</.tag>
<.tag color="success">已完成</.tag>
<.tag color="danger">已过期</.tag>
<.tag color="warning">待处理</.tag>
```

### 不同尺寸
```heex
<.tag size="small">小标签</.tag>
<.tag size="medium">中等标签</.tag>
<.tag size="large">大标签</.tag>
```

### 可关闭标签
```heex
<.tag closable on_close={JS.push("remove_tag", value: %{id: @tag.id})}>
  可关闭的标签
</.tag>
```

### 带图标的标签
```heex
<.tag color="primary">
  <:icon>
    <.icon name="hero-check-circle-mini" class="w-3 h-3" />
  </:icon>
  已认证
</.tag>
```

### 无边框标签
```heex
<.tag bordered={false} color="info">
  无边框
</.tag>
```

### 在表格中使用
```heex
# 订单状态展示
<.table>
  <:col :let={order} label="状态">
    <.tag color={get_status_color(order.status)}>
      <%= get_status_text(order.status) %>
    </.tag>
  </:col>
</.table>

# 辅助函数
defp get_status_color(status) do
  case status do
    "completed" -> "success"
    "pending" -> "warning"
    "cancelled" -> "danger"
    _ -> "default"
  end
end
```

### 标签组
```heex
<div class="flex flex-wrap gap-2">
  <.tag :for={tag <- @tags} 
        closable 
        on_close={JS.push("remove_tag", value: %{id: tag.id})}>
    <%= tag.name %>
  </.tag>
</div>
```

### 动态添加标签
```heex
<form phx-submit="add_tag">
  <div class="flex gap-2">
    <input type="text" name="tag_name" placeholder="输入标签名" />
    <.button type="submit">添加</.button>
  </div>
</form>

<div class="mt-4 flex flex-wrap gap-2">
  <.tag :for={tag <- @tags} 
        closable 
        on_close={JS.push("remove_tag", value: %{id: tag.id})}>
    <%= tag %>
  </.tag>
</div>
```

## 样式定制

### 自定义颜色
```heex
<.tag class="bg-purple-100 text-purple-800 border-purple-200">
  自定义颜色
</.tag>
```

### 自定义大小
```heex
<!-- 小号 -->
<.tag class="text-xs py-0 px-1.5">小标签</.tag>

<!-- 大号 -->
<.tag class="text-base py-1 px-4">大标签</.tag>
```

## 与Vue版本对比

### 属性映射
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `<a-tag>` | `<.tag>` | 组件名称 |
| `:color="red"` | `color="danger"` | 颜色属性 |
| `:closable="true"` | `closable` | 可关闭 |
| `@close="handle"` | `on_close={JS.push("handle")}` | 关闭事件 |
| `v-if="visible"` | `:if={@visible}` | 条件渲染 |

### 迁移示例

Vue代码：
```vue
<a-tag 
  :color="record.status === 'active' ? 'green' : 'red'"
  closable
  @close="removeTag(record.id)">
  {{ record.name }}
</a-tag>
```

Phoenix代码：
```heex
<.tag 
  color={if @record.status == "active", do: "success", else: "danger"}
  closable
  on_close={JS.push("remove_tag", value: %{id: @record.id})}>
  <%= @record.name %>
</.tag>
```

## 注意事项

1. **颜色一致性**：确保使用预定义的颜色值，保持视觉一致性
2. **可访问性**：标签应有足够的对比度，确保可读性
3. **性能考虑**：大量标签时考虑使用虚拟列表
4. **事件处理**：关闭事件需要在LiveView中处理

## 相关组件
- Badge 徽标 - 用于显示数字或状态点
- Label 标签 - 用于表单字段标注
- Chip 纸片 - Material Design风格的标签