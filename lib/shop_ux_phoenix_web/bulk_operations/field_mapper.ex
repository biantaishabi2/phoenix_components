defmodule ShopUxPhoenixWeb.BulkOperations.FieldMapper do
  @moduledoc """
  字段映射模块，处理文件字段到表单字段的映射
  """

  @doc """
  自动映射字段
  """
  def auto_map(headers, form_fields, mapping_rules \\ %{}) do
    try do
      # 首先使用预定义的映射规则
      mapped = Map.take(mapping_rules, headers)
      
      # 找出未映射的字段
      unmapped_headers = headers -- Map.keys(mapped)
      
      # 尝试智能匹配未映射的字段
      smart_mapped = smart_match(unmapped_headers, form_fields -- Map.values(mapped))
      
      # 合并映射结果
      final_mapping = Map.merge(mapped, smart_mapped)
      
      # 检查是否有未映射的字段
      still_unmapped = headers -- Map.keys(final_mapping)
      
      case still_unmapped do
        [] -> {:ok, final_mapping}
        unmapped -> {:partial, final_mapping, unmapped}
      end
    rescue
      error ->
        {:error, "字段映射失败: #{inspect(error)}"}
    end
  end

  @doc """
  验证字段映射的有效性
  """
  def validate_mapping(mapping, form_config) do
    form_field_names = extract_form_field_names(form_config)
    
    invalid_fields = mapping
    |> Map.values()
    |> Enum.reject(&(&1 in form_field_names))
    
    case invalid_fields do
      [] -> :ok
      invalid -> {:error, invalid}
    end
  end

  @doc """
  建议字段映射
  """
  def suggest_mapping(headers, form_config) do
    _form_field_names = extract_form_field_names(form_config)
    form_field_labels = extract_form_field_labels(form_config)
    
    suggestions = Enum.reduce(headers, %{}, fn header, acc ->
      # 基于标签相似度建议映射
      best_match = find_best_match(header, form_field_labels)
      
      case best_match do
        {field_name, _similarity} when field_name != nil ->
          Map.put(acc, header, field_name)
        
        _ -> acc
      end
    end)
    
    suggestions
  end

  @doc """
  计算映射置信度
  """
  def get_mapping_confidence(headers, mapping, _form_config) do
    total_headers = length(headers)
    mapped_headers = mapping |> Map.keys() |> length()
    
    case total_headers do
      0 -> 0.0
      _ -> mapped_headers / total_headers
    end
  end

  @doc """
  应用映射转换数据
  """
  def apply_mapping(headers, data_rows, mapping) do
    # 创建索引映射
    header_indices = headers
    |> Enum.with_index()
    |> Map.new()
    
    # 转换每一行数据
    Enum.map(data_rows, fn row ->
      Enum.reduce(mapping, %{}, fn {header, field_name}, acc ->
        case Map.get(header_indices, header) do
          nil -> acc
          index ->
            value = Enum.at(row, index)
            Map.put(acc, field_name, value)
        end
      end)
    end)
  end

  @doc """
  验证必填字段是否已映射
  """
  def validate_required_fields(mapping, form_config) do
    required_fields = extract_required_fields(form_config)
    mapped_fields = Map.values(mapping)
    
    missing_fields = required_fields -- mapped_fields
    
    case missing_fields do
      [] -> :ok
      missing -> {:error, missing}
    end
  end

  # 私有函数

  defp smart_match(headers, available_fields) do
    Enum.reduce(headers, %{}, fn header, acc ->
      case find_best_field_match(header, available_fields) do
        {field, _similarity} when field != nil ->
          Map.put(acc, header, field)
        
        _ -> acc
      end
    end)
  end

  defp find_best_field_match(header, fields) do
    header_lower = String.downcase(header)
    
    similarities = Enum.map(fields, fn field ->
      field_lower = String.downcase(field)
      similarity = calculate_similarity(header_lower, field_lower)
      {field, similarity}
    end)
    
    # 返回相似度最高且超过阈值的匹配
    similarities
    |> Enum.max_by(fn {_field, sim} -> sim end, fn -> {nil, 0.0} end)
    |> case do
      {field, sim} when sim > 0.6 -> {field, sim}
      _ -> {nil, 0.0}
    end
  end

  defp find_best_match(header, field_labels_map) do
    header_lower = String.downcase(header)
    
    similarities = Enum.map(field_labels_map, fn {field_name, label} ->
      label_lower = String.downcase(label)
      similarity = calculate_similarity(header_lower, label_lower)
      {field_name, similarity}
    end)
    
    similarities
    |> Enum.max_by(fn {_field, sim} -> sim end, fn -> {nil, 0.0} end)
    |> case do
      {field, sim} when sim > 0.7 -> {field, sim}
      _ -> {nil, 0.0}
    end
  end

  defp calculate_similarity(str1, str2) do
    # 简单的字符串相似度计算（Jaccard相似度）
    set1 = str1 |> String.graphemes() |> MapSet.new()
    set2 = str2 |> String.graphemes() |> MapSet.new()
    
    intersection_size = MapSet.intersection(set1, set2) |> MapSet.size()
    union_size = MapSet.union(set1, set2) |> MapSet.size()
    
    case union_size do
      0 -> 0.0
      _ -> intersection_size / union_size
    end
  end

  defp extract_form_field_names(form_config) do
    form_config
    |> Map.get(:fields, [])
    |> Enum.map(&Map.get(&1, :name))
    |> Enum.filter(&(&1 != nil))
  end

  defp extract_form_field_labels(form_config) do
    form_config
    |> Map.get(:fields, [])
    |> Enum.map(fn field ->
      {Map.get(field, :name), Map.get(field, :label)}
    end)
    |> Enum.filter(fn {name, label} -> name != nil and label != nil end)
    |> Map.new()
  end

  defp extract_required_fields(form_config) do
    form_config
    |> Map.get(:fields, [])
    |> Enum.filter(&Map.get(&1, :required, false))
    |> Enum.map(&Map.get(&1, :name))
    |> Enum.filter(&(&1 != nil))
  end
end