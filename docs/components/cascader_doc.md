# Cascader 级联选择器组件

## 概述
级联选择器，用于从一组相关联的数据集合中进行选择，常用于省市区选择、部门选择等场景。

## 何时使用
- 需要从一组有关联关系的数据中进行选择
- 选项具有清晰的层级关系
- 希望一次完成多级选择
- 需要节省页面空间

## 特性
- 支持多级数据展示
- 支持单选和多选
- 支持搜索功能
- 支持自定义字段名
- 支持动态加载数据
- 支持禁用状态
- 支持清除功能
- 支持自定义显示格式

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| id | 选择器唯一标识 | string | 必填 |
| name | 表单字段名 | string | nil |
| value | 当前选中的值路径 | list | nil |
| options | 可选项数据源 | list | [] |
| placeholder | 占位文字 | string | "请选择" |
| disabled | 是否禁用 | boolean | false |
| multiple | 是否多选 | boolean | false |
| searchable | 是否可搜索 | boolean | false |
| clearable | 是否可清除 | boolean | true |
| size | 尺寸 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| expand_trigger | 次级菜单的展开方式 | string (click/hover) | "click" |
| change_on_select | 是否允许选择任意一级选项 | boolean | false |
| show_all_levels | 是否显示完整路径 | boolean | true |
| separator | 分隔符 | string | " / " |
| field_names | 自定义字段名 | map | %{label: "label", value: "value", children: "children"} |
| load_data | 动态加载数据的函数 | function | nil |
| class | 自定义CSS类 | string | "" |
| on_change | 选中值改变时的回调 | JS | %JS{} |
| on_clear | 清除选中值时的回调 | JS | %JS{} |
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
# 基本数据结构
options = [
  %{
    value: "zhejiang",
    label: "浙江",
    children: [
      %{
        value: "hangzhou",
        label: "杭州",
        children: [
          %{value: "xihu", label: "西湖"},
          %{value: "yuhang", label: "余杭"}
        ]
      }
    ]
  }
]

# 自定义字段名
field_names = %{
  label: "name",
  value: "id", 
  children: "sub_items"
}
```

### 示例

#### 基本使用
```heex
<.cascader 
  id="area-select"
  options={@area_options}
  placeholder="请选择地区"
/>
```

#### 多选模式
```heex
<.cascader 
  id="multi-area"
  options={@area_options}
  multiple={true}
  placeholder="请选择多个地区"
/>
```

#### 可搜索
```heex
<.cascader 
  id="search-area"
  options={@area_options}
  searchable={true}
  placeholder="搜索地区"
/>
```

#### 自定义字段名
```heex
<.cascader 
  id="custom-field"
  options={@custom_options}
  field_names={%{label: "name", value: "id", children: "sub_items"}}
/>
```

#### 允许选择任意级别
```heex
<.cascader 
  id="any-level"
  options={@area_options}
  change_on_select={true}
  placeholder="可选择任意级别"
/>
```

#### 悬停展开
```heex
<.cascader 
  id="hover-expand"
  options={@area_options}
  expand_trigger="hover"
/>
```

#### 动态加载数据
```heex
<.cascader 
  id="lazy-load"
  options={@initial_options}
  load_data={&load_children/1}
  placeholder="动态加载数据"
/>
```

#### 自定义显示格式
```heex
<.cascader 
  id="custom-display"
  options={@area_options}
  show_all_levels={false}
  separator=" > "
/>
```

#### 事件处理
```heex
<.cascader 
  id="event-cascader"
  options={@area_options}
  on_change={JS.push("area_changed")}
  on_clear={JS.push("area_cleared")}
/>
```

#### 表单集成
```heex
<.simple_form for={@form} phx-submit="save">
  <.cascader 
    id="form-area"
    name="user[area]"
    options={@area_options}
    value={@form[:area].value}
  />
  <:actions>
    <.button>保存</.button>
  </:actions>
</.simple_form>
```

## 高级用法

### 动态加载数据
```elixir
def load_children(selected_options) do
  # 根据已选择的选项加载下级数据
  case selected_options do
    [] -> load_provinces()
    [province] -> load_cities(province)
    [province, city] -> load_districts(province, city)
    _ -> []
  end
end
```

### 自定义过滤
```elixir
def filter_options(options, search_term) do
  # 自定义搜索逻辑
  options
  |> Enum.filter(fn option ->
    String.contains?(String.downcase(option.label), String.downcase(search_term))
  end)
end
```

## 设计规范
- 参考 Ant Design Cascader 组件
- 支持键盘导航
- 支持无障碍访问
- 层级不宜过深（建议不超过4级）
- 每级选项数量不宜过多（建议不超过50个）

## 与Select的区别
- Cascader用于层级数据选择，Select用于平级数据选择
- Cascader显示完整路径，Select只显示当前选项
- Cascader支持逐级展开，Select是直接下拉列表
- Cascader适合地区选择等场景，Select适合状态选择等场景

## 注意事项
- 确保数据结构正确，避免循环引用
- 大数据量时建议使用动态加载
- 多选模式下注意性能优化
- 搜索功能建议添加防抖处理
- 移动端建议使用专门的移动端选择器