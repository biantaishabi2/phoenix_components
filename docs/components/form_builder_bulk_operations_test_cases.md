# FormBuilder 批量操作功能测试用例

## 概述

本文档详细定义FormBuilder批量操作功能的测试用例，包括单元测试、集成测试和用户界面测试，确保功能的可靠性和用户体验。

## 测试策略

### 测试分层
1. **单元测试**: 测试各个模块的独立功能
2. **集成测试**: 测试模块间的协作
3. **LiveView测试**: 测试用户交互流程
4. **性能测试**: 测试大文件处理性能
5. **边界测试**: 测试极限情况和错误处理

### 测试数据准备

#### 测试文件
```
test/fixtures/bulk_import/
├── valid_users.xlsx          # 有效的Excel文件
├── valid_users.csv           # 有效的CSV文件
├── invalid_format.txt        # 无效格式文件
├── corrupted.xlsx            # 损坏的Excel文件
├── large_file.xlsx           # 大文件（超过限制）
├── empty_file.xlsx           # 空文件
├── malformed.csv             # 格式错误的CSV
├── mixed_encoding.csv        # 编码问题的CSV
├── partial_valid.xlsx        # 部分数据有效的文件
└── duplicate_data.xlsx       # 包含重复数据的文件
```

#### 测试数据结构
```elixir
# 有效用户数据
@valid_user_data [
  %{"姓名" => "张三", "邮箱" => "zhang@test.com", "电话" => "13800138000", "部门" => "技术部"},
  %{"姓名" => "李四", "邮箱" => "li@test.com", "电话" => "13900139000", "部门" => "销售部"},
  %{"姓名" => "王五", "邮箱" => "wang@test.com", "电话" => "13700137000", "部门" => "市场部"}
]

# 包含错误的数据
@invalid_user_data [
  %{"姓名" => "", "邮箱" => "invalid-email", "电话" => "abc123", "部门" => ""},
  %{"姓名" => "重复用户", "邮箱" => "duplicate@test.com", "电话" => "13800138000", "部门" => "技术部"},
  %{"姓名" => "重复用户", "邮箱" => "duplicate@test.com", "电话" => "13800138000", "部门" => "技术部"}
]
```

## 单元测试用例

### 1. 文件解析器测试 (FileParser)

#### 1.1 Excel解析器测试
```elixir
describe "ExcelParser" do
  test "解析有效的Excel文件" do
    file_path = "test/fixtures/bulk_import/valid_users.xlsx"
    
    assert {:ok, data} = ExcelParser.parse_file(file_path)
    assert length(data) == 4  # 3行数据 + 1行表头
    assert List.first(data) == ["姓名", "邮箱", "电话", "部门"]
  end
  
  test "解析带表头的Excel文件" do
    file_path = "test/fixtures/bulk_import/valid_users.xlsx"
    
    assert {:ok, {headers, rows}} = ExcelParser.parse_with_headers(file_path)
    assert headers == ["姓名", "邮箱", "电话", "部门"]
    assert length(rows) == 3
  end
  
  test "处理损坏的Excel文件" do
    file_path = "test/fixtures/bulk_import/corrupted.xlsx"
    
    assert {:error, error_msg} = ExcelParser.parse_file(file_path)
    assert error_msg =~ "Excel解析失败"
  end
  
  test "处理不存在的文件" do
    file_path = "test/fixtures/bulk_import/nonexistent.xlsx"
    
    assert {:error, error_msg} = ExcelParser.parse_file(file_path)
    assert error_msg =~ "文件读取异常"
  end
  
  test "处理空Excel文件" do
    file_path = "test/fixtures/bulk_import/empty_file.xlsx"
    
    assert {:ok, []} = ExcelParser.parse_file(file_path)
  end
end
```

#### 1.2 CSV解析器测试
```elixir
describe "CSVParser" do
  test "解析有效的CSV文件" do
    file_path = "test/fixtures/bulk_import/valid_users.csv"
    
    assert {:ok, data} = CSVParser.parse_file(file_path)
    assert length(data) == 4  # 3行数据 + 1行表头
  end
  
  test "处理UTF-8编码的CSV文件" do
    file_path = "test/fixtures/bulk_import/utf8_users.csv"
    
    assert {:ok, data} = CSVParser.parse_file(file_path)
    # 验证中文字符正确解析
    assert Enum.any?(data, fn row -> 
      Enum.any?(row, &String.contains?(&1, "技术部"))
    end)
  end
  
  test "处理包含逗号的CSV字段" do
    content = "姓名,地址\n张三,\"北京市,海淀区\"\n"
    
    assert {:ok, [["姓名", "地址"], ["张三", "北京市,海淀区"]]} = 
      CSVParser.parse_string(content)
  end
  
  test "处理格式错误的CSV文件" do
    file_path = "test/fixtures/bulk_import/malformed.csv"
    
    assert {:error, error_msg} = CSVParser.parse_file(file_path)
    assert error_msg =~ "CSV解析失败"
  end
end
```

