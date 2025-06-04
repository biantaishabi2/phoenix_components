# Steps 步骤条组件

## 概述
引导用户按照流程完成任务的导航条，显示当前步骤和进度。

## 何时使用
- 当任务复杂或者存在先后关系时，将其分解成一系列步骤，从而简化任务
- 需要展示任务进度时
- 当用户需要完成一个冗长或不熟悉的表单时
- 引导用户完成复杂的操作流程

## 特性
- 支持水平和垂直两种方向
- 支持多种步骤状态（等待、进行中、完成、错误）
- 支持自定义图标
- 支持描述文字
- 支持点击跳转
- 支持进度条显示
- 支持自定义样式

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| id | 步骤条唯一标识 | string | 必填 |
| current | 指定当前步骤，从0开始计数 | integer | 0 |
| direction | 指定步骤条方向 | string (horizontal/vertical) | "horizontal" |
| size | 指定大小 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| status | 指定当前步骤状态 | string (wait/process/finish/error) | "process" |
| initial | 起始序号，从0开始计数 | integer | 0 |
| label_placement | 指定标签放置位置 | string (horizontal/vertical) | "horizontal" |
| progress_dot | 点状步骤条 | boolean | false |
| responsive | 响应式 | boolean | true |
| type | 步骤条类型 | string (default/navigation) | "default" |
| percent | 当前process步骤显示的进度条进度 | integer | nil |
| class | 自定义CSS类 | string | "" |
| on_change | 点击切换步骤时触发 | JS | %JS{} |
| rest | 其他HTML属性 | global | - |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | text-sm, py-2 px-3 |
| medium | 中等尺寸(默认) | text-sm, py-2 px-4 |
| large | 大尺寸 | text-base, py-2.5 px-6 |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 焦点和选中状态 |
| info | 信息色 | 信息类组件 |
| success | 成功色 | 成功状态组件 |
| warning | 警告色 | 警告状态组件 |
| danger | 危险色 | 错误状态组件 |

### 步骤数据结构
```elixir
# 步骤数据结构
steps = [
  %{
    title: "已完成",
    description: "这里是多信息的描述啊",
    status: "finish"
  },
  %{
    title: "进行中",
    description: "这里是多信息的描述啊",
    status: "process"
  },
  %{
    title: "等待中",
    description: "这里是多信息的描述啊",
    status: "wait"
  }
]

# 带图标的步骤
steps_with_icon = [
  %{
    title: "登录",
    description: "输入用户名和密码",
    icon: "user-icon",
    status: "finish"
  },
  %{
    title: "验证",
    description: "短信验证码验证",
    icon: "check-icon",
    status: "process"
  },
  %{
    title: "完成",
    description: "注册完成",
    icon: "finish-icon",
    status: "wait"
  }
]
```

## 示例

### 基本使用
```heex
<.steps 
  id="basic-steps"
  current={1}
  steps={[
    %{title: "已完成", description: "这是第一步"},
    %{title: "进行中", description: "这是第二步"},
    %{title: "等待中", description: "这是第三步"}
  ]}
/>
```

### 小尺寸步骤条
```heex
<.steps 
  id="small-steps"
  current={1}
  size="small"
  steps={@steps}
/>
```

### 带图标的步骤条
```heex
<.steps 
  id="icon-steps"
  current={1}
  steps={[
    %{title: "登录", icon: "user", status: "finish"},
    %{title: "验证", icon: "shield", status: "process"},
    %{title: "完成", icon: "check", status: "wait"}
  ]}
/>
```

### 垂直步骤条
```heex
<.steps 
  id="vertical-steps"
  current={1}
  direction="vertical"
  steps={@steps}
/>
```

### 点状步骤条
```heex
<.steps 
  id="dot-steps"
  current={1}
  progress_dot={true}
  steps={@steps}
/>
```

### 可点击的步骤条
```heex
<.steps 
  id="clickable-steps"
  current={@current_step}
  type="navigation"
  on_change={JS.push("step_change")}
  steps={@steps}
/>
```

### 带进度的步骤条
```heex
<.steps 
  id="progress-steps"
  current={1}
  percent={60}
  steps={@steps}
/>
```

