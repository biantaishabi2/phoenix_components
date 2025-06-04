# Dropdown 下拉菜单组件文档

## 组件概述

Dropdown 下拉菜单组件提供了一个可以显示一组选项或操作的浮层菜单。支持多种触发方式、自定义菜单内容和灵活的位置控制。

## API 参考

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| id | :string | 自动生成 | 下拉菜单的唯一标识符 |
| trigger_type | :string | "click" | 触发方式，可选值："click", "hover" |
| position | :string | "bottom-start" | 菜单位置，可选值："bottom-start", "bottom-end", "top-start", "top-end", "left", "right" |
| disabled | :boolean | false | 是否禁用下拉菜单 |
| arrow | :boolean | false | 是否显示箭头 |
| offset | :integer | 4 | 菜单与触发器的间距（像素） |
| class | :string | "" | 自定义 CSS 类 |
| menu_class | :string | "" | 菜单容器的自定义 CSS 类 |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| trigger | 触发器内容（默认插槽） |
| items | 菜单项列表 |

### 菜单项属性

| 属性 | 类型 | 说明 |
|------|------|------|
| key | :string | 菜单项的唯一标识 |
| label | :string | 菜单项显示文本 |
| icon | :string | 菜单项图标（SVG 或 HTML） |
| disabled | :boolean | 是否禁用该菜单项 |
| divider | :boolean | 是否为分隔线 |
| danger | :boolean | 是否为危险操作样式 |
| on_click | JS | 点击事件处理 |

## 使用示例

### 基础用法

```elixir
<.dropdown>
  <:trigger>
    <.button>
      操作
      <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
    </.button>
  </:trigger>
  <:items>
    <:item key="edit" label="编辑" icon={~s(<svg>...</svg>)} on_click={JS.push("edit")} />
    <:item key="copy" label="复制" on_click={JS.push("copy")} />
    <:item divider />
    <:item key="delete" label="删除" danger on_click={JS.push("delete")} />
  </:items>
</.dropdown>
```

### 悬停触发

```elixir
<.dropdown trigger_type="hover">
  <:trigger>
    <span class="cursor-pointer">更多选项</span>
  </:trigger>
  <:items>
    <:item key="option1" label="选项 1" />
    <:item key="option2" label="选项 2" />
  </:items>
</.dropdown>
```

### 不同位置

```elixir
<.dropdown position="top-start">
  <:trigger>
    <.button>上方左对齐</.button>
  </:trigger>
  <:items>
    <:item key="item1" label="菜单项 1" />
    <:item key="item2" label="菜单项 2" />
  </:items>
</.dropdown>
```

### 带图标的菜单项

```elixir
<.dropdown>
  <:trigger>
    <.button>文件操作</.button>
  </:trigger>
  <:items>
    <:item 
      key="new" 
      label="新建" 
      icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>)}
      on_click={JS.push("new_file")} 
    />
    <:item 
      key="open" 
      label="打开" 
      icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg>)}
      on_click={JS.push("open_file")} 
    />
    <:item divider />
    <:item 
      key="save" 
      label="保存" 
      icon={~s(<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" /></svg>)}
      on_click={JS.push("save_file")} 
    />
  </:items>
</.dropdown>
```

### 禁用状态

```elixir
<.dropdown disabled>
  <:trigger>
    <.button disabled>已禁用</.button>
  </:trigger>
  <:items>
    <:item key="item1" label="菜单项 1" />
  </:items>
</.dropdown>
```

### 批量操作下拉菜单

```elixir
<.dropdown>
  <:trigger>
    <.button>
      批量操作
      <.icon name="hero-chevron-down-mini" class="ml-1 w-4 h-4" />
    </.button>
  </:trigger>
  <:items>
    <:item key="export" label="导出" on_click={JS.push("batch_export")} />
    <:item key="archive" label="归档" on_click={JS.push("batch_archive")} />
    <:item divider />
    <:item 
      key="delete" 
      label="删除" 
      danger
      on_click={JS.push("batch_delete", value: %{confirm: true})} 
    />
  </:items>
</.dropdown>
```

### 自定义菜单内容

