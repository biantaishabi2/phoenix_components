# Table 表格组件

## 概述
Table组件用于展示多条结构类似的数据，可对数据进行排序、筛选、分页等操作。这是管理系统中最常用的数据展示组件。

## 何时使用
- 当有大量结构化的数据需要展现时
- 当需要对数据进行排序、搜索、分页、自定义操作等复杂行为时

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| id | 表格唯一标识 | string | 必需 | 1.0 |
| rows | 数据源 | list | [] | 1.0 |
| size | 表格尺寸 | string | "medium" | 1.0 |
| color | 表格颜色主题 | string | "primary" | 1.0 |
| row_click | 行点击事件 | JS | nil | 1.0 |
| row_id | 行数据的key函数 | function \| atom | nil | 1.0 |
| pagination | 分页配置 | map | nil | 1.0 |
| class | 自定义CSS类 | string | "" | 1.0 |
| sticky_header | 是否固定表头 | boolean | false | 1.0 |
| selectable | 是否可选择行 | boolean | false | 1.0 |
| sortable | 是否支持排序 | boolean | false | 1.0 |

### 插槽
| 名称 | 说明 | 参数 |
|-----|------|------|
| col | 列定义 | label, key, sortable, class, width, ellipsis, min_width, max_width |
| action | 操作列 | - |
| empty | 空数据时的展示 | - |

### 列属性详情
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| label | 列标题 | string | 必需 | 1.0 |
| key | 排序字段名 | string | - | 1.0 |
| sortable | 该列是否可排序 | boolean | false | 1.0 |
| class | 列的自定义CSS类 | string | - | 1.0 |
| width | 列宽度 | number \| string | - | 1.1 |
| ellipsis | 是否显示省略号 | boolean | false | 1.1 |
| min_width | 最小列宽 | number \| string | - | 1.1 |
| max_width | 最大列宽 | number \| string | - | 1.1 |
| fixed | 固定列位置，支持 'left' 或 'right' | string | - | 1.2 |

### 操作列属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| width | 操作列宽度 | number \| string | - | 1.1 |
| ellipsis | 是否显示省略号 | boolean | false | 1.1 |
| min_width | 最小列宽 | number \| string | - | 1.1 |
| max_width | 最大列宽 | number \| string | - | 1.1 |
| fixed | 固定操作列位置，支持 'left' 或 'right' | string | - | 1.2 |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | 紧凑行高，较小间距 |
| medium | 中等尺寸(默认) | 标准行高和间距 |
| large | 大尺寸 | 宽松行高，较大间距 |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 选中行、分页按钮等 |
| info | 信息色 | 信息类表格样式 |
| success | 成功色 | 成功状态表格 |
| warning | 警告色 | 警告状态表格 |
| danger | 危险色 | 错误或危险状态表格 |

### 分页配置
```elixir
%{
  current: 1,        # 当前页
  page_size: 10,     # 每页条数
  total: 0,          # 总条数
  show_total: true,  # 是否显示总数
  show_size_changer: false  # 是否可以改变pageSize
}
```

## 代码示例

### 基础表格
```heex
<.table id="basic-table" rows={@products}>
  <:col :let={product} label="ID" key="id">
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称" key="name">
    <%= product.name %>
  </:col>
  <:col :let={product} label="价格" key="price">
    ¥<%= product.price %>
  </:col>
  <:col :let={product} label="库存" key="stock">
    <%= product.stock %>
  </:col>
</.table>
```

### 带操作列的表格
```heex
<.table id="product-table" rows={@products}>
  <:col :let={product} label="商品名称">
    <%= product.name %>
  </:col>
  <:col :let={product} label="状态">
    <.tag color={if product.status == "active", do: "success", else: "danger"}>
      <%= product.status %>
    </.tag>
  </:col>
  <:action :let={product}>
    <.link navigate={~p"/products/#{product.id}"} class="text-primary">
      查看
    </.link>
    <.link navigate={~p"/products/#{product.id}/edit"} class="text-primary ml-2">
      编辑
    </.link>
    <.link phx-click={JS.push("delete_product", value: %{id: product.id})} 
           class="text-danger ml-2"
           data-confirm="确定要删除吗？">
      删除
    </.link>
  </:action>
</.table>
```

