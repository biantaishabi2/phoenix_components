# Card 卡片组件文档

## 组件概述

Card 卡片组件是一个通用的内容容器，用于组织和展示信息。它提供了一个带有边框、阴影和内边距的容器，可以包含标题、内容和操作区域。

## API 参考

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title | :string | nil | 卡片标题 |
| size | :string | "medium" | 卡片尺寸，可选值："small", "medium", "large" |
| bordered | :boolean | true | 是否显示边框 |
| hoverable | :boolean | false | 鼠标悬停时是否有阴影效果 |
| loading | :boolean | false | 是否显示加载状态 |
| body_style | :string | "" | 内容区域的自定义样式类 |
| header_class | :string | "" | 标题区域的自定义样式类 |
| class | :string | "" | 卡片容器的自定义 CSS 类 |
| rest | :global | - | 其他 HTML 属性 |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| inner_block | 默认插槽，卡片主体内容 |
| header | 自定义标题区域内容（会覆盖 title 属性） |
| extra | 标题栏右侧的额外内容 |
| actions | 卡片底部的操作区域 |
| cover | 卡片封面，通常用于图片 |

## 使用示例

### 基础用法

```elixir
<.card title="基础卡片">
  <p>这是一个基础的卡片组件。</p>
</.card>
```

### 无边框卡片

```elixir
<.card title="无边框卡片" bordered={false}>
  <p>这个卡片没有边框。</p>
</.card>
```

### 带额外内容的卡片

```elixir
<.card title="订单信息">
  <:extra>
    <.link navigate="/orders/123">更多</.link>
  </:extra>
  
  <p>订单号：ORD-2024-001</p>
  <p>金额：¥299.00</p>
</.card>
```

### 可悬停效果

```elixir
<.card title="可悬停卡片" hoverable>
  <p>鼠标悬停时会有阴影效果。</p>
</.card>
```

### 加载状态

```elixir
<.card title="加载中..." loading>
  <p>内容正在加载...</p>
</.card>
```

### 带操作的卡片

```elixir
<.card title="商品信息">
  <p>商品名称：iPhone 15</p>
  <p>价格：¥5999</p>
  
  <:actions>
    <.button type="primary">编辑</.button>
    <.button>删除</.button>
  </:actions>
</.card>
```

### 带封面的卡片

```elixir
<.card hoverable>
  <:cover>
    <img src="/images/product.jpg" alt="产品图片" />
  </:cover>
  
  <h3 class="text-lg font-semibold">产品名称</h3>
  <p class="text-gray-600">产品描述信息</p>
</.card>
```

### 不同尺寸

```elixir
<!-- 小尺寸 -->
<.card title="小卡片" size="small">
  <p>内容区域较小的卡片。</p>
</.card>

<!-- 中等尺寸（默认） -->
<.card title="中等卡片" size="medium">
  <p>标准尺寸的卡片。</p>
</.card>

<!-- 大尺寸 -->
<.card title="大卡片" size="large">
  <p>内容区域较大的卡片。</p>
</.card>
```

### 自定义样式

```elixir
<.card 
  title="自定义样式" 
  class="bg-blue-50"
  header_class="bg-blue-100"
  body_style="text-blue-900"
>
  <p>这是一个自定义样式的卡片。</p>
</.card>
```

### 嵌套卡片

```elixir
<.card title="父卡片">
  <p>这是父卡片的内容。</p>
  
  <.card title="子卡片" size="small" class="mt-4">
    <p>这是嵌套的子卡片。</p>
  </.card>
</.card>
```

### 完整示例：订单详情卡片

```elixir
<.card title="订单详情" hoverable>
  <:extra>
    <span class="text-sm text-gray-500">订单号：ORD-2024-001</span>
  </:extra>
  
  <div class="space-y-4">
    <div>
      <h4 class="font-semibold">收货信息</h4>
      <p class="text-gray-600">张三 138****5678</p>
      <p class="text-gray-600">北京市朝阳区xxx街道xxx号</p>
    </div>
    
    <div>
      <h4 class="font-semibold">商品信息</h4>
      <div class="flex justify-between py-2">
        <span>iPhone 15 Pro Max</span>
        <span>¥8999 x 1</span>
      </div>
      <div class="flex justify-between py-2">
        <span>保护壳</span>
        <span>¥99 x 2</span>
      </div>
    </div>
    
    <div class="border-t pt-4">
      <div class="flex justify-between font-semibold">
        <span>合计</span>
        <span class="text-lg text-red-600">¥9197</span>
      </div>
    </div>
  </div>
  
  <:actions>
    <.button type="primary">确认收货</.button>
    <.button>查看物流</.button>
    <.button>申请售后</.button>
  </:actions>
</.card>
```

