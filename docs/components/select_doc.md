# Select 选择器组件

## 概述
Select 组件是一个下拉选择器，当选项过多时，使用下拉菜单展示并选择内容。这是表单中最常用的输入组件之一。

## 何时使用
- 弹出一个下拉菜单给用户选择操作，用于代替原生的选择器
- 当选项少时（少于 5 项），建议直接将选项平铺，使用 Radio 是更好的选择

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| id | 选择器唯一标识 | string | 必需 | 1.0 |
| name | 表单字段名 | string | - | 1.0 |
| value | 当前选中的值 | any | nil | 1.0 |
| options | 选项数据 | list | [] | 1.0 |
| placeholder | 选择框默认文字 | string | "请选择" | 1.0 |
| disabled | 是否禁用 | boolean | false | 1.0 |
| multiple | 是否多选 | boolean | false | 1.0 |
| searchable | 是否可搜索 | boolean | false | 1.0 |
| clearable | 是否可清除 | boolean | false | 1.0 |
| size | 尺寸 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| class | 自定义CSS类 | string | "" | 1.0 |
| on_change | 选中值改变时的回调 | JS | - | 1.0 |
| on_search | 搜索文本改变时的回调 | JS | - | 1.0 |
| on_clear | 清除选中值时的回调 | JS | - | 1.0 |
| loading | 是否加载中 | boolean | false | 1.0 |
| max_tag_count | 多选时最多显示的tag数 | integer | nil | 1.0 |
| dropdown_class | 下拉菜单的className | string | "" | 1.0 |
| dropdown_style | 下拉菜单的style | string | "" | 1.0 |
| allow_create | 是否允许创建新选项 | boolean | false | 1.0 |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | text-sm, py-2 px-3 |
| medium | 中等尺寸(默认) | text-sm, py-2 px-4 |
| large | 大尺寸 | text-base, py-2.5 px-6 |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 焦点和选中状态 |
| info | 信息色 | 信息类选择器 |
| success | 成功色 | 成功状态选择器 |
| warning | 警告色 | 警告状态选择器 |
| danger | 危险色 | 错误状态选择器 |

### 选项数据结构
```elixir
# 基础格式
[
  %{value: "1", label: "Option 1"},
  %{value: "2", label: "Option 2"},
  %{value: "3", label: "Option 3", disabled: true}
]

# 分组格式
[
  %{
    label: "Group 1",
    options: [
      %{value: "1-1", label: "Option 1-1"},
      %{value: "1-2", label: "Option 1-2"}
    ]
  },
  %{
    label: "Group 2",
    options: [
      %{value: "2-1", label: "Option 2-1"},
      %{value: "2-2", label: "Option 2-2"}
    ]
  }
]
```

## 代码示例

### 基础用法
```heex
<.select 
  id="basic-select"
  name="city"
  options={[
    %{value: "beijing", label: "北京"},
    %{value: "shanghai", label: "上海"},
    %{value: "guangzhou", label: "广州"},
    %{value: "shenzhen", label: "深圳"}
  ]}
  placeholder="请选择城市"
/>
```

### 带默认值
```heex
<.select 
  id="default-select"
  name="status"
  value="active"
  options={[
    %{value: "active", label: "激活"},
    %{value: "inactive", label: "未激活"},
    %{value: "pending", label: "待审核"}
  ]}
/>
```

### 禁用状态
```heex
<.select 
  id="disabled-select"
  name="disabled_field"
  disabled
  value="1"
  options={[
    %{value: "1", label: "已选择的选项"}
  ]}
/>
```

### 可清除
```heex
<.select 
  id="clearable-select"
  name="clearable"
  clearable
  value="option1"
  on_clear={JS.push("clear_selection")}
  options={@options}
/>
```

### 多选
```heex
<.select 
  id="multiple-select"
  name="tags[]"
  multiple
  value={["tag1", "tag2"]}
  placeholder="请选择标签"
  options={[
    %{value: "tag1", label: "标签1"},
    %{value: "tag2", label: "标签2"},
    %{value: "tag3", label: "标签3"},
    %{value: "tag4", label: "标签4"}
  ]}
/>

<!-- 限制显示tag数量 -->
<.select 
  id="max-tag-select"
  name="categories[]"
  multiple
  max_tag_count={2}
  value={["cat1", "cat2", "cat3", "cat4"]}
  options={@categories}
/>
```

### 可搜索
```heex
<.select 
  id="searchable-select"
  name="product"
  searchable
  placeholder="搜索产品"
  on_search={JS.push("search_products")}
  options={@filtered_products}
  loading={@searching}
/>

<!-- 在LiveView中处理搜索 -->
def handle_event("search_products", %{"value" => search_term}, socket) do
  filtered = filter_products(socket.assigns.products, search_term)
  {:noreply, assign(socket, filtered_products: filtered, searching: false)}
end
```

### 分组选项
```heex
<.select 
  id="grouped-select"
  name="department"
  options={[
    %{
      label: "技术部",
      options: [
        %{value: "frontend", label: "前端开发"},
        %{value: "backend", label: "后端开发"},
        %{value: "devops", label: "运维"}
      ]
    },
    %{
      label: "产品部",
      options: [
        %{value: "pm", label: "产品经理"},
        %{value: "design", label: "设计师"}
      ]
    }
  ]}
/>
```

