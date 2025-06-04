# SearchableSelect 组件文档

## 组件概述

SearchableSelect 是一个支持搜索功能的下拉选择器组件，用户可以通过输入关键词快速找到需要的选项。支持单选、多选、远程搜索等功能。

## 基础用法

```elixir
<.searchable_select
  id="brand-select"
  name="brand"
  placeholder="请选择或搜索品牌"
  options={@brand_options}
  value={@selected_brand}
  on_change="brand_changed"
/>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| id | string | 必填 | 组件唯一标识符 |
| name | string | 必填 | 表单字段名称 |
| options | list | [] | 选项列表 |
| value | any | nil | 当前选中值 |
| placeholder | string | "请选择" | 占位符文本 |
| multiple | boolean | false | 是否支持多选 |
| searchable | boolean | true | 是否启用搜索功能 |
| remote_search | boolean | false | 是否启用远程搜索 |
| allow_clear | boolean | true | 是否显示清除按钮 |
| disabled | boolean | false | 是否禁用 |
| loading | boolean | false | 是否显示加载状态 |
| max_tag_count | integer | nil | 多选时最大显示标签数 |
| filter_option | string | "default" | 筛选方式："default", "custom", "none" |
| on_change | string | nil | 选择改变事件 |
| on_search | string | nil | 搜索事件 |
| on_focus | string | nil | 获得焦点事件 |
| on_blur | string | nil | 失去焦点事件 |
| class | string | "" | 自定义 CSS 类 |

## 选项数据格式

### 基础选项
```elixir
[
  %{value: "apple", label: "Apple"},
  %{value: "samsung", label: "Samsung"},
  %{value: "xiaomi", label: "小米"}
]
```

### 带描述的选项
```elixir
[
  %{
    value: "apple",
    label: "Apple",
    description: "美国科技公司",
    avatar: "/images/apple-logo.png"
  }
]
```

### 分组选项
```elixir
[
  %{
    label: "国外品牌",
    options: [
      %{value: "apple", label: "Apple"},
      %{value: "samsung", label: "Samsung"}
    ]
  },
  %{
    label: "国内品牌",
    options: [
      %{value: "xiaomi", label: "小米"},
      %{value: "huawei", label: "华为"}
    ]
  }
]
```

## 使用示例

### 基础用法
```elixir
<.searchable_select
  id="basic-select"
  name="brand"
  placeholder="选择品牌"
  options={[
    %{value: "apple", label: "Apple"},
    %{value: "samsung", label: "Samsung"},
    %{value: "xiaomi", label: "小米"}
  ]}
  value={@form.brand}
  on_change="update_brand"
/>
```

### 多选模式
```elixir
<.searchable_select
  id="multi-select"
  name="categories"
  placeholder="选择分类"
  options={@category_options}
  value={@form.categories}
  multiple={true}
  max_tag_count={3}
  on_change="update_categories"
/>
```

### 远程搜索
```elixir
<.searchable_select
  id="remote-select"
  name="products"
  placeholder="搜索商品"
  options={@search_results}
  value={@form.product_id}
  remote_search={true}
  loading={@searching}
  on_search="search_products"
  on_change="select_product"
/>
```

### 带分组的选择器
```elixir
<.searchable_select
  id="grouped-select"
  name="department"
  placeholder="选择部门"
  options={[
    %{
      label: "技术部",
      options: [
        %{value: "tech-dev", label: "开发组"},
        %{value: "tech-qa", label: "测试组"}
      ]
    },
    %{
      label: "产品部",
      options: [
        %{value: "product-design", label: "设计组"},
        %{value: "product-pm", label: "产品组"}
      ]
    }
  ]}
  on_change="select_department"
/>
```

### 自定义选项渲染
```elixir
<.searchable_select
  id="custom-option-select"
  name="user"
  placeholder="选择用户"
  options={@user_options}
  on_change="select_user"
>
  <:option :let={option}>
    <div class="flex items-center gap-2">
      <img src={option.avatar} class="w-6 h-6 rounded-full" />
      <div>
        <div class="font-medium">{option.label}</div>
        <div class="text-sm text-gray-500">{option.email}</div>
      </div>
    </div>
  </:option>
</.searchable_select>
```

## LiveView 事件处理

```elixir
def handle_event("update_brand", %{"value" => brand}, socket) do
  {:noreply, assign(socket, :selected_brand, brand)}
end

def handle_event("search_products", %{"query" => query}, socket) do
  results = search_products_by_name(query)
  
  {:noreply,
   socket
   |> assign(:search_results, results)
   |> assign(:searching, false)}
end

def handle_event("select_product", %{"value" => product_id}, socket) do
  product = get_product(product_id)
  
  {:noreply,
   socket
   |> assign(:selected_product, product)
   |> put_flash(:info, "已选择商品：#{product.name}")}
