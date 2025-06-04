# 组件开发规范指南

## 一、总体原则

### 1.1 设计理念
- **迁移友好**：API设计参考原Vue项目，降低迁移成本
- **生态融合**：遵循Phoenix和Petal Components的设计规范
- **渐进增强**：先实现核心功能，再逐步完善高级特性
- **测试驱动**：先写文档和测试，再实现功能

### 1.2 开发流程
1. 分析原Vue组件的使用场景和API
2. 编写组件文档（包含API说明和使用示例）
3. 编写测试用例
4. 实现组件功能
5. 运行测试验证
6. 编写使用指南

## 二、命名规范

### 2.1 文件命名
```
lib/shop_ux_phoenix_web/components/
├── tag.ex                    # 组件实现
├── tag_test.exs             # 组件测试
└── tag_doc.md               # 组件文档
```

### 2.2 模块命名
```elixir
defmodule ShopUxPhoenixWeb.Components.Tag do
  # 组件实现
end
```

### 2.3 函数命名
- 组件函数使用小写下划线：`def tag(assigns)`
- 私有函数加 `_` 前缀：`defp _get_color_class(color)`

### 2.4 属性命名对照表
| Vue (Ant Design) | Phoenix | 说明 |
|-----------------|---------|------|
| `@click` | `on_click` | 事件处理 |
| `@close` | `on_close` | 关闭事件 |
| `v-model` | `value` + `on_change` | 双向绑定 |
| `:color` | `color` | 属性传递 |
| `:closable` | `closable` | 布尔属性 |

## 三、组件结构规范

### 3.1 基本结构模板
```elixir
defmodule ShopUxPhoenixWeb.Components.ComponentName do
  @moduledoc """
  组件描述
  
  ## 特性
  - 特性1
  - 特性2
  
  ## 依赖
  - 无外部依赖 / 列出依赖
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  组件主函数说明
  
  ## 示例
      <.component_name attr="value">
        内容
      </.component_name>
  """
  # 声明属性
  attr :attribute_name, :type, default: default_value, doc: "属性说明"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :rest, :global, doc: "其他HTML属性"
  
  # 声明插槽
  slot :inner_block, required: true, doc: "组件内容"
  slot :actions, doc: "操作按钮插槽"
  
  def component_name(assigns) do
    ~H"""
    <!-- 组件模板 -->
    """
  end
  
  # 私有辅助函数
  defp helper_function(param) do
    # 实现
  end
end
```

### 3.2 样式规范
1. 使用Tailwind CSS类
2. 避免内联样式
3. 通过函数组合类名
```elixir
defp get_classes(type) do
  base = "px-4 py-2 rounded"
  
  type_classes = case type do
    "primary" -> "bg-blue-500 text-white"
    "danger" -> "bg-red-500 text-white"
    _ -> "bg-gray-500 text-white"
  end
  
  "#{base} #{type_classes}"
end
```

## 四、API设计规范

### 4.1 属性类型
```elixir
# 基础类型
attr :text, :string, required: true
attr :count, :integer, default: 0
attr :visible, :boolean, default: true

# 枚举类型
attr :size, :string, values: ["small", "medium", "large"], default: "medium"

# 复杂类型
attr :options, :list, default: []
attr :data, :map, default: %{}

# 全局属性
attr :rest, :global, include: ~w(disabled form name value)
```

### 4.2 事件处理
```elixir
# Phoenix风格
attr :on_click, JS, default: nil
attr :on_change, JS, default: nil

# 使用示例
<.button on_click={JS.push("save")}>保存</.button>
<.input on_change={JS.push("validate")} />
```

### 4.3 插槽设计
```elixir
# 默认插槽
slot :inner_block, required: true

# 命名插槽
slot :header
slot :footer

# 带属性的插槽
slot :actions do
  attr :class, :string
end
```

### 4.4 尺寸规范
所有支持尺寸的组件都应遵循统一的尺寸标准：

```elixir
# 尺寸属性定义
attr :size, :string, values: ~w(small medium large), default: "medium"

# 尺寸对应的样式类
defp get_size_classes(size) do
  case size do
    "small" -> "text-sm py-2 px-3"
    "medium" -> "text-sm py-2 px-4"  # 默认尺寸
    "large" -> "text-base py-2.5 px-6"
    _ -> "text-sm py-2 px-4"
  end
end
```

**尺寸规范表：**
| 尺寸 | 文字大小 | 内边距 | 使用场景 |
|------|----------|--------|----------|
| small | text-sm | py-2 px-3 | 密集布局、次要元素 |
| medium | text-sm | py-2 px-4 | 标准尺寸、主要元素 |
| large | text-base | py-2.5 px-6 | 强调元素、重要操作 |

### 4.5 颜色规范
所有支持颜色的组件都应遵循统一的颜色系统：

```elixir
# 颜色属性定义
attr :color, :string, values: ~w(primary info success warning danger), default: "primary"

# 颜色对应的样式类
defp get_color_classes(color, type \\ :background) do
  base_classes = case type do
    :background -> get_bg_classes(color)
    :text -> get_text_classes(color)
    :border -> get_border_classes(color)
    :focus -> get_focus_classes(color)
  end
  
  base_classes
end

defp get_bg_classes(color) do
  case color do
    "primary" -> "bg-primary hover:bg-primary/90 text-white"
    "info" -> "bg-blue-500 hover:bg-blue-600 text-white"
    "success" -> "bg-green-500 hover:bg-green-600 text-white"
    "warning" -> "bg-yellow-500 hover:bg-yellow-600 text-white"
    "danger" -> "bg-red-500 hover:bg-red-600 text-white"
    _ -> "bg-primary hover:bg-primary/90 text-white"
  end
end

defp get_focus_classes(color) do
  case color do
    "primary" -> "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
    "info" -> "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
    "success" -> "focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
    "warning" -> "focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2"
    "danger" -> "focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
    _ -> "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
  end
end
```