### 允许创建新选项
```heex
<.select 
  id="creatable-select"
  name="custom_tag"
  searchable
  allow_create
  multiple
  placeholder="输入标签名称，按回车创建"
  value={@selected_tags}
  options={@available_tags}
  on_change={JS.push("update_tags")}
/>
```

### 不同尺寸
```heex
<div class="space-y-4">
  <.select 
    id="small-select"
    size="small"
    options={@options}
    placeholder="小尺寸"
  />
  
  <.select 
    id="medium-select"
    size="medium"
    options={@options}
    placeholder="中等尺寸（默认）"
  />
  
  <.select 
    id="large-select"
    size="large"
    options={@options}
    placeholder="大尺寸"
  />
</div>
```

### 自定义下拉样式
```heex
<.select 
  id="custom-dropdown"
  name="custom"
  options={@options}
  dropdown_class="max-h-40 overflow-y-auto"
  dropdown_style="min-width: 200px;"
/>
```

### 在表单中使用
```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.select 
    id="user-role"
    name="user[role]"
    value={@form[:role].value}
    options={[
      %{value: "admin", label: "管理员"},
      %{value: "editor", label: "编辑"},
      %{value: "viewer", label: "查看者"}
    ]}
    on_change={JS.push("validate")}
  />
  
  <.select 
    id="user-permissions"
    name="user[permissions][]"
    multiple
    value={@form[:permissions].value || []}
    options={@permission_options}
    placeholder="选择权限"
  />
  
  <.button type="submit">保存</.button>
</.form>
```

### 级联选择（省市区）
```heex
<div class="grid grid-cols-3 gap-4">
  <.select 
    id="province"
    name="province"
    value={@selected_province}
    options={@provinces}
    placeholder="选择省份"
    on_change={JS.push("select_province")}
  />
  
  <.select 
    id="city"
    name="city"
    value={@selected_city}
    options={@cities}
    placeholder="选择城市"
    on_change={JS.push("select_city")}
    disabled={!@selected_province}
  />
  
  <.select 
    id="district"
    name="district"
    value={@selected_district}
    options={@districts}
    placeholder="选择区县"
    disabled={!@selected_city}
  />
</div>
```

### 远程搜索
```heex
<.select 
  id="remote-search"
  name="user_id"
  searchable
  placeholder="输入用户名搜索"
  loading={@searching_users}
  options={@user_options}
  on_search={JS.push("search_users") |> JS.debounce(300)}
  on_change={JS.push("select_user")}
/>

<!-- LiveView处理 -->
def handle_event("search_users", %{"value" => query}, socket) do
  {:noreply, 
   socket
   |> assign(searching_users: true)
   |> start_async(:search_users, fn -> search_users_from_api(query) end)}
end

def handle_async(:search_users, {:ok, users}, socket) do
  options = Enum.map(users, &%{value: &1.id, label: &1.name})
  {:noreply, assign(socket, user_options: options, searching_users: false)}
end
```

## 与Vue版本对比

### 属性映射
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `v-model` | `value` + `on_change` | 双向绑定 |
| `:options` | `options` | 选项数据 |
| `:mode` | `multiple` | 选择模式 |
| `:show-search` | `searchable` | 是否可搜索 |
| `:filter-option` | 在LiveView中处理 | 过滤逻辑 |
| `:loading` | `loading` | 加载状态 |
| `:allow-clear` | `clearable` | 是否可清除 |
| `:disabled` | `disabled` | 禁用状态 |
| `:tags` | `allow_create` | 标签模式 |

### 迁移示例

Vue代码：
```vue
<a-select
  v-model:value="selectedValue"
  placeholder="请选择"
  :options="options"
  :loading="loading"
  show-search
  allow-clear
  @change="handleChange"
  @search="handleSearch">
</a-select>
```

Phoenix代码：
```heex
<.select 
  id="my-select"
  value={@selected_value}
  placeholder="请选择"
  options={@options}
  loading={@loading}
  searchable
  clearable
  on_change={JS.push("handle_change")}
  on_search={JS.push("handle_search")}
/>
```

## 注意事项

1. **性能优化**
   - 大量选项时考虑使用虚拟滚动
   - 远程搜索应该加入防抖处理
   - 多选时限制最大选择数量

2. **可访问性**
   - 确保键盘导航功能正常
   - 添加适当的ARIA属性
   - 支持屏幕阅读器

3. **用户体验**
   - 选项过多时提供搜索功能
   - 加载状态要有明确提示
   - 错误状态要有清晰反馈

4. **表单集成**
   - 正确处理表单验证
   - 支持表单重置
   - 处理好name属性用于表单提交

## 相关组件
- Radio 单选框 - 选项较少时使用
- Checkbox 多选框 - 多选场景的另一种方案
- Cascader 级联选择 - 选择有层级关系的数据
- TreeSelect 树选择 - 选择树形结构数据
- AutoComplete 自动完成 - 根据输入提供建议