defmodule ShopUxPhoenixWeb.Components.Table.Filtering do
  @moduledoc """
  筛选功能模块
  处理表格的筛选状态管理和逻辑
  """

  use Phoenix.Component

  @doc """
  处理筛选状态，更新列的筛选属性
  """
  def process_filter_states(assigns) do
    filters = assigns[:filters] || %{}
    
    # 验证可筛选列必须有 key 属性
    validate_filterable_columns(assigns.col)
    
    # 更新列的筛选状态
    updated_cols = 
      Enum.map(assigns.col, fn col ->
        if col[:filterable] do
          filtered = Map.has_key?(filters, col[:key])
          Map.put(col, :filtered, filtered)
        else
          col
        end
      end)
    
    assign(assigns, :col, updated_cols)
  end

  @doc """
  渲染筛选图标
  """
  def render_filter_icon(col, assigns) do
    if col[:filterable] do
      assigns = assign(assigns, :col, col)
      ~H"""
      <button
        type="button"
        phx-click="filter_column"
        phx-value-column={@col[:key]}
        class={[
          "pc-table__filter-trigger inline-flex items-center justify-center w-4 h-4 transition-colors",
          @col[:filtered] && "text-blue-600" || "text-gray-400 hover:text-gray-600"
        ]}
        title="筛选"
      >
        <%= if @col[:filter_icon] do %>
          <%= @col[:filter_icon] %>
        <% else %>
          <%= render_default_filter_icon(assigns) %>
        <% end %>
      </button>
      """
    else
      nil
    end
  end

  @doc """
  渲染默认筛选图标
  """
  def render_default_filter_icon(assigns \\ %{}) do
    ~H"""
    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd" />
    </svg>
    """
  end

  @doc """
  检查列是否处于筛选状态
  """
  def is_column_filtered?(col, filters) do
    col[:filterable] && Map.has_key?(filters, col[:key])
  end

  @doc """
  获取筛选相关的CSS类
  """
  def get_filter_trigger_classes(col) do
    base_classes = "pc-table__filter-trigger inline-flex items-center justify-center w-4 h-4 transition-colors"
    
    if col[:filtered] do
      "#{base_classes} text-blue-600"
    else
      "#{base_classes} text-gray-400 hover:text-gray-600"
    end
  end

  # 私有函数

  defp validate_filterable_columns(cols) do
    invalid_cols = 
      Enum.filter(cols, fn col ->
        col[:filterable] && !col[:key]
      end)
    
    if not Enum.empty?(invalid_cols) do
      raise ArgumentError, "Filterable columns must have a 'key' attribute. Missing key in filterable columns."
    end
  end
end