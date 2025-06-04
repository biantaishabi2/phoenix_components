# Shop UX Phoenix 组件使用指南

本指南详细说明了如何在项目中使用 Shop UX Phoenix 组件库的所有组件。

## 📦 组件来源说明

我们的组件库包含三种来源的组件：

1. **Phoenix Core Components** - Phoenix LiveView 内置的核心组件
2. **Petal Components** - 第三方 Tailwind CSS 组件库
3. **Shop UX Components** - 我们自定义开发的业务组件

## 🚀 快速开始

### 1. 在新项目中使用

```elixir
# mix.exs
defp deps do
  [
    # ... 其他依赖
    {:shop_ux_phoenix, path: "../shop_ux_phoenix"}
  ]
end
```

### 2. 导入组件

```elixir
# 在你的 LiveView 或组件模块中
use ShopUxPhoenixWeb, :live_view
import ShopUxPhoenixWeb.Components.ShopUxComponents

# 或者单独导入特定组件
import ShopUxPhoenixWeb.Components.Table
import ShopUxPhoenixWeb.Components.FormBuilder
```

## 📋 完整组件列表

### 一、表单组件 (Form Components)

| 组件名称 | 来源 | 功能描述 | 使用示例 |
|---------|------|---------|---------|
| `.form` | Phoenix Core | 基础表单容器 | `<.form for={@form} phx-submit="save">` |
| `.input` | Phoenix Core | 基础输入框（支持多种类型） | `<.input field={@form[:name]} type="text" />` |
| `.label` | Phoenix Core | 表单标签 | `<.label for="email">邮箱</.label>` |
| `.error` | Phoenix Core | 错误信息显示 | `<.error :if={@error}>错误信息</.error>` |
| `.simple_form` | Phoenix Core | 简单表单容器 | `<.simple_form for={@form}>` |
| `.form_builder` | Shop UX | 动态表单构建器 | `<.form_builder fields={@fields} />` |
| `.select` | Shop UX | 增强选择框 | `<.select options={@options} />` |
| `.searchable_select` | Shop UX | 可搜索选择框 | `<.searchable_select options={@options} />` |
| `.tree_select` | Shop UX | 树形选择器 | `<.tree_select data={@tree_data} />` |
| `.cascader` | Shop UX | 级联选择器 | `<.cascader options={@regions} />` |
| `.input_number` | Shop UX | 数字输入框 | `<.input_number min={0} max={100} />` |
| `.switch` | Shop UX | 开关组件 | `<.switch field={@form[:enabled]} />` |
| `.date_picker` | Shop UX | 日期选择器 | `<.date_picker field={@form[:date]} />` |
| `.range_picker` | Shop UX | 日期范围选择器 | `<.range_picker start_field={@form[:start]} />` |
| `.address_selector` | Shop UX | 地址选择器 | `<.address_selector field={@form[:address]} />` |

### 二、数据展示组件 (Data Display Components)

| 组件名称 | 来源 | 功能描述 | 使用示例 |
|---------|------|---------|---------|
| `.table` | Shop UX/Petal | 数据表格（增强版） | `<.table rows={@products}>` |
| `.list` | Phoenix Core | 基础列表 | `<.list items={@items}>` |
| `.card` | Shop UX/Petal | 卡片容器 | `<.card title="标题">内容</.card>` |
| `.statistic` | Shop UX | 统计数值展示 | `<.statistic value={1000} label="总销量" />` |
| `.tag` | Shop UX | 标签 | `<.tag color="primary">标签</.tag>` |
| `.status_badge` | Shop UX | 状态徽章 | `<.status_badge status={:active} />` |
| `.progress` | Shop UX | 进度条 | `<.progress value={60} />` |
| `.timeline` | Shop UX | 时间轴 | `<.timeline items={@events} />` |
| `.breadcrumb` | Shop UX/Petal | 面包屑导航 | `<.breadcrumb items={@paths} />` |
| `.tooltip` | Shop UX | 提示框 | `<.tooltip content="提示">悬停我</.tooltip>` |

### 三、操作反馈组件 (Feedback Components)

| 组件名称 | 来源 | 功能描述 | 使用示例 |
|---------|------|---------|---------|
| `.button` | Phoenix Core/Petal | 按钮 | `<.button type="submit">提交</.button>` |
| `.link` | Phoenix Core | 链接 | `<.link navigate={~p"/users"}>用户列表</.link>` |
| `.modal` | Phoenix Core | 模态框 | `<.modal id="user-modal">` |
| `.flash` | Phoenix Core | 闪存消息 | `<.flash kind={:info} flash={@flash} />` |
| `.flash_group` | Phoenix Core | 闪存消息组 | `<.flash_group flash={@flash} />` |
| `.action_buttons` | Shop UX | 操作按钮组 | `<.action_buttons actions={@actions} />` |
| `.dropdown` | Shop UX/Petal | 下拉菜单 | `<.dropdown items={@menu_items} />` |

### 四、布局组件 (Layout Components)

| 组件名称 | 来源 | 功能描述 | 使用示例 |
|---------|------|---------|---------|
| `.header` | Phoenix Core | 页面头部 | `<.header>页面标题</.header>` |
| `.tabs` | Shop UX/Petal | 标签页 | `<.tabs tabs={@tabs} active={@active_tab} />` |
| `.steps` | Shop UX | 步骤条 | `<.steps items={@steps} current={2} />` |
| `.app_layout` | Shop UX | 应用布局（侧边栏+主内容） | `<.app_layout sidebar={@menu}>` |
| `.filter_form` | Shop UX | 筛选表单布局 | `<.filter_form filters={@filters} />` |