### 可选择的表格
```heex
<.table 
  id="selectable-table" 
  rows={@products}
  selectable
  row_id={&(&1.id)}>
  <:col :let={product} label="商品名称">
    <%= product.name %>
  </:col>
  <:col :let={product} label="价格">
    ¥<%= product.price %>
  </:col>
</.table>

<!-- 批量操作按钮 -->
<div class="mt-4">
  <.button phx-click="batch_delete" disabled={@selected_count == 0}>
    批量删除 (<%= @selected_count %>)
  </.button>
</div>
```

### 带分页的表格
```heex
<.table 
  id="paginated-table" 
  rows={@products}
  pagination={@pagination}>
  <:col :let={product} label="ID">
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称">
    <%= product.name %>
  </:col>
  <:col :let={product} label="创建时间">
    <%= product.created_at %>
  </:col>
</.table>

<!-- 在LiveView中处理分页 -->
def handle_event("change_page", %{"page" => page}, socket) do
  {:noreply, 
   socket
   |> assign(pagination: %{socket.assigns.pagination | current: page})
   |> fetch_products()}
end
```

### 可排序的表格
```heex
<.table 
  id="sortable-table" 
  rows={@products}
  sortable>
  <:col :let={product} label="名称" key="name" sortable>
    <%= product.name %>
  </:col>
  <:col :let={product} label="价格" key="price" sortable>
    ¥<%= product.price %>
  </:col>
  <:col :let={product} label="销量" key="sales" sortable>
    <%= product.sales %>
  </:col>
</.table>
```

### 自定义列渲染
```heex
<.table id="custom-table" rows={@orders}>
  <:col :let={order} label="订单号">
    <span class="font-mono"><%= order.order_no %></span>
  </:col>
  <:col :let={order} label="商品图片">
    <img src={order.product_image} class="w-12 h-12 object-cover rounded" />
  </:col>
  <:col :let={order} label="支付状态">
    <div class="flex items-center gap-2">
      <span class={[
        "w-2 h-2 rounded-full",
        order.paid && "bg-green-500",
        !order.paid && "bg-red-500"
      ]}></span>
      <%= if order.paid, do: "已支付", else: "未支付" %>
    </div>
  </:col>
  <:col :let={order} label="金额">
    <span class="text-lg font-semibold text-primary">
      ¥<%= order.amount %>
    </span>
  </:col>
</.table>
```

### 列宽控制
```heex
<.table id="width-table" rows={@products}>
  <:col :let={product} label="ID" width={80}>
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称" width={200}>
    <%= product.name %>
  </:col>
  <:col :let={product} label="描述" width="40%">
    <%= product.description %>
  </:col>
  <:col :let={product} label="价格" width={120}>
    ¥<%= product.price %>
  </:col>
  <:col :let={product} label="操作" width={150}>
    <.link navigate={~p"/products/#{product.id}"}>查看</.link>
  </:col>
</.table>
```

### 文本省略
```heex
<.table id="ellipsis-table" rows={@articles}>
  <:col :let={article} label="标题" width={200} ellipsis>
    <%= article.title %>
  </:col>
  <:col :let={article} label="摘要" width="30%" ellipsis>
    <%= article.summary %>
  </:col>
  <:col :let={article} label="内容" ellipsis>
    <%= article.content %>
  </:col>
  <:col :let={article} label="作者" width={100}>
    <%= article.author %>
  </:col>
</.table>
```

### 响应式列宽
```heex
<.table id="responsive-width-table" rows={@products}>
  <:col :let={product} label="商品名称" min_width={150} max_width={300}>
    <%= product.name %>
  </:col>
  <:col :let={product} label="描述" min_width={200} ellipsis>
    <%= product.description %>
  </:col>
  <:col :let={product} label="价格" width={100}>
    ¥<%= product.price %>
  </:col>
</.table>
```

### 固定表头
```heex
<div class="h-96 overflow-auto">
  <.table 
    id="sticky-header-table" 
    rows={@large_dataset}
    sticky_header>
    <:col :let={item} label="ID"><%= item.id %></:col>
    <:col :let={item} label="名称"><%= item.name %></:col>
    <:col :let={item} label="描述"><%= item.description %></:col>
  </.table>
</div>
```

### 固定列功能

#### 基础左固定列
```heex
<.table id="left-fixed-table" rows={@products}>
  <:col :let={product} label="ID" fixed="left" width={80}>
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称" fixed="left" width={150}>
    <%= product.name %>
  </:col>
  <:col :let={product} label="描述">
    <%= product.description %>
  </:col>
  <:col :let={product} label="价格">
    ¥<%= product.price %>
  </:col>
</.table>
```

