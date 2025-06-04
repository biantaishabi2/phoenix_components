# FormBuilder 表单构建器组件

## 概述

FormBuilder 表单构建器组件是一个强大的动态表单生成工具，通过 JSON 配置快速生成复杂的表单界面。支持多种字段类型、布局模式、验证规则和条件显示，极大提升表单开发效率。

## 特性

- 🎛️ **配置驱动** - 通过 JSON 配置快速生成表单
- 📋 **丰富字段类型** - 支持 20+ 种表单字段类型
- 🎨 **多种布局** - 支持垂直、水平、内联、网格布局
- ✅ **智能验证** - 内置常用验证规则，支持自定义验证
- 🔗 **字段联动** - 支持字段间的依赖和条件显示
- 📱 **响应式设计** - 适配各种屏幕尺寸
- 🎯 **类型安全** - 完整的 TypeScript 类型定义
- 🔧 **高度定制** - 支持自定义渲染和扩展

## 与 Vue 版本对比

| 特性 | Vue 版本 | Phoenix LiveView 版本 |
|------|----------|----------------------|
| 动态表单生成 | ✅ | ✅ |
| 字段类型 | 15+ | 20+ |
| 布局模式 | ✅ | ✅ (网格支持) |
| 表单验证 | ✅ | ✅ (Phoenix 验证) |
| 条件显示 | ✅ | ✅ (LiveView 响应式) |
| 文件上传 | ✅ | ✅ (Phoenix 上传) |
| 国际化 | ✅ | ✅ (Gettext) |

## API 参考

### Props

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | `string` | 必需 | 表单唯一标识 |
| `config` | `map` | `%{}` | 表单配置对象 |
| `initial_data` | `map` | `%{}` | 表单初始数据 |
| `changeset` | `Ecto.Changeset` | `nil` | Ecto Changeset 对象，用于自动生成表单配置 |
| `field_overrides` | `map` | `%{}` | 字段配置覆盖，用于自定义 Changeset 推断的字段 |
| `layout` | `string` | `"vertical"` | 布局模式：`vertical`、`horizontal`、`inline`、`grid` |
| `size` | `string` | `"medium"` | 表单尺寸：`small`、`medium`、`large` |
| `disabled` | `boolean` | `false` | 是否禁用整个表单 |
| `readonly` | `boolean` | `false` | 是否只读模式 |
| `loading` | `boolean` | `false` | 是否显示加载状态 |
| `validate_on_change` | `boolean` | `true` | 是否在值改变时验证 |
| `submit_text` | `string` | `"提交"` | 提交按钮文本 |
| `reset_text` | `string` | `"重置"` | 重置按钮文本 |
| `show_submit` | `boolean` | `true` | 是否显示提交按钮 |
| `show_reset` | `boolean` | `true` | 是否显示重置按钮 |
| `on_submit` | `string` | `nil` | 提交事件名 |
| `on_change` | `string` | `nil` | 字段变化事件名 |
| `on_reset` | `string` | `nil` | 重置事件名 |
| `class` | `string` | `""` | 自定义CSS类名 |

### 配置对象结构

```elixir
%{
  fields: [
    %{
      type: "input",           # 字段类型
      name: "username",        # 字段名称
      label: "用户名",         # 字段标签
      placeholder: "请输入用户名",
      required: true,          # 是否必填
      rules: [...],           # 验证规则
      props: %{},             # 字段属性
      grid: %{span: 12},      # 网格布局
      show_if: "role == 'admin'", # 条件显示
      options: [...]          # 选项数据（用于 select 等）
    }
  ],
  groups: [                  # 字段分组
    %{
      title: "基本信息",
      fields: ["username", "email"]
    }
  ],
  layout_config: %{          # 布局配置
    label_col: %{span: 6},
    wrapper_col: %{span: 18},
    gutter: 16
  }
}
```

## 支持的字段类型

### 文本输入类
- **input** - 文本输入框
- **textarea** - 多行文本域
- **password** - 密码输入框
- **number** - 数字输入框
- **email** - 邮箱输入框
- **tel** - 电话输入框
- **url** - URL输入框

### 选择类
- **select** - 下拉选择器
- **radio** - 单选框组
- **checkbox** - 复选框组
- **switch** - 开关
- **cascader** - 级联选择器
- **tree_select** - 树形选择器

### 日期时间类
- **date** - 日期选择器
- **datetime** - 日期时间选择器
- **time** - 时间选择器
- **date_range** - 日期范围选择器

