# FormBuilder 智能字段联动测试用例文档

## 一、测试场景分类

### 1. 复杂条件显示测试
- 单条件判断（向后兼容）
- AND 逻辑组合
- OR 逻辑组合
- 嵌套条件组合
- 数值比较条件
- 字符串匹配条件
- 数组包含条件
- 正则表达式匹配

### 2. 动态字段加载测试
- 同步选项加载
- 异步选项加载
- 选项加载失败处理
- 选项缓存机制
- 级联选项更新

### 3. 字段依赖和级联更新测试
- 单级依赖
- 多级依赖
- 循环依赖检测
- 字段重置
- 字段值更新
- 字段状态更新

### 4. 计算字段测试
- 简单算术计算
- 复杂公式计算
- 字符串拼接
- 条件计算
- 计算错误处理

### 5. 异步验证测试
- 单字段异步验证
- 依赖其他字段的异步验证
- 验证防抖
- 验证失败处理
- 并发验证处理

### 6. 性能测试
- 大量字段联动
- 复杂依赖图
- 频繁更新
- 内存使用

## 二、具体测试用例

### 1. 复杂条件显示测试用例

#### TC-1.1: 向后兼容简单条件
```elixir
test "简单字符串条件向后兼容" do
  config = %{
    fields: [
      %{name: "user_type", type: "select", options: [%{value: "personal"}, %{value: "company"}]},
      %{name: "company_name", type: "input", show_if: "user_type == 'company'"}
    ]
  }
  
  # 初始状态，company_name 应该隐藏
  assert field_visible?("company_name", %{"user_type" => "personal"}) == false
  
  # 选择 company 后，company_name 应该显示
  assert field_visible?("company_name", %{"user_type" => "company"}) == true
end
```

#### TC-1.2: AND 逻辑组合
```elixir
test "AND 逻辑组合条件" do
  config = %{
    fields: [
      %{name: "user_type", type: "select"},
      %{name: "revenue", type: "number"},
      %{
        name: "enterprise_features",
        type: "checkbox",
        show_if: %{
          and: [
            "user_type == 'company'",
            "revenue > 1000000"
          ]
        }
      }
    ]
  }
  
  # 两个条件都不满足
  assert field_visible?("enterprise_features", %{"user_type" => "personal", "revenue" => "500000"}) == false
  
  # 只满足一个条件
  assert field_visible?("enterprise_features", %{"user_type" => "company", "revenue" => "500000"}) == false
  
  # 两个条件都满足
  assert field_visible?("enterprise_features", %{"user_type" => "company", "revenue" => "2000000"}) == true
end
```

#### TC-1.3: OR 逻辑组合
```elixir
test "OR 逻辑组合条件" do
  config = %{
    fields: [
      %{name: "country", type: "select"},
      %{
        name: "tax_id",
        type: "input",
        show_if: %{
          or: ["country == 'US'", "country == 'CA'"]
        }
      }
    ]
  }
  
  assert field_visible?("tax_id", %{"country" => "US"}) == true
  assert field_visible?("tax_id", %{"country" => "CA"}) == true
  assert field_visible?("tax_id", %{"country" => "CN"}) == false
end
```

#### TC-1.4: 嵌套条件
```elixir
test "嵌套条件组合" do
  config = %{
    fields: [
      %{name: "user_type", type: "select"},
      %{name: "industry", type: "select"},
      %{name: "employees", type: "number"},
      %{
        name: "special_discount",
        type: "number",
        show_if: %{
          and: [
            "user_type == 'company'",
            %{
              or: [
                %{and: ["industry == 'tech'", "employees > 100"]},
                %{and: ["industry == 'finance'", "employees > 50"]}
              ]
            }
          ]
        }
      }
    ]
  }
  
  # 测试各种组合
  assert field_visible?("special_discount", %{
    "user_type" => "company",
    "industry" => "tech",
    "employees" => "150"
  }) == true
  
  assert field_visible?("special_discount", %{
    "user_type" => "company",
    "industry" => "tech",
    "employees" => "50"
  }) == false
end
```

### 2. 动态字段加载测试用例

#### TC-2.1: 同步选项加载
```elixir
test "根据省份同步加载城市选项" do
  config = %{
    fields: [
      %{
        name: "province",
        type: "select",
        options: [
          %{value: "guangdong", label: "广东"},
          %{value: "beijing", label: "北京"}
        ]
      },
      %{
        name: "city",
        type: "select",
        depends_on: ["province"],
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
    ]
  }
  
  # 选择广东省
  {:ok, view, _} = live(conn, "/test_form")
  
  view
  |> element("#province")
  |> render_change(%{"province" => "guangdong"})
  
  # 验证城市选项更新
  html = render(view)
  assert html =~ "广州"
  assert html =~ "深圳"
  refute html =~ "北京"
end
```

