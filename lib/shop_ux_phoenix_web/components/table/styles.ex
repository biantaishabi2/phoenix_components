defmodule ShopUxPhoenixWeb.Components.Table.Styles do
  @moduledoc """
  CSS 类和样式生成模块
  处理表格的各种样式类生成
  """

  @doc """
  获取表头单元格间距
  """
  def get_header_cell_padding(size) do
    case size do
      "small" -> "px-3 py-2"
      "medium" -> "px-4 py-3"
      "large" -> "px-6 py-4"
      _ -> "px-4 py-3"
    end
  end

  @doc """
  获取表格单元格间距
  """
  def get_body_cell_padding(size) do
    case size do
      "small" -> "px-3 py-2"
      "medium" -> "px-4 py-3"
      "large" -> "px-6 py-4"
      _ -> "px-4 py-3"
    end
  end

  @doc """
  获取焦点样式
  """
  def get_focus_classes(color) do
    case color do
      "primary" -> "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
      "info" -> "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      "success" -> "focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
      "warning" -> "focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2"
      "danger" -> "focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
      _ -> "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
    end
  end

  @doc """
  获取复选框样式
  """
  def get_checkbox_classes(color) do
    case color do
      "primary" -> "text-primary focus:ring-2 focus:ring-primary focus:ring-offset-2"
      "info" -> "text-blue-600 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      "success" -> "text-green-600 focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
      "warning" -> "text-yellow-600 focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2"
      "danger" -> "text-red-600 focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
      _ -> "text-primary focus:ring-2 focus:ring-primary focus:ring-offset-2"
    end
  end

  @doc """
  获取分页激活状态样式
  """
  def get_pagination_active_classes(color) do
    case color do
      "primary" -> "z-10 bg-primary border-primary text-white"
      "info" -> "z-10 bg-blue-600 border-blue-600 text-white"
      "success" -> "z-10 bg-green-600 border-green-600 text-white"
      "warning" -> "z-10 bg-yellow-500 border-yellow-500 text-white"
      "danger" -> "z-10 bg-red-600 border-red-600 text-white"
      _ -> "z-10 bg-primary border-primary text-white"
    end
  end
end