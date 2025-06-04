defmodule ShopUxPhoenixWeb.BulkOperations.BulkValidator do
  @moduledoc """
  批量数据验证模块
  """

  @doc """
  验证数据批次
  """
  def validate_batch(data, form_config, options \\ []) do
    try do
      case data do
        nil -> {:error, "数据不能为空"}
        [] -> {:ok, create_empty_result()}
        _ -> do_validate_batch(data, form_config, options)
      end
    rescue
      error ->
        {:error, "验证过程异常: #{inspect(error)}"}
    end
  end

  @doc """
  验证单行数据
  """
  def validate_single_row(row_data, form_config, row_number) do
    try do
      case validate_row(row_data, form_config, row_number) do
        {:ok, validated_data} -> {:ok, validated_data}
        {:error, errors} -> {:error, errors}
      end
    rescue
      error ->
        {:error, [create_error(row_number, "unknown", "验证异常: #{inspect(error)}", :exception)]}
    end
  end

  # 私有函数

  defp do_validate_batch(data, form_config, options) do
    detect_duplicates = Keyword.get(options, :detect_duplicates, false)
    _strict_mode = Keyword.get(options, :strict, false)
    _custom_validators = Keyword.get(options, :custom_validators, [])
    batch_size = Keyword.get(options, :batch_size, 1000)
    
    # 分批处理
    results = data
    |> Enum.chunk_every(batch_size)
    |> Enum.with_index()
    |> Enum.flat_map(fn {batch, batch_index} ->
      start_row = batch_index * batch_size + 1
      validate_batch_chunk(batch, form_config, start_row, options)
    end)
    
    # 汇总结果，每行只计算一次错误
    {valid_data, error_rows} = Enum.reduce(results, {[], 0}, fn
      {:ok, validated_data}, {valid_acc, error_acc} ->
        {[validated_data | valid_acc], error_acc}
      
      {:error, _errors}, {valid_acc, error_acc} ->
        {valid_acc, error_acc + 1}
    end)
    
    # 收集所有具体的错误信息用于显示
    all_errors = results
    |> Enum.flat_map(fn
      {:ok, _} -> []
      {:error, errors} -> errors
    end)
    
    # 重复检测
    {final_errors, final_valid_data, final_error_count} = if detect_duplicates do
      duplicate_errors = detect_duplicate_data(Enum.reverse(valid_data), options)
      total_errors = all_errors ++ duplicate_errors
      duplicate_count = length(duplicate_errors)
      
      # 如果检测到重复，从有效数据中移除重复项
      if duplicate_count > 0 do
        duplicate_fields = Keyword.get(options, :duplicate_fields, [])
        cleaned_data = remove_duplicate_items(Enum.reverse(valid_data), duplicate_fields)
        {total_errors, cleaned_data, error_rows + duplicate_count}
      else
        {total_errors, Enum.reverse(valid_data), error_rows}
      end
    else
      {all_errors, Enum.reverse(valid_data), error_rows}
    end
    
    # 生成最终结果
    result = %{
      total_rows: length(data),
      success_count: length(final_valid_data),
      error_count: final_error_count,
      valid_data: final_valid_data,
      errors: final_errors,
      warnings: []
    }
    
    determine_result_status(result)
  end

  defp validate_batch_chunk(batch, form_config, start_row, options) do
    strict_mode = Keyword.get(options, :strict, false)
    custom_validators = Keyword.get(options, :custom_validators, [])
    
    batch
    |> Enum.with_index(start_row)
    |> Enum.map(fn {row_data, row_number} ->
      # 基础验证
      case validate_row(row_data, form_config, row_number) do
        {:ok, validated_data} ->
          # 严格模式检查
          final_data = if strict_mode do
            case check_unknown_fields(row_data, form_config, row_number) do
              :ok -> validated_data
              {:error, errors} -> {:error, errors}
            end
          else
            validated_data
          end
          
          # 自定义验证
          case final_data do
            {:error, errors} -> {:error, errors}
            data -> apply_custom_validators(data, form_config, custom_validators, row_number)
          end
        
        {:error, errors} -> {:error, errors}
      end
    end)
  end

  defp validate_row(row_data, form_config, row_number) do
    try do
      fields = Map.get(form_config, :fields, [])
      
      {validated_data, errors} = Enum.reduce(fields, {%{}, []}, fn field, {data_acc, error_acc} ->
        field_name = Map.get(field, :name)
        field_value = Map.get(row_data, field_name)
        
        case validate_field(field, field_value, row_number) do
          {:ok, processed_value} ->
            {Map.put(data_acc, field_name, processed_value), error_acc}
          
          {:error, field_errors} ->
            {data_acc, field_errors ++ error_acc}
        end
      end)
      
      case errors do
        [] -> {:ok, validated_data}
        _ -> {:error, errors}
      end
    rescue
      error ->
        {:error, [create_error(row_number, "unknown", "行验证异常: #{inspect(error)}", :exception)]}
    end
  end

  defp validate_field(field, value, row_number) do
    field_name = Map.get(field, :name)
    field_type = Map.get(field, :type, "input")
    required = Map.get(field, :required, false)
    validations = Map.get(field, :validations, [])
    
    errors = []
    
    # 必填检查
    errors = if required and is_empty_value(value) do
      [create_error(row_number, field_name, "#{field_name}不能为空", :required) | errors]
    else
      errors
    end
    
    # 如果值为空且不是必填，跳过其他验证
    if is_empty_value(value) and not required do
      {:ok, value}
    else
      # 类型转换和验证
      case convert_and_validate_type(value, field_type, field_name, row_number) do
        {:ok, converted_value} ->
          # 应用额外验证规则
          case apply_field_validations(converted_value, validations, field_name, row_number) do
            :ok -> {:ok, converted_value}
            {:error, validation_errors} -> {:error, errors ++ validation_errors}
          end
        
        {:error, type_errors} ->
          {:error, errors ++ type_errors}
      end
    end
  end

  defp convert_and_validate_type(value, type, field_name, row_number) do
    try do
      case type do
        "input" -> 
          {:ok, to_string(value)}
        
        "email" ->
          email_str = to_string(value)
          if String.match?(email_str, ~r/^[^\s]+@[^\s]+\.[^\s]+$/) do
            {:ok, email_str}
          else
            {:error, [create_error(row_number, field_name, "邮箱格式不正确", :format)]}
          end
        
        "tel" ->
          phone_str = to_string(value)
          if String.match?(phone_str, ~r/^1[3-9]\d{9}$/) do
            {:ok, phone_str}
          else
            {:error, [create_error(row_number, field_name, "电话格式不正确", :format)]}
          end
        
        "number" ->
          case parse_number(value) do
            {:ok, number} -> {:ok, number}
            :error -> {:error, [create_error(row_number, field_name, "数字格式不正确", :format)]}
          end
        
        "select" ->
          {:ok, to_string(value)}
        
        _ ->
          {:ok, to_string(value)}
      end
    rescue
      error ->
        {:error, [create_error(row_number, field_name, "类型转换异常: #{inspect(error)}", :conversion_error)]}
    end
  end

  defp apply_field_validations(value, validations, field_name, row_number) do
    errors = Enum.reduce(validations, [], fn validation, acc ->
      case validate_single_rule(value, validation, field_name, row_number) do
        :ok -> acc
        {:error, error} -> [error | acc]
      end
    end)
    
    case errors do
      [] -> :ok
      _ -> {:error, Enum.reverse(errors)}
    end
  end

  defp validate_single_rule(value, validation, field_name, row_number) do
    case validation do
      %{type: :length, min: min, max: max} ->
        str_value = to_string(value)
        length = String.length(str_value)
        
        cond do
          length < min -> {:error, create_error(row_number, field_name, "长度不能少于#{min}个字符", :too_short)}
          length > max -> {:error, create_error(row_number, field_name, "长度不能超过#{max}个字符", :too_long)}
          true -> :ok
        end
      
      %{type: :format, pattern: pattern} ->
        str_value = to_string(value)
        if String.match?(str_value, pattern) do
          :ok
        else
          {:error, create_error(row_number, field_name, "格式不正确", :invalid_format)}
        end
      
      %{type: :number, min: min, max: max} ->
        case parse_number(value) do
          {:ok, number} ->
            cond do
              number < min -> {:error, create_error(row_number, field_name, "数值不能小于#{min}", :out_of_range)}
              number > max -> {:error, create_error(row_number, field_name, "数值不能大于#{max}", :out_of_range)}
              true -> :ok
            end
          
          :error ->
            {:error, create_error(row_number, field_name, "不是有效数字", :format)}
        end
      
      _ -> :ok
    end
  end

  defp check_unknown_fields(row_data, form_config, row_number) do
    known_fields = form_config
    |> Map.get(:fields, [])
    |> Enum.map(&Map.get(&1, :name))
    |> MapSet.new()
    
    unknown_fields = row_data
    |> Map.keys()
    |> Enum.reject(&MapSet.member?(known_fields, &1))
    
    case unknown_fields do
      [] -> :ok
      fields ->
        errors = Enum.map(fields, fn field ->
          create_error(row_number, field, "未知字段", :unknown_field)
        end)
        {:error, errors}
    end
  end

  defp apply_custom_validators(data, form_config, validators, row_number) do
    errors = Enum.reduce(validators, [], fn validator, acc ->
      case validator.(data, form_config) do
        :ok -> acc
        {:error, message} -> [create_error(row_number, "custom", message, :custom) | acc]
      end
    end)
    
    case errors do
      [] -> {:ok, data}
      _ -> {:error, errors}
    end
  end

  defp detect_duplicate_data(valid_data, options) do
    duplicate_fields = Keyword.get(options, :duplicate_fields, [])
    
    if Enum.empty?(duplicate_fields) do
      []
    else
      # 基于指定字段检测重复
      {_seen, errors} = valid_data
      |> Enum.with_index(1)
      |> Enum.reduce({MapSet.new(), []}, fn {data, index}, {seen, acc} ->
        key = Enum.map(duplicate_fields, &Map.get(data, &1)) |> Enum.join("|")
        
        if MapSet.member?(seen, key) do
          error = create_error(index, Enum.join(duplicate_fields, ","), "数据重复", :duplicate)
          {seen, [error | acc]}
        else
          {MapSet.put(seen, key), acc}
        end
      end)
      
      Enum.reverse(errors)
    end
  end

  defp remove_duplicate_items(valid_data, duplicate_fields) do
    if Enum.empty?(duplicate_fields) do
      valid_data
    else
      {_seen, cleaned} = valid_data
      |> Enum.reduce({MapSet.new(), []}, fn data, {seen, acc} ->
        key = Enum.map(duplicate_fields, &Map.get(data, &1)) |> Enum.join("|")
        
        if MapSet.member?(seen, key) do
          {seen, acc}  # 跳过重复项
        else
          {MapSet.put(seen, key), [data | acc]}
        end
      end)
      
      Enum.reverse(cleaned)
    end
  end

  defp create_error(row, field, message, type) do
    %{
      row: row,
      field: field,
      value: nil,
      message: message,
      type: type
    }
  end

  defp create_empty_result do
    %{
      total_rows: 0,
      success_count: 0,
      error_count: 0,
      valid_data: [],
      errors: [],
      warnings: []
    }
  end

  defp determine_result_status(result) do
    cond do
      result.error_count == 0 -> {:ok, result}
      result.success_count == 0 -> {:error, result}
      true -> {:error, result}  # 有错误就返回error状态
    end
  end

  defp is_empty_value(value) do
    case value do
      nil -> true
      "" -> true
      _ -> false
    end
  end

  defp parse_number(value) do
    case value do
      number when is_number(number) -> {:ok, number}
      string when is_binary(string) ->
        case Float.parse(string) do
          {number, ""} -> {:ok, number}
          _ ->
            case Integer.parse(string) do
              {number, ""} -> {:ok, number}
              _ -> :error
            end
        end
      _ -> :error
    end
  end
end