### 特殊类型
- **upload** - 文件上传
- **upload_image** - 图片上传
- **color** - 颜色选择器
- **rate** - 评分组件
- **slider** - 滑动输入条
- **address** - 地址选择器
- **rich_text** - 富文本编辑器

### 布局类
- **divider** - 分割线
- **text** - 静态文本
- **html** - 自定义HTML内容

## 使用示例

### 基础表单

```heex
<.form_builder
  id="basic-form"
  config={%{
    fields: [
      %{
        type: "input",
        name: "name",
        label: "姓名",
        required: true,
        placeholder: "请输入姓名"
      },
      %{
        type: "email",
        name: "email", 
        label: "邮箱",
        required: true
      },
      %{
        type: "select",
        name: "role",
        label: "角色",
        options: [
          %{value: "admin", label: "管理员"},
          %{value: "user", label: "普通用户"}
        ]
      }
    ]
  }}
  on_submit="save_user"
/>
```

### 水平布局表单

```heex
<.form_builder
  id="horizontal-form"
  layout="horizontal"
  config={%{
    layout_config: %{
      label_col: %{span: 4},
      wrapper_col: %{span: 20}
    },
    fields: [...]
  }}
/>
```

### 网格布局表单

```heex
<.form_builder
  id="grid-form"
  layout="grid"
  config={%{
    layout_config: %{gutter: 16},
    fields: [
      %{
        type: "input",
        name: "first_name",
        label: "名",
        grid: %{span: 12}
      },
      %{
        type: "input", 
        name: "last_name",
        label: "姓",
        grid: %{span: 12}
      }
    ]
  }}
/>
```

### 条件显示

```heex
<.form_builder
  id="conditional-form"
  config={%{
    fields: [
      %{
        type: "select",
        name: "type",
        label: "用户类型",
        options: [
          %{value: "personal", label: "个人"},
          %{value: "company", label: "企业"}
        ]
      },
      %{
        type: "input",
        name: "company_name", 
        label: "公司名称",
        show_if: "type == 'company'"
      }
    ]
  }}
/>
```

### 字段分组

```heex
<.form_builder
  id="grouped-form"
  config={%{
    fields: [...],
    groups: [
      %{
        title: "基本信息",
        fields: ["name", "email", "phone"]
      },
      %{
        title: "地址信息", 
        fields: ["address", "city", "country"]
      }
    ]
  }}
/>
```

### 复杂验证规则

```heex
<.form_builder
  id="validation-form"
  config={%{
    fields: [
      %{
        type: "password",
        name: "password",
        label: "密码",
        rules: [
          %{required: true, message: "请输入密码"},
          %{min_length: 8, message: "密码至少8位"},
          %{pattern: ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, message: "密码需包含大小写字母和数字"}
        ]
      }
    ]
  }}
/>
```

## 验证规则

### 内置验证规则

| 规则 | 说明 | 示例 |
|------|------|------|
| `required` | 必填验证 | `%{required: true, message: "此字段必填"}` |
| `type` | 类型验证 | `%{type: "email", message: "请输入有效邮箱"}` |
| `min_length` | 最小长度 | `%{min_length: 6, message: "至少6个字符"}` |
| `max_length` | 最大长度 | `%{max_length: 20, message: "最多20个字符"}` |
| `pattern` | 正则验证 | `%{pattern: ~r/^\d+$/, message: "只能输入数字"}` |
| `min` | 最小值 | `%{min: 0, message: "不能小于0"}` |
| `max` | 最大值 | `%{max: 100, message: "不能大于100"}` |
| `validator` | 自定义验证 | `%{validator: "custom_validate"}` |

### Changeset 集成（新功能）

FormBuilder 现在支持与 Ecto Changeset 的深度集成，可以自动提取和应用 Changeset 的验证规则。

#### 使用 Changeset 验证

```heex
<.form_builder
  id="user-form"
  changeset={@changeset}
  on_submit="save_user"
/>
```

#### 自动功能

1. **验证规则提取** - 自动从 Changeset 提取验证规则并应用到前端
2. **类型推断** - 根据 Ecto Schema 字段类型自动选择合适的表单控件
3. **错误显示** - 自动显示 Changeset 的验证错误
4. **帮助信息** - 根据验证规则生成字段提示信息

#### 支持的 Changeset 验证映射

