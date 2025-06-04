# Phoenix LiveView Table 固定列 API 设计

## 📋 设计概述

基于对 Ant Design 固定列实现原理和使用模式的深入研究，我为 Phoenix LiveView Table 组件设计了简洁、易用、功能完整的固定列 API。

## 🎯 设计目标

### 1. 核心原则
- **简洁性**: API 简单直观，易于理解和使用
- **一致性**: 与现有 Table 组件 API 保持一致
- **功能性**: 支持主要使用场景，满足实际需求
- **性能**: 充分利用服务端渲染优势
- **可扩展**: 为未来功能扩展留有空间

### 2. 功能范围
- ✅ 左固定列 (`fixed="left"`)
- ✅ 右固定列 (`fixed="right"`)
- ✅ 多列固定支持
- ✅ 自动位置计算
- ✅ 与现有功能兼容（宽度、省略、排序等）
- ✅ 响应式适配

## 🔧 API 设计

### 1. 基础 Slot 属性扩展

```elixir
# 在现有的 slot :col 中添加 fixed 属性
slot :col, required: true, doc: "列定义" do
  attr :label, :string, required: true, doc: "列标题"
  attr :key, :string, doc: "排序字段名"
  attr :sortable, :boolean, doc: "该列是否可排序"
  attr :class, :string, doc: "列的自定义CSS类"
  
  # 现有的列宽和省略功能
  attr :width, :any, doc: "列宽度，可以是数字（像素）或字符串（如 '20%'）"
  attr :ellipsis, :boolean, doc: "是否显示省略号"
  attr :min_width, :any, doc: "最小列宽"
  attr :max_width, :any, doc: "最大列宽"
  
  # 新增的固定列功能
  attr :fixed, :string, values: ["left", "right"], doc: "固定列位置，支持 'left' 或 'right'"
end

# 操作列也支持固定
slot :action, doc: "操作列" do
  attr :width, :any, doc: "操作列宽度"
  attr :ellipsis, :boolean, doc: "操作列是否显示省略号"
  attr :min_width, :any, doc: "操作列最小宽度"
  attr :max_width, :any, doc: "操作列最大宽度"
  
  # 新增的固定操作列功能
  attr :fixed, :string, values: ["left", "right"], doc: "固定操作列位置"
end
```

### 2. 使用示例

#### 基础左固定列
```heex
<.table id="basic-fixed" rows={@products}>
  <:col :let={product} label="ID" fixed="left" width={80}>
    <%= product.id %>
  </:col>
  <:col :let={product} label="名称" fixed="left" width={150}>
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

#### 左右固定列组合
```heex
<.table id="mixed-fixed" rows={@products}>
  <:col :let={product} label="ID" fixed="left" width={60}>
    <%= product.id %>
  </:col>
  <:col :let={product} label="名称" fixed="left" width={150}>
    <%= product.name %>
  </:col>
  
  <!-- 中间普通列 -->
  <:col :let={product} label="描述" width="40%">
    <%= product.description %>
  </:col>
  <:col :let={product} label="分类">
    <%= product.category %>
  </:col>
  
  <!-- 右固定列 -->
  <:col :let={product} label="状态" fixed="right" width={80}>
    <.tag color={product.status_color}><%= product.status %></.tag>
  </:col>
  <:action fixed="right" width={120}>
    <.button size="small">编辑</.button>
    <.button size="small" color="danger">删除</.button>
  </:action>
</.table>
```

#### 固定列与其他功能结合
```heex
<.table id="advanced-fixed" rows={@products} sortable selectable>
  <!-- 左固定：关键标识信息 -->
  <:col :let={product} label="ID" key="id" fixed="left" width={80} sortable>
    <%= product.id %>
  </:col>
  <:col :let={product} label="商品名称" key="name" fixed="left" width={200} ellipsis sortable>
    <%= product.name %>
  </:col>
  
  <!-- 中间：详细信息 -->
  <:col :let={product} label="详细描述" width={300} ellipsis>
    <%= product.description %>
  </:col>
  <:col :let={product} label="分类" key="category" sortable>
    <%= product.category %>
  </:col>
  <:col :let={product} label="创建时间" key="created_at" sortable>
    <%= format_date(product.created_at) %>
  </:col>
  
  <!-- 右固定：状态和操作 -->
  <:col :let={product} label="价格" key="price" fixed="right" width={100} sortable>
    ¥<%= product.price %>
  </:col>
  <:col :let={product} label="状态" fixed="right" width={80}>
    <.tag color={product.status_color}><%= product.status %></.tag>
  </:col>
  <:action fixed="right" width={150} ellipsis>
    <.button size="small" phx-click="edit" phx-value-id={product.id}>编辑</.button>
    <.button size="small" color="danger" phx-click="delete" phx-value-id={product.id}>删除</.button>
  </:action>
