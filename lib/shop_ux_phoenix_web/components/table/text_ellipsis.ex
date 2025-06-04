defmodule ShopUxPhoenixWeb.Components.Table.TextEllipsis do
  @moduledoc """
  文本省略功能模块
  处理表格中的文本溢出和省略显示
  """

  @doc """
  构建省略号CSS类
  """
  def build_ellipsis_class(col) do
    if Map.get(col, :ellipsis, false) do
      "pc-table__cell--ellipsis"
    else
      nil
    end
  end

  @doc """
  获取单元格内容的title属性（用于显示完整文本）
  """
  def get_cell_title(col, content) do
    if Map.get(col, :ellipsis, false) do
      # 只为简单文本内容提取title，复杂内容跳过
      case content do
        content when is_binary(content) -> 
          String.trim(content)
        # 对于只有静态内容的Rendered结构
        %{static: static_parts, dynamic: []} -> 
          static_parts
          |> Enum.join("")
          |> String.trim()
        # 对于包含动态内容的复杂结构，不提供title
        _ -> nil
      end
    else
      nil
    end
  end
end