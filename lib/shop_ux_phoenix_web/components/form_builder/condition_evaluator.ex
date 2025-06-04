defmodule ShopUxPhoenixWeb.Components.FormBuilder.ConditionEvaluator do
  @moduledoc """
  高级条件评估器，支持复杂的逻辑表达式
  
  支持的条件格式：
  - 简单字符串: "field == 'value'"
  - AND 逻辑: %{and: ["cond1", "cond2"]}
  - OR 逻辑: %{or: ["cond1", "cond2"]}
  - 嵌套条件: %{and: ["cond1", %{or: ["cond2", "cond3"]}]}
  - 高级表达式: %{expression: "field > 10 && (status == 'active' || priority == 'high')"}
  
  支持的操作符：
  - 比较: ==, !=, >, <, >=, <=
  - 逻辑: &&, ||, !
  - 包含: in, not_in
  - 正则: matches
  - 存在性: present, blank
  """
  
  @max_recursion_depth 10
  
  @doc """
  评估条件是否满足
  
  ## 参数
  - condition: 条件表达式（字符串或映射）
  - form_data: 表单数据映射
  
  ## 返回
  - true/false: 条件是否满足
  """
  def evaluate(condition, form_data, depth \\ 0)
  
  # 防止无限递归
  def evaluate(_condition, _form_data, depth) when depth > @max_recursion_depth do
    raise "Maximum recursion depth exceeded"
  end
  
  # 向后兼容：简单字符串条件
  def evaluate(condition, form_data, depth) when is_binary(condition) do
    evaluate_simple_condition(condition, form_data, depth)
  end
  
  # AND 逻辑
  def evaluate(%{and: conditions}, form_data, depth) when is_list(conditions) do
    Enum.all?(conditions, &evaluate(&1, form_data, depth + 1))
  end
  
  # OR 逻辑
  def evaluate(%{or: conditions}, form_data, depth) when is_list(conditions) do
    Enum.any?(conditions, &evaluate(&1, form_data, depth + 1))
  end
  
  # 高级表达式
  def evaluate(%{expression: expr}, form_data, depth) when is_binary(expr) do
    evaluate_expression(expr, form_data, depth)
  end
  
  # 默认情况
  def evaluate(_condition, _form_data, _depth), do: true
  
  # 评估简单条件字符串
  defp evaluate_simple_condition(condition, form_data, _depth) do
    cond do
      
      # 比较操作符
      Regex.match?(~r/^\s*(\w+)\s*(==|!=|>=?|<=?)\s*(.+)\s*$/, condition) ->
        evaluate_comparison(condition, form_data)
      
      # in 操作符
      Regex.match?(~r/^\s*(\w+)\s+in\s+\[(.+)\]\s*$/, condition) ->
        evaluate_in_operator(condition, form_data)
      
      # not_in 操作符
      Regex.match?(~r/^\s*(\w+)\s+not_in\s+\[(.+)\]\s*$/, condition) ->
        evaluate_not_in_operator(condition, form_data)
      
      # matches 操作符
      Regex.match?(~r/^\s*(\w+)\s+matches\s+'(.+)'\s*$/, condition) ->
        evaluate_matches_operator(condition, form_data)
      
      # present 操作符
      Regex.match?(~r/^\s*(\w+)\s+present\s*$/, condition) ->
        evaluate_present_operator(condition, form_data)
      
      # blank 操作符
      Regex.match?(~r/^\s*(\w+)\s+blank\s*$/, condition) ->
        evaluate_blank_operator(condition, form_data)
      
      # 默认
      true -> true
    end
  end
  
  # 评估比较操作
  defp evaluate_comparison(condition, form_data) do
    case Regex.run(~r/^\s*(\w+)\s*(==|!=|>=?|<=?)\s*(.+)\s*$/, condition) do
      [_, field_name, operator, value] ->
        field_value = get_field_value(form_data, field_name)
        compare_values(field_value, operator, parse_value(value))
      _ ->
        true
    end
  end
  
  # 评估 in 操作符
  defp evaluate_in_operator(condition, form_data) do
    case Regex.run(~r/^\s*(\w+)\s+in\s+\[(.+)\]\s*$/, condition) do
      [_, field_name, values_str] ->
        field_value = to_string(get_field_value(form_data, field_name) || "")
        values = parse_array_values(values_str)
        field_value in values
      _ ->
        true
    end
  end
  
  # 评估 not_in 操作符
  defp evaluate_not_in_operator(condition, form_data) do
    case Regex.run(~r/^\s*(\w+)\s+not_in\s+\[(.+)\]\s*$/, condition) do
      [_, field_name, values_str] ->
        field_value = to_string(get_field_value(form_data, field_name) || "")
        values = parse_array_values(values_str)
        field_value not in values
      _ ->
        true
    end
  end
  
  # 评估 matches 操作符
  defp evaluate_matches_operator(condition, form_data) do
    case Regex.run(~r/^\s*(\w+)\s+matches\s+'(.+)'\s*$/, condition) do
      [_, field_name, pattern] ->
        field_value = to_string(get_field_value(form_data, field_name) || "")
        case Regex.compile(pattern) do
          {:ok, regex} -> Regex.match?(regex, field_value)
          {:error, _} -> false
        end
      _ ->
        true
    end
  end
  
  # 评估 present 操作符
  defp evaluate_present_operator(condition, form_data) do
    case Regex.run(~r/^\s*(\w+)\s+present\s*$/, condition) do
      [_, field_name] ->
        field_value = get_field_value(form_data, field_name)
        field_value != nil && field_value != ""
      _ ->
        true
    end
  end
  
  # 评估 blank 操作符
  defp evaluate_blank_operator(condition, form_data) do
    case Regex.run(~r/^\s*(\w+)\s+blank\s*$/, condition) do
      [_, field_name] ->
        field_value = get_field_value(form_data, field_name)
        field_value == nil || field_value == ""
      _ ->
        true
    end
  end
  
  # 评估复杂表达式
  defp evaluate_expression(expr, form_data, depth) do
    # 这是一个简化版本，实际应用中可能需要更复杂的表达式解析器
    # 先处理逻辑操作符
    cond do
      String.contains?(expr, "&&") ->
        parts = String.split(expr, "&&", parts: 2)
        Enum.all?(parts, &evaluate(&1, form_data, depth + 1))
      
      String.contains?(expr, "||") ->
        parts = String.split(expr, "||", parts: 2)
        Enum.any?(parts, &evaluate(&1, form_data, depth + 1))
      
      true ->
        evaluate_simple_condition(expr, form_data, depth)
    end
  end
  
  # 比较两个值
  defp compare_values(field_value, operator, compare_value) do
    # 尝试转换为数字进行比较
    with {num1, ""} <- Float.parse(to_string(field_value || "")),
         {num2, ""} <- Float.parse(to_string(compare_value)) do
      compare_numbers(num1, operator, num2)
    else
      _ ->
        # 字符串比较
        str1 = to_string(field_value || "")
        str2 = to_string(compare_value)
        compare_strings(str1, operator, str2)
    end
  end
  
  # 数字比较
  defp compare_numbers(num1, "==", num2), do: num1 == num2
  defp compare_numbers(num1, "!=", num2), do: num1 != num2
  defp compare_numbers(num1, ">", num2), do: num1 > num2
  defp compare_numbers(num1, "<", num2), do: num1 < num2
  defp compare_numbers(num1, ">=", num2), do: num1 >= num2
  defp compare_numbers(num1, "<=", num2), do: num1 <= num2
  defp compare_numbers(_, _, _), do: false
  
  # 字符串比较
  defp compare_strings(str1, "==", str2), do: str1 == str2
  defp compare_strings(str1, "!=", str2), do: str1 != str2
  defp compare_strings(_, _, _), do: false
  
  # 解析值
  defp parse_value(value) do
    value = String.trim(value)
    
    cond do
      # 字符串值（带引号）
      String.starts_with?(value, "'") && String.ends_with?(value, "'") ->
        String.slice(value, 1..-2//1)
      
      String.starts_with?(value, "\"") && String.ends_with?(value, "\"") ->
        String.slice(value, 1..-2//1)
      
      # 数字值
      true ->
        value
    end
  end
  
  # 解析数组值
  defp parse_array_values(values_str) do
    values_str
    |> String.split(",")
    |> Enum.map(&parse_value(String.trim(&1)))
  end
  
  # 获取字段值
  defp get_field_value(form_data, field_name) when is_map(form_data) do
    Map.get(form_data, field_name) || Map.get(form_data, to_string(field_name))
  end
  defp get_field_value(_, _), do: nil
end