#### 基础右固定列
```heex
<.table id="right-fixed-table" rows={@products}>
  <:col :let={product} label="商品名称">
    <%= product.name %>
  </:col>
  <:col :let={product} label="描述">
    <%= product.description %>
  </:col>
  <:col :let={product} label="价格" fixed="right" width={100}>
    ¥<%= product.price %>
  </:col>
  <:action fixed="right" width={120}>
    <.button size="small">编辑</.button>
    <.button size="small" color="danger">删除</.button>
  </:action>
</.table>
```

#### 左右固定列组合
```heex
<.table id="mixed-fixed-table" rows={@products}>
  <!-- 左固定：关键标识信息 -->
  <:col :let={product} label="ID" fixed="left" width={60}>
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称" fixed="left" width={150}>
    <%= product.name %>
  </:col>
  
  <!-- 中间：详细信息 -->
  <:col :let={product} label="详细描述" width="40%">
    <%= product.description %>
  </:col>
  <:col :let={product} label="分类">
    <%= product.category %>
  </:col>
  <:col :let={product} label="创建时间">
    <%= format_date(product.created_at) %>
  </:col>
  
  <!-- 右固定：状态和操作 -->
  <:col :let={product} label="状态" fixed="right" width={80}>
    <.tag color={product.status_color}><%= product.status %></.tag>
  </:col>
  <:action fixed="right" width={150}>
    <.button size="small" phx-click="edit" phx-value-id={product.id}>编辑</.button>
    <.button size="small" color="danger" phx-click="delete" phx-value-id={product.id}>删除</.button>
  </:action>
</.table>
```

#### 固定列与其他功能结合
```heex
<.table 
  id="advanced-fixed-table" 
  rows={@products}
  sortable
  selectable
  row_id={&(&1.id)}>
  
  <!-- 左固定：关键信息 -->
  <:col :let={product} label="ID" key="id" fixed="left" width={80} sortable>
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称" key="name" fixed="left" width={200} ellipsis sortable>
    <%= product.name %>
  </:col>
  
  <!-- 中间：可滚动内容 -->
  <:col :let={product} label="详细描述" width={300} ellipsis>
    <%= product.description %>
  </:col>
  <:col :let={product} label="分类" key="category" sortable>
    <%= product.category %>
  </:col>
  <:col :let={product} label="供应商">
    <%= product.supplier %>
  </:col>
  <:col :let={product} label="库存" key="stock" sortable>
    <%= product.stock %>
  </:col>
  <:col :let={product} label="创建时间" key="created_at" sortable>
    <%= format_datetime(product.created_at) %>
  </:col>
  
  <!-- 右固定：价格、状态和操作 -->
  <:col :let={product} label="价格" key="price" fixed="right" width={100} sortable>
    ¥<%= product.price %>
  </:col>
  <:col :let={product} label="状态" fixed="right" width={80}>
    <.tag color={product.status_color}><%= product.status %></.tag>
  </:col>
  <:action fixed="right" width={150} ellipsis>
    <.button size="small" phx-click="edit" phx-value-id={product.id}>编辑详情</.button>
    <.button size="small" color="danger" phx-click="delete" phx-value-id={product.id}>删除</.button>
  </:action>
</.table>
```

### 空状态
```heex
<.table id="empty-table" rows={[]}>
  <:col label="商品名称"></:col>
  <:col label="价格"></:col>
  <:empty>
    <div class="text-center py-8">
      <.icon name="hero-inbox" class="mx-auto h-12 w-12 text-gray-400" />
      <p class="mt-2 text-gray-500">暂无数据</p>
      <.button class="mt-4" phx-click="add_product">
        添加商品
      </.button>
    </div>
  </:empty>
</.table>
```

