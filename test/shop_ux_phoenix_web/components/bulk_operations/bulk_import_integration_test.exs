defmodule ShopUxPhoenixWeb.BulkOperations.BulkImportIntegrationTest do
  use ExUnit.Case, async: false
  
  alias ShopUxPhoenixWeb.BulkOperations.BulkImport
  alias ShopUxPhoenixWeb.TestDataGenerator
  
  setup_all do
    # 创建测试文件
    TestDataGenerator.setup_test_files()
    TestDataGenerator.create_invalid_file()
    TestDataGenerator.create_corrupted_excel()
    
    # 不在这里清理文件，让文件保留供其他测试使用
    # on_exit(fn ->
    #   TestDataGenerator.cleanup_test_files()
    # end)
    
    :ok
  end
  
  setup do
    # 每个测试前确保文件存在
    fixtures_dir = Path.join([__DIR__, "..", "..", "..", "fixtures", "bulk_import"])
    unless File.exists?(fixtures_dir) and File.ls!(fixtures_dir) != [] do
      TestDataGenerator.setup_test_files()
      TestDataGenerator.create_invalid_file()
      TestDataGenerator.create_corrupted_excel()
    end
    
    :ok
  end
  
  setup do
    form_config = %{
      fields: [
        %{name: "name", label: "姓名", type: "input", required: true},
        %{name: "email", label: "邮箱", type: "email", required: true},
        %{name: "phone", label: "电话", type: "tel"},
        %{name: "department", label: "部门", type: "select"}
      ]
    }
    
    bulk_config = %{
      accepted_file_types: [".xlsx", ".csv"],
      max_file_size: 50 * 1024 * 1024,
      batch_size: 1000,
      field_mapping: %{
        "姓名" => "name",
        "邮箱" => "email",
        "电话" => "phone",
        "部门" => "department"
      },
      save_function: fn data ->
        # 模拟保存函数
        Enum.map(data, fn item -> 
          {:ok, Map.put(item, "id", :rand.uniform(1000))} 
        end)
      end
    }
    
    %{form_config: form_config, bulk_config: bulk_config}
  end
  
  describe "完整导入流程" do
    test "Excel文件完整导入流程", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("valid_users.xlsx")
      
      # 1. 检查文件是否存在和格式有效
      assert {:ok, file_info} = BulkImport.validate_file(file_path, bulk_config)
      assert file_info.type == :excel
      assert file_info.size > 0
      
      # 2. 解析文件
      assert {:ok, {headers, rows}} = BulkImport.parse_file(file_path)
      assert headers == ["姓名", "邮箱", "电话", "部门"]
      assert length(rows) == 3
      
      # 3. 字段映射
      assert {:ok, mapping} = BulkImport.auto_map_fields(headers, form_config, bulk_config)
      expected_mapping = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone", "部门" => "department"}
      assert mapping == expected_mapping
      
      # 4. 数据转换
      assert {:ok, mapped_data} = BulkImport.map_data(headers, rows, mapping)
      assert length(mapped_data) == 3
      first_item = List.first(mapped_data)
      assert first_item["name"] == "张三"
      assert first_item["email"] == "zhang@test.com"
      
      # 5. 数据验证
      assert {:ok, validation_result} = BulkImport.validate_data(mapped_data, form_config)
      assert validation_result.success_count == 3
      assert validation_result.error_count == 0
      
      # 6. 数据保存
      assert {:ok, save_result} = BulkImport.save_data(validation_result.valid_data, bulk_config)
      assert save_result.success_count == 3
      assert save_result.error_count == 0
    end
    
    test "CSV文件完整导入流程", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("valid_users.csv")
      
      assert {:ok, import_result} = BulkImport.import_file(file_path, form_config, bulk_config)
      assert import_result.success_count == 3
      assert import_result.error_count == 0
      assert import_result.total_rows == 3
      assert length(import_result.saved_data) == 3
    end
    
    test "处理部分有效数据的导入流程", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("partial_valid.xlsx")
      
      result = BulkImport.import_file(file_path, form_config, bulk_config)
      assert match?({:error, _}, result) or match?({:partial, _}, result)
      {_, result} = result
      assert result.success_count > 0
      assert result.error_count > 0
      assert result.total_rows == result.success_count + result.error_count
      assert length(result.errors) >= result.error_count  # 可能有多个字段错误
      # BulkValidator返回的是valid_data，BulkImport集成后才有saved_data
      data_field = if Map.has_key?(result, :saved_data), do: :saved_data, else: :valid_data
      assert length(Map.get(result, data_field)) == result.success_count
    end
    
    test "处理包含重复数据的导入", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("duplicate_data.xlsx")
      
      # 启用重复检测
      bulk_config_with_dup = bulk_config
      |> Map.put(:detect_duplicates, true)
      |> Map.put(:duplicate_fields, ["email"])
      
      assert {:error, result} = BulkImport.import_file(file_path, form_config, bulk_config_with_dup)
      assert result.error_count > 0
      
      # 检查是否检测到重复数据错误
      duplicate_errors = Enum.filter(result.errors, &(&1.type == :duplicate))
      assert length(duplicate_errors) > 0
    end
    
    test "处理特殊字符数据的导入", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("special_chars.xlsx")
      
      assert {:ok, result} = BulkImport.import_file(file_path, form_config, bulk_config)
      assert result.success_count > 0
      
      # 验证特殊字符被正确处理
      saved_item = List.first(result.saved_data)
      assert String.contains?(saved_item["name"], "🔥")
    end
  end
  
  describe "错误处理流程" do
    test "处理不支持的文件格式" do
      file_path = TestDataGenerator.get_fixture_path("invalid_format.txt")
      bulk_config = %{accepted_file_types: [".xlsx", ".csv"]}
      
      assert {:error, error} = BulkImport.validate_file(file_path, bulk_config)
      assert error =~ "不支持的文件格式"
    end
    
    test "处理损坏的Excel文件", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("corrupted.xlsx")
      
      assert {:error, error} = BulkImport.import_file(file_path, form_config, bulk_config)
      assert error =~ "文件解析失败" or error =~ "Excel解析失败"
    end
    
    test "处理空文件", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("empty_file.xlsx")
      
      result = BulkImport.import_file(file_path, form_config, bulk_config)
      # 空文件可能返回成功但没有数据，或者返回特定错误
      case result do
        {:ok, import_result} -> 
          assert import_result.total_rows == 0
        {:error, _error} -> 
          # 也可以接受错误结果
          :ok
      end
    end
    
    test "处理字段映射失败", %{form_config: form_config} do
      file_path = TestDataGenerator.get_fixture_path("valid_users.csv")
      
      # 使用不匹配的字段映射配置
      bulk_config = %{
        field_mapping: %{"完全不匹配" => "name"},
        save_function: fn data -> Enum.map(data, &{:ok, &1}) end
      }
      
      result = BulkImport.import_file(file_path, form_config, bulk_config)
      # 应该返回映射错误或者部分成功
      assert match?({:error, _}, result) or match?({:partial, _}, result)
    end
  end
  
  describe "大文件处理" do
    @tag :performance
    test "处理大Excel文件", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("large_file.xlsx")
      
      {time, result} = :timer.tc(fn ->
        BulkImport.import_file(file_path, form_config, bulk_config)
      end)
      
      assert match?({:ok, _}, result)
      {:ok, import_result} = result
      assert import_result.success_count > 1000
      
      # 大文件处理应该在合理时间内完成（30秒）
      assert time < 30_000_000
    end
    
    @tag :performance
    test "处理大CSV文件", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("large_file.csv")
      
      {time, result} = :timer.tc(fn ->
        BulkImport.import_file(file_path, form_config, bulk_config)
      end)
      
      assert match?({:ok, _}, result)
      {:ok, import_result} = result
      assert import_result.success_count > 1000
      
      # 大文件处理应该在合理时间内完成
      assert time < 30_000_000
    end
    
    @tag :performance
    test "内存使用控制" do
      initial_memory = :erlang.memory(:total)
      
      file_path = TestDataGenerator.get_fixture_path("large_file.csv")
      form_config = %{
        fields: [
          %{name: "name", label: "姓名", type: "input", required: true},
          %{name: "email", label: "邮箱", type: "email", required: true},
          %{name: "phone", label: "电话", type: "tel"},
          %{name: "department", label: "部门", type: "select"}
        ]
      }
      bulk_config = %{
        batch_size: 100,  # 小批次处理
        field_mapping: %{"姓名" => "name", "邮箱" => "email", "电话" => "phone", "部门" => "department"},
        save_function: fn data -> Enum.map(data, &{:ok, &1}) end
      }
      
      result = BulkImport.import_file(file_path, form_config, bulk_config)
      assert match?({:ok, _}, result) or match?({:partial, _}, result)
      {_, _result} = result
      
      final_memory = :erlang.memory(:total)
      memory_increase = final_memory - initial_memory
      
      # 内存增长应该控制在合理范围内（300MB）
      assert memory_increase < 300 * 1024 * 1024
    end
  end
  
  describe "并发处理" do
    @tag :performance
    test "并发导入多个文件" do
      files = [
        "valid_users.csv",
        "partial_valid.csv",
        "special_chars.xlsx"
      ]
      
      form_config = %{
        fields: [
          %{name: "name", label: "姓名", type: "input", required: true},
          %{name: "email", label: "邮箱", type: "email", required: true}
        ]
      }
      
      bulk_config = %{
        field_mapping: %{"姓名" => "name", "邮箱" => "email"},
        save_function: fn data -> 
          Process.sleep(10)  # 模拟保存延迟
          Enum.map(data, &{:ok, &1}) 
        end
      }
      
      tasks = Enum.map(files, fn filename ->
        Task.async(fn ->
          file_path = TestDataGenerator.get_fixture_path(filename)
          BulkImport.import_file(file_path, form_config, bulk_config)
        end)
      end)
      
      results = Task.await_many(tasks, 30_000)
      
      # 所有导入都应该完成（成功或部分成功）
      assert Enum.all?(results, fn result ->
        match?({:ok, _}, result) or match?({:partial, _}, result)
      end)
    end
  end
  
  describe "数据完整性检查" do
    test "验证保存数据的完整性", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("valid_users.csv")
      
      # 自定义保存函数来验证数据完整性
      saved_items = []
      save_function = fn data ->
        # 将保存的数据记录下来
        results = Enum.map(data, fn item ->
          saved_item = Map.put(item, "id", :rand.uniform(1000))
          _saved_items = [saved_item | saved_items]
          {:ok, saved_item}
        end)
        
        # 验证保存的数据结构
        Enum.each(data, fn item ->
          assert Map.has_key?(item, "name")
          assert Map.has_key?(item, "email")
          assert is_binary(item["name"])
          assert is_binary(item["email"])
        end)
        
        results
      end
      
      bulk_config_with_save = Map.put(bulk_config, :save_function, save_function)
      
      assert {:ok, result} = BulkImport.import_file(file_path, form_config, bulk_config_with_save)
      assert result.success_count > 0
      
      # 验证返回的保存数据
      Enum.each(result.saved_data, fn item ->
        assert Map.has_key?(item, "id")
        assert Map.has_key?(item, "name")
        assert Map.has_key?(item, "email")
      end)
    end
    
    test "验证错误报告的准确性", %{form_config: form_config, bulk_config: bulk_config} do
      file_path = TestDataGenerator.get_fixture_path("all_errors.csv")
      
      assert {:error, result} = BulkImport.import_file(file_path, form_config, bulk_config)
      
      # 验证错误报告的结构和内容
      assert length(result.errors) > 0
      
      Enum.each(result.errors, fn error ->
        assert Map.has_key?(error, :row)
        assert Map.has_key?(error, :field)
        assert Map.has_key?(error, :message)
        assert Map.has_key?(error, :type)
        assert is_integer(error.row)
        assert is_binary(error.field)
        assert is_binary(error.message)
        assert is_atom(error.type)
      end)
      
      # 验证行号的准确性（应该从1开始，跳过表头）
      row_numbers = Enum.map(result.errors, &(&1.row))
      assert Enum.all?(row_numbers, &(&1 > 0))
    end
  end
  
  describe "配置验证" do
    test "验证必要配置项", %{form_config: form_config} do
      # 缺少必要配置的bulk_config
      incomplete_config = %{}
      
      file_path = TestDataGenerator.get_fixture_path("valid_users.csv")
      result = BulkImport.import_file(file_path, form_config, incomplete_config)
      
      # 应该返回配置错误
      assert match?({:error, _}, result)
    end
    
    test "验证字段映射配置", %{form_config: form_config} do
      file_path = TestDataGenerator.get_fixture_path("valid_users.csv")
      
      # 包含无效字段映射的配置
      invalid_config = %{
        field_mapping: %{"姓名" => "invalid_field"},
        save_function: fn data -> Enum.map(data, &{:ok, &1}) end
      }
      
      result = BulkImport.import_file(file_path, form_config, invalid_config)
      # 应该检测到无效的字段映射
      assert match?({:error, _}, result) or match?({:partial, _}, result)
    end
  end
end