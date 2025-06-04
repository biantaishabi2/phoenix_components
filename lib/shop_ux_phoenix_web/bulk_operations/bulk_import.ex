defmodule ShopUxPhoenixWeb.BulkOperations.BulkImport do
  @moduledoc """
  批量导入主模块，整合文件解析、字段映射、数据验证和保存功能
  """

  alias ShopUxPhoenixWeb.BulkOperations.{CSVParser, FieldMapper, BulkValidator, BulkSaver}
  alias ShopUxPhoenixWeb.ExcelHelper

  @doc """
  导入文件的完整流程
  """
  def import_file(file_path, form_config, bulk_config) do
    try do
      with {:ok, file_info} <- validate_file(file_path, bulk_config),
           {:ok, {headers, rows}} <- parse_file(file_path),
           {:ok, mapping} <- auto_map_fields(headers, form_config, bulk_config),
           {:ok, mapped_data} <- map_data(headers, rows, mapping),
           {:ok, validation_result} <- validate_data(mapped_data, form_config, 
             detect_duplicates: Map.get(bulk_config, :detect_duplicates, false),
             duplicate_fields: Map.get(bulk_config, :duplicate_fields, [])),
           {:ok, save_result} <- save_data(validation_result.valid_data, bulk_config) do
        
        # 合并结果
        final_result = %{
          total_rows: validation_result.total_rows,
          success_count: save_result.success_count,
          error_count: validation_result.error_count + save_result.error_count,
          saved_data: save_result.saved_data,
          errors: validation_result.errors ++ save_result.errors,
          file_info: file_info,
          mapping: mapping
        }
        
        determine_import_status(final_result)
      else
        {:error, reason} -> {:error, reason}
        {:partial, result, unmapped} -> {:partial, Map.put(result, :unmapped_fields, unmapped)}
      end
    rescue
      error ->
        {:error, "导入过程异常: #{inspect(error)}"}
    end
  end

  @doc """
  验证文件格式和大小
  """
  def validate_file(file_path, bulk_config) do
    try do
      # 检查文件是否存在
      unless File.exists?(file_path) do
        throw({:error, "文件不存在"})
      end
      
      # 检查文件扩展名
      ext = Path.extname(file_path) |> String.downcase()
      accepted_types = Map.get(bulk_config, :accepted_file_types, [".xlsx", ".csv"])
      
      unless ext in accepted_types do
        throw({:error, "不支持的文件格式: #{ext}"})
      end
      
      # 检查文件大小
      stat = File.stat!(file_path)
      max_size = Map.get(bulk_config, :max_file_size, 50 * 1024 * 1024)  # 默认50MB
      
      if stat.size > max_size do
        throw({:error, "文件大小超过限制: #{format_bytes(stat.size)} > #{format_bytes(max_size)}"})
      end
      
      # 返回文件信息
      file_type = case ext do
        ".xlsx" -> :excel
        ".csv" -> :csv
        _ -> :unknown
      end
      
      {:ok, %{
        path: file_path,
        size: stat.size,
        type: file_type,
        extension: ext
      }}
      
    rescue
      error -> {:error, "文件验证失败: #{inspect(error)}"}
    catch
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  解析文件内容
  """
  def parse_file(file_path) do
    case Path.extname(file_path) |> String.downcase() do
      ".xlsx" -> 
        case ExcelHelper.read_excel_file(file_path) do
          {:ok, {headers, rows}} -> {:ok, {headers, rows}}
          {:error, reason} -> {:error, reason}
        end
      ".csv" -> 
        case CSVParser.parse_with_headers(file_path) do
          {:ok, {headers, rows}} -> {:ok, {headers, rows}}
          {:error, reason} -> {:error, reason}
        end
      ext -> {:error, "不支持的文件格式: #{ext}"}
    end
  end

  @doc """
  自动映射字段
  """
  def auto_map_fields(headers, form_config, bulk_config) do
    form_fields = extract_form_field_names(form_config)
    mapping_rules = Map.get(bulk_config, :field_mapping, %{})
    
    case FieldMapper.auto_map(headers, form_fields, mapping_rules) do
      {:ok, mapping} ->
        # 验证映射的有效性
        case FieldMapper.validate_mapping(mapping, form_config) do
          :ok -> {:ok, mapping}
          {:error, invalid_fields} ->
            {:error, "无效的字段映射: #{Enum.join(invalid_fields, ", ")}"}
        end
      
      {:partial, mapping, unmapped} ->
        case FieldMapper.validate_mapping(mapping, form_config) do
          :ok -> 
            # 检查必填字段是否都已映射
            case FieldMapper.validate_required_fields(mapping, form_config) do
              :ok -> {:partial, mapping, unmapped}
              {:error, missing} ->
                {:error, "缺少必填字段映射: #{Enum.join(missing, ", ")}"}
            end
          
          {:error, invalid_fields} ->
            {:error, "无效的字段映射: #{Enum.join(invalid_fields, ", ")}"}
        end
      
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  应用字段映射转换数据
  """
  def map_data(headers, rows, mapping) do
    try do
      mapped_data = FieldMapper.apply_mapping(headers, rows, mapping)
      {:ok, mapped_data}
    rescue
      error ->
        {:error, "数据映射失败: #{inspect(error)}"}
    end
  end

  @doc """
  验证数据
  """
  def validate_data(mapped_data, form_config, options \\ []) do
    # 从bulk_config中提取重复检测配置
    detect_duplicates = options[:detect_duplicates] || false
    duplicate_fields = options[:duplicate_fields] || []
    
    validator_options = [
      detect_duplicates: detect_duplicates,
      duplicate_fields: duplicate_fields
    ]
    
    BulkValidator.validate_batch(mapped_data, form_config, validator_options)
  end

  @doc """
  保存数据
  """
  def save_data(valid_data, bulk_config) do
    save_function = Map.get(bulk_config, :save_function)
    
    unless save_function do
      throw({:error, "缺少保存函数配置"})
    end
    
    batch_size = Map.get(bulk_config, :batch_size, 1000)
    options = [batch_size: batch_size]
    
    BulkSaver.save_batch(valid_data, save_function, options)
  catch
    {:error, reason} -> {:error, reason}
  end

  @doc """
  获取导入模板
  """
  def generate_template(form_config, format \\ :excel) do
    headers = extract_form_field_labels(form_config)
    
    case format do
      :excel ->
        # 生成Excel模板
        temp_path = generate_temp_path("template.xlsx")
        case ExcelHelper.create_excel_file(temp_path, "模板", headers, []) do
          {:ok, _} -> {:ok, temp_path}
          {:error, reason} -> {:error, reason}
        end
      
      :csv ->
        # 生成CSV模板
        csv_content = Enum.join(headers, ",") <> "\n"
        temp_path = generate_temp_path("template.csv")
        case File.write(temp_path, csv_content) do
          :ok -> {:ok, temp_path}
          {:error, reason} -> {:error, "CSV模板生成失败: #{inspect(reason)}"}
        end
      
      _ ->
        {:error, "不支持的模板格式"}
    end
  end

  @doc """
  获取导入进度（用于实时更新）
  """
  def get_import_progress(import_id) do
    # 这里可以实现基于GenServer的进度跟踪
    # 暂时返回模拟数据
    %{
      import_id: import_id,
      status: :processing,
      progress: 75,
      processed_rows: 750,
      total_rows: 1000,
      success_count: 720,
      error_count: 30
    }
  end

  # 私有函数

  defp extract_form_field_names(form_config) do
    form_config
    |> Map.get(:fields, [])
    |> Enum.map(&Map.get(&1, :name))
    |> Enum.filter(&(&1 != nil))
  end

  defp extract_form_field_labels(form_config) do
    form_config
    |> Map.get(:fields, [])
    |> Enum.map(&(Map.get(&1, :label) || Map.get(&1, :name)))
    |> Enum.filter(&(&1 != nil))
  end

  defp determine_import_status(result) do
    cond do
      result.error_count == 0 -> {:ok, result}
      result.success_count == 0 -> {:error, result}
      true -> {:partial, result}
    end
  end

  defp format_bytes(bytes) do
    cond do
      bytes >= 1024 * 1024 * 1024 -> "#{Float.round(bytes / (1024 * 1024 * 1024), 2)} GB"
      bytes >= 1024 * 1024 -> "#{Float.round(bytes / (1024 * 1024), 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} bytes"
    end
  end

  defp generate_temp_path(filename) do
    temp_dir = System.tmp_dir!()
    timestamp = System.system_time(:millisecond)
    unique_filename = "#{timestamp}_#{filename}"
    Path.join(temp_dir, unique_filename)
  end
end