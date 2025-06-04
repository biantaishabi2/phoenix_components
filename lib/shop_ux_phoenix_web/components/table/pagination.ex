defmodule ShopUxPhoenixWeb.Components.Table.Pagination do
  @moduledoc """
  分页功能模块
  处理表格的分页逻辑和渲染
  """

  use Phoenix.Component
  import ShopUxPhoenixWeb.Components.Table.Styles

  @doc """
  渲染分页组件
  """
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between px-4 py-3 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 sm:px-6">
      <div class="flex-1 flex justify-between sm:hidden">
        <button
          phx-click="change_page"
          phx-value-page={@pagination.current - 1}
          disabled={@pagination.current == 1}
          class="relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          上一页
        </button>
        <button
          phx-click="change_page"
          phx-value-page={@pagination.current + 1}
          disabled={@pagination.current * @pagination.page_size >= @pagination.total}
          class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          下一页
        </button>
      </div>
      
      <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
        <div>
          <%= if @pagination[:show_total] do %>
            <p class="text-sm text-gray-700 dark:text-gray-300">
              共 <span class="font-medium"><%= @pagination.total %></span> 条
            </p>
          <% end %>
        </div>
        
        <div>
          <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
            <!-- 上一页 -->
            <button
              phx-click="change_page"
              phx-value-page={@pagination.current - 1}
              disabled={@pagination.current == 1}
              class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-sm font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
              </svg>
            </button>
            
            <!-- 页码 -->
            <%= for page <- get_page_numbers(@pagination) do %>
              <%= if page == "..." do %>
                <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-sm font-medium text-gray-700 dark:text-gray-300">
                  ...
                </span>
              <% else %>
                <button
                  phx-click="change_page"
                  phx-value-page={page}
                  class={[
                    "relative inline-flex items-center px-4 py-2 border text-sm font-medium",
                    page == @pagination.current && get_pagination_active_classes(@color),
                    page != @pagination.current && "bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-600"
                  ]}
                >
                  <%= page %>
                </button>
              <% end %>
            <% end %>
            
            <!-- 下一页 -->
            <button
              phx-click="change_page"
              phx-value-page={@pagination.current + 1}
              disabled={@pagination.current * @pagination.page_size >= @pagination.total}
              class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-sm font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </button>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  获取要显示的页码
  """
  def get_page_numbers(%{current: current, page_size: page_size, total: total}) do
    total_pages = ceil(total / page_size)
    
    cond do
      total_pages <= 7 ->
        Enum.to_list(1..total_pages)
      
      current <= 4 ->
        Enum.to_list(1..5) ++ ["...", total_pages]
      
      current >= total_pages - 3 ->
        [1, "..."] ++ Enum.to_list((total_pages - 4)..total_pages)
      
      true ->
        [1, "..."] ++ Enum.to_list((current - 1)..(current + 1)) ++ ["...", total_pages]
    end
  end
  def get_page_numbers(_), do: []
end