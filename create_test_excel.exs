# 创建测试用的Excel文件
alias ShopUxPhoenixWeb.ExcelHelper

# 确保目录存在
File.mkdir_p!("test/fixtures/bulk_import")

# 创建valid_users.xlsx
headers = ["姓名", "邮箱", "电话", "部门"]
data = [
  ["张三", "zhang@test.com", "13800138000", "技术部"],
  ["李四", "li@test.com", "13900139000", "销售部"],
  ["王五", "wang@test.com", "13700137000", "市场部"]
]

ExcelHelper.create_excel_file(
  "test/fixtures/bulk_import/valid_users.xlsx",
  "用户数据",
  headers,
  data
)

# 创建partial_valid.xlsx
partial_data = [
  ["张三", "zhang@test.com", "13800138000", "技术部"],
  ["", "invalid-email", "abc123", ""],  # 无效行
  ["王五", "wang@test.com", "13700137000", "市场部"],
  ["李四", "", "13900139000", "销售部"]  # 部分无效
]

ExcelHelper.create_excel_file(
  "test/fixtures/bulk_import/partial_valid.xlsx",
  "部分有效数据",
  headers,
  partial_data
)

# 创建duplicate_data.xlsx
duplicate_data = [
  ["张三", "zhang@test.com", "13800138000", "技术部"],
  ["李四", "li@test.com", "13900139000", "销售部"],
  ["张三", "zhang@test.com", "13800138000", "技术部"],  # 重复
  ["王五", "wang@test.com", "13700137000", "市场部"]
]

ExcelHelper.create_excel_file(
  "test/fixtures/bulk_import/duplicate_data.xlsx",
  "重复数据",
  headers,
  duplicate_data
)

# 创建special_chars.xlsx
special_data = [
  ["张三🔥", "zhang@test.com", "13800138000", "技术部"],
  ["李四", "li@test.com", "13900139000", "销售部"]
]

ExcelHelper.create_excel_file(
  "test/fixtures/bulk_import/special_chars.xlsx",
  "特殊字符",
  headers,
  special_data
)

# 创建空文件
ExcelHelper.create_excel_file(
  "test/fixtures/bulk_import/empty_file.xlsx",
  "空数据",
  [],
  []
)

# 创建大文件
large_data = Enum.map(1..2000, fn i ->
  ["用户#{i}", "user#{i}@test.com", "13800138000", "技术部"]
end)

ExcelHelper.create_excel_file(
  "test/fixtures/bulk_import/large_file.xlsx",
  "大数据",
  headers,
  large_data
)

# 创建损坏的Excel文件（实际上是文本内容）
File.write!(
  "test/fixtures/bulk_import/corrupted.xlsx",
  "这不是真正的Excel文件内容，只是文本"
)

IO.puts("Excel测试文件创建完成！")