</.table>
```

## 🔄 内部实现设计

### 1. 数据处理流程

```elixir
def table(assigns) do
  assigns = 
    assigns
    |> assign_existing_features()  # 现有功能赋值
    |> assign_fixed_columns_info() # 新增固定列处理
  
  # 渲染模板
end

# 新增的固定列信息处理
defp assign_fixed_columns_info(assigns) do
  cols = assigns[:col] || []
  action = assigns[:action] || []
  
  # 分析固定列结构
  {left_fixed_cols, normal_cols, right_fixed_cols} = analyze_fixed_columns(cols)
  
  # 计算固定列位置
  left_positions = calculate_left_fixed_positions(left_fixed_cols)
  right_positions = calculate_right_fixed_positions(right_fixed_cols)
  
  assigns
  |> assign(:left_fixed_cols, left_fixed_cols)
  |> assign(:normal_cols, normal_cols) 
  |> assign(:right_fixed_cols, right_fixed_cols)
  |> assign(:left_fixed_positions, left_positions)
  |> assign(:right_fixed_positions, right_positions)
  |> assign(:has_fixed_left, length(left_fixed_cols) > 0)
  |> assign(:has_fixed_right, length(right_fixed_cols) > 0 || has_fixed_action?(action))
  |> assign(:fixed_action, get_fixed_action(action))
end
```

### 2. 位置计算算法

```elixir
# 计算左固定列的偏移位置
defp calculate_left_fixed_positions(left_fixed_cols) do
  left_fixed_cols
  |> Enum.with_index()
  |> Enum.map(fn {col, index} ->
    # 计算当前列左侧所有固定列的总宽度
    left_offset = left_fixed_cols
                  |> Enum.take(index)
                  |> Enum.reduce(0, fn col, acc ->
                    width = parse_column_width(col[:width]) || 150
                    acc + width
                  end)
    
    {col, %{
      left: "#{left_offset}px",
      is_first: index == 0,
      is_last: index == length(left_fixed_cols) - 1
    }}
  end)
end

# 计算右固定列的偏移位置
defp calculate_right_fixed_positions(right_fixed_cols) do
  total_cols = length(right_fixed_cols)
  
  right_fixed_cols
  |> Enum.with_index()
  |> Enum.map(fn {col, index} ->
    # 从右往左计算偏移
    right_offset = right_fixed_cols
                   |> Enum.drop(index + 1)
                   |> Enum.reduce(0, fn col, acc ->
                     width = parse_column_width(col[:width]) || 150
                     acc + width
                   end)
    
    {col, %{
      right: "#{right_offset}px",
      is_first: index == 0,
      is_last: index == total_cols - 1
    }}
  end)
end

# 解析列宽度（复用现有逻辑）
defp parse_column_width(width) when is_number(width), do: width
defp parse_column_width(width) when is_binary(width) do
  case Integer.parse(width) do
    {num, "px"} -> num
    {num, ""} -> num
    _ -> nil
  end
end
defp parse_column_width(_), do: nil
```

### 3. CSS 类生成

```elixir
# 生成固定列的 CSS 类
defp build_fixed_column_classes(col, position_info, type \\ :normal) do
  base_classes = [
    "pc-table__cell",
    type == :header && "pc-table__header-cell"
  ]
  
  fixed_classes = case col[:fixed] do
    "left" -> [
      "pc-table__cell--fixed-left",
      position_info[:is_first] && "pc-table__cell--fixed-left-first",
      position_info[:is_last] && "pc-table__cell--fixed-left-last"
    ]
    "right" -> [
      "pc-table__cell--fixed-right", 
      position_info[:is_first] && "pc-table__cell--fixed-right-first",
      position_info[:is_last] && "pc-table__cell--fixed-right-last"
    ]
    _ -> []
  end
  
  (base_classes ++ fixed_classes)
  |> Enum.filter(& &1)
  |> Enum.join(" ")
end

# 生成固定列的 style 属性
defp build_fixed_column_style(col, position_info) do
  width_style = build_width_style(col)  # 复用现有宽度逻辑
  
  fixed_style = case col[:fixed] do
    "left" -> "left: #{position_info[:left]}"
    "right" -> "right: #{position_info[:right]}"
    _ -> nil
  end
  
  [width_style, fixed_style]
  |> Enum.filter(& &1)
  |> Enum.join("; ")
