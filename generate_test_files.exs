# 运行这个脚本来生成测试文件
# mix run generate_test_files.exs

Code.require_file("test/support/test_file_generator.ex")
ShopUxPhoenixWeb.TestFileGenerator.generate_all()
IO.puts("测试文件已生成！")