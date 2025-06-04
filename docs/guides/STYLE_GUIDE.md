# Shop UX Phoenix 样式指南

## 与 Petal Components 的一致性

为了确保自定义组件与 Petal Components 库的样式一致性，我们采用以下设计规范：

## CSS 命名规范

### 基础规则
- **前缀**：所有组件类名使用 `pc-` 前缀
- **组件名**：使用小写字母和连字符，如 `pc-steps`、`pc-statistic`
- **BEM 结构**：
  - 元素：`pc-component__element`
  - 修饰符：`pc-component--modifier`
  - 组合：`pc-component__element--modifier`

### 示例
```css
/* 基础组件 */
.pc-steps { }
.pc-statistic { }

/* 元素 */
.pc-steps__item { }
.pc-statistic__value { }
.pc-statistic__title { }

/* 修饰符 */
.pc-steps--vertical { }
.pc-statistic--info { }

/* 组合 */
.pc-steps__item--active { }
```

## 颜色系统

### 语义化颜色
使用 Petal Components 的标准颜色语义：
- `info` - 信息（蓝色）
- `success` - 成功（绿色）
- `warning` - 警告（黄色）
- `danger` - 危险（红色）

### 变体
- `light` - 浅色变体
- `soft` - 柔和变体  
- `dark` - 深色变体
- `outline` - 边框变体

### 示例
```css
.pc-alert--info-light { }
.pc-button--success-outline { }
.pc-badge--warning-soft { }
```

## 暗色模式支持

所有组件都应支持暗色模式，使用 Tailwind 的 `dark:` 前缀：

```css
.pc-component {
  @apply bg-white text-gray-900;
  @apply dark:bg-gray-800 dark:text-gray-100;
}
```

## 组件结构模式

### 容器模式
```elixir
def component(assigns) do
  ~H"""
  <div class={["pc-component", variant_classes(@variant, @color), @class]} {@rest}>
    <div class="pc-component__inner">
      <!-- 内容 -->
    </div>
  </div>
  """
end
```

### 属性定义模式
```elixir
attr(:color, :string, 
  default: "info", 
  values: ["info", "success", "warning", "danger"]
)
attr(:variant, :string, 
  default: "light", 
  values: ["light", "soft", "dark", "outline"]
)
attr(:class, :any, default: nil)
attr(:rest, :global)
```

### 样式类生成模式
```elixir
defp variant_classes(variant, color) do
  "pc-component--#{color}-#{variant}"
end
```

## 现有组件重构指南

### Steps 组件
```css
/* 当前 */
.steps-container → .pc-steps
.step-item → .pc-steps__item
.step-active → .pc-steps__item--active

/* 新增变体 */
.pc-steps--info
.pc-steps--success
.pc-steps--vertical
```

### Statistic 组件
```css
/* 当前 */
.statistic-container → .pc-statistic
.statistic-value → .pc-statistic__value
.statistic-title → .pc-statistic__title

/* 新增变体 */
.pc-statistic--info
.pc-statistic--success
.pc-statistic--large
```

### Tag 组件
```css
/* 当前 */
.tag → .pc-tag
.tag-closable → .pc-tag--closable

/* 新增变体 */
.pc-tag--info-light
.pc-tag--success-outline
```

## 测试规范

确保所有样式变体都有对应的测试：

```elixir
test "renders with color variants" do
  for color <- ["info", "success", "warning", "danger"] do
    html = render_component(&component/1, %{color: color})
    assert html =~ "pc-component--#{color}"
  end
end
```

## 文档规范

每个组件都应包含：
- 基础用法示例
- 所有属性说明
- 颜色变体示例
- 暗色模式展示

## 迁移清单

- [ ] 更新 Steps 组件使用 pc- 前缀
- [ ] 更新 Statistic 组件使用 pc- 前缀  
- [ ] 更新 Tag 组件使用 pc- 前缀
- [ ] 更新 Table 组件使用 pc- 前缀
- [ ] 更新 Select 组件使用 pc- 前缀
- [ ] 更新 DatePicker 组件使用 pc- 前缀
- [ ] 更新 RangePicker 组件使用 pc- 前缀
- [ ] 更新 Cascader 组件使用 pc- 前缀
- [ ] 更新 TreeSelect 组件使用 pc- 前缀
- [ ] 添加语义化颜色支持
- [ ] 添加暗色模式支持
- [ ] 更新所有测试
- [ ] 更新文档