#### TC-2.2: 异步选项加载
```elixir
test "异步加载字段选项" do
  config = %{
    fields: [
      %{
        name: "category",
        type: "select",
        options: load_categories()
      },
      %{
        name: "subcategory",
        type: "select",
        depends_on: ["category"],
        load_options: "/api/subcategories"
      }
    ]
  }
  
  {:ok, view, _} = live(conn, "/test_form")
  
  # Mock API response
  expect_api_call("/api/subcategories?category=electronics", fn ->
    {:ok, [
      %{value: "phones", label: "手机"},
      %{value: "laptops", label: "笔记本"}
    ]}
  end)
  
  view
  |> element("#category")
  |> render_change(%{"category" => "electronics"})
  
  # 等待异步加载
  Process.sleep(100)
  
  html = render(view)
  assert html =~ "手机"
  assert html =~ "笔记本"
end
```

### 3. 字段依赖和级联更新测试用例

#### TC-3.1: 级联重置
```elixir
test "字段改变触发级联重置" do
  {:ok, view, _} = live(conn, "/test_form")
  
  # 设置省市区的值
  view
  |> render_change(%{
    "province" => "guangdong",
    "city" => "guangzhou",
    "district" => "tianhe"
  })
  
  # 改变省份应该重置市和区
  view
  |> element("#province")
  |> render_change(%{"province" => "beijing"})
  
  form_data = get_form_data(view)
  assert form_data["province"] == "beijing"
  assert form_data["city"] == nil
  assert form_data["district"] == nil
end
```

#### TC-3.2: 循环依赖检测
```elixir
test "检测并处理循环依赖" do
  config = %{
    fields: [
      %{name: "field_a", depends_on: ["field_b"]},
      %{name: "field_b", depends_on: ["field_c"]},
      %{name: "field_c", depends_on: ["field_a"]}
    ]
  }
  
  assert_raise RuntimeError, ~r/Circular dependency detected/, fn ->
    build_dependency_graph(config.fields)
  end
end
```

### 4. 计算字段测试用例

#### TC-4.1: 简单算术计算
```elixir
test "价格自动计算" do
  config = %{
    fields: [
      %{name: "unit_price", type: "number"},
      %{name: "quantity", type: "number"},
      %{
        name: "total",
        type: "number",
        readonly: true,
        computed: %{
          formula: "unit_price * quantity",
          depends_on: ["unit_price", "quantity"]
        }
      }
    ]
  }
  
  {:ok, view, _} = live(conn, "/test_form")
  
  view
  |> render_change(%{
    "unit_price" => "100",
    "quantity" => "5"
  })
  
  # 验证计算结果
  assert get_field_value(view, "total") == "500"
end
```

#### TC-4.2: 条件计算
```elixir
test "根据会员等级计算折扣价" do
  config = %{
    fields: [
      %{name: "price", type: "number"},
      %{name: "member_level", type: "select", options: ["normal", "vip", "svip"]},
      %{
        name: "final_price",
        type: "number",
        readonly: true,
        computed: %{
          compute: fn form_data ->
            price = String.to_float(form_data["price"] || "0")
            discount = case form_data["member_level"] do
              "vip" -> 0.9
              "svip" -> 0.8
              _ -> 1.0
            end
            price * discount
          end,
          depends_on: ["price", "member_level"]
        }
      }
    ]
  }
  
  {:ok, view, _} = live(conn, "/test_form")
  
  view
  |> render_change(%{
    "price" => "100",
    "member_level" => "vip"
  })
  
  assert get_field_value(view, "final_price") == "90"
end
```

### 5. 异步验证测试用例

#### TC-5.1: 用户名唯一性验证
```elixir
test "异步验证用户名唯一性" do
  config = %{
    fields: [
      %{
        name: "username",
        type: "input",
        async_validation: %{
          endpoint: "/api/check_username",
          debounce: 300,
          message: "用户名已存在"
        }
      }
    ]
  }
  
  {:ok, view, _} = live(conn, "/test_form")
  
  # Mock API - 用户名已存在
  expect_api_call("/api/check_username", %{"username" => "john"}, fn ->
    {:ok, %{valid: false, message: "用户名已存在"}}
  end)
  
  view
  |> element("#username")
  |> render_change(%{"username" => "john"})
  
  # 等待防抖和异步验证
  Process.sleep(400)
  
  html = render(view)
  assert html =~ "用户名已存在"
end
```

#### TC-5.2: 依赖其他字段的异步验证
```elixir
test "根据用户类型验证税号格式" do
  config = %{
    fields: [
      %{name: "user_type", type: "select", options: ["personal", "company"]},
      %{
        name: "tax_id",
        type: "input",
        async_validation: %{
          endpoint: "/api/validate_tax_id",
          depends_on: ["user_type"],
          params: fn form_data ->
            %{
              tax_id: form_data["tax_id"],
              user_type: form_data["user_type"]
            }
          end
        }
      }
    ]
  }
  
  {:ok, view, _} = live(conn, "/test_form")
  
  # 设置用户类型为公司
  view |> render_change(%{"user_type" => "company"})
  
  # Mock API - 公司税号格式错误
  expect_api_call("/api/validate_tax_id", 
    %{"tax_id" => "123", "user_type" => "company"}, 
    fn ->
      {:ok, %{valid: false, message: "公司税号格式不正确"}}
    end
  )
  
  view
  |> element("#tax_id")
  |> render_change(%{"tax_id" => "123"})
  
  Process.sleep(400)
  
  html = render(view)
  assert html =~ "公司税号格式不正确"
end
```

