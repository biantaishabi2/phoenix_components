# FormBuilder 智能字段联动增强设计文档

## 一、概述

FormBuilder 组件目前已经支持基础的条件显示功能（通过 `show_if` 属性），但只支持简单的相等和不等判断。为了满足更复杂的业务需求，我们需要增强字段联动功能，支持：

1. **复杂条件表达式**：支持 AND/OR 逻辑组合
2. **动态字段加载**：根据条件动态加载或更新字段选项
3. **级联更新**：一个字段的改变可以触发多个字段的更新
4. **计算字段**：根据其他字段的值自动计算
5. **异步验证**：基于其他字段的值进行异步验证

## 二、现有实现分析

### 当前 show_if 实现

```elixir
# 当前的条件评估函数
defp evaluate_condition(condition, form_data) do
  case Regex.run(~r/(\w+)\s*(==|!=)\s*'([^']*)'/, condition) do
    [_, field_name, operator, value] ->
      field_value = to_string(get_field_value(form_data, field_name) || "")
      case operator do
        "==" -> field_value == value
        "!=" -> field_value != value
        _ -> true
      end
    _ -> true
  end
end
```

**局限性**：
- 只支持简单的等于/不等于判断
- 不支持逻辑组合（AND/OR）
- 不支持数值比较（>, <, >=, <=）
- 不支持正则表达式匹配
- 不支持多字段条件

## 三、增强设计方案

### 1. 复杂条件表达式

#### 新的条件语法设计

```elixir
# 简单条件（向后兼容）
show_if: "user_type == 'company'"

# 复杂条件
show_if: %{
  and: [
    "user_type == 'company'",
    "company_size > 10"
  ]
}

# 或条件
show_if: %{
  or: [
    "country == 'CN'",
    "country == 'US'"
  ]
}

# 嵌套条件
show_if: %{
  and: [
    "user_type == 'company'",
    %{or: ["industry == 'tech'", "industry == 'finance'"]}
  ]
}

# 高级条件
show_if: %{
  expression: "user_type == 'company' && (revenue > 1000000 || employees > 50)"
}
```

#### 支持的操作符

- 比较：`==`, `!=`, `>`, `<`, `>=`, `<=`
- 逻辑：`&&`, `||`, `!`
- 包含：`in`, `not_in`
- 正则：`matches`
- 存在性：`present`, `blank`

### 2. 动态字段配置

#### 字段依赖声明

```elixir
%{
  type: "select",
  name: "city",
  label: "城市",
  # 依赖省份字段
  depends_on: ["province"],
  # 动态加载选项
  load_options: "load_cities_by_province",
  # 或使用内联函数
  load_options: fn form_data ->
    case form_data["province"] do
      "guangdong" -> [
        %{value: "guangzhou", label: "广州"},
        %{value: "shenzhen", label: "深圳"}
      ]
      "beijing" -> [
        %{value: "beijing", label: "北京"}
      ]
      _ -> []
    end
  end
}
```

#### 级联更新配置

```elixir
%{
  type: "select",
  name: "category",
  label: "分类",
  # 当此字段改变时，重置或更新其他字段
  on_change: %{
    reset: ["subcategory", "product"],
    update: [
      %{field: "price_range", action: "load_options"},
      %{field: "attributes", action: "show_hide"}
    ]
  }
}
```

### 3. 计算字段

```elixir
%{
  type: "number",
  name: "total_price",
  label: "总价",
  readonly: true,
  # 计算规则
  computed: %{
    formula: "unit_price * quantity * (1 - discount / 100)",
    # 或使用函数
    compute: fn form_data ->
      unit_price = String.to_float(form_data["unit_price"] || "0")
      quantity = String.to_integer(form_data["quantity"] || "0")
      discount = String.to_float(form_data["discount"] || "0")
      unit_price * quantity * (1 - discount / 100)
    end,
    # 依赖的字段
    depends_on: ["unit_price", "quantity", "discount"]
  }
}
```

### 4. 异步验证

```elixir
%{
  type: "input",
  name: "username",
  label: "用户名",
  # 异步验证配置
  async_validation: %{
    # 验证端点
    endpoint: "/api/check_username",
    # 防抖延迟（毫秒）
    debounce: 500,
    # 依赖其他字段
    depends_on: ["user_type"],
    # 自定义参数
    params: fn form_data ->
      %{
        username: form_data["username"],
        user_type: form_data["user_type"]
      }
    end
  }
}
```

## 四、实现方案

### 1. 增强条件评估器

```elixir
defmodule ShopUxPhoenixWeb.Components.FormBuilder.ConditionEvaluator do
  @moduledoc """
  高级条件评估器，支持复杂的逻辑表达式
  """

  def evaluate(condition, form_data) when is_binary(condition) do
    # 向后兼容：简单字符串条件
    evaluate_simple_condition(condition, form_data)
  end

  def evaluate(%{and: conditions}, form_data) do
    Enum.all?(conditions, &evaluate(&1, form_data))
  end

  def evaluate(%{or: conditions}, form_data) do
    Enum.any?(conditions, &evaluate(&1, form_data))
  end

  def evaluate(%{expression: expr}, form_data) do
    evaluate_expression(expr, form_data)
  end

  # ... 更多实现
end
```

### 2. 字段依赖管理器

