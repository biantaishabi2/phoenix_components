# 在其他项目中使用组件

现在所有组件都使用了 `PetalComponents.Custom.*` 命名空间，可以轻松地在其他 Phoenix 项目中使用。

## 快速使用方法

### 1. 复制组件文件

将以下文件复制到你的项目中：

```bash
# 创建组件目录
mkdir -p lib/your_project_web/components/petal_custom

# 复制组件文件
cp /path/to/shop_ux_phoenix/lib/shop_ux_phoenix_web/components/*.ex \
   lib/your_project_web/components/petal_custom/
```

### 2. 在项目中导入组件

在 `lib/your_project_web.ex` 中添加：

```elixir
defp html_helpers do
  quote do
    # Phoenix 默认组件
    import Phoenix.HTML
    import YourProjectWeb.CoreComponents
    
    # Petal Custom 组件
    import PetalComponents.Custom.Tag
    import PetalComponents.Custom.Table
    import PetalComponents.Custom.Select
    import PetalComponents.Custom.DatePicker
    import PetalComponents.Custom.RangePicker
    import PetalComponents.Custom.Cascader
    import PetalComponents.Custom.TreeSelect
    import PetalComponents.Custom.Steps
    import PetalComponents.Custom.Statistic
    
    # 或者使用宏一次导入所有组件
    use ShopUxPhoenixWeb.ShopUxComponents
  end
end
```

### 3. 配置 Tailwind CSS

确保你的 `assets/tailwind.config.js` 包含必要的配置：

```javascript
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    // 添加组件路径
    "../lib/*_web/components/**/*.ex"
  ],
  theme: {
    extend: {
      colors: {
        // 添加主色
        primary: "#FD8E25",
      }
    }
  }
}
```

### 4. 使用组件

在你的 LiveView 或模板中：

```heex
<!-- Tag 组件 -->
<PetalComponents.Custom.Tag.tag color="success" size="large">
  成功
</PetalComponents.Custom.Tag.tag>

<!-- Table 组件 -->
<PetalComponents.Custom.Table.table id="users" rows={@users}>
  <:col :let={user} label="姓名"><%= user.name %></:col>
  <:col :let={user} label="邮箱"><%= user.email %></:col>
</PetalComponents.Custom.Table.table>

<!-- Select 组件 -->
<PetalComponents.Custom.Select.select 
  id="city-select"
  options={@cities}
  value={@selected_city}
  on_change={JS.push("select_city")}
/>
```

## 组件列表

| 组件 | 模块名 | 用途 |
|------|--------|------|
| Tag | `PetalComponents.Custom.Tag` | 标签 |
| Table | `PetalComponents.Custom.Table` | 表格 |
| Select | `PetalComponents.Custom.Select` | 选择器 |
| DatePicker | `PetalComponents.Custom.DatePicker` | 日期选择器 |
| RangePicker | `PetalComponents.Custom.RangePicker` | 日期范围选择器 |
| Cascader | `PetalComponents.Custom.Cascader` | 级联选择器 |
| TreeSelect | `PetalComponents.Custom.TreeSelect` | 树形选择器 |
| Steps | `PetalComponents.Custom.Steps` | 步骤条 |
| Statistic | `PetalComponents.Custom.Statistic` | 统计数值 |

## 注意事项

1. **命名冲突**：如果与 CoreComponents 中的组件冲突（如 table），使用完整模块路径调用
2. **样式依赖**：确保项目使用 Tailwind CSS 并包含必要的颜色配置
3. **LiveView 版本**：组件基于 Phoenix LiveView 0.20+ 开发

## 测试

复制测试文件（可选）：

```bash
cp -r /path/to/shop_ux_phoenix/test/shop_ux_phoenix_web/components/* \
      test/your_project_web/components/
```

更新测试文件中的模块引用即可。