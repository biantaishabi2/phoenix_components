defmodule ShopUxPhoenixWeb.Components.Table.FixedColumns do
  @moduledoc """
  固定列功能模块
  处理表格的左右固定列逻辑
  """

  @doc """
  处理固定列相关的 assigns
  """
  def process_fixed_columns(assigns) do
    cols = assigns[:col] || []
    action = assigns[:action] || []
    
    # 检查是否有任何固定列
    has_any_fixed = Enum.any?(cols, &(&1[:fixed] in ["left", "right"])) || 
                    Enum.any?(action, &(&1[:fixed] in ["left", "right"]))
    
    if has_any_fixed do
      # 分析固定列结构
      {left_fixed_cols, normal_cols, right_fixed_cols} = analyze_fixed_columns(cols)
      
      # 计算固定列位置
      left_positions = calculate_left_fixed_positions(left_fixed_cols)
      right_positions = calculate_right_fixed_positions(right_fixed_cols)
      
      assigns
      |> Map.put(:left_fixed_cols, left_fixed_cols)
      |> Map.put(:normal_cols, normal_cols)
      |> Map.put(:right_fixed_cols, right_fixed_cols)
      |> Map.put(:left_fixed_positions, left_positions)
      |> Map.put(:right_fixed_positions, right_positions)
      |> Map.put(:has_fixed_left, length(left_fixed_cols) > 0)
      |> Map.put(:has_fixed_right, length(right_fixed_cols) > 0 || has_fixed_action?(action))
      |> Map.put(:fixed_action, get_fixed_action(action))
      |> Map.put(:has_fixed_columns, true)
    else
      # 没有固定列时，保持原有行为
      assigns
      |> Map.put(:has_fixed_columns, false)
      |> Map.put(:has_fixed_left, false)
      |> Map.put(:has_fixed_right, false)
      |> Map.put(:left_fixed_positions, [])
      |> Map.put(:right_fixed_positions, [])
      |> Map.put(:normal_cols, cols)
    end
  end

  @doc """
  生成固定列的 CSS 类
  """
  def build_fixed_column_classes(col, position_info, _type \\ :body) do
    base_classes = []
    
    fixed_classes = case col[:fixed] do
      "left" -> [
        "pc-table__cell--fixed-left",
        position_info[:is_first] && "pc-table__cell--fixed-left-first",
        position_info[:is_last] && "pc-table__cell--fixed-left-last"
      ]
      "right" -> [
        "pc-table__cell--fixed-right", 
        position_info[:is_first] && "pc-table__cell--fixed-right-first",
        position_info[:is_last] && "pc-table__cell--fixed-right-last"
      ]
      _ -> []
    end
    
    (base_classes ++ fixed_classes)
    |> Enum.filter(& &1)
    |> Enum.join(" ")
  end

  @doc """
  生成固定列的 style 属性
  """
  def build_fixed_column_style(col, position_info) do
    style_parts = []
    
    # 添加宽度样式
    style_parts = 
      case build_width_style(col) do
        nil -> style_parts
        width_style -> [width_style | style_parts]
      end
    
    # 添加固定位置样式
    style_parts = 
      case col[:fixed] do
        "left" -> ["left: #{position_info[:left]}" | style_parts]
        "right" -> ["right: #{position_info[:right]}" | style_parts]
        _ -> style_parts
      end
    
    case style_parts do
      [] -> nil
      parts -> Enum.join(Enum.reverse(parts), "; ")
    end
  end

  @doc """
  构建固定操作列的样式
  """
  def build_fixed_action_style(action) do
    style_parts = []
    
    # 添加宽度样式
    style_parts = 
      case build_width_style(action) do
        nil -> style_parts
        width_style -> [width_style | style_parts]
      end
    
    # 添加固定位置样式（操作列通常在最右边，所以right为0）
    style_parts = 
      case action[:fixed] do
        "left" -> ["left: 0px" | style_parts]
        "right" -> ["right: 0px" | style_parts]
        _ -> style_parts
      end
    
    case style_parts do
      [] -> nil
      parts -> Enum.join(Enum.reverse(parts), "; ")
    end
  end

  # 私有函数

  defp analyze_fixed_columns(cols) do
    # 只有设置了width的固定列才能真正固定
    {left_fixed, rest} = Enum.split_with(cols, &(&1[:fixed] == "left" && &1[:width] != nil))
    {right_fixed, normal} = Enum.split_with(rest, &(&1[:fixed] == "right" && &1[:width] != nil))
    
    {left_fixed, normal, right_fixed}
  end

  defp calculate_left_fixed_positions(left_fixed_cols) do
    left_fixed_cols
    |> Enum.with_index()
    |> Enum.map(fn {col, index} ->
      # 计算当前列左侧所有固定列的总宽度
      left_offset = left_fixed_cols
                    |> Enum.take(index)
                    |> Enum.reduce(0, fn col, acc ->
                      width = parse_column_width(col[:width])
                      if width, do: acc + width, else: acc + 150
                    end)
      
      {col, %{
        left: "#{left_offset}px",
        is_first: index == 0,
        is_last: index == length(left_fixed_cols) - 1
      }}
    end)
  end

  defp calculate_right_fixed_positions(right_fixed_cols) do
    total_cols = length(right_fixed_cols)
    
    right_fixed_cols
    |> Enum.with_index()
    |> Enum.map(fn {col, index} ->
      # 从右往左计算偏移
      right_offset = right_fixed_cols
                     |> Enum.drop(index + 1)
                     |> Enum.reduce(0, fn col, acc ->
                       width = parse_column_width(col[:width])
                       if width, do: acc + width, else: acc + 150
                     end)
      
      {col, %{
        right: "#{right_offset}px",
        is_first: index == 0,
        is_last: index == total_cols - 1
      }}
    end)
  end

  defp parse_column_width(width) when is_number(width), do: width
  defp parse_column_width(width) when is_binary(width) do
    case Integer.parse(width) do
      {num, "px"} -> num
      {num, ""} -> num
      _ -> nil
    end
  end
  defp parse_column_width(_), do: nil

  defp has_fixed_action?([]), do: false
  defp has_fixed_action?([action | _]), do: action[:fixed] in ["left", "right"]

  defp get_fixed_action([]), do: nil
  defp get_fixed_action([action | _]) do
    if action[:fixed] in ["left", "right"], do: action, else: nil
  end

  # 临时函数，需要从宽度模块导入
  defp build_width_style(col) do
    ShopUxPhoenixWeb.Components.Table.ColumnWidth.build_width_style(col)
  end
end