```elixir
defmodule ShopUxPhoenixWeb.Components.FormBuilder.DependencyManager do
  @moduledoc """
  管理字段之间的依赖关系和级联更新
  """

  def build_dependency_graph(fields) do
    # 构建依赖关系图
  end

  def get_affected_fields(changed_field, dependency_graph) do
    # 获取受影响的字段列表
  end

  def update_dependent_fields(changed_field, form_data, fields) do
    # 更新依赖字段的配置
  end
end
```

### 3. LiveView 事件处理

```elixir
def handle_event("field_changed", %{"field" => field_name, "value" => value} = params, socket) do
  # 更新表单数据
  form_data = Map.put(socket.assigns.form_data, field_name, value)
  
  # 获取受影响的字段
  affected_fields = DependencyManager.get_affected_fields(field_name, socket.assigns.dependency_graph)
  
  # 更新字段配置
  updated_config = DependencyManager.update_dependent_fields(field_name, form_data, socket.assigns.config.fields)
  
  # 触发异步操作（如加载选项）
  socket = Enum.reduce(affected_fields, socket, fn field, acc ->
    maybe_load_field_options(acc, field, form_data)
  end)
  
  {:noreply, 
   socket
   |> assign(:form_data, form_data)
   |> assign(:config, %{socket.assigns.config | fields: updated_config})}
end
```

## 五、API 设计

### 新增属性

1. **字段级属性**：
   - `show_if`: 支持字符串或复杂条件对象
   - `depends_on`: 字段依赖列表
   - `load_options`: 动态加载选项的函数或端点
   - `on_change`: 字段改变时的动作配置
   - `computed`: 计算字段配置
   - `async_validation`: 异步验证配置

2. **表单级属性**：
   - `enable_smart_linkage`: 启用智能联动（默认 true）
   - `linkage_debounce`: 联动防抖延迟（默认 300ms）
   - `on_field_change`: 字段改变的全局回调

### 新增事件

1. `field_changed`: 字段值改变
2. `load_field_options`: 加载字段选项
3. `validate_field_async`: 异步验证字段
4. `compute_field_value`: 计算字段值

## 六、使用示例

### 1. 省市区三级联动

```elixir
config = %{
  fields: [
    %{
      type: "select",
      name: "province",
      label: "省份",
      options: load_provinces(),
      on_change: %{
        reset: ["city", "district"],
        update: [%{field: "city", action: "load_options"}]
      }
    },
    %{
      type: "select",
      name: "city",
      label: "城市",
      depends_on: ["province"],
      load_options: "load_cities_by_province",
      on_change: %{
        reset: ["district"],
        update: [%{field: "district", action: "load_options"}]
      }
    },
    %{
      type: "select",
      name: "district",
      label: "区县",
      depends_on: ["city"],
      load_options: "load_districts_by_city"
    }
  ]
}
```

### 2. 动态表单

```elixir
config = %{
  fields: [
    %{
      type: "radio",
      name: "product_type",
      label: "产品类型",
      options: [
        %{value: "physical", label: "实物商品"},
        %{value: "virtual", label: "虚拟商品"},
        %{value: "service", label: "服务"}
      ]
    },
    # 实物商品字段
    %{
      type: "input",
      name: "weight",
      label: "重量(kg)",
      show_if: "product_type == 'physical'",
      required: true
    },
    %{
      type: "input",
      name: "dimensions",
      label: "尺寸",
      show_if: "product_type == 'physical'"
    },
    # 虚拟商品字段
    %{
      type: "input",
      name: "download_link",
      label: "下载链接",
      show_if: "product_type == 'virtual'",
      required: true
    },
    # 服务字段
    %{
      type: "number",
      name: "service_hours",
      label: "服务时长(小时)",
      show_if: "product_type == 'service'",
      required: true
    }
  ]
}
```

### 3. 价格计算

```elixir
config = %{
  fields: [
    %{
      type: "number",
      name: "unit_price",
      label: "单价",
      required: true
    },
    %{
      type: "number",
      name: "quantity",
      label: "数量",
      required: true,
      min: 1
    },
    %{
      type: "number",
      name: "discount",
      label: "折扣(%)",
      min: 0,
      max: 100
    },
    %{
      type: "number",
      name: "subtotal",
      label: "小计",
      readonly: true,
      computed: %{
        formula: "unit_price * quantity",
        depends_on: ["unit_price", "quantity"]
      }
    },
    %{
      type: "number",
      name: "total",
      label: "总计",
      readonly: true,
      computed: %{
        formula: "subtotal * (1 - discount / 100)",
        depends_on: ["subtotal", "discount"]
      }
    }
  ]
}
```

## 七、性能优化

1. **防抖处理**：字段联动和异步操作都需要防抖
2. **依赖图缓存**：预先计算并缓存字段依赖关系
3. **选择性更新**：只更新受影响的字段，避免全表单重渲染
4. **异步加载优化**：使用缓存避免重复请求
5. **批量更新**：合并多个字段更新为一次渲染

## 八、测试策略

1. **单元测试**：
   - 条件评估器的各种条件测试
   - 依赖管理器的依赖图构建和更新测试
   - 计算字段的公式解析和计算测试

2. **集成测试**：
   - 字段联动的完整流程测试
   - 异步加载和验证测试
   - 性能测试（大量字段和复杂依赖）

3. **LiveView 测试**：
   - 用户交互触发的联动测试
   - 异步操作的界面更新测试
   - 错误处理和边界情况测试

## 九、向后兼容性

1. 保持现有 `show_if` 字符串语法的支持
2. 新功能默认关闭，通过 `enable_smart_linkage` 开启
3. 渐进式增强，不影响现有表单的正常使用