### 复杂示例：订单管理表格
```heex
<.table 
  id="order-management-table"
  rows={@orders}
  pagination={@pagination}
  selectable
  row_id={&(&1.id)}
  row_click={&JS.navigate(~p"/orders/#{&1.id}")}>
  
  <:col :let={order} label="订单号" key="order_no" sortable width={150}>
    <span class="font-mono text-sm"><%= order.order_no %></span>
  </:col>
  
  <:col :let={order} label="客户" width={200}>
    <div>
      <p class="font-medium"><%= order.customer_name %></p>
      <p class="text-sm text-gray-500"><%= order.customer_phone %></p>
    </div>
  </:col>
  
  <:col :let={order} label="商品信息" min_width={200} max_width={300} ellipsis>
    <div class="flex items-center gap-2">
      <img src={order.product_image} class="w-10 h-10 rounded flex-shrink-0" />
      <div class="min-w-0">
        <p class="text-sm truncate"><%= order.product_name %></p>
        <p class="text-xs text-gray-500">x<%= order.quantity %></p>
      </div>
    </div>
  </:col>
  
  <:col :let={order} label="收货地址" width="20%" ellipsis>
    <%= order.shipping_address %>
  </:col>
  
  <:col :let={order} label="金额" key="amount" sortable width={100}>
    <span class="font-semibold">¥<%= order.amount %></span>
  </:col>
  
  <:col :let={order} label="状态" width={100}>
    <.tag color={order_status_color(order.status)}>
      <%= order_status_text(order.status) %>
    </.tag>
  </:col>
  
  <:col :let={order} label="下单时间" key="created_at" sortable width={160}>
    <%= format_datetime(order.created_at) %>
  </:col>
  
  <:action :let={order}>
    <.dropdown label="操作">
      <.dropdown_menu_item>
        <.link navigate={~p"/orders/#{order.id}"}>
          <.icon name="hero-eye" /> 查看详情
        </.link>
      </.dropdown_menu_item>
      
      <.dropdown_menu_item :if={order.status == "pending"}>
        <.link phx-click={JS.push("ship_order", value: %{id: order.id})}>
          <.icon name="hero-truck" /> 发货
        </.link>
      </.dropdown_menu_item>
      
      <.dropdown_menu_item>
        <.link phx-click={JS.push("export_order", value: %{id: order.id})}>
          <.icon name="hero-arrow-down-tray" /> 导出
        </.link>
      </.dropdown_menu_item>
    </.dropdown>
  </:action>
</.table>
```

## 与Vue版本对比

### 属性映射
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `<a-table>` | `<.table>` | 组件名称 |
| `:columns` | `<:col>` slots | 列定义方式不同 |
| `:data-source` | `rows` | 数据源 |
| `:row-selection` | `selectable` + `row_id` | 行选择配置 |
| `:pagination` | `pagination` | 分页配置 |
| `@change` | 事件处理在LiveView中 | 事件处理方式 |
| `:row-key` | `row_id` | 行唯一标识 |

### 固定列功能对比
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `fixed: 'left'` | `fixed="left"` | 左固定列 |
| `fixed: 'right'` | `fixed="right"` | 右固定列 |
| `fixed: true` | `fixed="left"` | 布尔值等同于左固定 |
| `scroll={{ x: 'max-content' }}` | 自动处理 | 滚动配置更简单 |
| CSS-in-JS 阴影 | CSS 阴影效果 | 更好的性能 |
| JavaScript 状态检测 | 可选的 LiveView Hook | 服务端优先 |

### 迁移示例

Vue代码：
```vue
<a-table
  :columns="columns"
  :data-source="products"
  :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
  :pagination="pagination"
  @change="handleTableChange">
  <template #bodyCell="{ column, record }">
    <template v-if="column.dataIndex === 'image'">
      <a-image :src="record.image" :width="50" />
    </template>
    <template v-if="column.dataIndex === 'action'">
      <a-button type="link" @click="handleEdit(record)">编辑</a-button>
    </template>
  </template>
</a-table>
```

Phoenix代码：
```heex
<.table 
  id="products-table"
  rows={@products}
  selectable
  row_id={&(&1.id)}
  pagination={@pagination}>
  
  <:col :let={product} label="图片">
    <img src={product.image} class="w-12 h-12" />
  </:col>
  
  <:col :let={product} label="名称">
    <%= product.name %>
  </:col>
  
  <:action :let={product}>
    <.link phx-click={JS.push("edit_product", value: %{id: product.id})}>
      编辑
    </.link>
  </:action>
</.table>
```

## 注意事项

1. **性能优化**：大数据量时应使用分页或虚拟滚动
2. **响应式设计**：考虑移动端的表格展示方案
3. **可访问性**：确保表格结构清晰，便于屏幕阅读器使用
4. **状态管理**：选择、排序、分页等状态应在LiveView中统一管理
5. **固定列限制**：固定列数量不宜过多，建议左右固定列总计不超过4个

## 固定列最佳实践

### 固定列使用指南