end
```

## 🎨 模板渲染设计

### 1. 表头渲染

```heex
<thead class={[
  "pc-table__header bg-gray-50 dark:bg-gray-800",
  @sticky_header && "sticky top-0 z-10"
]}>
  <tr>
    <!-- 选择列 -->
    <%= if @selectable do %>
      <th class={["relative w-12", @header_cell_padding]}>
        <!-- 选择框内容 -->
      </th>
    <% end %>
    
    <!-- 左固定列 -->
    <%= for {col, position_info} <- @left_fixed_positions do %>
      <th class={build_fixed_column_classes(col, position_info, :header)}
          style={build_fixed_column_style(col, position_info)}>
        <%= render_column_header(col, assigns) %>
      </th>
    <% end %>
    
    <!-- 普通列 -->
    <%= for col <- @normal_cols do %>
      <th class={["text-left text-xs font-medium", @header_cell_padding, col[:class]]}
          style={build_width_style(col)}>
        <%= render_column_header(col, assigns) %>
      </th>
    <% end %>
    
    <!-- 右固定列 -->
    <%= for {col, position_info} <- @right_fixed_positions do %>
      <th class={build_fixed_column_classes(col, position_info, :header)}
          style={build_fixed_column_style(col, position_info)}>
        <%= render_column_header(col, assigns) %>
      </th>
    <% end %>
    
    <!-- 固定操作列 -->
    <%= if @fixed_action do %>
      <th class={build_action_fixed_classes(@fixed_action)}
          style={build_action_fixed_style(@fixed_action)}>
        操作
      </th>
    <% end %>
  </tr>
</thead>
```

### 2. 表体渲染

```heex
<tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
  <%= for row <- @rows do %>
    <tr class={["pc-table__row", @row_click && "cursor-pointer"]}>
      <!-- 选择列 -->
      <%= if @selectable do %>
        <td class={["pc-table__cell w-12", @body_cell_padding]}>
          <!-- 选择框内容 -->
        </td>
      <% end %>
      
      <!-- 左固定列 -->
      <%= for {col, position_info} <- @left_fixed_positions do %>
        <% content = render_slot(col, row) %>
        <td class={[
             build_fixed_column_classes(col, position_info),
             @body_cell_padding,
             build_ellipsis_class(col)
           ]}
           style={build_fixed_column_style(col, position_info)}
           title={get_cell_title(col, content)}>
          <%= content %>
        </td>
      <% end %>
      
      <!-- 普通列 -->
      <%= for col <- @normal_cols do %>
        <% content = render_slot(col, row) %>
        <td class={[
             "pc-table__cell text-sm text-gray-900 dark:text-gray-100",
             @body_cell_padding,
             col[:class],
             build_ellipsis_class(col)
           ]}
           style={build_width_style(col)}
           title={get_cell_title(col, content)}>
          <%= content %>
        </td>
      <% end %>
      
      <!-- 右固定列 -->
      <%= for {col, position_info} <- @right_fixed_positions do %>
        <% content = render_slot(col, row) %>
        <td class={[
             build_fixed_column_classes(col, position_info),
             @body_cell_padding,
             build_ellipsis_class(col)
           ]}
           style={build_fixed_column_style(col, position_info)}
           title={get_cell_title(col, content)}>
          <%= content %>
        </td>
      <% end %>
      
      <!-- 固定操作列 -->
      <%= if @fixed_action do %>
        <td class={[build_action_fixed_classes(@fixed_action), @body_cell_padding]}>
          <div class="flex items-center gap-3">
            <%= render_slot(@action, row) %>
          </div>
        </td>
      <% end %>
    </tr>
  <% end %>
</tbody>
```

## 📊 容器状态管理

### 1. 表格容器类

```heex
<div class={[
  "pc-table",
  @class,
  @has_fixed_left && "pc-table--has-fix-left",
  @has_fixed_right && "pc-table--has-fix-right",
  # 这些状态可以通过 LiveView 的 JS hook 动态添加
  # "pc-table--ping-left",
  # "pc-table--ping-right"
]}>
  <table class="pc-table__table min-w-full">
    <!-- 表格内容 -->
  </table>
