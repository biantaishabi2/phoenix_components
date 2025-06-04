defmodule ShopUxPhoenixWeb.ExcelHelper do
  @moduledoc """
  Excel文件创建和处理助手模块
  """

  @doc """
  创建Excel文件
  """
  def create_excel_file(file_path, sheet_name, headers, data) do
    try do
      # 使用Elixlsx创建Excel文件
      workbook = %Elixlsx.Workbook{
        sheets: [
          %Elixlsx.Sheet{
            name: sheet_name,
            rows: [headers | data]
          }
        ]
      }
      
      # 确保目录存在
      file_path |> Path.dirname() |> File.mkdir_p!()
      
      # 写入文件
      Elixlsx.write_to(workbook, file_path)
      
      :ok
    rescue
      error ->
        {:error, "Excel文件创建失败: #{inspect(error)}"}
    end
  end

  @doc """
  读取Excel文件
  """
  def read_excel_file(file_path) do
    try do
      case Xlsxir.extract(file_path, 0) do
        {:ok, sheet_id} ->
          rows = Xlsxir.get_list(sheet_id)
          Xlsxir.close(sheet_id)
          
          case rows do
            [] -> {:ok, {[], []}}
            [headers | data_rows] -> {:ok, {headers, data_rows}}
          end
        
        {:error, reason} ->
          {:error, "Excel解析失败: #{inspect(reason)}"}
      end
    rescue
      error ->
        {:error, "Excel读取失败: #{inspect(error)}"}
    end
  end

  @doc """
  获取Excel文件信息
  """
  def get_file_info(file_path) do
    try do
      stat = File.stat!(file_path)
      
      %{
        size: stat.size,
        type: :excel,
        extension: Path.extname(file_path)
      }
    rescue
      _ -> {:error, "无法获取文件信息"}
    end
  end

  @doc """
  验证Excel文件格式
  """
  def validate_excel_file(file_path) do
    case Path.extname(file_path) do
      ".xlsx" -> 
        case read_excel_file(file_path) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
      
      ext -> 
        {:error, "不支持的Excel格式: #{ext}"}
    end
  end

  @doc """
  在内存中创建Excel数据
  """
  def create_excel_binary(sheet_name, headers, data) do
    workbook = %Elixlsx.Workbook{
      sheets: [
        %Elixlsx.Sheet{
          name: sheet_name,
          rows: [headers | data]
        }
      ]
    }
    
    # Elixlsx.write_to_memory返回 {:ok, {filename, binary_data}}
    case Elixlsx.write_to_memory(workbook, "output.xlsx") do
      {:ok, {_filename, binary_data}} -> {binary_data, "output.xlsx"}
      error -> error
    end
  end

  @doc """
  创建示例Excel文件
  """
  def create_sample_excel(filename) do
    headers = ["姓名", "年龄", "部门", "邮箱"]
    data = [
      ["张三", 28, "技术部", "zhang@example.com"],
      ["李四", 32, "销售部", "li@example.com"],
      ["王五", 26, "市场部", "wang@example.com"]
    ]
    
    case create_excel_file(filename, "示例数据", headers, data) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  创建多工作表Excel文件
  """
  def create_multi_sheet_excel(filename) do
    workbook = %Elixlsx.Workbook{
      sheets: [
        %Elixlsx.Sheet{
          name: "用户数据",
          rows: [
            ["姓名", "年龄", "部门"],
            ["张三", 28, "技术部"],
            ["李四", 32, "销售部"]
          ]
        },
        %Elixlsx.Sheet{
          name: "产品数据", 
          rows: [
            ["产品名", "价格", "库存"],
            ["笔记本", 5000, 10],
            ["鼠标", 50, 100]
          ]
        }
      ]
    }
    
    try do
      # 确保目录存在
      filename |> Path.dirname() |> File.mkdir_p!()
      
      # 写入文件
      Elixlsx.write_to(workbook, filename)
      :ok
    rescue
      error ->
        {:error, "多工作表Excel创建失败: #{inspect(error)}"}
    end
  end

  @doc """
  创建带格式的Excel文件
  """
  def create_formatted_excel(filename) do
    # 注意：Elixlsx对格式支持有限，这里创建基本的格式化文件
    workbook = %Elixlsx.Workbook{
      sheets: [
        %Elixlsx.Sheet{
          name: "格式化数据",
          rows: [
            ["产品名称", "单价", "数量", "总计"],
            ["笔记本电脑", 5000.00, 2, 10000.00],
            ["无线鼠标", 150.50, 5, 752.50],
            ["机械键盘", 399.99, 3, 1199.97]
          ]
        }
      ]
    }
    
    try do
      # 确保目录存在
      filename |> Path.dirname() |> File.mkdir_p!()
      
      # 写入文件
      Elixlsx.write_to(workbook, filename)
      :ok
    rescue
      error ->
        {:error, "格式化Excel创建失败: #{inspect(error)}"}
    end
  end
end