**颜色规范表：**
| 颜色 | 色值 | 语义 | 使用场景 |
|------|------|------|----------|
| primary | #FD8E25 | 主色 | 主要操作、品牌色 |
| info | #3b82f6 | 信息 | 信息提示、链接 |
| success | #10b981 | 成功 | 成功状态、确认操作 |
| warning | #f59e0b | 警告 | 警告提示、注意事项 |
| danger | #ef4444 | 危险 | 错误状态、删除操作 |

## 五、测试规范

### 5.1 测试文件结构
```elixir
defmodule ShopUxPhoenixWeb.Components.TagTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.Tag
  
  describe "tag/1" do
    test "renders basic tag" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tag>内容</.tag>
      """)
      
      assert html =~ "内容"
      assert html =~ "tag"
    end
    
    test "renders with different colors" do
      for color <- ~w(primary info success warning danger) do
        assigns = %{color: color}
        
        html = rendered_to_string(~H"""
          <.tag color={@color}>标签</.tag>
        """)
        
        # 验证颜色对应的CSS类存在
        assert html =~ "标签"
      end
    end
    
    test "renders with different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.tag size={@size}>标签</.tag>
        """)
        
        case size do
          "small" -> assert html =~ "text-sm" && assert html =~ "py-2 px-3"
          "medium" -> assert html =~ "text-sm" && assert html =~ "py-2 px-4"
          "large" -> assert html =~ "text-base" && assert html =~ "py-2.5 px-6"
        end
      end
    end
    
    test "renders closable tag" do
      # 测试可关闭功能
    end
  end
end
```

### 5.2 测试覆盖要求
- 基本渲染测试
- 所有属性的测试
- 边界情况测试
- 事件处理测试
- 插槽渲染测试

## 六、文档规范

### 6.1 组件文档模板
```markdown
# Tag 标签组件

## 概述
用于标记和分类的小标签。

## 何时使用
- 用于标记事物的属性和维度
- 进行分类

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| color | 标签颜色 | string | "primary" |
| size | 标签尺寸 | string | "medium" |
| closable | 是否可关闭 | boolean | false |
| on_close | 关闭时的回调 | JS | - |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | text-sm, py-2 px-3 |
| medium | 中等尺寸(默认) | text-sm, py-2 px-4 |
| large | 大尺寸 | text-base, py-2.5 px-6 |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 主要操作、品牌色 |
| info | 信息色 | 信息提示、链接 |
| success | 成功色 | 成功状态、确认操作 |
| warning | 警告色 | 警告提示、注意事项 |
| danger | 危险色 | 错误状态、删除操作 |

### 示例

#### 基本使用
\```heex
<.tag>标签</.tag>
<.tag color="success">成功</.tag>
<.tag color="danger">错误</.tag>
\```

#### 不同尺寸
\```heex
<.tag size="small">小标签</.tag>
<.tag size="medium">中等标签</.tag>
<.tag size="large">大标签</.tag>
\```

#### 可关闭标签
\```heex
<.tag closable on_close={JS.push("remove_tag")}>
  可关闭
</.tag>
\```

#### 组合使用
\```heex
<.tag color="primary" size="large" closable on_close={JS.push("remove_tag")}>
  主要大标签
</.tag>
\```

## 设计规范
参考 Ant Design Tag 组件
```

### 6.2 示例代码要求
- 覆盖所有主要用法
- 包含真实场景示例
- 注释说明关键点

## 七、迁移对照表

### 7.1 Tag组件对照
| Ant Design Vue | Phoenix Component | 说明 |
|---------------|-------------------|------|
| `<a-tag>` | `<.tag>` | 基本用法 |
| `:color="red"` | `color="danger"` | 颜色映射 |
| `:closable="true"` | `closable` | 布尔简写 |
| `@close="handleClose"` | `on_close={JS.push("handle_close")}` | 事件处理 |

### 7.2 颜色映射
| Ant Design | Tailwind/Phoenix | 
|-----------|------------------|
| processing | primary |
| success | success |
| error | danger |
| warning | warning |
| default | gray |

## 八、主题定制

### 8.1 颜色变量
```css
/* 在 app.css 中定义 */
:root {
  --color-primary: #FD8E25;
  --color-success: #52c41a;
  --color-danger: #ff4d4f;
  --color-warning: #faad14;
}
```

### 8.2 使用CSS变量
```elixir
# 在组件中使用
"bg-[var(--color-primary)]"
```

## 九、性能优化

### 9.1 编译时优化
- 使用编译时计算减少运行时开销
- 避免在渲染函数中进行复杂计算

### 9.2 条件渲染
```elixir
# 好的做法
<%= if @visible do %>
  <div>内容</div>
<% end %>

# 避免
<div class={if @visible, do: "block", else: "hidden"}>
  内容
</div>
```

## 十、发布清单

- [ ] 组件功能完整
- [ ] 测试全部通过
- [ ] 文档编写完成
- [ ] 示例代码可运行
- [ ] 代码审查通过
- [ ] 更新组件索引

## 附录：常用工具函数

```elixir
# 类名组合
defp classes(list) do
  list
  |> Enum.filter(& &1)
  |> Enum.join(" ")
end

# 合并属性
defp merge_attrs(defaults, user_attrs) do
  Keyword.merge(defaults, user_attrs)
end
```