| Changeset 验证 | FormBuilder 规则 | 自动提示 |
|----------------|-----------------|----------|
| `validate_required/3` | `required: true` | "此字段必填" |
| `validate_length/3` | `min_length`, `max_length` | "长度应在 X-Y 之间" |
| `validate_number/3` | `min`, `max` | "数值应在 X-Y 之间" |
| `validate_format/3` | `pattern` | "格式不正确" |
| `validate_inclusion/3` | `options` | 自动生成选项列表 |
| `validate_acceptance/2` | `type: "checkbox"` | "请接受条款" |
| `validate_confirmation/3` | 自动添加确认字段 | "两次输入不一致" |

#### Ecto 类型映射

| Ecto 类型 | FormBuilder 字段类型 |
|-----------|-------------------|
| `:string` | `input` |
| `:text` | `textarea` |
| `:integer` / `:float` | `number` |
| `:boolean` | `checkbox` 或 `switch` |
| `:date` | `date` |
| `:naive_datetime` | `datetime-local` |
| `:utc_datetime` | `datetime-local` |
| `{:array, _}` | `select` with `multiple` |
| `:map` / `:json` | `textarea` with JSON 验证 |

#### 高级用法

```elixir
# 在 LiveView 中使用
def mount(_params, _session, socket) do
  changeset = User.changeset(%User{}, %{})
  
  # 可选：自定义字段配置覆盖自动推断
  field_overrides = %{
    "role" => %{
      type: "select",
      options: [
        %{value: "admin", label: "管理员"},
        %{value: "user", label: "用户"}
      ]
    }
  }
  
  {:ok, 
   socket
   |> assign(:changeset, changeset)
   |> assign(:field_overrides, field_overrides)}
end

def handle_event("save_user", %{"user" => user_params}, socket) do
  case Users.create_user(user_params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "用户创建成功")
       |> push_navigate(to: ~p"/users/#{user}")}
       
    {:error, %Ecto.Changeset{} = changeset} ->
      # FormBuilder 会自动显示错误
      {:noreply, assign(socket, :changeset, changeset)}
  end
end
```

#### 自定义验证消息

```elixir
# 在 Schema 或 Changeset 中定义
def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :email, :age])
  |> validate_required([:name, :email], message: "不能为空")
  |> validate_length(:name, min: 2, max: 100, 
      message: "长度应在 %{min} 到 %{max} 个字符之间")
  |> validate_format(:email, ~r/@/, message: "邮箱格式不正确")
end
```

### 自定义验证器

```elixir
def handle_event("custom_validate", %{"field" => field, "value" => value}, socket) do
  case validate_custom_rule(value) do
    {:ok, _} -> {:noreply, socket}
    {:error, message} -> 
      {:noreply, put_flash(socket, :error, message)}
  end
end
```

## 事件处理

### 表单提交

```elixir
def handle_event("form_submit", %{"form_data" => data}, socket) do
  case validate_and_save(data) do
    {:ok, result} ->
      {:noreply, 
       socket
       |> put_flash(:info, "保存成功")
       |> push_navigate(to: "/success")}
    
    {:error, changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end
```

### 字段变化

```elixir
def handle_event("field_changed", %{"field" => field, "value" => value}, socket) do
  # 处理字段变化，比如联动更新其他字段
  new_data = Map.put(socket.assigns.form_data, field, value)
  {:noreply, assign(socket, :form_data, new_data)}
end
```

## 样式定制

### 自定义主题

```heex
<.form_builder
  id="custom-theme-form"
  class="custom-form-theme"
  config={%{
    theme: %{
      primary_color: "#1890ff",
      border_radius: "6px",
      spacing: "16px"
    }
  }}
/>
```

### CSS 类名约定

```css
.form-builder {
  @apply space-y-4;
}

.form-builder-field {
  @apply relative;
}

.form-builder-label {
  @apply text-sm font-medium text-gray-700 mb-1;
}

.form-builder-error {
  @apply text-xs text-red-600 mt-1;
}
```

## 最佳实践

1. **合理分组** - 对相关字段进行分组，提升用户体验
2. **渐进增强** - 从简单配置开始，逐步添加复杂功能
3. **验证优先** - 优先考虑前端验证，提供即时反馈
4. **响应式设计** - 使用网格布局适配不同屏幕尺寸
5. **性能优化** - 对于大型表单考虑懒加载和虚拟滚动
6. **可访问性** - 确保表单对屏幕阅读器友好
7. **错误处理** - 提供清晰的错误提示和恢复机制

## 注意事项

- 复杂的条件逻辑可能影响性能，建议适度使用
- 文件上传字段需要配置相应的上传处理器
- 自定义验证器需要在 LiveView 中实现对应的事件处理
- 大型表单建议使用分步骤的向导模式
- 确保表单配置的安全性，避免注入攻击