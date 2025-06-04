# FormBuilder Changeset 集成测试用例

## 测试场景概述

本文档定义了 FormBuilder 与 Ecto Changeset 集成功能的测试用例，确保自动字段生成、验证规则提取和错误显示等功能正常工作。

## 1. Ecto 类型推断测试

### 1.1 基本类型推断

**测试数据结构**：
```elixir
defmodule TestUser do
  use Ecto.Schema
  
  schema "users" do
    field :name, :string
    field :bio, :text
    field :age, :integer
    field :height, :float
    field :active, :boolean
    field :birth_date, :date
    field :last_login, :naive_datetime
    field :settings, :map
    field :tags, {:array, :string}
  end
end
```

**期望结果**：
- `name` → `type: "input"`
- `bio` → `type: "textarea"`
- `age` → `type: "number", step: 1`
- `height` → `type: "number", step: "any"`
- `active` → `type: "checkbox"`
- `birth_date` → `type: "date"`
- `last_login` → `type: "datetime-local"`
- `settings` → `type: "textarea"` with JSON 提示
- `tags` → `type: "select", multiple: true`

### 1.2 关联类型推断

**测试数据**：
```elixir
schema "products" do
  belongs_to :category, Category
  has_many :images, ProductImage
end
```

**期望结果**：
- `category_id` → `type: "select"` with options
- `images` → 不生成字段（has_many 关系）

## 2. 验证规则提取测试

### 2.1 必填验证

**Changeset**：
```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :email])
  |> validate_required([:name, :email])
end
```

**期望生成的字段配置**：
```elixir
%{
  name: "name",
  type: "input",
  required: true,
  description: "此字段必填"
}
```

### 2.2 长度验证

**Changeset**：
```elixir
|> validate_length(:username, min: 3, max: 20)
|> validate_length(:bio, max: 500)
```

**期望生成的字段配置**：
```elixir
%{
  name: "username",
  type: "input",
  min_length: 3,
  max_length: 20,
  description: "长度应在 3 到 20 个字符之间"
}
```

### 2.3 数值范围验证

**Changeset**：
```elixir
|> validate_number(:age, greater_than_or_equal_to: 18, less_than: 150)
```

**期望生成的字段配置**：
```elixir
%{
  name: "age",
  type: "number",
  min: 18,
  max: 149,
  description: "数值应在 18 到 149 之间"
}
```

### 2.4 格式验证

**Changeset**：
```elixir
|> validate_format(:email, ~r/@/)
|> validate_format(:phone, ~r/^\d{11}$/)
```

**期望生成的字段配置**：
```elixir
%{
  name: "email",
  type: "email",
  pattern: ".*@.*",
  description: "请输入有效的邮箱地址"
}
```

### 2.5 选项验证

**Changeset**：
```elixir
|> validate_inclusion(:role, ["admin", "user", "guest"])
```

**期望生成的字段配置**：
```elixir
%{
  name: "role",
  type: "select",
  options: [
    %{value: "admin", label: "admin"},
    %{value: "user", label: "user"},
    %{value: "guest", label: "guest"}
  ]
}
```

### 2.6 确认字段验证

**Changeset**：
```elixir
|> validate_confirmation(:password)
```

**期望生成的字段配置**：
```elixir
[
  %{
    name: "password",
    type: "password",
    required: true
  },
  %{
    name: "password_confirmation",
    type: "password",
    required: true,
    description: "请再次输入密码"
  }
]
```

## 3. 错误显示测试

### 3.1 单字段错误

**Changeset 错误**：
```elixir
%Ecto.Changeset{
  errors: [
    name: {"不能为空", [validation: :required]}
  ]
}
```

**期望显示**：
- 字段边框变红
- 显示错误信息 "不能为空"

### 3.2 多个错误

**Changeset 错误**：
```elixir
%Ecto.Changeset{
  errors: [
    password: {"太短了", [count: 8, validation: :length, kind: :min]},
    password: {"必须包含数字", [validation: :format]}
  ]
}
```

**期望显示**：
- 显示所有错误信息
- 错误信息换行显示

### 3.3 嵌套错误

**Changeset 错误**：
```elixir
%Ecto.Changeset{
  changes: %{
    address: %Ecto.Changeset{
      errors: [city: {"不能为空", []}]
    }
  }
}
```

**期望显示**：
- 正确定位嵌套字段
- 显示嵌套错误信息

## 4. 自定义覆盖测试

### 4.1 字段类型覆盖

**测试场景**：
```elixir
# Schema 定义 active 为 :boolean
# 但想要显示为 switch 而不是 checkbox

field_overrides = %{
  "active" => %{type: "switch"}
}
```

**期望结果**：
- 使用 switch 组件而不是默认的 checkbox

### 4.2 添加自定义选项

**测试场景**：
```elixir
# Schema 定义 category_id 为 belongs_to
# 添加自定义选项列表

field_overrides = %{
  "category_id" => %{
    options: [
      %{value: 1, label: "电子产品"},
      %{value: 2, label: "图书"}
    ]
  }
}
```

**期望结果**：
- 使用提供的选项列表

## 5. 复杂场景测试

### 5.1 动态表单生成

**测试场景**：
```elixir
# 根据用户类型动态生成不同字段
def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :type])
  |> validate_required([:name, :type])
  |> then(fn cs ->
    case get_field(cs, :type) do
      "company" ->
        cs
        |> cast(attrs, [:company_name, :tax_id])
        |> validate_required([:company_name, :tax_id])
      _ ->
        cs
    end
  end)
end
```

**期望结果**：
- 选择 "company" 时显示额外字段
- 切换类型时正确更新表单

### 5.2 自定义验证消息

**测试场景**：
```elixir
|> validate_length(:name, min: 2, message: "名字太短啦，至少要 %{count} 个字")
|> validate_format(:email, ~r/@/, message: "这不像是个邮箱哦")
```

**期望结果**：
- 显示自定义的错误消息
- 正确替换占位符

## 6. 性能测试

### 6.1 大型 Schema

**测试场景**：
- Schema 包含 50+ 字段
- 多个复杂验证规则

**验证点**：
- 表单生成时间 < 100ms
- 无明显卡顿

### 6.2 实时验证

**测试场景**：
- 启用 validate_on_change
- 快速输入触发验证

**验证点**：
- 验证响应及时
- 不影响输入体验

## 测试执行计划

1. **单元测试**（form_builder_test.exs）
   - 测试各个提取函数的正确性
   - 测试类型映射逻辑
   - 测试验证规则转换

2. **集成测试**（form_builder_live_test.exs）
   - 测试完整的表单渲染
   - 测试用户交互
   - 测试错误显示
   - 测试表单提交

3. **边界测试**
   - 空 Changeset
   - 无验证规则的 Changeset
   - 循环依赖的验证
   - 极大数据量

## 测试数据准备

需要创建以下测试辅助模块：
- `TestSchemas` - 包含各种测试用 Schema
- `TestChangesets` - 包含各种验证组合
- `TestHelpers` - 测试辅助函数