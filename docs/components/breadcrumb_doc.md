# Breadcrumb 面包屑导航组件

面包屑导航组件，用于显示当前页面在网站层次结构中的位置。

## 基础用法

```elixir
<.breadcrumb items={[
  %{title: "首页", path: "/"},
  %{title: "产品管理", path: "/products"},
  %{title: "产品列表", path: nil}
]} />
```

## 带图标的面包屑

```elixir
<.breadcrumb items={[
  %{title: "首页", path: "/", icon: "hero-home"},
  %{title: "用户管理", path: "/users", icon: "hero-users"},
  %{title: "用户详情", path: nil, icon: "hero-user"}
]} />
```

## 自定义分隔符

```elixir
<.breadcrumb 
  separator="/" 
  items={[
    %{title: "首页", path: "/"},
    %{title: "设置", path: "/settings"},
    %{title: "账户设置", path: nil}
  ]} 
/>
```

## 最大显示项数

```elixir
<.breadcrumb 
  max_items={3}
  items={[
    %{title: "首页", path: "/"},
    %{title: "产品管理", path: "/products"},
    %{title: "分类管理", path: "/products/categories"},
    %{title: "子分类", path: "/products/categories/sub"},
    %{title: "详情", path: nil}
  ]} 
/>
```

## 不同尺寸

```elixir
<!-- 小尺寸 -->
<.breadcrumb size="small" items={@items} />

<!-- 默认尺寸 -->
<.breadcrumb size="medium" items={@items} />

<!-- 大尺寸 -->
<.breadcrumb size="large" items={@items} />
```

## 响应式隐藏

```elixir
<.breadcrumb 
  responsive={true}
  items={@items} 
/>
```

## API

### 属性

| 属性名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `items` | `list` | `[]` | 面包屑项列表 |
| `separator` | `string` | `"chevron"` | 分隔符类型: `"chevron"`, `"slash"`, `"arrow"` 或自定义字符 |
| `size` | `string` | `"medium"` | 尺寸: `"small"`, `"medium"`, `"large"` |
| `max_items` | `integer` | `nil` | 最大显示项数，超出时中间显示省略号 |
| `responsive` | `boolean` | `false` | 是否在移动端隐藏中间项 |
| `show_home` | `boolean` | `true` | 是否显示首页链接 |
| `home_title` | `string` | `"首页"` | 首页显示文字 |
| `home_path` | `string` | `"/"` | 首页链接地址 |
| `home_icon` | `string` | `"hero-home"` | 首页图标 |
| `class` | `string` | `""` | 自定义CSS类 |
| `rest` | `global` | - | 其他HTML属性 |

### 面包屑项属性

每个面包屑项支持以下属性：

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `title` | `string` | 显示文字 |
| `path` | `string` | 链接地址，为`nil`时不可点击 |
| `icon` | `string` | 图标名称（可选） |
| `overlay` | `string` | 提示文字（可选） |

### 插槽

| 插槽名 | 说明 |
|--------|------|
| `item` | 自定义面包屑项内容 |
| `separator` | 自定义分隔符内容 |

## 样式定制

### 尺寸规格

| 尺寸 | 文字大小 | 图标大小 | 间距 |
|------|----------|----------|------|
| `small` | `text-xs` | `h-3 w-3` | `space-x-1` |
| `medium` | `text-sm` | `h-4 w-4` | `space-x-2` |
| `large` | `text-base` | `h-5 w-5` | `space-x-3` |

### 分隔符类型

| 类型 | 显示 | 说明 |
|------|------|------|
| `chevron` | `>` | 右箭头图标（默认） |
| `slash` | `/` | 斜杠字符 |
| `arrow` | `→` | 箭头字符 |
| 自定义 | 任意字符 | 传入具体字符串 |

## 使用场景

### 1. 页面导航
在后台管理系统中显示当前页面位置：

```elixir
<.breadcrumb items={[
  %{title: "首页", path: "/"},
  %{title: "商品管理", path: "/products"},
  %{title: "商品列表", path: nil}
]} />
```

### 2. 多级分类导航
在商品分类页面显示分类层级：

```elixir
<.breadcrumb items={[
  %{title: "所有分类", path: "/categories"},
  %{title: "电子产品", path: "/categories/electronics"},
  %{title: "手机", path: "/categories/electronics/phones"},
  %{title: "智能手机", path: nil}
]} />
```

### 3. 文件路径导航
在文件管理系统中显示文件路径：

```elixir
<.breadcrumb 
  separator="/"
  items={[
    %{title: "根目录", path: "/files"},
    %{title: "文档", path: "/files/documents"},
    %{title: "项目文档", path: "/files/documents/projects"},
    %{title: "README.md", path: nil}
  ]} 
/>
```

## 设计原则

1. **清晰的层级关系**：通过视觉分隔符明确显示页面层级
2. **易于导航**：除最后一项外都可点击跳转
3. **空间高效**：在有限空间内显示完整路径信息
4. **响应式友好**：在小屏幕设备上合理显示或隐藏部分项目

## 注意事项

1. 面包屑项的`path`为`nil`时表示当前页面，不可点击
2. 使用`max_items`时，会保留首尾项目，中间显示省略号
3. 图标是可选的，建议在需要强调某些层级时使用
4. 分隔符支持自定义，但建议保持一致性