### 2. 字段映射器测试 (FieldMapper)

```elixir
describe "FieldMapper" do
  test "自动映射相同名称的字段" do
    headers = ["姓名", "邮箱", "电话"]
    form_fields = ["name", "email", "phone"]
    mapping_rules = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
    
    assert {:ok, mapping} = FieldMapper.auto_map(headers, form_fields, mapping_rules)
    assert mapping == %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
  end
  
  test "处理无法映射的字段" do
    headers = ["姓名", "未知字段", "邮箱"]
    form_fields = ["name", "email"]
    mapping_rules = %{"姓名" => "name", "邮箱" => "email"}
    
    assert {:partial, mapping, unmapped} = FieldMapper.auto_map(headers, form_fields, mapping_rules)
    assert unmapped == ["未知字段"]
  end
  
  test "验证字段映射的有效性" do
    mapping = %{"姓名" => "name", "邮箱" => "email"}
    form_config = %{fields: [%{name: "name"}, %{name: "email"}, %{name: "phone"}]}
    
    assert :ok = FieldMapper.validate_mapping(mapping, form_config)
  end
  
  test "检测无效的字段映射" do
    mapping = %{"姓名" => "invalid_field"}
    form_config = %{fields: [%{name: "name"}, %{name: "email"}]}
    
    assert {:error, invalid_fields} = FieldMapper.validate_mapping(mapping, form_config)
    assert invalid_fields == ["invalid_field"]
  end
end
```

### 3. 批量验证器测试 (BulkValidator)

```elixir
describe "BulkValidator" do
  test "验证有效的数据批次" do
    data = [
      %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"},
      %{"name" => "李四", "email" => "li@test.com", "phone" => "13900139000"}
    ]
    form_config = get_user_form_config()
    
    assert {:ok, result} = BulkValidator.validate_batch(data, form_config)
    assert result.success_count == 2
    assert result.error_count == 0
  end
  
  test "处理包含错误的数据批次" do
    data = [
      %{"name" => "张三", "email" => "invalid-email", "phone" => "13800138000"},
      %{"name" => "", "email" => "li@test.com", "phone" => "abc123"},
      %{"name" => "王五", "email" => "wang@test.com", "phone" => "13700137000"}
    ]
    form_config = get_user_form_config()
    
    assert {:error, result} = BulkValidator.validate_batch(data, form_config)
    assert result.success_count == 1
    assert result.error_count == 2
    assert length(result.errors) == 3  # 两行错误，其中一行有两个错误
  end
  
  test "检测重复数据" do
    data = [
      %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"},
      %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"}
    ]
    form_config = get_user_form_config()
    
    assert {:error, result} = BulkValidator.validate_batch(data, form_config, detect_duplicates: true)
    assert result.error_count == 1
    assert Enum.any?(result.errors, &(&1.type == :duplicate_data))
  end
  
  test "应用自定义验证规则" do
    data = [%{"name" => "张三", "email" => "zhang@test.com", "department" => "无效部门"}]
    
    custom_validator = fn data, _config ->
      if data["department"] not in ["技术部", "销售部", "市场部"] do
        {:error, "部门名称无效"}
      else
        :ok
      end
    end
    
    form_config = get_user_form_config()
    options = [custom_validators: [custom_validator]]
    
    assert {:error, result} = BulkValidator.validate_batch(data, form_config, options)
    assert Enum.any?(result.errors, &(&1.message =~ "部门名称无效"))
  end
end
```

### 4. 批量保存器测试 (BulkSaver)

