defmodule ShopUxPhoenixWeb.TestDataGenerator do
  @moduledoc """
  生成测试用的Excel和CSV文件
  """

  alias ShopUxPhoenixWeb.ExcelHelper
  
  @fixtures_dir Path.join([__DIR__, "..", "fixtures", "bulk_import"])
  
  def setup_test_files do
    ensure_fixtures_dir()
    create_excel_files()
    create_basic_csv_files()
    create_additional_csv_files()
  end
  
  defp ensure_fixtures_dir do
    File.mkdir_p!(@fixtures_dir)
  end
  
  defp create_excel_files do
    # 有效的用户数据Excel文件
    valid_headers = ["姓名", "邮箱", "电话", "部门"]
    valid_data = [
      ["张三", "zhang@test.com", "13800138000", "技术部"],
      ["李四", "li@test.com", "13900139000", "销售部"],
      ["王五", "wang@test.com", "13700137000", "市场部"]
    ]
    
    ExcelHelper.create_excel_file(
      Path.join(@fixtures_dir, "valid_users.xlsx"),
      "用户数据",
      valid_headers,
      valid_data
    )
    
    # 部分有效数据的Excel文件
    partial_data = [
      ["张三", "zhang@test.com", "13800138000", "技术部"],
      ["", "invalid-email", "abc123", ""],  # 无效行
      ["王五", "wang@test.com", "13700137000", "市场部"],
      ["李四", "", "13900139000", "销售部"]  # 部分无效
    ]
    
    ExcelHelper.create_excel_file(
      Path.join(@fixtures_dir, "partial_valid.xlsx"),
      "部分有效数据",
      valid_headers,
      partial_data
    )
    
    # 包含重复数据的Excel文件
    duplicate_data = [
      ["张三", "zhang@test.com", "13800138000", "技术部"],
      ["李四", "li@test.com", "13900139000", "销售部"],
      ["张三", "zhang@test.com", "13800138000", "技术部"],  # 重复
      ["王五", "wang@test.com", "13700137000", "市场部"]
    ]
    
    ExcelHelper.create_excel_file(
      Path.join(@fixtures_dir, "duplicate_data.xlsx"),
      "重复数据",
      valid_headers,
      duplicate_data
    )
    
    # 空Excel文件
    ExcelHelper.create_excel_file(
      Path.join(@fixtures_dir, "empty_file.xlsx"),
      "空数据",
      [],
      []
    )
    
    # 大数据文件（用于性能测试）
    large_data = Enum.map(1..5000, fn i ->
      ["用户#{i}", "user#{i}@test.com", "1380013#{String.pad_leading(Integer.to_string(rem(i, 10000)), 4, "0")}", "技术部"]
    end)
    
    ExcelHelper.create_excel_file(
      Path.join(@fixtures_dir, "large_file.xlsx"),
      "大数据",
      valid_headers,
      large_data
    )
    
    # 包含特殊字符的Excel文件
    special_data = [
      ["张三 🔥", "zhang+test@example.com", "13800138000", "技术部"],
      ["Li & Smith", "li.smith@test-company.co.uk", "13900139000", "R&D部门"],
      ["王五@北京", "wang.wu@email.中国", "13700137000", "市场&销售部"]
    ]
    
    ExcelHelper.create_excel_file(
      Path.join(@fixtures_dir, "special_chars.xlsx"),
      "特殊字符",
      valid_headers,
      special_data
    )
  end
  
  defp create_basic_csv_files do
    # 有效的用户数据CSV文件
    valid_csv_content = """
姓名,邮箱,电话,部门
张三,zhang@test.com,13800138000,技术部
李四,li@test.com,13900139000,销售部
王五,wang@test.com,13700137000,市场部
"""
    
    File.write!(
      Path.join(@fixtures_dir, "valid_users.csv"),
      valid_csv_content
    )
    
    # 部分有效数据的CSV文件
    partial_csv_content = """
姓名,邮箱,电话,部门
张三,zhang@test.com,13800138000,技术部
,invalid-email,abc123,
王五,wang@test.com,13700137000,市场部
李四,,13900139000,销售部
"""
    
    File.write!(
      Path.join(@fixtures_dir, "partial_valid.csv"),
      partial_csv_content
    )
    
    # 包含特殊字符的CSV文件
    special_csv_content = """
姓名,邮箱,电话,部门
张三 🔥,zhang+test@example.com,13800138000,技术部
Li & Smith,li.smith@test-company.co.uk,13900139000,R&D部门
王五@北京,wang.wu@email.中国,13700137000,市场&销售部
"""
    
    File.write!(
      Path.join(@fixtures_dir, "special_chars.csv"),
      special_csv_content
    )
  end
  
  defp create_additional_csv_files do
    # 确保目录存在
    ensure_fixtures_dir()
    # 格式错误的CSV文件
    malformed_content = """
    姓名,邮箱,电话
    张三,zhang@test.com,13800138000
    李四,"unclosed quote,13900139000
    王五,wang@test.com,13700137000
    """
    
    File.write!(
      Path.join(@fixtures_dir, "malformed.csv"),
      malformed_content
    )
    
    # 编码问题的CSV文件（模拟GBK编码）
    mixed_encoding_content = """
    姓名,邮箱,电话,备注
    张三,zhang@test.com,13800138000,正常数据
    李四,li@test.com,13900139000,包含中文
    """
    
    File.write!(
      Path.join(@fixtures_dir, "mixed_encoding.csv"),
      mixed_encoding_content
    )
    
    # 超大CSV文件（用于内存测试）
    large_csv_headers = "姓名,邮箱,电话,部门\n"
    large_csv_rows = Enum.map(1..10000, fn i ->
      "用户#{i},user#{i}@test.com,1380013#{String.pad_leading(Integer.to_string(rem(i, 10000)), 4, "0")},技术部"
    end) |> Enum.join("\n")
    
    File.write!(
      Path.join(@fixtures_dir, "large_file.csv"),
      large_csv_headers <> large_csv_rows
    )
    
    # 空CSV文件
    File.write!(Path.join(@fixtures_dir, "empty_file.csv"), "")
    
    # 只有表头的CSV文件
    File.write!(Path.join(@fixtures_dir, "headers_only.csv"), "姓名,邮箱,电话,部门")
    
    # 包含所有错误类型的CSV文件
    error_csv_content = """
    姓名,邮箱,电话,部门
    ,invalid-email,abc123,
    ,bad@,xyz,无效部门
    重复用户,duplicate@test.com,13800138000,技术部
    重复用户,duplicate@test.com,13800138000,技术部
    #{String.duplicate("超长姓名", 100)},toolong@test.com,13900139000,技术部
    正常用户,normal@test.com,13700137000,销售部
    """
    
    File.write!(
      Path.join(@fixtures_dir, "all_errors.csv"),
      error_csv_content
    )
  end
  
  def create_invalid_file do
    # 确保目录存在
    ensure_fixtures_dir()
    # 创建一个无效格式的文件（不是Excel或CSV）
    File.write!(
      Path.join(@fixtures_dir, "invalid_format.txt"),
      "这是一个文本文件，不是Excel或CSV格式"
    )
  end
  
  def create_corrupted_excel do
    # 确保目录存在
    ensure_fixtures_dir()
    # 创建一个损坏的Excel文件（实际上是文本内容）
    File.write!(
      Path.join(@fixtures_dir, "corrupted.xlsx"),
      "这不是真正的Excel文件内容，只是文本"
    )
  end
  
  def cleanup_test_files do
    if File.exists?(@fixtures_dir) do
      File.rm_rf!(@fixtures_dir)
    end
  end
  
  def get_fixture_path(filename) do
    Path.join(@fixtures_dir, filename)
  end
end