1. **必需属性**：固定列必须设置 width 属性
   ```heex
   <!-- 正确：固定列设置了宽度 -->
   <:col :let={item} label="ID" fixed="left" width={80}><%= item.id %></:col>
   
   <!-- 错误：固定列未设置宽度 -->
   <:col :let={item} label="ID" fixed="left"><%= item.id %></:col>
   ```

2. **宽度分配策略**：合理分配固定列和普通列的宽度
   ```heex
   <!-- 左固定：紧凑的关键信息 -->
   <:col :let={item} label="ID" fixed="left" width={60}><%= item.id %></:col>
   <:col :let={item} label="名称" fixed="left" width={150}><%= item.name %></:col>
   
   <!-- 中间：自适应内容 -->
   <:col :let={item} label="描述" min_width={200}><%= item.description %></:col>
   
   <!-- 右固定：状态和操作 -->
   <:col :let={item} label="状态" fixed="right" width={80}><%= item.status %></:col>
   <:action fixed="right" width={120}>
     <.button size="small">编辑</.button>
   </:action>
   ```

3. **固定列数量建议**：避免过多固定列影响体验
   - 左固定列：1-2 个（关键标识信息）
   - 右固定列：1-2 个（状态和操作）
   - 总计不超过 4 个固定列

### 与其他功能结合

1. **固定列 + 排序**：固定列完全支持排序功能
   ```heex
   <:col :let={item} label="名称" key="name" fixed="left" width={150} sortable>
     <%= item.name %>
   </:col>
   ```

2. **固定列 + 文本省略**：为固定列设置省略避免内容溢出
   ```heex
   <:col :let={item} label="标题" fixed="left" width={200} ellipsis>
     <%= item.title %>
   </:col>
   ```

3. **固定列 + 选择功能**：选择列会自动固定在最左侧
   ```heex
   <.table rows={@data} selectable row_id={&(&1.id)}>
     <:col :let={item} label="名称" fixed="left" width={150}>
       <%= item.name %>
     </:col>
   </.table>
   ```

### 固定列常见问题

**Q: 为什么固定列没有固定效果？**
A: 检查以下几点：
- 确保设置了 `width` 属性
- 检查表格是否有足够的宽度需要水平滚动
- 验证 CSS 样式是否正确加载

**Q: 固定列在移动端显示异常？**
A: 我们的固定列在移动端（768px以下）会自动禁用，恢复正常的表格滚动。这是为了保证移动端的用户体验。

**Q: 如何调整固定列的阴影效果？**
A: 阴影效果通过 CSS 控制，当表格内容可以滚动时会自动显示。如需自定义，可以修改 `app.css` 中的相关样式。

**Q: 固定列可以与 sticky_header 同时使用吗？**
A: 可以，固定列和固定表头可以同时使用，并且层级关系已经正确处理。

## 列宽和文本省略最佳实践

### 列宽设置指南
1. **固定宽度**：适用于内容长度固定的列（如ID、状态、操作列）
   ```heex
   <:col :let={item} label="ID" width={80}><%= item.id %></:col>
   ```

2. **百分比宽度**：适用于需要占据容器特定比例的列
   ```heex
   <:col :let={item} label="描述" width="40%"><%= item.description %></:col>
   ```

3. **响应式宽度**：使用 min_width 和 max_width 实现自适应
   ```heex
   <:col :let={item} label="标题" min_width={200} max_width={400}>
     <%= item.title %>
   </:col>
   ```

### 文本省略使用建议
1. **长文本列**：对于可能包含长文本的列启用省略
   ```heex
   <:col :let={item} label="详细描述" ellipsis><%= item.description %></:col>
   ```

2. **搭配 title 提示**：省略的文本会自动添加 title 属性显示完整内容

3. **与固定宽度结合**：省略功能在固定宽度列中效果最佳
   ```heex
   <:col :let={item} label="标题" width={200} ellipsis><%= item.title %></:col>
   ```

### 常见问题

**Q: 为什么设置了省略但没有生效？**
A: 确保父容器有足够的宽度约束，建议与 width 属性配合使用。

**Q: 如何在移动端优化表格显示？**
A: 使用 min_width 确保重要列不会过窄，考虑隐藏次要列或使用卡片布局。

**Q: 列宽可以使用 rem 等其他单位吗？**
A: 目前支持数字（转换为像素）和百分比字符串，如需其他单位请使用 class 属性自定义样式。

## 相关组件
- List 列表 - 简单的列表展示
- Card 卡片 - 网格化的数据展示
- Description 描述列表 - 成组展示多个字段