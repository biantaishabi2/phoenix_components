# FilterForm 组件文档

## 组件概述

FilterForm 是一个灵活的筛选表单组件，用于在数据列表页面提供搜索和筛选功能。它支持多种表单控件类型，采用内联布局，并提供响应式设计。

## 基础用法

```elixir
<.filter_form
  id="order-filter"
  fields={[
    %{name: "search", label: "搜索", type: "input", placeholder: "输入关键词"},
    %{name: "status", label: "状态", type: "select", options: @status_options},
    %{name: "date_range", label: "日期范围", type: "date_range"}
  ]}
  on_search="search"
  on_reset="reset"
/>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| id | string | 必填 | 表单唯一标识符 |
| fields | list | [] | 表单字段配置列表 |
| values | map | %{} | 表单字段值 |
| on_search | string | - | 搜索事件处理函数 |
| on_reset | string | - | 重置事件处理函数 |
| layout | string | "inline" | 表单布局方式 |
| class | string | "" | 自定义CSS类 |

## 字段配置

每个字段支持以下配置：

| 属性 | 类型 | 说明 |
|------|------|------|
| name | string | 字段名称（必填） |
| label | string | 字段标签 |
| type | string | 字段类型 |
| placeholder | string/list | 占位符文本 |
| width | string | 字段宽度 |
| options | list | 选项列表（select类型） |
| required | boolean | 是否必填 |
| props | map | 额外属性 |

## 支持的字段类型

### 1. input - 文本输入
```elixir
%{
  name: "keyword",
  label: "关键词",
  type: "input",
  placeholder: "请输入关键词",
  width: "200px"
}
```

### 2. search - 搜索输入
```elixir
%{
  name: "search",
  label: "搜索",
  type: "search",
  placeholder: "搜索订单号、商品名称",
  width: "300px"
}
```

### 3. select - 下拉选择
```elixir
%{
  name: "status",
  label: "状态",
  type: "select",
  placeholder: "请选择状态",
  options: [
    %{value: "active", label: "启用"},
    %{value: "inactive", label: "禁用"}
  ],
  props: %{mode: "multiple"} # 支持多选
}
```

### 4. date - 日期选择
```elixir
%{
  name: "date",
  label: "日期",
  type: "date",
  placeholder: "选择日期"
}
```

### 5. date_range - 日期范围
```elixir
%{
  name: "date_range",
  label: "日期范围",
  type: "date_range",
  placeholder: ["开始日期", "结束日期"]
}
```

### 6. number - 数字输入
```elixir
%{
  name: "amount",
  label: "金额",
  type: "number",
  placeholder: "输入金额",
  props: %{min: 0, max: 9999}
}
```

### 7. checkbox - 复选框
```elixir
%{
  name: "only_active",
  label: "仅显示启用",
  type: "checkbox"
}
```

## 完整示例

### 订单筛选表单
```elixir
<.filter_form
  id="order-filter"
  fields={[
    %{
      name: "search",
      type: "search",
      placeholder: "搜索订单号、商品名称、收件人信息",
      width: "300px"
    },
    %{
      name: "status",
      label: "订单状态",
      type: "select",
      options: [
        %{value: "pending", label: "待付款"},
        %{value: "paid", label: "已付款"},
        %{value: "shipped", label: "已发货"},
        %{value: "completed", label: "已完成"}
      ],
      props: %{mode: "multiple"}
    },
    %{
      name: "date_range",
      label: "下单时间",
      type: "date_range"
    },
    %{
      name: "amount_range",
      label: "金额范围",
      type: "number_range",
      placeholder: ["最小金额", "最大金额"]
    }
  ]}
  values={@filter_values}
  on_search="apply_filters"
  on_reset="reset_filters"
/>
```

### 商品筛选表单
```elixir
<.filter_form
  id="product-filter"
  fields={[
    %{
      name: "keyword",
      label: "关键词",
      type: "input",
      placeholder: "商品名称/SKU"
    },
    %{
      name: "category",
      label: "分类",
      type: "tree_select",
      options: @category_tree,
      props: %{multiple: true}
    },
    %{
      name: "brand",
      label: "品牌",
      type: "select",
      options: @brand_options
    },
    %{
      name: "status",
      label: "状态",
      type: "select",
      options: [
        %{value: "on_sale", label: "在售"},
        %{value: "off_sale", label: "下架"}
      ]
    },
    %{
      name: "price_range",
      label: "价格",
      type: "number_range"
    }
  ]}
  on_search="filter_products"
  on_reset="reset_product_filters"
/>
```

## LiveView 事件处理

```elixir
def handle_event("apply_filters", params, socket) do
  filters = params["filters"]
  
  {:noreply,
   socket
   |> assign(:filters, filters)
   |> assign(:products, filter_products(filters))}
end

def handle_event("reset_filters", _params, socket) do
  {:noreply,
   socket
   |> assign(:filters, %{})
   |> assign(:products, list_products())}
end
```

## 高级用法

### 自定义按钮
```elixir
<.filter_form id="custom-filter" fields={@fields}>
  <:actions>
    <.button type="primary" phx-click="search">
      <.icon name="hero-magnifying-glass" /> 搜索
    </.button>
    <.button phx-click="reset">重置</.button>
    <.button phx-click="export">导出</.button>
  </:actions>
</.filter_form>
```

### 折叠展开
```elixir
<.filter_form
  id="collapsible-filter"
  fields={@fields}
  collapsible={true}
  collapsed={@filter_collapsed}
  on_toggle="toggle_filter"
/>
```

### 响应式布局
```elixir
<.filter_form
  id="responsive-filter"
  fields={@fields}
  responsive={%{
    sm: 1,  # 小屏每行1个字段
    md: 2,  # 中屏每行2个字段
    lg: 3,  # 大屏每行3个字段
    xl: 4   # 超大屏每行4个字段
  }}
/>
```

## 样式定制

FilterForm 组件使用 Tailwind CSS 类，支持通过 class 属性自定义样式：

```elixir
<.filter_form
  id="styled-filter"
  fields={@fields}
  class="bg-gray-50 p-4 rounded-lg"
  field_class="mb-2"
  button_class="shadow-sm"
/>
```

## 最佳实践

1. **字段命名**：使用清晰、语义化的字段名称
2. **默认值**：为常用筛选项设置合理的默认值
3. **性能优化**：避免在每次输入时触发搜索，使用防抖或明确的搜索按钮
4. **状态管理**：在 LiveView 中维护筛选状态，支持 URL 参数同步
5. **响应式设计**：根据屏幕大小调整字段布局
6. **用户体验**：提供清晰的重置功能，保持筛选状态的可见性

## 注意事项

1. 表单字段的 name 必须唯一
2. select 类型的 options 必须包含 value 和 label
3. date_range 类型返回的是一个包含两个日期的列表
4. 使用 tree_select 时需要确保数据结构正确
5. 自定义验证逻辑应在事件处理函数中实现