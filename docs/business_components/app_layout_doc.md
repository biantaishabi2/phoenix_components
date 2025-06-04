# AppLayout 应用布局组件文档

## 组件概述

AppLayout 是一个完整的后台管理系统布局组件，提供了侧边栏导航、顶部栏、面包屑导航和主内容区域的布局结构。适用于需要完整导航体系的管理后台页面。

## 组件结构

AppLayout 由以下子组件组成：
- **AppSidebar**: 侧边栏导航组件
- **AppHeader**: 顶部导航栏组件
- **Breadcrumb**: 面包屑导航
- **MainContent**: 主内容容器

## API 参考

### AppLayout 主组件

#### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| page_title | :string | "" | 页面标题 |
| breadcrumbs | :list | [] | 面包屑导航项 |
| current_user | :map | nil | 当前用户信息 |
| collapsed | :boolean | false | 侧边栏是否折叠 |
| class | :string | "" | 自定义 CSS 类 |

#### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| inner_block | 主内容区域 |

### AppSidebar 侧边栏组件

#### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| collapsed | :boolean | false | 是否折叠 |
| menu_items | :list | [] | 菜单项列表 |
| current_path | :string | "" | 当前路径 |
| logo_url | :string | "/images/logo.svg" | Logo 图片路径 |
| collapsed_logo_url | :string | "/images/logo-icon.svg" | 折叠时的 Logo |

### AppHeader 顶部栏组件

#### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title | :string | "" | 系统标题 |
| current_user | :map | nil | 当前用户信息 |
| notifications_count | :integer | 0 | 通知数量 |
| on_toggle_sidebar | :any | nil | 切换侧边栏回调 |

## 使用示例

### 基础用法

```elixir
defmodule MyAppWeb.DashboardLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "仪表盘")
     |> assign(:breadcrumbs, [
       %{title: "首页", path: "/"},
       %{title: "仪表盘", path: nil}
     ])
     |> assign(:current_user, %{
       name: "张三",
       company: "示例公司"
     })}
  end
  
  def render(assigns) do
    ~H"""
    <.app_layout 
      page_title={@page_title}
      breadcrumbs={@breadcrumbs}
      current_user={@current_user}
    >
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- 仪表盘内容 -->
      </div>
    </.app_layout>
    """
  end
end
```

### 自定义菜单

```elixir
def menu_items do
  [
    %{
      key: "dashboard",
      title: "仪表盘",
      icon: "hero-home",
      path: "/dashboard"
    },
    %{
      key: "products",
      title: "商品管理",
      icon: "hero-shopping-bag",
      children: [
        %{key: "product-list", title: "商品列表", path: "/products"},
        %{key: "product-create", title: "新建商品", path: "/products/new"}
      ]
    },
    %{
      key: "orders",
      title: "订单管理",
      icon: "hero-clipboard-document-list",
      children: [
        %{key: "order-list", title: "订单列表", path: "/orders"},
        %{key: "order-ship", title: "批量发货", path: "/orders/ship"}
      ]
    }
  ]
end
```

### 处理侧边栏折叠

```elixir
def handle_event("toggle_sidebar", _params, socket) do
  {:noreply, update(socket, :sidebar_collapsed, &(!&1))}
end

def handle_event("logout", _params, socket) do
  {:noreply, 
   socket
   |> put_flash(:info, "已退出登录")
   |> redirect(to: "/login")}
end
```

### 动态面包屑

```elixir
defp build_breadcrumbs(socket) do
  path = socket.assigns.current_path
  
  base = [%{title: "首页", path: "/"}]
  
  case path do
    "/products" -> base ++ [%{title: "商品管理", path: nil}]
    "/products/" <> id -> 
      base ++ [
        %{title: "商品管理", path: "/products"},
        %{title: "商品详情", path: nil}
      ]
    "/orders" -> base ++ [%{title: "订单管理", path: nil}]
    _ -> base
  end
end
```

## 布局结构

```
┌─────────────────────────────────────────────────────┐
│                    AppHeader                         │
├─────────┬───────────────────────────────────────────┤
│         │  Breadcrumb                                │
│         ├───────────────────────────────────────────┤
│ Sidebar │                                           │
│         │         MainContent                        │
│         │         (Your content here)                │
│         │                                           │
│         │                                           │
└─────────┴───────────────────────────────────────────┘
```

## 响应式设计

- **桌面端**: 完整显示侧边栏和所有导航元素
- **平板端**: 侧边栏可折叠，优化空间利用
- **移动端**: 侧边栏变为抽屉式，通过汉堡菜单触发

## 状态管理

AppLayout 管理以下状态：
- 侧边栏折叠状态
- 当前选中的菜单项
- 面包屑导航路径
- 用户信息和通知

## 事件处理

| 事件名 | 说明 | 参数 |
|--------|------|------|
| toggle_sidebar | 切换侧边栏 | 无 |
| menu_click | 菜单项点击 | %{key: string, path: string} |
| logout | 退出登录 | 无 |
| show_notifications | 显示通知 | 无 |

## 样式定制

### CSS 变量

```css
:root {
  --sidebar-width: 200px;
  --sidebar-collapsed-width: 80px;
  --header-height: 64px;
  --sidebar-bg: #ffffff;
  --header-bg: #ffffff;
}
```

### 自定义主题

```elixir
<.app_layout 
  class="custom-theme"
  sidebar_class="bg-gray-900 text-white"
  header_class="bg-blue-600 text-white"
>
  <!-- 内容 -->
</.app_layout>
```

## 与路由集成

建议在路由中使用 live_session 来共享布局状态：

```elixir
live_session :admin,
  on_mount: [{MyAppWeb.UserAuth, :ensure_authenticated}] do
  
  live "/dashboard", DashboardLive
  live "/products", ProductListLive
  live "/products/:id", ProductDetailLive
  live "/orders", OrderListLive
end
```

## 最佳实践

1. **统一使用**: 在所有需要完整导航的管理页面使用 AppLayout
2. **状态持久化**: 侧边栏折叠状态可以保存到 localStorage
3. **权限控制**: 根据用户权限动态生成菜单项
4. **加载状态**: 在数据加载时显示适当的加载指示器
5. **错误处理**: 统一处理导航和操作错误

## 注意事项

1. AppLayout 是一个业务组件，不是替代 Phoenix 的默认布局
2. 需要配合路由和认证系统使用
3. 移动端需要额外的 JavaScript 来处理抽屉式菜单
4. 确保所有子页面都正确设置了 page_title 和 breadcrumbs