```elixir
describe "BulkSaver" do
  test "批量保存有效数据" do
    data = [
      %{"name" => "张三", "email" => "zhang@test.com"},
      %{"name" => "李四", "email" => "li@test.com"}
    ]
    
    save_function = fn batch -> 
      Enum.map(batch, fn item -> {:ok, Map.put(item, "id", :rand.uniform(1000))} end)
    end
    
    assert {:ok, result} = BulkSaver.save_batch(data, save_function)
    assert result.success_count == 2
    assert result.error_count == 0
  end
  
  test "处理部分保存失败的情况" do
    data = [
      %{"name" => "张三", "email" => "zhang@test.com"},
      %{"name" => "重复用户", "email" => "duplicate@test.com"}
    ]
    
    save_function = fn batch ->
      Enum.map(batch, fn item ->
        if item["name"] == "重复用户" do
          {:error, "用户名已存在"}
        else
          {:ok, Map.put(item, "id", :rand.uniform(1000))}
        end
      end)
    end
    
    assert {:partial, result} = BulkSaver.save_batch(data, save_function)
    assert result.success_count == 1
    assert result.error_count == 1
  end
  
  test "使用事务保存数据" do
    data = [
      %{"name" => "张三", "email" => "zhang@test.com"},
      %{"name" => "李四", "email" => "li@test.com"}
    ]
    
    save_function = fn batch ->
      # 模拟事务操作
      Enum.reduce_while(batch, [], fn item, acc ->
        if String.length(item["name"]) > 0 do
          {:cont, [{:ok, Map.put(item, "id", :rand.uniform(1000))} | acc]}
        else
          {:halt, [{:error, "姓名不能为空"} | acc]}
        end
      end)
      |> Enum.reverse()
    end
    
    assert {:ok, result} = BulkSaver.save_batch(data, save_function, transaction: true)
    assert result.success_count == 2
  end
end
```

## 集成测试用例

### 5. 批量导入流程测试

```elixir
describe "BulkImport Integration" do
  test "完整的Excel导入流程" do
    file_path = "test/fixtures/bulk_import/valid_users.xlsx"
    form_config = get_user_form_config()
    bulk_config = get_bulk_config()
    
    # 1. 解析文件
    assert {:ok, {headers, rows}} = BulkImport.parse_file(file_path)
    
    # 2. 字段映射
    assert {:ok, mapping} = BulkImport.auto_map_fields(headers, form_config, bulk_config)
    
    # 3. 数据转换
    assert {:ok, mapped_data} = BulkImport.map_data(headers, rows, mapping)
    
    # 4. 数据验证
    assert {:ok, validation_result} = BulkImport.validate_data(mapped_data, form_config)
    
    # 5. 数据保存
    assert {:ok, save_result} = BulkImport.save_data(validation_result.valid_data, bulk_config)
    
    assert save_result.success_count == 3
  end
  
  test "处理部分有效数据的导入流程" do
    file_path = "test/fixtures/bulk_import/partial_valid.xlsx"
    form_config = get_user_form_config()
    bulk_config = get_bulk_config()
    
    assert {:partial, result} = BulkImport.import_file(file_path, form_config, bulk_config)
    assert result.success_count > 0
    assert result.error_count > 0
    assert length(result.errors) == result.error_count
  end
  
  test "处理完全无效数据的导入" do
    file_path = "test/fixtures/bulk_import/invalid_data.xlsx"
    form_config = get_user_form_config()
    bulk_config = get_bulk_config()
    
    assert {:error, result} = BulkImport.import_file(file_path, form_config, bulk_config)
    assert result.success_count == 0
    assert result.error_count > 0
  end
end
```

## LiveView 测试用例

### 6. 用户交互测试

