defmodule ShopUxPhoenixWeb.Components.FormBuilder.DependencyManager do
  @moduledoc """
  管理字段之间的依赖关系和级联更新
  
  主要功能：
  - 构建字段依赖关系图
  - 检测循环依赖
  - 计算受影响的字段
  - 管理字段更新顺序
  """
  
  @doc """
  构建字段依赖关系图
  
  ## 参数
  - fields: 字段配置列表
  
  ## 返回
  - {:ok, graph}: 依赖关系图
  - {:error, reason}: 错误信息
  """
  def build_dependency_graph(fields) when is_list(fields) do
    # 构建依赖映射
    deps_map = build_dependencies_map(fields)
    
    # 检查循环依赖
    case check_circular_dependencies(deps_map) do
      :ok -> {:ok, deps_map}
      {:error, _} = error -> error
    end
  end
  
  @doc """
  获取字段改变时受影响的字段列表
  
  ## 参数
  - changed_field: 改变的字段名
  - dependency_graph: 依赖关系图
  
  ## 返回
  - [field_names]: 受影响的字段名列表
  """
  def get_affected_fields(changed_field, dependency_graph) do
    get_dependent_fields(changed_field, dependency_graph, MapSet.new())
    |> MapSet.to_list()
  end
  
  @doc """
  更新依赖字段的配置
  
  ## 参数
  - changed_field: 改变的字段名
  - form_data: 当前表单数据
  - fields: 字段配置列表
  
  ## 返回
  - updated_fields: 更新后的字段配置列表
  """
  def update_dependent_fields(changed_field, form_data, fields) do
    # 找到改变字段的配置
    changed_field_config = Enum.find(fields, &(&1[:name] == changed_field))
    
    if changed_field_config && changed_field_config[:on_change] do
      handle_field_change(changed_field_config[:on_change], form_data, fields)
    else
      fields
    end
  end
  
  @doc """
  处理字段的动态选项加载
  
  ## 参数
  - field: 字段配置
  - form_data: 当前表单数据
  
  ## 返回
  - {:ok, options}: 加载的选项列表
  - {:error, reason}: 错误信息
  """
  def load_field_options(field, form_data) do
    case field[:load_options] do
      nil -> 
        {:ok, field[:options] || []}
      
      func when is_function(func, 1) ->
        try do
          {:ok, func.(form_data)}
        rescue
          e -> {:error, Exception.message(e)}
        end
      
      endpoint when is_binary(endpoint) ->
        # 这里应该调用实际的API，现在返回模拟数据
        load_options_from_endpoint(endpoint, field, form_data)
      
      _ ->
        {:ok, []}
    end
  end
  
  @doc """
  计算字段的值
  
  ## 参数
  - field: 字段配置
  - form_data: 当前表单数据
  
  ## 返回
  - {:ok, value}: 计算得到的值
  - {:error, reason}: 错误信息
  """
  def compute_field_value(field, form_data) do
    case field[:computed] do
      nil -> 
        {:ok, nil}
      
      %{formula: formula} ->
        evaluate_formula(formula, form_data)
      
      %{compute: func} when is_function(func, 1) ->
        try do
          value = func.(form_data)
          {:ok, value}
        rescue
          e -> {:error, Exception.message(e)}
        end
      
      _ ->
        {:ok, nil}
    end
  end
  
  # 私有函数
  
  defp build_dependencies_map(fields) do
    Enum.reduce(fields, %{}, fn field, acc ->
      dependencies = collect_field_dependencies(field)
      
      if dependencies == [] do
        acc
      else
        Map.put(acc, field[:name], dependencies)
      end
    end)
  end
  
  defp collect_field_dependencies(field) do
    deps = []
    
    # depends_on 依赖
    deps = if field[:depends_on], do: deps ++ field[:depends_on], else: deps
    
    # computed 依赖
    deps = case field[:computed] do
      %{depends_on: computed_deps} -> deps ++ computed_deps
      _ -> deps
    end
    
    # async_validation 依赖
    deps = case field[:async_validation] do
      %{depends_on: validation_deps} -> deps ++ validation_deps
      _ -> deps
    end
    
    # show_if 中的字段依赖
    deps = deps ++ extract_show_if_dependencies(field[:show_if])
    
    Enum.uniq(deps)
  end
  
  defp extract_show_if_dependencies(nil), do: []
  defp extract_show_if_dependencies(condition) when is_binary(condition) do
    # 从条件字符串中提取字段名
    Regex.scan(~r/(\w+)\s*[><=!]/, condition)
    |> Enum.map(fn [_, field_name] -> field_name end)
    |> Enum.uniq()
  end
  defp extract_show_if_dependencies(%{and: conditions}) do
    Enum.flat_map(conditions, &extract_show_if_dependencies/1)
  end
  defp extract_show_if_dependencies(%{or: conditions}) do
    Enum.flat_map(conditions, &extract_show_if_dependencies/1)
  end
  defp extract_show_if_dependencies(%{expression: expr}) do
    extract_show_if_dependencies(expr)
  end
  defp extract_show_if_dependencies(_), do: []
  
  defp check_circular_dependencies(deps_map) do
    Enum.reduce_while(deps_map, :ok, fn {field, _}, _ ->
      case check_field_circular_dependency(field, deps_map, MapSet.new()) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end
  
  defp check_field_circular_dependency(field, deps_map, visited) do
    cond do
      MapSet.member?(visited, field) ->
        {:error, "Circular dependency detected: #{field}"}
      
      not Map.has_key?(deps_map, field) ->
        :ok
      
      true ->
        visited = MapSet.put(visited, field)
        dependencies = Map.get(deps_map, field, [])
        
        Enum.reduce_while(dependencies, :ok, fn dep, _ ->
          case check_field_circular_dependency(dep, deps_map, visited) do
            :ok -> {:cont, :ok}
            error -> {:halt, error}
          end
        end)
    end
  end
  
  defp get_dependent_fields(field, deps_map, visited) do
    if MapSet.member?(visited, field) do
      visited
    else
      visited = MapSet.put(visited, field)
      
      # 找到所有依赖于当前字段的字段
      dependents = Enum.filter(deps_map, fn {_, deps} ->
        field in deps
      end)
      |> Enum.map(fn {dependent_field, _} -> dependent_field end)
      
      # 递归获取间接依赖
      Enum.reduce(dependents, visited, fn dep, acc ->
        get_dependent_fields(dep, deps_map, acc)
      end)
    end
  end
  
  defp handle_field_change(on_change_config, form_data, fields) do
    fields = if on_change_config[:reset] do
      reset_fields(on_change_config[:reset], fields)
    else
      fields
    end
    
    if on_change_config[:update] do
      update_fields(on_change_config[:update], form_data, fields)
    else
      fields
    end
  end
  
  defp reset_fields(fields_to_reset, fields) do
    Enum.map(fields, fn field ->
      if field[:name] in fields_to_reset do
        # 重置字段值，保留其他配置
        Map.delete(field, :value)
      else
        field
      end
    end)
  end
  
  defp update_fields(update_configs, form_data, fields) do
    Enum.map(fields, fn field ->
      update_config = Enum.find(update_configs, &(&1[:field] == field[:name]))
      
      if update_config do
        apply_field_update(field, update_config, form_data)
      else
        field
      end
    end)
  end
  
  defp apply_field_update(field, %{action: "load_options"}, form_data) do
    case load_field_options(field, form_data) do
      {:ok, options} -> Map.put(field, :options, options)
      {:error, _} -> field
    end
  end
  
  defp apply_field_update(field, %{action: "show_hide"}, form_data) do
    # 动态更新显示/隐藏状态
    visible = evaluate_field_visibility(field, form_data)
    Map.put(field, :visible, visible)
  end
  
  defp apply_field_update(field, _, _), do: field
  
  defp evaluate_field_visibility(field, form_data) do
    case field[:show_if] do
      nil -> true
      condition -> 
        # 使用 ConditionEvaluator 评估条件
        alias ShopUxPhoenixWeb.Components.FormBuilder.ConditionEvaluator
        ConditionEvaluator.evaluate(condition, form_data)
    end
  end
  
  defp evaluate_formula(formula, form_data) do
    # 简单的公式评估器
    # 实际应用中可能需要更复杂的表达式解析器
    try do
      # 替换变量
      evaluated = Regex.replace(~r/\b(\w+)\b/, formula, fn _, var ->
        value = form_data[var] || "0"
        to_string(value)
      end)
      
      # 评估表达式（这里需要一个安全的表达式评估器）
      # 暂时使用简单的实现
      case evaluate_simple_expression(evaluated) do
        {:ok, result} -> {:ok, result}
        :error -> {:error, "Invalid formula"}
      end
    rescue
      _ -> {:error, "Formula evaluation failed"}
    end
  end
  
  defp evaluate_simple_expression(expr) do
    # 这是一个非常简化的实现
    # 只支持基本的算术运算
    if Regex.match?(~r/^[\d\.\s\+\-\*\/\(\)]+$/, expr) do
      # 注意：在生产环境中不应该使用 Code.eval_string
      # 应该使用专门的数学表达式解析器
      try do
        {result, _} = Code.eval_string(expr)
        {:ok, result}
      rescue
        _ -> :error
      end
    else
      :error
    end
  end
  
  defp load_options_from_endpoint(endpoint, _field, form_data) do
    # 模拟API调用
    # 实际应用中应该使用 HTTPoison 或其他 HTTP 客户端
    case endpoint do
      "/api/cities" ->
        cities = case form_data["province"] do
          "guangdong" -> [
            %{value: "guangzhou", label: "广州"},
            %{value: "shenzhen", label: "深圳"},
            %{value: "zhuhai", label: "珠海"}
          ]
          "beijing" -> [
            %{value: "beijing", label: "北京"}
          ]
          _ -> []
        end
        {:ok, cities}
      
      "/api/subcategories" ->
        subcategories = case form_data["category"] do
          "electronics" -> [
            %{value: "phones", label: "手机"},
            %{value: "laptops", label: "笔记本"},
            %{value: "tablets", label: "平板"}
          ]
          _ -> []
        end
        {:ok, subcategories}
      
      _ ->
        {:ok, []}
    end
  end
end