### 错误状态
```heex
<.steps 
  id="error-steps"
  current={1}
  status="error"
  steps={[
    %{title: "已完成", status: "finish"},
    %{title: "出错了", status: "error"},
    %{title: "等待中", status: "wait"}
  ]}
/>
```

### 自定义图标步骤条
```heex
<.steps 
  id="custom-icon-steps"
  current={1}
  steps={[
    %{
      title: "第一步",
      description: "填写基本信息",
      icon: ~H"<svg class='w-4 h-4' fill='currentColor'>...</svg>",
      status: "finish"
    },
    %{
      title: "第二步", 
      description: "确认信息",
      icon: ~H"<svg class='w-4 h-4' fill='currentColor'>...</svg>",
      status: "process"
    }
  ]}
/>
```

### 响应式步骤条
```heex
<.steps 
  id="responsive-steps"
  current={@current_step}
  responsive={true}
  direction="horizontal"
  steps={@steps}
  class="md:flex-row flex-col"
/>
```

### 事件处理
```heex
<.steps 
  id="interactive-steps"
  current={@current_step}
  type="navigation"
  on_change={JS.push("step_changed")}
  steps={@steps}
/>
```

### 表单流程中的应用
```heex
<div class="max-w-4xl mx-auto p-6">
  <.steps 
    id="form-steps"
    current={@current_step}
    steps={[
      %{title: "基本信息", description: "填写用户基本信息"},
      %{title: "联系信息", description: "填写联系方式"},
      %{title: "确认信息", description: "确认所有信息"},
      %{title: "完成", description: "注册完成"}
    ]}
  />
  
  <div class="mt-8">
    <%= case @current_step do %>
      <% 0 -> %>
        <.form for={@form} phx-submit="next_step">
          <!-- 基本信息表单 -->
        </.form>
      <% 1 -> %>
        <.form for={@form} phx-submit="next_step">
          <!-- 联系信息表单 -->
        </.form>
      <% 2 -> %>
        <!-- 确认页面 -->
      <% 3 -> %>
        <!-- 完成页面 -->
    <% end %>
  </div>
</div>
```

## 高级用法

### 动态步骤
```elixir
def handle_event("add_step", _params, socket) do
  new_step = %{
    title: "新步骤",
    description: "动态添加的步骤",
    status: "wait"
  }
  
  steps = socket.assigns.steps ++ [new_step]
  {:noreply, assign(socket, steps: steps)}
end
```

### 步骤验证
```elixir
def handle_event("step_change", %{"step" => step_str}, socket) do
  step = String.to_integer(step_str)
  
  # 验证是否可以跳转到该步骤
  if can_go_to_step?(socket.assigns, step) do
    {:noreply, assign(socket, current_step: step)}
  else
    {:noreply, put_flash(socket, :error, "请完成当前步骤")}
  end
end

defp can_go_to_step?(assigns, target_step) do
  # 只能跳转到已完成的步骤或下一步
  target_step <= assigns.current_step + 1
end
```

### 步骤状态管理
```elixir
def update_step_status(socket, step_index, status) do
  steps = 
    socket.assigns.steps
    |> Enum.with_index()
    |> Enum.map(fn {step, index} ->
      if index == step_index do
        Map.put(step, :status, status)
      else
        step
      end
    end)
  
  assign(socket, steps: steps)
end
```

## 设计规范
- 参考 Ant Design Steps 组件
- 支持键盘导航（左右箭头切换步骤）
- 支持无障碍访问（ARIA属性）
- 步骤数量建议不超过6个
- 每个步骤的标题应该简洁明了
- 在移动端自动适配为垂直布局

## Steps vs Breadcrumb
- **Steps**: 用于显示任务进度和引导用户完成流程，强调顺序性
- **Breadcrumb**: 用于显示当前页面路径，强调层级关系

## 注意事项
- 步骤条应该清晰地显示当前进度
- 确保每个步骤的标题和描述准确描述该步骤的内容
- 在移动设备上考虑使用垂直布局或简化显示
- 避免步骤过多，必要时可以进行分组
- 提供明确的前进和后退操作
- 在表单验证失败时，应该在相应步骤显示错误状态