### 五、文件上传组件 (Upload Components)

| 组件名称 | 来源 | 功能描述 | 使用示例 |
|---------|------|---------|---------|
| `.live_file_input` | Phoenix Core | 文件上传基础组件 | `<.live_file_input upload={@uploads.avatar} />` |
| `.media_upload` | Shop UX | 媒体文件上传（图片/视频） | `<.media_upload upload={@uploads.images} />` |

### 六、图标组件 (Icon Components)

| 组件名称 | 来源 | 功能描述 | 使用示例 |
|---------|------|---------|---------|
| `.icon` | Phoenix Core | 基础图标 | `<.icon name="hero-user" />` |
| `.icon` | Petal | Heroicons 图标 | `<.icon name="hero-home" class="w-5 h-5" />` |

## 🎨 组件样式定制

### 1. 使用 Tailwind CSS 类

所有组件都支持通过 `class` 属性添加自定义样式：

```elixir
<.button class="bg-purple-600 hover:bg-purple-700">
  自定义按钮
</.button>
```

### 2. 主题颜色

大部分组件支持 `color` 属性，可选值：
- `primary` (默认)
- `secondary`
- `success`
- `warning`
- `danger`
- `info`

```elixir
<.tag color="success">成功</.tag>
<.button color="danger">删除</.button>
```

### 3. 尺寸控制

支持尺寸的组件通常有 `size` 属性：
- `small`
- `medium` (默认)
- `large`

```elixir
<.table size="small" rows={@data} />
<.button size="large">大按钮</.button>
```

## 📝 使用示例

### 完整的表单示例

```elixir
<.simple_form for={@form} phx-submit="save">
  <.input field={@form[:name]} type="text" label="姓名" required />
  
  <.select 
    field={@form[:category]} 
    options={[{"电子产品", "electronics"}, {"服装", "clothing"}]}
    label="分类"
  />
  
  <.date_picker field={@form[:date]} label="日期" />
  
  <.switch field={@form[:active]} label="是否启用" />
  
  <:actions>
    <.button type="submit">保存</.button>
    <.button type="button" color="secondary" phx-click="cancel">
      取消
    </.button>
  </:actions>
</.simple_form>
```

### 数据表格示例

```elixir
<.table 
  id="products-table"
  rows={@products}
  row_click={fn product -> JS.navigate(~p"/products/#{product}") end}
>
  <:col :let={product} label="名称">
    <%= product.name %>
  </:col>
  
  <:col :let={product} label="价格" text_align="right">
    ¥<%= product.price %>
  </:col>
  
  <:col :let={product} label="状态">
    <.status_badge status={product.status} />
  </:col>
  
  <:action :let={product}>
    <.link navigate={~p"/products/#{product}/edit"}>
      编辑
    </.link>
  </:action>
</.table>
```

## 🔧 高级用法

### 1. 组合使用

```elixir
<.card>
  <:header>
    <.breadcrumb items={[
      %{label: "首页", path: "/"},
      %{label: "产品管理", path: "/products"},
      %{label: "编辑产品"}
    ]} />
  </:header>
  
  <.form_builder 
    fields={@form_fields}
    values={@form_values}
    phx-change="validate"
    phx-submit="save"
  />
</.card>
```

### 2. 自定义组件

基于现有组件创建自定义组件：

```elixir
defmodule MyAppWeb.Components do
  use Phoenix.Component
  import ShopUxPhoenixWeb.Components.ShopUxComponents
  
  def product_card(assigns) do
    ~H"""
    <.card class="hover:shadow-lg transition-shadow">
      <:header>
        <h3 class="text-lg font-semibold"><%= @product.name %></h3>
      </:header>
      
      <.statistic value={@product.price} prefix="¥" label="价格" />
      
      <:footer>
        <.action_buttons actions={[
          %{label: "查看", icon: "hero-eye", action: "view"},
          %{label: "编辑", icon: "hero-pencil", action: "edit"}
        ]} />
      </:footer>
    </.card>
    """
  end
end
```

## 📚 更多资源

- [组件详细文档](../components/) - 每个组件的完整 API 文档
- [组件开发指南](COMPONENT_DEVELOPMENT_GUIDE.md) - 如何开发新组件
- [测试指南](LIVEVIEW_TESTING_GUIDE.md) - 组件测试方法

## ❓ 常见问题

### Q: 如何知道组件来自哪里？

A: 一般规则：
- 简单的单词组件（如 `.form`, `.input`）来自 Phoenix Core
- 业务相关的组件（如 `.form_builder`, `.address_selector`）来自 Shop UX
- 一些通用 UI 组件可能来自 Petal Components

### Q: 能否同时使用多个来源的组件？

A: 可以！所有组件都设计为可以协同工作。例如：

```elixir
# 混合使用不同来源的组件
<.card>                           # Shop UX/Petal
  <.form for={@form}>            # Phoenix Core
    <.input field={@form[:name]} /># Phoenix Core
    <.select options={@options} /> # Shop UX
  </.form>
</.card>
```

### Q: 如何处理样式冲突？

A: 优先级规则：
1. 组件的 `class` 属性中的类会覆盖默认样式
2. Shop UX 组件的样式优先级高于 Petal Components
3. 使用 `!important` 强制覆盖（不推荐）