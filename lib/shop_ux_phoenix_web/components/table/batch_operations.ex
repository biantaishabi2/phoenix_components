defmodule ShopUxPhoenixWeb.Components.Table.BatchOperations do
  @moduledoc """
  表格批量操作功能模块
  提供选择状态管理和批量操作相关的辅助函数
  """
  
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import ShopUxPhoenixWeb.CoreComponents, only: [icon: 1]

  @doc """
  处理选择状态管理
  """
  def process_selection_state(assigns) do
    selected_ids = assigns[:selected_ids] || []
    current_page_ids = get_current_page_ids(assigns.rows, assigns[:row_id] || (&(&1.id)))
    total_count = assigns[:total_count] || length(assigns.rows)
    
    selection_mode = determine_selection_mode(selected_ids, current_page_ids, total_count)
    selected_count = length(selected_ids)
    
    assigns
    |> assign(:selected_ids, selected_ids)
    |> assign(:selected_count, selected_count)
    |> assign(:selection_mode, selection_mode)
    |> assign(:current_page_ids, current_page_ids)
  end

  @doc """
  切换单行选择状态
  """
  def toggle_row_selection(selected_ids, row_id) when is_list(selected_ids) do
    if row_id in selected_ids do
      List.delete(selected_ids, row_id)
    else
      [row_id | selected_ids]
    end
  end

  def toggle_row_selection(selected_ids, row_id) when is_map(selected_ids) do
    if MapSet.member?(selected_ids, row_id) do
      MapSet.delete(selected_ids, row_id)
    else
      MapSet.put(selected_ids, row_id)
    end
  end

  @doc """
  全选当前页面的行
  """
  def select_all_current_page(rows, row_id_fun) do
    rows
    |> Enum.map(row_id_fun)
  end

  @doc """
  清空所有选择
  """
  def clear_all_selections do
    []
  end

  @doc """
  检查行是否被选中
  """
  def row_selected?(selected_ids, row_id) when is_list(selected_ids) do
    row_id in selected_ids
  end

  def row_selected?(selected_ids, row_id) when is_map(selected_ids) do
    MapSet.member?(selected_ids, row_id)
  end

  @doc """
  获取选择状态的CSS类
  """
  def get_selection_checkbox_class(selected_ids, current_page_ids) do
    selection_mode = determine_selection_mode(selected_ids, current_page_ids, length(current_page_ids))
    
    base_class = "h-4 w-4 rounded border-gray-300 transition duration-150 ease-in-out"
    
    case selection_mode do
      :all -> "#{base_class} bg-blue-600 border-blue-600 text-white"
      :some -> "#{base_class} bg-blue-600 border-blue-600 text-white indeterminate"
      :none -> "#{base_class} text-blue-600 focus:ring-blue-500"
    end
  end

  @doc """
  渲染批量操作栏
  """
  def batch_action_bar(assigns) do
    ~H"""
    <div class="batch-action-bar bg-blue-50 border-b border-blue-200 px-4 py-3 sm:px-6" 
         style={if @selected_count == 0, do: "display: none;", else: ""}>
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <p class="text-sm text-blue-700">
            已选择 <span class="font-medium"><%= @selected_count %></span> 项
            <%= if @total_count && @selected_count < @total_count do %>
              <button 
                phx-click="select_all_pages" 
                class="ml-2 text-blue-600 hover:text-blue-500 underline">
                选择全部 <%= @total_count %> 项
              </button>
            <% end %>
          </p>
        </div>
        
        <div class="flex items-center space-x-3">
          <%= if @batch_operations do %>
            <%= for operation <- @batch_operations do %>
              <button
                phx-click={"batch_#{operation.key}"}
                phx-value-operation={operation.key}
                class={[
                  "inline-flex items-center px-3 py-1.5 border text-sm font-medium rounded-md transition-colors",
                  operation.color == "danger" && "border-red-300 text-red-700 bg-red-50 hover:bg-red-100",
                  operation.color == "primary" && "border-blue-300 text-blue-700 bg-blue-50 hover:bg-blue-100",
                  operation.color == "warning" && "border-yellow-300 text-yellow-700 bg-yellow-50 hover:bg-yellow-100",
                  (!operation.color || operation.color == "default") && "border-gray-300 text-gray-700 bg-gray-50 hover:bg-gray-100"
                ]}
                data-confirm={Map.get(operation, :confirm, false) && "确定要执行此操作吗？"}
              >
                <%= if Map.get(operation, :icon) do %>
                  <.icon name={Map.get(operation, :icon)} class="w-4 h-4 mr-1.5" />
                <% end %>
                <%= operation.label %>
                <span class="ml-1">(<%= @selected_count %>)</span>
              </button>
            <% end %>
          <% end %>
          
          <button
            phx-click="clear_selection"
            class="text-gray-400 hover:text-gray-500"
            title="清除选择"
          >
            <.icon name="hero-x-mark" class="w-5 h-5" />
          </button>
        </div>
      </div>
      
      <%= if @batch_operation && @batch_operation.status == :processing do %>
        <div class="mt-3">
          <div class="flex items-center">
            <div class="flex-1">
              <div class="bg-blue-200 rounded-full h-2">
                <div 
                  class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                  style={"width: #{@batch_operation.progress || 0}%"}
                ></div>
              </div>
            </div>
            <span class="ml-3 text-sm text-blue-700">
              <%= @batch_operation.message || "处理中..." %>
            </span>
            <%= if @batch_operation.cancelable do %>
              <button
                phx-click="cancel_batch_operation"
                class="ml-3 text-red-600 hover:text-red-500"
              >
                取消
              </button>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  渲染操作结果提示
  """
  def operation_feedback(assigns) do
    ~H"""
    <%= if @batch_operation && @batch_operation.status in [:completed, :error] do %>
      <div class={[
        "px-4 py-3 sm:px-6 border-l-4",
        @batch_operation.status == :completed && "bg-green-50 border-green-400",
        @batch_operation.status == :error && "bg-red-50 border-red-400"
      ]}>
        <div class="flex">
          <div class="flex-shrink-0">
            <%= if @batch_operation.status == :completed do %>
              <.icon name="hero-check-circle" class="h-5 w-5 text-green-400" />
            <% else %>
              <.icon name="hero-x-circle" class="h-5 w-5 text-red-400" />
            <% end %>
          </div>
          <div class="ml-3">
            <p class={[
              "text-sm",
              @batch_operation.status == :completed && "text-green-700",
              @batch_operation.status == :error && "text-red-700"
            ]}>
              <%= @batch_operation.message %>
            </p>
            <%= if @batch_operation.details do %>
              <div class="mt-2 text-sm">
                <%= for detail <- @batch_operation.details do %>
                  <p class="text-gray-600"><%= detail %></p>
                <% end %>
              </div>
            <% end %>
          </div>
          <div class="ml-auto pl-3">
            <button
              phx-click="dismiss_feedback"
              class={[
                "inline-flex rounded-md p-1.5 focus:outline-none focus:ring-2 focus:ring-offset-2",
                @batch_operation.status == :completed && "text-green-400 hover:bg-green-100 focus:ring-green-500",
                @batch_operation.status == :error && "text-red-400 hover:bg-red-100 focus:ring-red-500"
              ]}
            >
              <.icon name="hero-x-mark" class="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  @doc """
  生成选择行的事件处理JS
  """
  def select_row_js(row_id) do
    JS.push("select_row", value: %{id: row_id})
  end

  @doc """
  生成全选事件处理JS
  """
  def select_all_js do
    JS.push("select_all")
  end

  @doc """
  生成批量操作事件处理JS
  """
  def batch_operation_js(operation_key) do
    JS.push("batch_operation", value: %{operation: operation_key})
  end

  # 私有函数

  defp get_current_page_ids(rows, row_id_fun) do
    Enum.map(rows, row_id_fun)
  end

  defp determine_selection_mode(selected_ids, current_page_ids, total_count) when is_list(selected_ids) do
    selected_count = length(selected_ids)
    current_page_count = length(current_page_ids)
    
    cond do
      selected_count == 0 -> :none
      selected_count == total_count -> :all
      selected_count == current_page_count && 
        Enum.all?(current_page_ids, &(&1 in selected_ids)) -> :page
      true -> :some
    end
  end

  defp determine_selection_mode(selected_ids, current_page_ids, total_count) when is_map(selected_ids) do
    selected_count = MapSet.size(selected_ids)
    current_page_count = length(current_page_ids)
    current_page_set = MapSet.new(current_page_ids)
    
    cond do
      selected_count == 0 -> :none
      selected_count == total_count -> :all
      selected_count == current_page_count && 
        MapSet.subset?(current_page_set, selected_ids) -> :page
      true -> :some
    end
  end

  @doc """
  验证批量操作配置
  """
  def validate_batch_operations(operations) when is_list(operations) do
    Enum.all?(operations, &validate_single_operation/1)
  end

  def validate_batch_operations(_), do: false

  defp validate_single_operation(%{key: key, label: label}) 
       when is_binary(key) and is_binary(label), do: true
  defp validate_single_operation(_), do: false

  @doc """
  处理批量操作结果
  """
  def process_batch_result({:ok, count}, operation_type) do
    %{
      status: :completed,
      message: get_success_message(operation_type, count),
      progress: 100
    }
  end

  def process_batch_result({:error, reason}, operation_type) do
    %{
      status: :error,
      message: get_error_message(operation_type, reason),
      progress: 0
    }
  end

  def process_batch_result({:partial, success_count, failed_count, details}, operation_type) do
    %{
      status: :completed,
      message: "#{operation_type}完成：#{success_count} 项成功，#{failed_count} 项失败",
      details: details,
      progress: 100
    }
  end

  defp get_success_message("delete", count), do: "成功删除 #{count} 项"
  defp get_success_message("export", count), do: "成功导出 #{count} 项"
  defp get_success_message("archive", count), do: "成功归档 #{count} 项"
  defp get_success_message(type, count), do: "#{type}操作完成，处理了 #{count} 项"

  defp get_error_message("delete", reason), do: "删除失败：#{reason}"
  defp get_error_message("export", reason), do: "导出失败：#{reason}"
  defp get_error_message("archive", reason), do: "归档失败：#{reason}"
  defp get_error_message(type, reason), do: "#{type}操作失败：#{reason}"
end