```elixir
<.dropdown menu_class="w-64 p-4">
  <:trigger>
    <.button>用户菜单</.button>
  </:trigger>
  <:items>
    <div class="flex items-center mb-3 pb-3 border-b">
      <img src="/avatar.jpg" class="w-10 h-10 rounded-full mr-3" />
      <div>
        <div class="font-medium">张三</div>
        <div class="text-sm text-gray-500">admin@example.com</div>
      </div>
    </div>
    <:item key="profile" label="个人资料" on_click={JS.navigate("/profile")} />
    <:item key="settings" label="设置" on_click={JS.navigate("/settings")} />
    <:item divider />
    <:item key="logout" label="退出登录" on_click={JS.push("logout")} />
  </:items>
</.dropdown>
```

## 样式定制

### 使用自定义类

```elixir
<.dropdown 
  class="my-dropdown" 
  menu_class="bg-gray-900 text-white border-gray-700"
>
  <:trigger>
    <.button>深色主题菜单</.button>
  </:trigger>
  <:items>
    <:item key="item1" label="菜单项 1" />
    <:item key="item2" label="菜单项 2" />
  </:items>
</.dropdown>
```

### 响应式设计

```elixir
<.dropdown position="bottom-end" menu_class="w-full sm:w-48">
  <:trigger>
    <.button class="w-full sm:w-auto">响应式菜单</.button>
  </:trigger>
  <:items>
    <:item key="item1" label="菜单项 1" />
    <:item key="item2" label="菜单项 2" />
  </:items>
</.dropdown>
```

## 实际应用场景

### 表格行操作

```elixir
<.table>
  <:col :let={item} label="操作">
    <.dropdown position="bottom-end">
      <:trigger>
        <.button size="sm" variant="ghost">
          <.icon name="hero-ellipsis-horizontal" class="w-4 h-4" />
        </.button>
      </:trigger>
      <:items>
        <:item key="view" label="查看" on_click={JS.navigate("/items/#{item.id}")} />
        <:item key="edit" label="编辑" on_click={JS.navigate("/items/#{item.id}/edit")} />
        <:item divider />
        <:item key="delete" label="删除" danger on_click={JS.push("delete", value: %{id: item.id})} />
      </:items>
    </.dropdown>
  </:col>
</.table>
```

### 导航栏用户菜单

```elixir
<nav class="flex justify-between items-center">
  <div>Logo</div>
  <.dropdown position="bottom-end">
    <:trigger>
      <button class="flex items-center space-x-2">
        <img src={@current_user.avatar} class="w-8 h-8 rounded-full" />
        <span><%= @current_user.name %></span>
        <.icon name="hero-chevron-down-mini" class="w-4 h-4" />
      </button>
    </:trigger>
    <:items>
      <:item key="dashboard" label="控制台" on_click={JS.navigate("/dashboard")} />
      <:item key="profile" label="个人资料" on_click={JS.navigate("/profile")} />
      <:item divider />
      <:item key="logout" label="退出" on_click={JS.push("logout")} />
    </:items>
  </.dropdown>
</nav>
```

## 与 Vue 版本的对比

| 特性 | Vue (Ant Design) | Phoenix |
|------|------------------|----------|
| 触发方式 | trigger="click/hover/contextMenu" | trigger="click/hover" |
| 位置控制 | placement 属性 | position 属性 |
| 菜单定义 | <a-menu> 组件 | :items 插槽 |
| 事件处理 | @click 事件 | on_click={JS.push(...)} |
| 禁用状态 | :disabled | disabled 属性 |
| 分隔线 | <a-menu-divider> | :item divider |

## 注意事项

1. **无障碍性**: 组件自动添加了 ARIA 属性，确保键盘导航和屏幕阅读器支持
2. **性能**: 使用 LiveView JS 实现动画，避免服务器往返
3. **响应式**: 在移动设备上自动调整菜单位置和宽度
4. **主题**: 支持通过 Tailwind CSS 类自定义外观

## 常见问题

### 如何在菜单项中添加图标？
使用 `icon` 属性传入 SVG HTML 字符串。

### 如何实现多级菜单？
当前版本不支持多级菜单。如需此功能，建议使用嵌套的 Dropdown 组件或考虑使用 Cascader 组件。

### 如何控制菜单的宽度？
使用 `menu_class` 属性添加宽度相关的 Tailwind CSS 类，如 `w-48` 或 `min-w-[200px]`。

### 如何实现右键菜单？
当前版本不支持右键触发。如需此功能，需要额外的 JavaScript 处理。