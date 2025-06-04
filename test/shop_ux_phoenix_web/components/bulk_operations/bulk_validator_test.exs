defmodule ShopUxPhoenixWeb.BulkOperations.BulkValidatorTest do
  use ExUnit.Case, async: true
  
  alias ShopUxPhoenixWeb.BulkOperations.BulkValidator
  
  setup do
    form_config = %{
      fields: [
        %{
          name: "name",
          label: "姓名",
          type: "input",
          required: true,
          validations: [%{type: :length, min: 1, max: 50}]
        },
        %{
          name: "email",
          label: "邮箱",
          type: "email",
          required: true,
          validations: [%{type: :format, pattern: ~r/^[^\s]+@[^\s]+\.[^\s]+$/}]
        },
        %{
          name: "phone",
          label: "电话",
          type: "tel",
          validations: [%{type: :format, pattern: ~r/^1[3-9]\d{9}$/}]
        },
        %{
          name: "age",
          label: "年龄",
          type: "number",
          validations: [%{type: :number, min: 0, max: 120}]
        },
        %{
          name: "department",
          label: "部门",
          type: "select",
          options: [
            %{value: "tech", label: "技术部"},
            %{value: "sales", label: "销售部"},
            %{value: "marketing", label: "市场部"}
          ]
        }
      ]
    }
    
    %{form_config: form_config}
  end
  
  describe "validate_batch/2" do
    test "验证有效的数据批次", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000", "age" => "28"},
        %{"name" => "李四", "email" => "li@test.com", "phone" => "13900139000", "age" => "32"}
      ]
      
      assert {:ok, result} = BulkValidator.validate_batch(data, form_config)
      assert result.total_rows == 2
      assert result.success_count == 2
      assert result.error_count == 0
      assert result.errors == []
      assert length(result.valid_data) == 2
    end
    
    test "处理包含错误的数据批次", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "invalid-email", "phone" => "13800138000"},
        %{"name" => "", "email" => "li@test.com", "phone" => "abc123"},
        %{"name" => "王五", "email" => "wang@test.com", "phone" => "13700137000"}
      ]
      
      assert {:error, result} = BulkValidator.validate_batch(data, form_config)
      assert result.total_rows == 3
      assert result.success_count == 1
      assert result.error_count == 2
      assert length(result.errors) >= 2
      assert length(result.valid_data) == 1
      
      # 验证错误信息的结构
      first_error = List.first(result.errors)
      assert Map.has_key?(first_error, :row)
      assert Map.has_key?(first_error, :field)
      assert Map.has_key?(first_error, :message)
      assert Map.has_key?(first_error, :type)
    end
    
    test "处理空数据批次", %{form_config: form_config} do
      data = []
      
      assert {:ok, result} = BulkValidator.validate_batch(data, form_config)
      assert result.total_rows == 0
      assert result.success_count == 0
      assert result.error_count == 0
      assert result.valid_data == []
    end
    
    test "验证必填字段", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},  # 有效
        %{"name" => "", "email" => "li@test.com"},  # name为空
        %{"name" => "王五", "email" => ""},  # email为空
        %{"phone" => "13700137000"}  # 缺少必填字段
      ]
      
      assert {:error, result} = BulkValidator.validate_batch(data, form_config)
      assert result.success_count == 1
      assert result.error_count == 3
      
      # 检查是否正确标识了必填字段错误
      required_errors = Enum.filter(result.errors, &(&1.type == :required))
      assert length(required_errors) >= 2
    end
    
    test "验证数据格式", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "invalid-email", "phone" => "13800138000"},
        %{"name" => "李四", "email" => "li@test.com", "phone" => "invalid-phone"},
        %{"name" => "王五", "email" => "wang@test.com", "age" => "invalid-age"}
      ]
      
      assert {:error, result} = BulkValidator.validate_batch(data, form_config)
      
      # 检查格式错误
      format_errors = Enum.filter(result.errors, &(&1.type == :format || &1.type == :invalid_format))
      assert length(format_errors) >= 3
    end
    
    test "验证数值范围", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com", "age" => "-5"},  # 年龄小于最小值
        %{"name" => "李四", "email" => "li@test.com", "age" => "150"},  # 年龄大于最大值
        %{"name" => String.duplicate("王", 60), "email" => "wang@test.com"}  # 姓名过长
      ]
      
      assert {:error, result} = BulkValidator.validate_batch(data, form_config)
      
      # 检查范围和长度错误
      range_errors = Enum.filter(result.errors, &(&1.type in [:out_of_range, :too_long, :too_short]))
      assert length(range_errors) >= 3
    end
  end
  
  describe "validate_batch/3 with options" do
    test "检测重复数据", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"},
        %{"name" => "李四", "email" => "li@test.com", "phone" => "13900139000"},
        %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"}  # 重复
      ]
      
      options = [detect_duplicates: true, duplicate_fields: ["email"]]
      assert {:error, result} = BulkValidator.validate_batch(data, form_config, options)
      
      duplicate_errors = Enum.filter(result.errors, &(&1.type == :duplicate))
      assert length(duplicate_errors) >= 1
    end
    
    test "应用自定义验证规则", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com", "department" => "技术部"},
        %{"name" => "李四", "email" => "li@test.com", "department" => "无效部门"}
      ]
      
      custom_validator = fn row_data, _config ->
        case row_data["department"] do
          dept when dept in ["技术部", "销售部", "市场部"] -> :ok
          _ -> {:error, "部门名称无效"}
        end
      end
      
      options = [custom_validators: [custom_validator]]
      assert {:error, result} = BulkValidator.validate_batch(data, form_config, options)
      
      custom_errors = Enum.filter(result.errors, &(&1.message =~ "部门名称无效"))
      assert length(custom_errors) == 1
    end
    
    test "批量大小限制", %{form_config: form_config} do
      data = Enum.map(1..100, fn i ->
        %{"name" => "用户#{i}", "email" => "user#{i}@test.com"}
      end)
      
      options = [batch_size: 10]
      assert {:ok, result} = BulkValidator.validate_batch(data, form_config, options)
      assert result.success_count == 100
    end
    
    test "严格模式验证", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com", "unknown_field" => "value"}
      ]
      
      # 非严格模式（默认）应该忽略未知字段
      assert {:ok, _result} = BulkValidator.validate_batch(data, form_config, strict: false)
      
      # 严格模式应该报错未知字段
      assert {:error, result} = BulkValidator.validate_batch(data, form_config, strict: true)
      unknown_errors = Enum.filter(result.errors, &(&1.type == :unknown_field))
      assert length(unknown_errors) >= 1
    end
  end
  
  describe "validate_single_row/3" do
    test "验证单行有效数据", %{form_config: form_config} do
      row_data = %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"}
      
      assert {:ok, validated_data} = BulkValidator.validate_single_row(row_data, form_config, 1)
      assert validated_data["name"] == "张三"
      assert validated_data["email"] == "zhang@test.com"
    end
    
    test "验证单行无效数据", %{form_config: form_config} do
      row_data = %{"name" => "", "email" => "invalid-email"}
      
      assert {:error, errors} = BulkValidator.validate_single_row(row_data, form_config, 2)
      assert length(errors) >= 2
      assert Enum.any?(errors, &(&1.row == 2))
    end
    
    test "数据类型转换", %{form_config: form_config} do
      row_data = %{"name" => "张三", "email" => "zhang@test.com", "age" => "28"}
      
      assert {:ok, validated_data} = BulkValidator.validate_single_row(row_data, form_config, 1)
      # 年龄应该被转换为数字
      assert is_integer(validated_data["age"]) or is_float(validated_data["age"])
    end
  end
  
  describe "performance tests" do
    @tag :performance
    test "大批量数据验证性能", %{form_config: form_config} do
      # 生成10000条记录
      large_data = Enum.map(1..10000, fn i ->
        %{
          "name" => "用户#{i}",
          "email" => "user#{i}@test.com",
          "phone" => "1380013#{String.pad_leading(Integer.to_string(rem(i, 10000)), 4, "0")}"
        }
      end)
      
      {time, {:ok, result}} = :timer.tc(fn ->
        BulkValidator.validate_batch(large_data, form_config)
      end)
      
      # 验证应该在合理时间内完成（10秒）
      assert time < 10_000_000  # 10秒 = 10,000,000微秒
      assert result.success_count == 10000
    end
    
    @tag :performance
    test "内存使用测试", %{form_config: form_config} do
      initial_memory = :erlang.memory(:total)
      
      # 处理大量数据
      large_data = Enum.map(1..50000, fn i ->
        %{"name" => "用户#{i}", "email" => "user#{i}@test.com"}
      end)
      
      {:ok, _result} = BulkValidator.validate_batch(large_data, form_config)
      
      final_memory = :erlang.memory(:total)
      memory_increase = final_memory - initial_memory
      
      # 内存增长应该合理（小于200MB）
      assert memory_increase < 200 * 1024 * 1024
    end
  end
  
  describe "error handling" do
    test "处理nil数据", %{form_config: form_config} do
      assert {:error, "数据不能为空"} = BulkValidator.validate_batch(nil, form_config)
    end
    
    test "处理无效的配置", %{form_config: _form_config} do
      data = [%{"name" => "张三"}]
      invalid_config = %{fields: "invalid"}
      
      assert {:error, _message} = BulkValidator.validate_batch(data, invalid_config)
    end
    
    test "处理异常情况", %{form_config: _form_config} do
      # 模拟引发异常的数据 - 使用无效的配置
      invalid_config = %{fields: "invalid_string_not_list"}
      problematic_data = [%{"name" => "test", "email" => "test@test.com"}]
      
      # 应该捕获异常并返回错误信息
      result = BulkValidator.validate_batch(problematic_data, invalid_config)
      assert match?({:error, _}, result)
    end
  end
  
  describe "validation result structure" do
    test "验证结果包含所有必要字段", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "", "email" => "invalid-email"}
      ]
      
      assert {:error, result} = BulkValidator.validate_batch(data, form_config)
      
      # 检查结果结构
      assert Map.has_key?(result, :total_rows)
      assert Map.has_key?(result, :success_count)
      assert Map.has_key?(result, :error_count)
      assert Map.has_key?(result, :errors)
      assert Map.has_key?(result, :valid_data)
      assert Map.has_key?(result, :warnings)
      
      # 检查错误对象结构
      if length(result.errors) > 0 do
        error = List.first(result.errors)
        assert Map.has_key?(error, :row)
        assert Map.has_key?(error, :field)
        assert Map.has_key?(error, :value)
        assert Map.has_key?(error, :message)
        assert Map.has_key?(error, :type)
      end
    end
    
    test "统计信息正确性", %{form_config: form_config} do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},  # 有效
        %{"name" => "", "email" => "invalid-email"},       # 2个错误
        %{"name" => "王五", "email" => "wang@test.com"}     # 有效
      ]
      
      assert {:error, result} = BulkValidator.validate_batch(data, form_config)
      
      assert result.total_rows == 3
      assert result.success_count == 2
      assert result.error_count == 1
      assert result.success_count + result.error_count == result.total_rows
    end
  end
end