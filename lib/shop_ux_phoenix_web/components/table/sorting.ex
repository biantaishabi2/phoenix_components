defmodule ShopUxPhoenixWeb.Components.Table.Sorting do
  @moduledoc """
  排序功能模块
  处理表格的排序逻辑
  """

  use Phoenix.Component
  import ShopUxPhoenixWeb.Components.Table.Styles
  alias ShopUxPhoenixWeb.Components.Table.Filtering

  @doc """
  渲染列头内容（处理排序和筛选功能）
  """
  def render_column_header(col, assigns) do
    has_sortable = assigns.sortable && col[:sortable]
    has_filterable = col[:filterable]
    
    cond do
      has_sortable && has_filterable ->
        render_sortable_filterable_header(col, assigns)
      
      has_sortable ->
        render_sortable_header(col, assigns)
      
      has_filterable ->
        render_filterable_header(col, assigns)
      
      true ->
        col.label
    end
  end

  # 同时有排序和筛选的列头
  defp render_sortable_filterable_header(col, assigns) do
    assigns = assign(assigns, :col, col)
    ~H"""
    <div class="pc-table__header-content flex items-center gap-2">
      <button
        phx-click="sort"
        phx-value-field={@col[:key]}
        class={["pc-table__sort-button group inline-flex items-center gap-1 transition duration-150 ease-in-out hover:text-gray-700 dark:hover:text-gray-300 rounded", get_focus_classes(@color)]}
      >
        <%= @col.label %>
        <span class="sort-icon text-gray-400 group-hover:text-gray-500">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z"/>
          </svg>
        </span>
      </button>
      <%= Filtering.render_filter_icon(@col, assigns) %>
    </div>
    """
  end

  # 只有排序的列头
  defp render_sortable_header(col, assigns) do
    assigns = assign(assigns, :col, col)
    ~H"""
    <button
      phx-click="sort"
      phx-value-field={@col[:key]}
      class={["pc-table__sort-button group inline-flex items-center gap-1 transition duration-150 ease-in-out hover:text-gray-700 dark:hover:text-gray-300 rounded", get_focus_classes(@color)]}
    >
      <%= @col.label %>
      <span class="sort-icon text-gray-400 group-hover:text-gray-500">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z"/>
        </svg>
      </span>
    </button>
    """
  end

  # 只有筛选的列头
  defp render_filterable_header(col, assigns) do
    assigns = assign(assigns, :col, col)
    ~H"""
    <div class="pc-table__header-content flex items-center gap-2">
      <span class="pc-table__column-title"><%= @col.label %></span>
      <%= Filtering.render_filter_icon(@col, assigns) %>
    </div>
    """
  end
end