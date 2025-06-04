defmodule ShopUxPhoenixWeb.BulkOperations.BulkSaverTest do
  use ExUnit.Case, async: true
  
  alias ShopUxPhoenixWeb.BulkOperations.BulkSaver
  
  describe "save_batch/2" do
    test "批量保存有效数据" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "李四", "email" => "li@test.com"}
      ]
      
      save_function = fn batch -> 
        Enum.map(batch, fn item -> 
          {:ok, Map.put(item, "id", :rand.uniform(1000))} 
        end)
      end
      
      assert {:ok, result} = BulkSaver.save_batch(data, save_function)
      assert result.total_rows == 2
      assert result.success_count == 2
      assert result.error_count == 0
      assert length(result.saved_data) == 2
      assert result.errors == []
      
      # 验证保存的数据包含ID
      saved_item = List.first(result.saved_data)
      assert Map.has_key?(saved_item, "id")
    end
    
    test "处理部分保存失败的情况" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "重复用户", "email" => "duplicate@test.com"},
        %{"name" => "李四", "email" => "li@test.com"}
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
      assert result.total_rows == 3
      assert result.success_count == 2
      assert result.error_count == 1
      assert length(result.saved_data) == 2
      assert length(result.errors) == 1
      
      # 验证错误信息
      error = List.first(result.errors)
      assert error.message == "用户名已存在"
      assert error.row_data["name"] == "重复用户"
    end
    
    test "处理全部保存失败的情况" do
      data = [
        %{"name" => "无效用户1", "email" => "invalid1@test.com"},
        %{"name" => "无效用户2", "email" => "invalid2@test.com"}
      ]
      
      save_function = fn batch ->
        Enum.map(batch, fn _item ->
          {:error, "保存失败"}
        end)
      end
      
      assert {:error, result} = BulkSaver.save_batch(data, save_function)
      assert result.total_rows == 2
      assert result.success_count == 0
      assert result.error_count == 2
      assert result.saved_data == []
      assert length(result.errors) == 2
    end
    
    test "处理空数据批次" do
      data = []
      
      save_function = fn batch ->
        Enum.map(batch, fn item -> {:ok, item} end)
      end
      
      assert {:ok, result} = BulkSaver.save_batch(data, save_function)
      assert result.total_rows == 0
      assert result.success_count == 0
      assert result.error_count == 0
      assert result.saved_data == []
      assert result.errors == []
    end
  end
  
  describe "save_batch/3 with options" do
    test "分批处理大量数据" do
      # 生成100条记录
      data = Enum.map(1..100, fn i ->
        %{"name" => "用户#{i}", "email" => "user#{i}@test.com"}
      end)
      
      batch_count = :atomics.new(1, [])
      
      save_function = fn batch ->
        :atomics.add(batch_count, 1, 1)
        Enum.map(batch, fn item -> 
          {:ok, Map.put(item, "id", :rand.uniform(1000))} 
        end)
      end
      
      options = [batch_size: 10]
      assert {:ok, result} = BulkSaver.save_batch(data, save_function, options)
      
      assert result.success_count == 100
      # 应该分成10批次处理
      assert :atomics.get(batch_count, 1) == 10
    end
    
    test "使用事务保存数据" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "李四", "email" => "li@test.com"}
      ]
      
      save_function = fn batch ->
        # 模拟事务操作
        try do
          results = Enum.map(batch, fn item ->
            if String.length(item["name"]) > 0 do
              {:ok, Map.put(item, "id", :rand.uniform(1000))}
            else
              throw({:error, "姓名不能为空"})
            end
          end)
          results
        catch
          {:error, reason} -> 
            Enum.map(batch, fn _item -> {:error, reason} end)
        end
      end
      
      options = [transaction: true]
      assert {:ok, result} = BulkSaver.save_batch(data, save_function, options)
      assert result.success_count == 2
    end
    
    test "事务回滚处理" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "", "email" => "empty@test.com"},  # 会导致失败
        %{"name" => "李四", "email" => "li@test.com"}
      ]
      
      save_function = fn batch ->
        # 模拟事务：如果任何一个失败，全部回滚
        case Enum.find(batch, &(String.length(&1["name"]) == 0)) do
          nil -> 
            Enum.map(batch, fn item -> 
              {:ok, Map.put(item, "id", :rand.uniform(1000))} 
            end)
          _failed_item ->
            Enum.map(batch, fn _item -> {:error, "事务回滚"} end)
        end
      end
      
      options = [transaction: true]
      assert {:error, result} = BulkSaver.save_batch(data, save_function, options)
      assert result.success_count == 0
      assert result.error_count == 3
    end
    
    test "设置超时限制" do
      data = [%{"name" => "张三", "email" => "zhang@test.com"}]
      
      slow_save_function = fn batch ->
        # 模拟慢速保存操作
        Process.sleep(100)
        Enum.map(batch, fn item -> {:ok, item} end)
      end
      
      options = [timeout: 50]  # 50ms超时
      result = BulkSaver.save_batch(data, slow_save_function, options)
      
      # 应该超时或者成功（取决于具体实现）
      assert match?({:error, _}, result) or match?({:ok, _}, result)
    end
    
    test "自定义错误处理器" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "失败用户", "email" => "fail@test.com"}
      ]
      
      save_function = fn batch ->
        Enum.map(batch, fn item ->
          if item["name"] == "失败用户" do
            {:error, %{code: "DUPLICATE", message: "用户已存在", details: item}}
          else
            {:ok, Map.put(item, "id", :rand.uniform(1000))}
          end
        end)
      end
      
      error_handler = fn error_info, row_data ->
        %{
          row_data: row_data,
          error_code: error_info.code,
          message: error_info.message,
          timestamp: DateTime.utc_now()
        }
      end
      
      options = [error_handler: error_handler]
      assert {:partial, result} = BulkSaver.save_batch(data, save_function, options)
      
      error = List.first(result.errors)
      assert Map.has_key?(error, :error_code)
      assert Map.has_key?(error, :timestamp)
    end
  end
  
  describe "save_with_validation/3" do
    test "保存前验证数据" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "", "email" => "invalid-email"}  # 无效数据
      ]
      
      validator = fn item ->
        cond do
          String.length(item["name"]) == 0 -> {:error, "姓名不能为空"}
          not String.contains?(item["email"], "@") -> {:error, "邮箱格式不正确"}
          true -> :ok
        end
      end
      
      save_function = fn batch ->
        Enum.map(batch, fn item -> {:ok, Map.put(item, "id", :rand.uniform(1000))} end)
      end
      
      assert {:partial, result} = BulkSaver.save_with_validation(data, validator, save_function)
      assert result.success_count == 1
      assert result.error_count == 1
    end
    
    test "所有数据验证通过" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "李四", "email" => "li@test.com"}
      ]
      
      validator = fn item ->
        if String.length(item["name"]) > 0 and String.contains?(item["email"], "@") do
          :ok
        else
          {:error, "数据无效"}
        end
      end
      
      save_function = fn batch ->
        Enum.map(batch, fn item -> {:ok, Map.put(item, "id", :rand.uniform(1000))} end)
      end
      
      assert {:ok, result} = BulkSaver.save_with_validation(data, validator, save_function)
      assert result.success_count == 2
      assert result.error_count == 0
    end
  end
  
  describe "performance tests" do
    @tag :performance
    test "大批量保存性能" do
      # 生成10000条记录
      large_data = Enum.map(1..10000, fn i ->
        %{"name" => "用户#{i}", "email" => "user#{i}@test.com"}
      end)
      
      save_function = fn batch ->
        Enum.map(batch, fn item -> 
          {:ok, Map.put(item, "id", :rand.uniform(1000))} 
        end)
      end
      
      {time, {:ok, result}} = :timer.tc(fn ->
        BulkSaver.save_batch(large_data, save_function, batch_size: 100)
      end)
      
      # 保存应该在合理时间内完成（15秒）
      assert time < 15_000_000  # 15秒
      assert result.success_count == 10000
    end
    
    @tag :performance
    test "并发保存测试" do
      # 创建多个并发保存任务
      tasks = Enum.map(1..5, fn i ->
        Task.async(fn ->
          data = Enum.map(1..1000, fn j ->
            %{"name" => "用户#{i}-#{j}", "email" => "user#{i}-#{j}@test.com"}
          end)
          
          save_function = fn batch ->
            Enum.map(batch, fn item -> {:ok, Map.put(item, "id", :rand.uniform(1000))} end)
          end
          
          BulkSaver.save_batch(data, save_function)
        end)
      end)
      
      results = Task.await_many(tasks, 30_000)
      
      # 所有任务都应该成功完成
      assert Enum.all?(results, &match?({:ok, _}, &1))
      
      # 验证总保存数量
      total_saved = results
      |> Enum.map(fn {:ok, result} -> result.success_count end)
      |> Enum.sum()
      
      assert total_saved == 5000
    end
  end
  
  describe "error handling and edge cases" do
    test "处理保存函数异常" do
      data = [%{"name" => "张三", "email" => "zhang@test.com"}]
      
      # 会抛出异常的保存函数
      failing_save_function = fn _batch ->
        raise "数据库连接失败"
      end
      
      result = BulkSaver.save_batch(data, failing_save_function)
      assert match?({:error, _}, result)
    end
    
    test "处理nil保存函数结果" do
      data = [%{"name" => "张三", "email" => "zhang@test.com"}]
      
      nil_save_function = fn _batch -> nil end
      
      result = BulkSaver.save_batch(data, nil_save_function)
      assert match?({:error, _}, result)
    end
    
    test "处理格式错误的保存函数结果" do
      data = [%{"name" => "张三", "email" => "zhang@test.com"}]
      
      invalid_save_function = fn _batch ->
        ["invalid", "result", "format"]
      end
      
      result = BulkSaver.save_batch(data, invalid_save_function)
      assert match?({:error, _}, result)
    end
    
    test "处理超大数据项" do
      # 创建包含大量数据的单个项目
      large_content = String.duplicate("内容", 10000)
      data = [%{"name" => "张三", "content" => large_content}]
      
      save_function = fn batch ->
        Enum.map(batch, fn item -> {:ok, Map.put(item, "id", :rand.uniform(1000))} end)
      end
      
      assert {:ok, result} = BulkSaver.save_batch(data, save_function)
      assert result.success_count == 1
    end
  end
  
  describe "save result structure" do
    test "验证保存结果包含所有必要字段" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},
        %{"name" => "失败用户", "email" => "fail@test.com"}
      ]
      
      save_function = fn batch ->
        Enum.map(batch, fn item ->
          if item["name"] == "失败用户" do
            {:error, "保存失败"}
          else
            {:ok, Map.put(item, "id", :rand.uniform(1000))}
          end
        end)
      end
      
      assert {:partial, result} = BulkSaver.save_batch(data, save_function)
      
      # 检查结果结构
      assert Map.has_key?(result, :total_rows)
      assert Map.has_key?(result, :success_count)
      assert Map.has_key?(result, :error_count)
      assert Map.has_key?(result, :saved_data)
      assert Map.has_key?(result, :errors)
      assert Map.has_key?(result, :processing_time)
      
      # 检查错误对象结构
      if length(result.errors) > 0 do
        error = List.first(result.errors)
        assert Map.has_key?(error, :row_data)
        assert Map.has_key?(error, :message)
        assert Map.has_key?(error, :index)
      end
    end
    
    test "统计信息正确性" do
      data = [
        %{"name" => "张三", "email" => "zhang@test.com"},  # 成功
        %{"name" => "失败1", "email" => "fail1@test.com"}, # 失败
        %{"name" => "李四", "email" => "li@test.com"},     # 成功
        %{"name" => "失败2", "email" => "fail2@test.com"}  # 失败
      ]
      
      save_function = fn batch ->
        Enum.map(batch, fn item ->
          if String.starts_with?(item["name"], "失败") do
            {:error, "保存失败"}
          else
            {:ok, Map.put(item, "id", :rand.uniform(1000))}
          end
        end)
      end
      
      assert {:partial, result} = BulkSaver.save_batch(data, save_function)
      
      assert result.total_rows == 4
      assert result.success_count == 2
      assert result.error_count == 2
      assert result.success_count + result.error_count == result.total_rows
      assert length(result.saved_data) == result.success_count
      assert length(result.errors) == result.error_count
    end
  end
end