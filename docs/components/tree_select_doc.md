# TreeSelect 树选择器组件

## 概述
树型选择控件，可以像Select一样选择，也可以像TreeNode一样展开、收起、选择。

## 何时使用
- 需要从树形结构中选择数据
- 类似Select的选择体验，但数据结构是树形的
- 需要展示层级关系的选择场景
- 组织架构、文件目录、地区选择等场景

## 特性
- 支持树形数据展示
- 支持单选和多选
- 支持搜索过滤
- 支持异步加载数据
- 支持节点禁用
- 支持复选框模式
- 支持自定义节点渲染
- 支持拖拽排序（可选）

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| id | 选择器唯一标识 | string | 必填 |
| name | 表单字段名 | string | nil |
| value | 当前选中的值 | string \| list | nil |
| tree_data | 树形数据源 | list | [] |
| placeholder | 选择框默认文字 | string | "请选择" |
| disabled | 是否禁用 | boolean | false |
| multiple | 支持多选 | boolean | false |
| checkable | 节点前添加复选框 | boolean | false |
| show_search | 是否显示搜索框 | boolean | false |
| search_placeholder | 搜索框占位符 | string | "搜索" |
| tree_default_expand_all | 默认展开所有树节点 | boolean | false |
| tree_default_expanded_keys | 默认展开的树节点 | list | [] |
| tree_checkable | 显示复选框 | boolean | false |
| tree_check_strictly | checkable状态下节点选择完全受控 | boolean | false |
| tree_selectable | 是否可选中 | boolean | true |
| drop_down_style | 下拉菜单的样式 | string | "" |
| max_tag_count | 最多显示多少个tag | integer | nil |
| max_tag_placeholder | 隐藏tag时显示的内容 | string | "+ {count} ..." |
| tree_node_filter_prop | 输入项过滤对应的treeNode属性 | string | "title" |
| tree_node_label_prop | 作为显示的prop设置 | string | "title" |
| allow_clear | 显示清除按钮 | boolean | true |
| size | 选择框大小 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| field_names | 自定义字段名 | map | %{title: "title", key: "key", children: "children"} |
| load_data | 异步加载数据的函数 | function | nil |
| filter_tree_node | 是否根据输入项进行筛选 | boolean \| function | false |
| class | 自定义CSS类 | string | "" |
| on_change | 选中树节点时调用 | JS | %JS{} |
| on_search | 文本框值变化时回调 | JS | %JS{} |
| on_tree_expand | 展开/收起节点时触发 | JS | %JS{} |
| on_select | 点击树节点触发 | JS | %JS{} |
| on_check | 点击复选框触发 | JS | %JS{} |
| on_clear | 清除时触发 | JS | %JS{} |
| rest | 其他HTML属性 | global | - |

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
| info | 信息色 | 信息类组件 |
| success | 成功色 | 成功状态组件 |
| warning | 警告色 | 警告状态组件 |
| danger | 危险色 | 错误状态组件 |

### 数据结构
```elixir
# 基本树形数据结构
tree_data = [
  %{
    title: "Node1",
    key: "0-0",
    children: [
      %{
        title: "Child Node1",
        key: "0-0-1",
        disabled: true
      },
      %{
        title: "Child Node2", 
        key: "0-0-2"
      }
    ]
  },
  %{
    title: "Node2",
    key: "0-1"
  }
]

# 自定义字段名
field_names = %{
  title: "name",
  key: "id", 
  children: "sub_nodes"
}
```

## 示例

### 基本使用
```heex
<.tree_select 
  id="basic-tree"
  tree_data={@tree_data}
  placeholder="请选择节点"
/>
```

### 多选模式
```heex
<.tree_select 
  id="multiple-tree"
  tree_data={@tree_data}
  multiple={true}
  placeholder="请选择多个节点"
/>
```

### 复选框模式
```heex
<.tree_select 
  id="checkable-tree"
  tree_data={@tree_data}
  checkable={true}
  placeholder="请选择节点"
/>
```

### 可搜索
```heex
<.tree_select 
  id="searchable-tree"
  tree_data={@tree_data}
  show_search={true}
  search_placeholder="搜索节点"
/>
```

### 默认展开所有节点
```heex
<.tree_select 
  id="expanded-tree"
  tree_data={@tree_data}
  tree_default_expand_all={true}
/>
```

### 自定义字段名
```heex
<.tree_select 
  id="custom-field"
  tree_data={@custom_tree_data}
  field_names={%{title: "name", key: "id", children: "sub_nodes"}}
/>
```

### 异步加载数据
```heex
<.tree_select 
  id="async-tree"
  tree_data={@initial_tree_data}
  load_data={&load_tree_data/1}
  placeholder="异步加载数据"
/>
```

### 限制标签数量
```heex
<.tree_select 
  id="limited-tags"
  tree_data={@tree_data}
  multiple={true}
  max_tag_count={3}
  max_tag_placeholder="+ {count} 项"
/>
```

### 事件处理
```heex
<.tree_select 
  id="event-tree"
  tree_data={@tree_data}
  on_change={JS.push("tree_changed")}
  on_search={JS.push("tree_searched")}
  on_select={JS.push("node_selected")}
/>
```

### 表单集成
```heex
<.simple_form for={@form} phx-submit="save">
  <.tree_select 
    id="form-tree"
    name="user[department]"
    tree_data={@department_tree}
    value={@form[:department].value}
    placeholder="选择部门"
  />
  <:actions>
    <.button>保存</.button>
  </:actions>
</.simple_form>
```

## 高级用法

### 自定义过滤函数
```elixir
def filter_tree_node(input_value, tree_node) do
  tree_node.title
  |> String.downcase()
  |> String.contains?(String.downcase(input_value))
end
```

### 异步加载数据
```elixir
def load_tree_data(tree_node) do
  case tree_node.key do
    "async-parent" -> 
      [
        %{title: "Async Child 1", key: "async-child-1"},
        %{title: "Async Child 2", key: "async-child-2"}
      ]
    _ -> []
  end
end
```

### 处理节点选择
```elixir
def handle_event("tree_changed", %{"value" => value, "selected_nodes" => nodes}, socket) do
  # 处理选择变化
  {:noreply, assign(socket, selected_value: value, selected_nodes: nodes)}
end

def handle_event("node_selected", %{"selected" => selected, "node" => node}, socket) do
  # 处理节点点击
  {:noreply, socket}
end
```

## 设计规范
- 参考 Ant Design TreeSelect 组件
- 支持键盘导航（上下箭头、回车选择、ESC关闭）
- 支持无障碍访问（ARIA属性）
- 保持与其他选择组件的一致性
- 异步加载时显示加载状态
- 搜索时高亮匹配文本

## TreeSelect vs Select vs Cascader
- **TreeSelect**: 用于树形结构数据选择，支持搜索和多层级展开
- **Select**: 用于平级数据选择，简单快速
- **Cascader**: 用于层级数据的逐级选择，强调路径选择

## 注意事项
- 大数据量时建议使用虚拟滚动
- 异步加载时注意错误处理
- 搜索功能建议添加防抖处理
- 确保树形数据结构正确，避免循环引用
- 多选模式下注意性能优化
- 移动端建议调整交互方式