defmodule ShopUxPhoenixWeb.BulkOperations.CSVParser do
  @moduledoc """
  CSV文件解析模块
  """

  @doc """
  解析CSV文件
  """
  def parse_file(file_path) do
    try do
      case File.read(file_path) do
        {:ok, content} ->
          parse_content(content)
        
        {:error, reason} ->
          {:error, "文件读取异常: #{inspect(reason)}"}
      end
    rescue
      error ->
        {:error, "CSV解析异常: #{inspect(error)}"}
    end
  end

  @doc """
  解析CSV内容字符串
  """
  def parse_content(content) do
    try do
      # 使用NimbleCSV解析
      rows = content
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      
      {:ok, rows}
    rescue
      error ->
        {:error, "CSV格式错误: #{inspect(error)}"}
    end
  end

  @doc """
  解析CSV字符串，返回所有行
  """
  def parse_string(content) do
    try do
      rows = content
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      
      {:ok, rows}
    rescue
      error ->
        {:error, "CSV格式错误: #{inspect(error)}"}
    end
  end

  @doc """
  解析CSV字符串，分离表头和数据行
  """
  def parse_string_with_headers(content) do
    case parse_string(content) do
      {:ok, []} -> {:ok, {[], []}}
      {:ok, [headers | data_rows]} -> {:ok, {headers, data_rows}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  解析CSV文件，分离表头和数据行
  """
  def parse_with_headers(file_path) do
    case parse_file(file_path) do
      {:ok, []} -> {:ok, {[], []}}
      {:ok, [headers | data_rows]} -> {:ok, {headers, data_rows}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  验证CSV文件格式
  """
  def validate_csv_file(file_path) do
    case Path.extname(file_path) do
      ".csv" ->
        case parse_file(file_path) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
      
      ext ->
        {:error, "不支持的CSV格式: #{ext}"}
    end
  end

  @doc """
  获取CSV文件信息
  """
  def get_file_info(file_path) do
    try do
      stat = File.stat!(file_path)
      
      # 估算行数（仅用于信息显示）
      {:ok, content} = File.read(file_path)
      line_count = content |> String.split("\n") |> length()
      
      %{
        size: stat.size,
        type: :csv,
        extension: Path.extname(file_path),
        estimated_rows: max(0, line_count - 1)  # 减去表头行
      }
    rescue
      _ -> {:error, "无法获取CSV文件信息"}
    end
  end

  @doc """
  检测CSV文件编码
  """
  def detect_encoding(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        # 简单的编码检测逻辑
        cond do
          String.valid?(content) -> {:ok, :utf8}
          true -> {:ok, :unknown}
        end
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  处理CSV文件中的特殊字符
  """
  def clean_csv_data(rows) do
    Enum.map(rows, fn row ->
      Enum.map(row, fn cell ->
        case cell do
          nil -> ""
          value when is_binary(value) ->
            value
            |> String.trim()
            |> String.replace(~r/\r\n|\r|\n/, " ")  # 替换换行符
          
          value -> to_string(value)
        end
      end)
    end)
  end
end