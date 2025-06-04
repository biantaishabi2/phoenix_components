# Phoenix Table 组件 API 设计

## 列宽和文本省略功能 API 设计

### 新增的 slot 属性

在现有的 `slot :col` 中添加以下属性：

```elixir
slot :col, required: true, doc: "列定义" do
  attr :label, :string, required: true, doc: "列标题"
  attr :key, :string, doc: "排序字段名"
  attr :sortable, :boolean, doc: "该列是否可排序"
  attr :class, :string, doc: "列的自定义CSS类"
  
  # 新增属性
  attr :width, :any, doc: "列宽度，可以是数字（像素）或字符串（如 '20%'）"
  attr :ellipsis, :boolean, default: false, doc: "是否显示省略号"
  attr :min_width, :any, doc: "最小列宽"
  attr :max_width, :any, doc: "最大列宽"
end
```

### 使用示例

```elixir
<.table id="products-table" rows={@products}>
  <:col :let={product} label="名称" width={150} ellipsis>
    <%= product.name %>
  </:col>
  <:col :let={product} label="描述" width="40%" ellipsis>
    <%= product.description %>
  </:col>
  <:col :let={product} label="价格" width={100}>
    <%= product.price %>
  </:col>
  <:action :let={product}>
    <.link navigate={~p"/products/#{product.id}"}>查看</.link>
  </:action>
</.table>
```

### 实现细节

1. **列宽处理**：
   - 如果 width 是数字，渲染为 `style="width: 150px"`
   - 如果 width 是字符串，直接使用 `style="width: 40%"`
   - 支持 min_width 和 max_width 的组合使用

2. **文本省略处理**：
   - 当 ellipsis 为 true 时，添加 CSS 类 `pc-table__cell--ellipsis`
   - 同时为单元格内容添加 `title` 属性，显示完整文本
   - CSS 样式：
     ```css
     .pc-table__cell--ellipsis {
       max-width: 0; /* 必须设置以使 text-overflow 生效 */
       overflow: hidden;
       text-overflow: ellipsis;
       white-space: nowrap;
     }
     ```

3. **与 Tailwind 的集成**：
   - 可以使用 Tailwind 的 `truncate` 类替代自定义 CSS
   - 但需要注意表格单元格的特殊性（需要设置 max-width）

### 设计决策

1. **为什么不支持对象形式的 ellipsis**：
   - Ant Design 的 `ellipsis: { showTitle: false }` 主要是为了自定义 tooltip
   - 在 Phoenix LiveView 中，如果需要自定义提示，可以直接在 slot 内容中实现
   - 保持 API 简洁，避免过度设计

2. **为什么添加 min_width 和 max_width**：
   - 响应式设计需要
   - 允许列在一定范围内自适应
   - 比固定宽度更灵活

3. **服务端渲染的优势**：
   - 不需要 JavaScript 计算列宽
   - 所有样式在服务端生成，首屏渲染更快
   - 避免客户端重排和重绘

## 固定列功能 API 设计（第二阶段）

```elixir
slot :col, required: true, doc: "列定义" do
  # ... 现有属性 ...
  
  # 固定列属性
  attr :fixed, :string, values: ["left", "right"], doc: "固定列位置"
end
```

### 注意事项

1. 固定列需要配合横向滚动容器使用
2. 需要计算固定列的偏移位置
3. 使用 CSS `position: sticky` 实现，无需 JavaScript