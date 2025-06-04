# Shop UX Phoenix 组件库快速上手

## 🚀 30秒快速开始

### 1. 添加依赖
```elixir
# mix.exs
{:shop_ux_phoenix, path: "../shop_ux_phoenix"}
```

### 2. 导入组件
```elixir
# 在你的 LiveView 中
use ShopUxPhoenixWeb, :live_view
import ShopUxPhoenixWeb.Components.ShopUxComponents
```

### 3. 使用组件
```elixir
<.card title="我的第一个组件">
  <.button color="primary">点击我</.button>
</.card>
```

## 📋 组件速查表

### 最常用的 15 个组件

| 组件 | 用途 | 快速示例 |
|------|------|---------|
| `.form` | 表单容器 | `<.form for={@form} phx-submit="save">` |
| `.input` | 输入框 | `<.input field={@form[:name]} />` |
| `.button` | 按钮 | `<.button>点击</.button>` |
| `.table` | 数据表格 | `<.table rows={@data}>` |
| `.card` | 卡片 | `<.card title="标题">内容</.card>` |
| `.modal` | 弹窗 | `<.modal id="my-modal">` |
| `.select` | 下拉选择 | `<.select options={@options} />` |
| `.tag` | 标签 | `<.tag color="success">标签</.tag>` |
| `.tabs` | 标签页 | `<.tabs tabs={@tabs} />` |
| `.dropdown` | 下拉菜单 | `<.dropdown items={@items} />` |
| `.date_picker` | 日期选择 | `<.date_picker field={@form[:date]} />` |
| `.switch` | 开关 | `<.switch field={@form[:active]} />` |
| `.progress` | 进度条 | `<.progress value={75} />` |
| `.tooltip` | 提示 | `<.tooltip content="提示">悬停</.tooltip>` |
| `.breadcrumb` | 面包屑 | `<.breadcrumb items={@paths} />` |

## 🎨 三种组件来源

1. **Phoenix Core** ⚡ - 内置组件
   - `.form`, `.input`, `.button`, `.link`, `.modal`, `.flash`

2. **Petal Components** 🌸 - 第三方UI库
   - 增强的 `.button`, `.card`, `.dropdown`, `.tabs`

3. **Shop UX Custom** 🛍️ - 业务定制组件
   - `.form_builder`, `.table`(增强版), `.select`(增强版)
   - `.date_picker`, `.address_selector`, `.media_upload`
   - 所有其他业务相关组件

## 📖 详细文档

👉 **[查看完整组件使用指南](docs/guides/COMPONENT_USAGE_GUIDE.md)**

包含：
- 所有 50+ 组件的完整列表
- 详细的 API 文档
- 代码示例
- 最佳实践

## 💡 提示

- 所有组件都支持 Tailwind CSS 类
- 大部分组件支持 `color` 和 `size` 属性
- 组件可以自由组合使用
- 查看 `/demo` 路由看实际效果