end
```

## 高级用法

### 异步加载选项
```elixir
<.searchable_select
  id="async-select"
  name="supplier"
  placeholder="选择供应商"
  options={@supplier_options}
  loading={@loading_suppliers}
  on_focus="load_suppliers"
  on_change="select_supplier"
/>
```

### 自定义筛选逻辑
```elixir
<.searchable_select
  id="custom-filter-select"
  name="product"
  placeholder="搜索商品"
  options={@products}
  filter_option="custom"
  on_search="filter_products"
/>
```

### 标签模式（多选时的显示方式）
```elixir
<.searchable_select
  id="tag-select"
  name="skills"
  placeholder="选择技能"
  options={@skill_options}
  multiple={true}
  max_tag_count={5}
  tag_render="compact"
  on_change="update_skills"
/>
```

## 样式定制

### 基础样式定制
```elixir
<.searchable_select
  id="styled-select"
  name="category"
  options={@options}
  class="w-full"
  dropdown_class="max-h-60"
  option_class="hover:bg-blue-50"
/>
```

### 尺寸变体
```elixir
<!-- 小尺寸 -->
<.searchable_select size="sm" />

<!-- 中等尺寸（默认） -->
<.searchable_select size="md" />

<!-- 大尺寸 -->
<.searchable_select size="lg" />
```

## 验证和错误处理

```elixir
<.searchable_select
  id="validated-select"
  name="required_field"
  options={@options}
  value={@form.required_field}
  required={true}
  errors={@form.errors[:required_field]}
  on_change="validate_field"
/>
```

## 可访问性

SearchableSelect 组件支持完整的键盘导航和屏幕阅读器：

- **Tab/Shift+Tab**: 聚焦/失焦
- **Enter/Space**: 打开/关闭下拉菜单
- **↑/↓**: 导航选项
- **Enter**: 选择当前高亮选项
- **Esc**: 关闭下拉菜单
- **字母键**: 快速导航到匹配的选项

## 实际应用场景

### 商品选择器
```elixir
<.searchable_select
  id="product-selector"
  name="product_id"
  placeholder="搜索商品名称、SKU或条码"
  options={@products}
  remote_search={true}
  loading={@searching}
  on_search="search_products"
  on_change="add_to_cart"
>
  <:option :let={product}>
    <div class="flex justify-between">
      <div>
        <div class="font-medium">{product.name}</div>
        <div class="text-sm text-gray-500">SKU: {product.sku}</div>
      </div>
      <div class="text-right">
        <div class="font-medium text-green-600">¥{product.price}</div>
        <div class="text-sm text-gray-500">库存: {product.stock}</div>
      </div>
    </div>
  </:option>
</.searchable_select>
```

### 用户选择器
```elixir
<.searchable_select
  id="user-selector"
  name="assigned_to"
  placeholder="分配给..."
  options={@team_members}
  on_change="assign_task"
>
  <:option :let={user}>
    <div class="flex items-center gap-3">
      <img src={user.avatar} class="w-8 h-8 rounded-full" />
      <div>
        <div class="font-medium">{user.name}</div>
        <div class="text-sm text-gray-500">{user.department}</div>
      </div>
      <div class="ml-auto">
        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs bg-green-100 text-green-800">
          在线
        </span>
      </div>
    </div>
  </:option>
</.searchable_select>
```

## 性能优化

### 虚拟滚动（大数据量）
```elixir
<.searchable_select
  id="virtual-select"
  name="city"
  options={@cities} # 数千个城市
  virtual_scroll={true}
  option_height={40}
  max_visible_options={10}
/>
```

### 防抖搜索
```elixir
<.searchable_select
  id="debounced-select"
  name="suggestion"
  remote_search={true}
  search_debounce={300} # 300ms 防抖
  on_search="search_suggestions"
/>
```

## 注意事项

1. **性能考虑**: 大量选项时建议使用远程搜索或虚拟滚动
2. **数据格式**: 确保选项数据包含必需的 `value` 和 `label` 字段
3. **事件处理**: 避免在搜索事件中执行耗时操作，建议使用防抖
4. **可访问性**: 确保选项有合适的 `aria-label` 标签
5. **多选限制**: 合理设置 `max_tag_count` 避免界面过于拥挤

## 与原生 Select 的对比

| 特性 | 原生 Select | SearchableSelect |
|------|-------------|------------------|
| 搜索功能 | ❌ | ✅ |
| 远程数据 | ❌ | ✅ |
| 自定义渲染 | ❌ | ✅ |
| 多选支持 | 基础 | 增强 |
| 异步加载 | ❌ | ✅ |
| 虚拟滚动 | ❌ | ✅ |
| 性能 | 一般 | 优秀 |