```elixir
describe "BulkImport LiveView" do
  test "上传有效Excel文件", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    # 启用批量操作模式
    view |> element("button", "批量导入") |> render_click()
    
    # 上传文件
    file = %{
      last_modified: 1_594_171_879_000,
      name: "valid_users.xlsx",
      content: File.read!("test/fixtures/bulk_import/valid_users.xlsx"),
      size: 5024,
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
    
    assert render_upload(view, :bulk_file, [file]) =~ "文件上传成功"
  end
  
  test "字段映射确认流程", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    # 模拟文件上传完成后的状态
    view |> element("button", "批量导入") |> render_click()
    
    # 检查字段映射界面
    html = render(view)
    assert html =~ "字段映射确认"
    assert html =~ "姓名"
    assert html =~ "邮箱"
    
    # 确认映射
    view
    |> form("#field-mapping-form", %{
      "mapping" => %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
    })
    |> render_submit()
    
    assert render(view) =~ "数据验证中"
  end
  
  test "验证结果显示", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    # 模拟验证完成状态
    result = %{
      total_rows: 10,
      success_count: 8,
      error_count: 2,
      errors: [
        %{row: 3, field: "email", message: "邮箱格式不正确"},
        %{row: 7, field: "name", message: "姓名不能为空"}
      ]
    }
    
    send(view.pid, {:validation_complete, result})
    
    html = render(view)
    assert html =~ "总计: 10"
    assert html =~ "成功: 8"
    assert html =~ "失败: 2"
    assert html =~ "邮箱格式不正确"
  end
  
  test "导入历史记录查看", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    view |> element("button", "导入历史") |> render_click()
    
    html = render(view)
    assert html =~ "导入历史"
    assert html =~ "导入时间"
    assert html =~ "文件名"
    assert html =~ "状态"
  end
  
  test "错误报告下载", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    # 模拟有错误的验证结果
    result = %{
      errors: [
        %{row: 1, field: "email", value: "invalid", message: "邮箱格式不正确"}
      ]
    }
    send(view.pid, {:validation_complete, result})
    
    # 点击下载错误报告
    response = view |> element("button", "下载错误报告") |> render_click()
    
    assert response =~ "application/vnd.ms-excel"
  end
end
```

### 7. 错误处理测试

```elixir
describe "BulkImport Error Handling" do
  test "处理不支持的文件格式", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    file = %{
      name: "invalid.txt",
      content: "some text content",
      size: 100,
      type: "text/plain"
    }
    
    assert render_upload(view, :bulk_file, [file]) =~ "不支持的文件格式"
  end
  
  test "处理文件大小超限", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    large_content = String.duplicate("x", 51 * 1024 * 1024)  # 51MB
    file = %{
      name: "large.xlsx",
      content: large_content,
      size: byte_size(large_content),
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
    
    assert render_upload(view, :bulk_file, [file]) =~ "文件大小超过限制"
  end
  
  test "处理空文件", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    file = %{
      name: "empty.xlsx",
      content: "",
      size: 0,
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
    
    assert render_upload(view, :bulk_file, [file]) =~ "文件不能为空"
  end
  
  test "处理网络中断的上传", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form_builder_demo")
    
    # 模拟网络中断
    Process.exit(view.pid, :kill)
    
    # 重新连接后应该恢复状态
    {:ok, new_view, html} = live(conn, "/form_builder_demo")
    assert html =~ "批量导入"
  end
end
```

## 性能测试用例

### 8. 大文件处理测试

```elixir
describe "BulkImport Performance" do
  @tag :performance
  test "处理大量数据的性能" do
    # 生成包含10000行数据的测试文件
    large_data = Enum.map(1..10000, fn i ->
      %{
        "name" => "用户#{i}",
        "email" => "user#{i}@test.com",
        "phone" => "1380013#{String.pad_leading(Integer.to_string(i), 4, "0")}"
      }
    end)
    
    form_config = get_user_form_config()
    
    {time, {:ok, result}} = :timer.tc(fn ->
      BulkValidator.validate_batch(large_data, form_config)
    end)
    
    # 验证应该在10秒内完成
    assert time < 10_000_000  # 10秒 = 10,000,000微秒
    assert result.success_count == 10000
  end
  
  @tag :performance
  test "内存使用测试" do
    initial_memory = :erlang.memory(:total)
    
    # 处理大文件
    large_data = Enum.map(1..50000, fn i ->
      %{"name" => "用户#{i}", "email" => "user#{i}@test.com"}
    end)
    
    BulkValidator.validate_batch(large_data, get_user_form_config())
    
    final_memory = :erlang.memory(:total)
    memory_increase = final_memory - initial_memory
    
    # 内存增长应该合理（小于100MB）
    assert memory_increase < 100 * 1024 * 1024
  end
  
  @tag :performance
  test "并发处理测试" do
    tasks = Enum.map(1..5, fn i ->
      Task.async(fn ->
        data = Enum.map(1..1000, fn j ->
          %{"name" => "用户#{i}-#{j}", "email" => "user#{i}-#{j}@test.com"}
        end)
        BulkValidator.validate_batch(data, get_user_form_config())
      end)
    end)
    
    results = Task.await_many(tasks, 30_000)
    
    # 所有任务都应该成功完成
    assert Enum.all?(results, &match?({:ok, _}, &1))
  end
end
```

## 边界测试用例

### 9. 极限情况测试

