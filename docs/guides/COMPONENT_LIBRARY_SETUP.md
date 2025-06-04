# 如何将组件提取为独立库

## 1. 创建新的 Mix 项目

```bash
mix new phoenix_ui_components
cd phoenix_ui_components
```

## 2. 添加依赖

在 `mix.exs` 中添加：

```elixir
defp deps do
  [
    {:phoenix, "~> 1.7"},
    {:phoenix_live_view, "~> 0.20"},
    {:phoenix_html, "~> 4.0"},
    {:jason, "~> 1.4"},
    {:ex_doc, "~> 0.31", only: :dev, runtime: false}
  ]
end
```

## 3. 组织组件结构

```
phoenix_ui_components/
├── lib/
│   ├── phoenix_ui_components.ex
│   └── phoenix_ui_components/
│       ├── tag.ex
│       ├── table.ex
│       ├── select.ex
│       ├── date_picker.ex
│       └── ...
├── mix.exs
└── README.md
```

## 4. 修改组件命名空间

```elixir
# 原来的 ShopUxPhoenixWeb.Components.Tag
# 改为
defmodule PhoenixUiComponents.Tag do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  # 组件代码保持不变
  attr :color, :string, default: "default"
  attr :size, :string, default: "medium"
  # ...
  
  def tag(assigns) do
    # ...
  end
end
```

## 5. 创建主模块导出所有组件

```elixir
# lib/phoenix_ui_components.ex
defmodule PhoenixUiComponents do
  @moduledoc """
  Phoenix UI Components - 可重用的 Phoenix LiveView 组件库
  """
  
  defmacro __using__(_opts) do
    quote do
      import PhoenixUiComponents.Tag
      import PhoenixUiComponents.Table
      import PhoenixUiComponents.Select
      import PhoenixUiComponents.DatePicker
      import PhoenixUiComponents.RangePicker
      import PhoenixUiComponents.Cascader
      import PhoenixUiComponents.TreeSelect
      import PhoenixUiComponents.Steps
      import PhoenixUiComponents.Statistic
    end
  end
end
```

## 6. 在其他项目中使用

### 添加依赖

```elixir
# mix.exs
defp deps do
  [
    # 从 Hex
    {:phoenix_ui_components, "~> 0.1.0"}
    
    # 或从 GitHub
    {:phoenix_ui_components, github: "your-username/phoenix_ui_components"}
    
    # 或从本地路径（开发时）
    {:phoenix_ui_components, path: "../phoenix_ui_components"}
  ]
end
```

### 在项目中导入

```elixir
# 在 lib/your_app_web.ex 中
defp html_helpers do
  quote do
    # 导入所有组件
    use PhoenixUiComponents
    
    # 或单独导入
    import PhoenixUiComponents.Tag
    import PhoenixUiComponents.Table
  end
end
```

### 使用组件

```heex
<.tag color="success" size="large">
  成功
</.tag>

<.table id="users" rows={@users}>
  <:col :let={user} label="姓名"><%= user.name %></:col>
  <:col :let={user} label="邮箱"><%= user.email %></:col>
</.table>
```

## 7. 处理样式依赖

### Tailwind 配置

确保使用组件的项目包含必要的 Tailwind 配置：

```javascript
// assets/tailwind.config.js
module.exports = {
  content: [
    // 添加组件库路径
    "../deps/phoenix_ui_components/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        primary: "#FD8E25", // 如果使用自定义颜色
      }
    }
  }
}
```

### 发布到 Hex.pm

```bash
# 准备发布
mix hex.publish

# 或先发布到私有仓库测试
mix hex.build
```

## 8. 版本管理建议

- 使用语义化版本控制
- 主版本号变更：破坏性改动
- 次版本号变更：新增功能
- 补丁版本号：bug 修复

## 9. 文档建议

为每个组件创建详细文档：

```elixir
@moduledoc """
## 使用示例

    <.tag color="primary">标签</.tag>

## 属性

  * `:color` - 颜色主题，可选值：default, primary, success, warning, danger
  * `:size` - 尺寸，可选值：small, medium, large
  * `:closable` - 是否可关闭
"""
```

## 10. 测试策略

将测试也一起迁移：

```
test/
├── phoenix_ui_components/
│   ├── tag_test.exs
│   ├── table_test.exs
│   └── ...
└── test_helper.exs
```

这样就可以在任何 Phoenix 项目中使用这些组件了！