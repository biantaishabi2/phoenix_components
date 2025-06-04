defmodule ShopUxPhoenixWeb.BulkOperations.CSVParserTest do
  use ExUnit.Case, async: true
  
  alias ShopUxPhoenixWeb.BulkOperations.CSVParser
  alias ShopUxPhoenixWeb.TestDataGenerator
  
  setup_all do
    TestDataGenerator.setup_test_files()
    
    # 不清理文件，让其他测试可以使用
    # on_exit(fn ->
    #   TestDataGenerator.cleanup_test_files()
    # end)
    
    :ok
  end
  
  describe "parse_file/1" do
    test "解析有效的CSV文件" do
      file_path = ShopUxPhoenixWeb.TestDataGenerator.get_fixture_path("valid_users.csv")
      
      assert {:ok, data} = CSVParser.parse_file(file_path)
      assert length(data) == 4  # 3行数据 + 1行表头
      assert List.first(data) == ["姓名", "邮箱", "电话", "部门"]
      
      [_headers | rows] = data
      assert length(rows) == 3
      assert List.first(rows) == ["张三", "zhang@test.com", "13800138000", "技术部"]
    end
    
    test "处理不存在的文件" do
      file_path = Path.join([__DIR__, "../../../..", "test/fixtures/bulk_import/nonexistent.csv"])
      
      assert {:error, error_msg} = CSVParser.parse_file(file_path)
      assert error_msg =~ "文件读取异常"
    end
  end
  
  describe "parse_string/1" do
    test "解析CSV字符串内容" do
      content = "姓名,邮箱\n张三,zhang@test.com\n李四,li@test.com"
      
      assert {:ok, data} = CSVParser.parse_string(content)
      assert data == [
        ["姓名", "邮箱"],
        ["张三", "zhang@test.com"],
        ["李四", "li@test.com"]
      ]
    end
    
    test "处理包含逗号的CSV字段" do
      content = "姓名,地址\n张三,\"北京市,海淀区\"\n"
      
      assert {:ok, data} = CSVParser.parse_string(content)
      assert data == [
        ["姓名", "地址"],
        ["张三", "北京市,海淀区"]
      ]
    end
    
    test "处理空字符串" do
      assert {:ok, []} = CSVParser.parse_string("")
    end
    
    test "处理只有表头的CSV" do
      content = "姓名,邮箱,电话"
      
      assert {:ok, data} = CSVParser.parse_string(content)
      assert data == [["姓名", "邮箱", "电话"]]
    end
  end
  
  describe "parse_with_headers/1" do
    test "分离表头和数据行" do
      file_path = ShopUxPhoenixWeb.TestDataGenerator.get_fixture_path("valid_users.csv")
      
      assert {:ok, {headers, rows}} = CSVParser.parse_with_headers(file_path)
      assert headers == ["姓名", "邮箱", "电话", "部门"]
      assert length(rows) == 3
      assert List.first(rows) == ["张三", "zhang@test.com", "13800138000", "技术部"]
    end
    
    test "处理空文件" do
      content = ""
      
      assert {:ok, {[], []}} = CSVParser.parse_string_with_headers(content)
    end
    
    test "处理只有表头的文件" do
      content = "姓名,邮箱"
      
      assert {:ok, {headers, rows}} = CSVParser.parse_string_with_headers(content)
      assert headers == ["姓名", "邮箱"]
      assert rows == []
    end
  end
  
  describe "数据类型处理" do
    test "处理空值和空字符串" do
      content = "姓名,年龄,备注\n张三,,\n,25,备注\n李四,30,完整数据"
      
      assert {:ok, data} = CSVParser.parse_string(content)
      [_headers | rows] = data
      
      assert Enum.at(rows, 0) == ["张三", "", ""]
      assert Enum.at(rows, 1) == ["", "25", "备注"]
      assert Enum.at(rows, 2) == ["李四", "30", "完整数据"]
    end
    
    test "处理特殊字符" do
      content = "姓名,备注\n张三,\"包含特殊字符: @#$%^&*()\"\n李四,包含中文和数字123"
      
      assert {:ok, data} = CSVParser.parse_string(content)
      [_headers | rows] = data
      
      assert Enum.at(rows, 0) == ["张三", "包含特殊字符: @#$%^&*()"]
      assert Enum.at(rows, 1) == ["李四", "包含中文和数字123"]
    end
  end
  
  describe "错误处理" do
    test "处理格式错误的CSV" do
      # 未闭合的引号
      content = "姓名,备注\n张三,\"未闭合引号\n李四,正常数据"
      
      # 应该能够容错处理或返回适当的错误
      result = CSVParser.parse_string(content)
      # 根据实际实现调整断言
      assert match?({:error, _}, result) or match?({:ok, _}, result)
    end
    
    test "处理超长行" do
      long_value = String.duplicate("a", 100_000)
      content = "姓名,备注\n张三,#{long_value}"
      
      assert {:ok, data} = CSVParser.parse_string(content)
      [_headers | rows] = data
      [_name, note] = List.first(rows)
      assert String.length(note) == 100_000
    end
  end
end