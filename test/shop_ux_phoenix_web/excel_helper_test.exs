defmodule ShopUxPhoenixWeb.ExcelHelperTest do
  use ExUnit.Case, async: true

  alias ShopUxPhoenixWeb.ExcelHelper

  @temp_dir System.tmp_dir!()

  describe "create_excel_file/4" do
    test "creates an Excel file with headers and data" do
      filename = Path.join(@temp_dir, "test_basic.xlsx")
      headers = ["Name", "Age", "City"]
      data = [
        ["John Doe", 30, "New York"],
        ["Jane Smith", 25, "Los Angeles"]
      ]

      assert :ok = ExcelHelper.create_excel_file(filename, "TestSheet", headers, data)
      assert File.exists?(filename)

      # Clean up
      File.rm(filename)
    end
  end

  describe "create_excel_binary/3" do
    test "creates Excel data in memory" do
      headers = ["Product", "Price"]
      data = [["Laptop", 1000], ["Mouse", 25]]

      {content, filename} = ExcelHelper.create_excel_binary("Products", headers, data)

      assert is_binary(content)
      assert filename == "output.xlsx"
      assert byte_size(content) > 0
    end
  end

  describe "create_sample_excel/1" do
    test "creates a sample Excel file with default name" do
      filename = Path.join(@temp_dir, "sample_test.xlsx")

      assert :ok = ExcelHelper.create_sample_excel(filename)
      assert File.exists?(filename)

      # Clean up
      File.rm(filename)
    end
  end

  describe "create_multi_sheet_excel/1" do
    test "creates an Excel file with multiple sheets" do
      filename = Path.join(@temp_dir, "multi_sheet_test.xlsx")

      assert :ok = ExcelHelper.create_multi_sheet_excel(filename)
      assert File.exists?(filename)

      # Clean up
      File.rm(filename)
    end
  end

  describe "create_formatted_excel/1" do
    test "creates an Excel file with formatting" do
      filename = Path.join(@temp_dir, "formatted_test.xlsx")

      assert :ok = ExcelHelper.create_formatted_excel(filename)
      assert File.exists?(filename)

      # Clean up
      File.rm(filename)
    end
  end
end