```elixir
describe "BulkImport Boundary Tests" do
  test "处理单行数据" do
    data = [%{"name" => "张三", "email" => "zhang@test.com"}]
    form_config = get_user_form_config()
    
    assert {:ok, result} = BulkValidator.validate_batch(data, form_config)
    assert result.success_count == 1
  end
  
  test "处理空数据集" do
    data = []
    form_config = get_user_form_config()
    
    assert {:ok, result} = BulkValidator.validate_batch(data, form_config)
    assert result.success_count == 0
    assert result.error_count == 0
  end
  
  test "处理超长字段值" do
    long_string = String.duplicate("a", 10000)
    data = [%{"name" => long_string, "email" => "test@test.com"}]
    form_config = get_user_form_config()
    
    assert {:error, result} = BulkValidator.validate_batch(data, form_config)
    assert Enum.any?(result.errors, &(&1.message =~ "长度"))
  end
  
  test "处理特殊字符" do
    data = [%{
      "name" => "🔥💯😊",
      "email" => "emoji@test.com",
      "note" => "包含特殊字符: @#$%^&*()_+{}[]|\\:;\"'<>?,./"
    }]
    form_config = get_user_form_config()
    
    assert {:ok, result} = BulkValidator.validate_batch(data, form_config)
    assert result.success_count == 1
  end
  
  test "处理SQL注入尝试" do
    malicious_data = [%{
      "name" => "'; DROP TABLE users; --",
      "email" => "test@test.com"
    }]
    form_config = get_user_form_config()
    
    # 应该安全处理，不会导致错误
    assert {:ok, result} = BulkValidator.validate_batch(malicious_data, form_config)
    assert result.success_count == 1
  end
end
```

## 辅助函数

### 测试配置生成器

```elixir
defp get_user_form_config do
  %{
    fields: [
      %{
        type: "input",
        name: "name",
        label: "姓名",
        required: true,
        validations: [%{type: :length, min: 1, max: 50}]
      },
      %{
        type: "email",
        name: "email",
        label: "邮箱",
        required: true,
        validations: [%{type: :format, pattern: ~r/^[^\s]+@[^\s]+\.[^\s]+$/}]
      },
      %{
        type: "tel",
        name: "phone",
        label: "电话",
        validations: [%{type: :format, pattern: ~r/^1[3-9]\d{9}$/}]
      },
      %{
        type: "select",
        name: "department",
        label: "部门",
        options: [
          %{value: "tech", label: "技术部"},
          %{value: "sales", label: "销售部"},
          %{value: "marketing", label: "市场部"}
        ]
      }
    ]
  }
end

defp get_bulk_config do
  %{
    accepted_file_types: [".xlsx", ".csv"],
    max_file_size: 50 * 1024 * 1024,
    batch_size: 1000,
    field_mapping: %{
      "姓名" => "name",
      "邮箱" => "email",
      "电话" => "phone",
      "部门" => "department"
    },
    validate_batch: &BulkValidator.validate_batch/2,
    save_batch: &BulkSaver.save_batch/2
  }
end
```

## 测试执行计划

### 测试优先级
1. **P0 (关键)**: 基本文件解析、字段映射、数据验证
2. **P1 (重要)**: 错误处理、部分成功处理、用户界面交互
3. **P2 (一般)**: 性能测试、边界情况、安全测试

### 测试环境
- **开发环境**: 所有单元测试和集成测试
- **测试环境**: 性能测试和压力测试
- **生产环境**: 烟雾测试和关键路径测试

### 测试数据管理
- 使用fixtures管理测试文件
- 自动生成大量测试数据
- 隔离测试环境的数据

## 验收标准

### 功能验收
- [ ] 支持Excel和CSV文件导入
- [ ] 智能字段映射功能正常
- [ ] 数据验证准确无误
- [ ] 错误报告详细清晰
- [ ] 部分成功处理正确

### 性能验收
- [ ] 10000行数据验证在10秒内完成
- [ ] 内存使用增长小于100MB
- [ ] 50MB文件上传成功
- [ ] 并发处理稳定

### 用户体验验收
- [ ] 界面响应及时
- [ ] 进度反馈清晰
- [ ] 错误信息友好
- [ ] 操作流程顺畅

## 总结

本测试用例文档涵盖了批量操作功能的各个方面，从基础的文件解析到复杂的用户交互，从正常流程到异常处理，确保功能的可靠性和用户体验。

下一步将基于这些测试用例编写具体的测试代码，为功能实现提供可靠的测试保障。