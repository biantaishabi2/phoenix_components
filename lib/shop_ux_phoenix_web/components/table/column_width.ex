defmodule ShopUxPhoenixWeb.Components.Table.ColumnWidth do
  @moduledoc """
  列宽控制功能模块
  处理表格列的宽度设置
  """

  @doc """
  构建列宽度样式字符串
  """
  def build_width_style(col) do
    width_parts = []
    
    width_parts = 
      case col[:width] do
        nil -> width_parts
        width when is_number(width) -> ["width: #{width}px" | width_parts]
        width when is_binary(width) -> ["width: #{width}" | width_parts]
        _ -> width_parts
      end
    
    width_parts = 
      case col[:min_width] do
        nil -> width_parts
        min_width when is_number(min_width) -> ["min-width: #{min_width}px" | width_parts]
        min_width when is_binary(min_width) -> ["min-width: #{min_width}" | width_parts]
        _ -> width_parts
      end
    
    width_parts = 
      case col[:max_width] do
        nil -> width_parts
        max_width when is_number(max_width) -> ["max-width: #{max_width}px" | width_parts]
        max_width when is_binary(max_width) -> ["max-width: #{max_width}" | width_parts]
        _ -> width_parts
      end
    
    case width_parts do
      [] -> nil
      parts -> Enum.join(Enum.reverse(parts), "; ")
    end
  end

  @doc """
  解析列宽度值为数字
  """
  def parse_column_width(width) when is_number(width), do: width
  def parse_column_width(width) when is_binary(width) do
    case Integer.parse(width) do
      {num, "px"} -> num
      {num, ""} -> num
      _ -> nil
    end
  end
  def parse_column_width(_), do: nil
end