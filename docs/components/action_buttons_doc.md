# ActionButtons 操作按钮组组件

## 组件概述

ActionButtons 组件用于组织和展示一组相关的操作按钮，提供统一的布局和样式。常用于表格操作列、表单底部、页面顶部等位置，支持灵活的按钮配置和响应式布局。

## 特性

- 支持多种布局方式（水平、垂直、紧凑）
- 自动处理按钮间距
- 支持按钮分组
- 响应式设计，自动适配移动端
- 支持条件渲染
- 内置常见操作模板

## API

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| size | string | "medium" | 按钮尺寸，可选值："small", "medium", "large" |
| spacing | string | "medium" | 按钮间距，可选值："small", "medium", "large", "none" |
| align | string | "left" | 对齐方式，可选值："left", "center", "right", "between" |
| direction | string | "horizontal" | 布局方向，可选值："horizontal", "vertical" |
| compact | boolean | false | 是否紧凑模式（移动端自动开启） |
| divider | boolean | false | 是否在按钮间显示分隔符 |
| class | string | "" | 自定义 CSS 类 |
| rest | global | - | 其他 HTML 属性 |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| inner_block | 默认插槽，放置按钮内容 |
| extra | 额外内容，显示在按钮组末尾 |

## 使用示例

### 基础用法

```elixir
<.action_buttons>
  <.button>编辑</.button>
  <.button>删除</.button>
  <.button>查看详情</.button>
</.action_buttons>
```

### 表格操作列

```elixir
<.table rows={@items}>
  <:col :let={item} label="名称">
    <%= item.name %>
  </:col>
  <:col :let={item} label="操作">
    <.action_buttons size="small" spacing="small">
      <.link navigate={~p"/items/#{item.id}"}>查看</.link>
      <.link navigate={~p"/items/#{item.id}/edit"}>编辑</.link>
      <.link 
        phx-click="delete" 
        phx-value-id={item.id}
        data-confirm="确定要删除吗？"
        class="text-red-600 hover:text-red-700"
      >
        删除
      </.link>
    </.action_buttons>
  </:col>
</.table>
```

### 表单底部按钮

```elixir
<.form for={@form} phx-submit="save" phx-change="validate">
  <!-- 表单字段 -->
  
  <.action_buttons align="right" spacing="medium">
    <.button type="button" phx-click="cancel">
      取消
    </.button>
    <.button type="button" phx-click="save_draft">
      保存草稿
    </.button>
    <.button type="submit" phx-disable-with="保存中...">
      保存
    </.button>
  </.action_buttons>
</.form>
```

### 页面顶部操作栏

```elixir
<div class="mb-6">
  <.action_buttons align="between">
    <div>
      <.button :if={@selected_count > 0} phx-click="batch_delete">
        批量删除 (<%= @selected_count %>)
      </.button>
      <.button :if={@selected_count > 0} phx-click="batch_export">
        批量导出
      </.button>
    </div>
    <:extra>
      <.button phx-click="create_new">
        <.icon name="hero-plus" class="w-4 h-4 mr-1" />
        新建
      </.button>
    </:extra>
  </.action_buttons>
</div>
```

### 垂直布局

```elixir
<.action_buttons direction="vertical" spacing="small">
  <.button icon="hero-pencil">编辑资料</.button>
  <.button icon="hero-key">修改密码</.button>
  <.button icon="hero-bell">通知设置</.button>
  <.button icon="hero-shield-check">隐私设置</.button>
</.action_buttons>
```

### 带分隔符

```elixir
<.action_buttons divider>
  <.link navigate={~p"/dashboard"}>仪表板</.link>
  <.link navigate={~p"/reports"}>报表</.link>
  <.link navigate={~p"/settings"}>设置</.link>
</.action_buttons>
```

### 响应式设计

```elixir
<.action_buttons compact={@mobile?}>
  <.button>操作1</.button>
  <.button>操作2</.button>
  <.button>操作3</.button>
  <.button>操作4</.button>
</.action_buttons>
```

### 条件渲染

```elixir
<.action_buttons>
  <.button :if={@can_edit?} phx-click="edit">
    编辑
  </.button>
  <.button :if={@can_delete?} phx-click="delete">
    删除
  </.button>
  <.button :if={@can_publish?} phx-click="publish">
    发布
  </.button>
  <.link navigate={~p"/items/#{@item.id}"}>
    查看详情
  </.link>
</.action_buttons>
```

### 内置模板：CRUD 操作

```elixir
defmodule MyAppWeb.Components do
  use Phoenix.Component
  import MyAppWeb.CoreComponents
  
  def crud_actions(assigns) do
    ~H"""
    <.action_buttons size="small" spacing="small">
      <.link navigate={@view_path}>查看</.link>
      <.link :if={@can_edit} navigate={@edit_path}>编辑</.link>
      <.link 
        :if={@can_delete}
        phx-click="delete" 
        phx-value-id={@id}
        data-confirm="确定要删除吗？"
        class="text-red-600"
      >
        删除
      </.link>
    </.action_buttons>
    """
  end
end

# 使用
<.crud_actions 
  id={item.id}
  view_path={~p"/items/#{item.id}"}
  edit_path={~p"/items/#{item.id}/edit"}
  can_edit={@current_user.role == :admin}
  can_delete={@current_user.role == :admin}
/>
```

### 批量操作模板

```elixir
def batch_actions(assigns) do
  ~H"""
  <.action_buttons>
    <.dropdown :if={@selected_count > 0}>
      <:trigger>
        <.button>
          批量操作 (<%= @selected_count %>)
          <.icon name="hero-chevron-down" class="w-4 h-4 ml-1" />
        </.button>
      </:trigger>
      <:item phx-click="batch_export">导出所选</:item>
      <:item phx-click="batch_archive">归档所选</:item>
      <:item phx-click="batch_delete" class="text-red-600">删除所选</:item>
    </.dropdown>
    
    <.button type="primary" phx-click={@create_action}>
      <.icon name="hero-plus" class="w-4 h-4 mr-1" />
      <%= @create_label %>
    </.button>
  </.action_buttons>
  """
end
```

## 与 Vue 版本的对比

| Vue/Ant Design | Phoenix | 说明 |
|----------------|---------|------|
| `<a-space>` | `<.action_buttons>` | 组件名称 |
| `:size` | `spacing` | 间距控制 |
| `<a-button-group>` | `<.action_buttons>` | 按钮组 |
| `v-if` | `:if` | 条件渲染 |
| `@click` | `phx-click` | 点击事件 |

## 最佳实践

1. **合理分组**：相关操作放在一起，危险操作（如删除）单独分组或放在最后
2. **限制数量**：表格操作列建议不超过3-4个按钮
3. **明确反馈**：使用 `phx-disable-with` 提供操作反馈
4. **确认危险操作**：删除等危险操作使用 `data-confirm` 二次确认
5. **响应式考虑**：移动端使用紧凑模式或下拉菜单

## 注意事项

1. **按钮类型**：支持混合使用 `<.button>`、`<.link>` 和普通 `<a>` 标签
2. **样式一致性**：组件会自动处理不同元素类型的样式统一
3. **可访问性**：确保所有操作都可通过键盘访问
4. **性能**：大量条件渲染时注意性能影响
5. **语义化**：使用合适的 HTML 元素（链接用于导航，按钮用于操作）

## 相关组件

- Button：单个按钮组件
- Dropdown：下拉菜单组件
- Link：链接组件
- Table：表格组件（常配合使用）