</div>
```

### 2. 滚动状态检测（可选）

```javascript
// 可选的 JavaScript Hook for 滚动状态检测
const TableScrollHook = {
  mounted() {
    const container = this.el.querySelector('.pc-table__table');
    
    const checkScroll = () => {
      const scrollLeft = container.scrollLeft;
      const scrollWidth = container.scrollWidth;
      const clientWidth = container.clientWidth;
      
      // 添加/移除滚动状态类
      this.el.classList.toggle('pc-table--ping-left', scrollLeft > 0);
      this.el.classList.toggle('pc-table--ping-right', 
        scrollLeft < scrollWidth - clientWidth);
    };
    
    container.addEventListener('scroll', checkScroll);
    checkScroll(); // 初始检查
  }
};

// 在 LiveView 中使用
<div class="pc-table" phx-hook="TableScroll">
```

## ⚙️ 配置选项

### 1. 表格级别配置

```elixir
# 可选的表格级别固定列配置
attr :fixed_column_config, :map, default: %{}, doc: "固定列配置" do
  # 可以包含：
  # - responsive: boolean - 是否响应式
  # - mobile_threshold: integer - 移动端断点
  # - shadow_config: map - 阴影配置
end
```

### 2. 使用示例

```heex
<.table 
  id="responsive-fixed" 
  rows={@products}
  fixed_column_config={%{
    responsive: true,
    mobile_threshold: 768,
    shadow_config: %{opacity: 0.2}
  }}>
  <!-- 列定义 -->
</.table>
```

## 🎯 兼容性和迁移

### 1. 向后兼容

```elixir
# 现有的 table 组件完全兼容
<.table id="existing" rows={@data}>
  <:col :let={item} label="Name"><%= item.name %></:col>
  <!-- 不设置 fixed 属性，行为保持不变 -->
</.table>
```

### 2. 渐进式采用

```elixir
# 可以逐步添加固定列功能
<.table id="progressive" rows={@data}>
  <:col :let={item} label="ID" fixed="left" width={80}><%= item.id %></:col>
  <:col :let={item} label="Name"><%= item.name %></:col>  # 原有列保持不变
  <:col :let={item} label="Description"><%= item.description %></:col>
</.table>
```

## 📝 API 决策说明

### 1. 为什么选择字符串而非布尔值？

```elixir
# 选择: fixed="left" | fixed="right"
# 而非: fixed_left={true} | fixed_right={true}
```

**原因**：
- ✅ 更直观，一目了然
- ✅ 扩展性好，未来可以支持更多位置
- ✅ 与 Ant Design API 保持一致
- ✅ 避免多个布尔属性的冲突

### 2. 为什么不支持 boolean 类型？

```elixir
# 不支持: fixed={true} (等同于 fixed="left")
```

**原因**：
- ✅ 避免 API 歧义
- ✅ 保持 API 简洁性
- ✅ 鼓励明确的意图表达

### 3. 为什么操作列也支持固定？

```elixir
<:action fixed="right" width={120}>
```

**原因**：
- ✅ 操作列通常需要始终可见
- ✅ 提高用户体验
- ✅ 与标准固定列保持一致的 API

## 🚀 实现优先级

### 阶段一：基础功能
1. ✅ `fixed="left"` 基础支持
2. ✅ `fixed="right"` 基础支持
3. ✅ 与现有宽度功能结合
4. ✅ 基础 CSS 样式

### 阶段二：完善功能
1. ⏳ 多列固定支持
2. ⏳ 固定操作列
3. ⏳ 阴影边界效果
4. ⏳ 位置自动计算

### 阶段三：高级功能
1. ⏳ 滚动状态检测
2. ⏳ 响应式适配
3. ⏳ 性能优化
4. ⏳ 高级动画效果

## 📋 总结

Phoenix LiveView Table 固定列 API 设计体现了以下原则：

- **简洁直观**: `fixed="left"` 一目了然
- **功能完整**: 支持主要使用场景
- **向后兼容**: 不影响现有代码
- **性能优先**: 利用服务端渲染优势
- **易于扩展**: 为未来功能留有空间

这个 API 设计为实现阶段提供了清晰的指导方向。

## 🔄 后续重构计划

由于 `table.ex` 文件在添加固定列功能后会变得过大（预计 600-700 行），我们计划在功能实现完成后进行模块化重构：

### 重构方向
1. **功能模块化**: 将各功能（宽度、省略、选择、排序、分页、固定列）拆分为独立模块
2. **文件结构优化**: 创建 `table/` 目录存放子模块
3. **测试文件整理**: 相应地拆分测试文件

### 重构时机
- 在固定列功能实现并通过所有测试后进行
- 保持 API 不变，只进行内部结构优化
- 详见 `table-refactoring-plan.md`

### 预期收益
- 提高代码可维护性
- 方便团队协作
- 更容易添加新功能
- 编译和热重载性能提升