### 6. 性能测试用例

#### TC-6.1: 大量字段联动性能
```elixir
test "100个字段的联动性能测试" do
  # 创建100个相互依赖的字段
  fields = Enum.map(1..100, fn i ->
    %{
      name: "field_#{i}",
      type: "input",
      show_if: if(i > 1, do: "field_#{i-1} != ''", else: nil)
    }
  end)
  
  config = %{fields: fields}
  
  {:ok, view, _} = live(conn, "/test_form")
  
  # 测量更新第一个字段导致的级联更新时间
  {time, _} = :timer.tc(fn ->
    view
    |> element("#field_1")
    |> render_change(%{"field_1" => "test"})
  end)
  
  # 应该在1秒内完成
  assert time < 1_000_000
end
```

#### TC-6.2: 频繁更新防抖测试
```elixir
test "频繁更新触发防抖机制" do
  {:ok, view, _} = live(conn, "/test_form")
  
  # 记录API调用次数
  call_count = :counters.new(1, [])
  
  expect_api_call("/api/search", fn params ->
    :counters.add(call_count, 1, 1)
    {:ok, []}
  end)
  
  # 快速输入10次
  Enum.each(1..10, fn i ->
    view
    |> element("#search")
    |> render_change(%{"search" => "test#{i}"})
    Process.sleep(50)
  end)
  
  # 等待防抖完成
  Process.sleep(400)
  
  # 应该只调用一次API
  assert :counters.get(call_count, 1) == 1
end
```

## 三、边界情况测试

### 1. 空值和nil处理
```elixir
test "正确处理空值和nil" do
  # 测试各种空值情况下的条件评估
  assert evaluate_condition("field == ''", %{"field" => nil}) == false
  assert evaluate_condition("field == ''", %{"field" => ""}) == true
  assert evaluate_condition("field > 0", %{"field" => nil}) == false
end
```

### 2. 类型转换错误
```elixir
test "处理类型转换错误" do
  # 测试无效的数值比较
  assert evaluate_condition("field > 10", %{"field" => "abc"}) == false
  
  # 测试计算字段的错误处理
  config = %{
    fields: [
      %{name: "invalid_number", type: "input"},
      %{
        name: "result",
        computed: %{formula: "invalid_number * 2"}
      }
    ]
  }
  
  # 应该返回错误或默认值，而不是崩溃
  assert compute_field_value("result", %{"invalid_number" => "not a number"}) == {:error, "Invalid number"}
end
```

### 3. 递归深度限制
```elixir
test "防止无限递归" do
  # 创建深度嵌套的条件
  deep_condition = Enum.reduce(1..100, "true", fn _, acc ->
    %{and: [acc, "true"]}
  end)
  
  # 应该有递归深度限制
  assert_raise RuntimeError, ~r/Maximum recursion depth/, fn ->
    evaluate_condition(deep_condition, %{})
  end
end
```

## 四、集成测试场景

### 1. 完整的订单表单
```elixir
test "完整订单表单的字段联动" do
  # 包含：
  # - 客户类型选择（个人/企业）
  # - 根据类型显示不同字段
  # - 产品选择和数量
  # - 自动计算价格
  # - 地址级联选择
  # - 支付方式根据金额显示
  # - 发票信息根据客户类型显示
end
```

### 2. 动态问卷调查
```elixir
test "动态问卷调查表单" do
  # 包含：
  # - 根据答案显示后续问题
  # - 跳过逻辑
  # - 分支路径
  # - 进度计算
  # - 答案关联性验证
end
```

## 五、测试数据准备

### 1. Mock 数据
```elixir
def mock_provinces do
  [
    %{value: "guangdong", label: "广东省"},
    %{value: "beijing", label: "北京市"},
    %{value: "shanghai", label: "上海市"}
  ]
end

def mock_cities(province) do
  case province do
    "guangdong" -> [
      %{value: "guangzhou", label: "广州市"},
      %{value: "shenzhen", label: "深圳市"}
    ]
    # ...
  end
end
```

### 2. API Mock 设置
```elixir
def setup_api_mocks do
  # 设置各种API响应
end
```

## 六、测试执行计划

1. **第一阶段**：基础功能测试（2小时）
   - 复杂条件评估
   - 简单字段联动

2. **第二阶段**：高级功能测试（3小时）
   - 动态加载
   - 计算字段
   - 异步验证

3. **第三阶段**：集成和性能测试（2小时）
   - 完整场景测试
   - 性能基准测试
   - 边界情况测试