## 实际应用场景

### 信息展示卡片

```elixir
<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
  <.card title="今日订单" hoverable>
    <div class="text-3xl font-bold text-blue-600">128</div>
    <p class="text-gray-500">较昨日 +12%</p>
  </.card>
  
  <.card title="营业额" hoverable>
    <div class="text-3xl font-bold text-green-600">¥28,459</div>
    <p class="text-gray-500">较昨日 +8%</p>
  </.card>
  
  <.card title="新增用户" hoverable>
    <div class="text-3xl font-bold text-purple-600">56</div>
    <p class="text-gray-500">较昨日 +23%</p>
  </.card>
</div>
```

### 表单卡片

```elixir
<.card title="基本信息">
  <.form for={@form} phx-submit="save">
    <div class="space-y-4">
      <.input field={@form[:name]} label="姓名" />
      <.input field={@form[:email]} label="邮箱" type="email" />
      <.input field={@form[:phone]} label="电话" />
    </div>
    
    <:actions>
      <.button type="submit" phx-disable-with="保存中...">保存</.button>
      <.button type="button" phx-click="cancel">取消</.button>
    </:actions>
  </.form>
</.card>
```

### 列表卡片

```elixir
<.card title="最新订单" loading={@loading}>
  <:extra>
    <.link navigate="/orders">查看全部</.link>
  </:extra>
  
  <div class="space-y-2">
    <%= for order <- @recent_orders do %>
      <div class="flex justify-between py-2 border-b">
        <div>
          <div class="font-medium"><%= order.number %></div>
          <div class="text-sm text-gray-500"><%= order.customer %></div>
        </div>
        <div class="text-right">
          <div class="font-medium">¥<%= order.amount %></div>
          <div class="text-sm text-gray-500"><%= order.status %></div>
        </div>
      </div>
    <% end %>
  </div>
</.card>
```

## 与 Vue 版本的对比

| 特性 | Vue (Ant Design) | Phoenix |
|------|------------------|----------|
| 基本用法 | `<a-card>` | `<.card>` |
| 标题 | `:title="标题"` | `title="标题"` |
| 边框 | `:bordered="false"` | `bordered={false}` |
| 悬停效果 | `:hoverable="true"` | `hoverable` |
| 加载状态 | `:loading="true"` | `loading` |
| 额外内容 | `<template #extra>` | `<:extra>` |
| 操作区域 | `<template #actions>` | `<:actions>` |
| 自定义样式 | `:bodyStyle="{}"` | `body_style=""` |

## 注意事项

1. **性能考虑**: 当在列表中使用大量卡片时，考虑使用虚拟滚动或分页
2. **响应式设计**: 卡片会自动适应容器宽度，但建议配合栅格系统使用
3. **嵌套使用**: 避免过深的嵌套，通常不超过两层
4. **加载状态**: 加载状态下会显示骨架屏，确保用户体验流畅
5. **无障碍性**: 卡片自动添加了适当的 ARIA 属性

## 常见问题

### 如何实现卡片的展开/收起？
可以结合 Phoenix.LiveView.JS 实现：

```elixir
<.card title="可折叠卡片">
  <:extra>
    <button phx-click={JS.toggle(to: "#card-content")}>
      展开/收起
    </button>
  </:extra>
  
  <div id="card-content">
    <p>可以展开或收起的内容。</p>
  </div>
</.card>
```

### 如何实现卡片拖拽？
需要配合 JavaScript Hook 或第三方库实现拖拽功能。

### 如何自定义卡片阴影？
通过 `class` 属性添加自定义的阴影类：

```elixir
<.card class="shadow-xl" hoverable>
  <p>自定义阴影的卡片</p>
</.card>
```