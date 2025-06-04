# Phoenix LiveView 批量操作功能实现指南

## 概述

本指南详细说明如何在Phoenix LiveView项目中实现批量操作功能，支持Excel/CSV文件导入、数据验证和错误处理。

## 依赖库

首先在 `mix.exs` 中添加必要的依赖：

```elixir
defp deps do
  [
    # 现有依赖...
    {:xlsxir, "~> 1.6.4"},        # Excel文件解析
    {:nimble_csv, "~> 1.2"},      # CSV文件解析
    {:broadway, "~> 1.0"},        # 批量处理
    {:gen_stage, "~> 1.0"}        # 背压处理
  ]
end
```

## 1. Excel文件解析模块

```elixir
defmodule ShopUxPhoenix.FileParser.ExcelParser do
  @moduledoc """
  Excel文件解析器，使用xlsxir库
  """

  def parse_file(file_path) do
    try do
      case Xlsxir.multi_extract(file_path, 0) do
        {:ok, table_id} ->
          data = Xlsxir.get_list(table_id)
          Xlsxir.close(table_id)
          {:ok, data}
        
        {:error, reason} ->
          {:error, "Excel解析失败: #{inspect(reason)}"}
      end
    rescue
      error ->
        {:error, "Excel文件读取异常: #{Exception.message(error)}"}
    end
  end

  def parse_with_headers(file_path) do
    case parse_file(file_path) do
      {:ok, [headers | rows]} ->
        mapped_data = Enum.map(rows, fn row ->
          headers
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {header, index}, acc ->
            value = Enum.at(row, index, "")
            Map.put(acc, header, value)
          end)
        end)
        {:ok, mapped_data}
      
      {:ok, []} ->
        {:error, "Excel文件为空"}
      
      error ->
        error
    end
  end
end
```

## 2. CSV文件解析模块

```elixir
defmodule ShopUxPhoenix.FileParser.CSVParser do
  @moduledoc """
  CSV文件解析器，使用nimble_csv库
  """
  
  alias NimbleCSV.RFC4180, as: CSV

  def parse_file(file_path) do
    try do
      data = 
        file_path
        |> File.stream!()
        |> CSV.parse_stream(skip_headers: false)
        |> Enum.to_list()
      
      {:ok, data}
    rescue
      error ->
        {:error, "CSV文件解析失败: #{Exception.message(error)}"}
    end
  end

  def parse_with_headers(file_path) do
    case parse_file(file_path) do
      {:ok, [headers | rows]} ->
        mapped_data = Enum.map(rows, fn row ->
          headers
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {header, index}, acc ->
            value = Enum.at(row, index, "")
            Map.put(acc, String.trim(header), String.trim(value))
          end)
        end)
        {:ok, mapped_data}
      
      {:ok, []} ->
        {:error, "CSV文件为空"}
      
      error ->
        error
    end
  end

  def parse_stream(file_path) do
    file_path
    |> File.stream!()
    |> CSV.parse_stream(skip_headers: true)
  end
end
```

## 3. 批量验证模块

```elixir
defmodule ShopUxPhoenix.BatchValidator do
  @moduledoc """
  批量数据验证器
  """
  
  import Ecto.Changeset

  defstruct [:total, :valid, :invalid, :errors, :processed]

  def new do
    %__MODULE__{
      total: 0,
      valid: [],
      invalid: [],
      errors: [],
      processed: 0
    }
  end

  def validate_batch(data, schema, validation_fn) when is_list(data) do
    result = new()
    
    {valid, invalid} = 
      data
      |> Enum.with_index()
      |> Enum.map(fn {record, index} ->
        changeset = validation_fn.(record)
        {changeset, index + 1}
      end)
      |> Enum.split_with(fn {changeset, _index} -> changeset.valid? end)

    %{result |
      total: length(data),
      valid: Enum.map(valid, fn {changeset, index} -> {changeset.changes, index} end),
      invalid: Enum.map(invalid, &extract_errors/1),
      processed: length(data)
    }
  end

  def validate_stream(stream, schema, validation_fn, batch_size \\ 100) do
    stream
    |> Stream.chunk_every(batch_size)
    |> Stream.map(&validate_batch(&1, schema, validation_fn))
  end

  defp extract_errors({changeset, index}) do
    %{
      row: index,
      data: changeset.data,
      errors: traverse_errors(changeset, &translate_error/1)
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
```

## 4. 文件处理服务

```elixir
defmodule ShopUxPhoenix.FileProcessor do
  @moduledoc """
  文件处理服务，统一处理Excel和CSV文件
  """
  
  alias ShopUxPhoenix.FileParser.{ExcelParser, CSVParser}
  alias ShopUxPhoenix.BatchValidator

  def process_file(file_path, file_type, schema, validation_fn) do
    with {:ok, data} <- parse_file(file_path, file_type),
         validation_result <- BatchValidator.validate_batch(data, schema, validation_fn) do
      {:ok, validation_result}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def process_file_stream(file_path, file_type, schema, validation_fn, batch_size \\ 100) do
    case file_type do
      :csv ->
        CSVParser.parse_stream(file_path)
        |> BatchValidator.validate_stream(schema, validation_fn, batch_size)
      
      :excel ->
        # Excel不支持流式处理，降级到批量处理
        process_file(file_path, file_type, schema, validation_fn)
    end
  end

  defp parse_file(file_path, :excel), do: ExcelParser.parse_with_headers(file_path)
  defp parse_file(file_path, :csv), do: CSVParser.parse_with_headers(file_path)
  defp parse_file(_file_path, type), do: {:error, "不支持的文件类型: #{type}"}

  def detect_file_type(filename) do
    case Path.extname(filename) |> String.downcase() do
      ".xlsx" -> :excel
      ".xls" -> :excel
      ".csv" -> :csv
      _ -> :unknown
    end
  end
end
```

## 5. 批量操作LiveView

```elixir
defmodule ShopUxPhoenixWeb.BatchImportLive do
  use ShopUxPhoenixWeb, :live_view
  
  alias ShopUxPhoenix.{FileProcessor, BatchValidator}

  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(:uploaded_files, [])
     |> assign(:import_results, nil)
     |> assign(:processing, false)
     |> assign(:progress, 0)
     |> allow_upload(:import_file,
         accept: ~w(.csv .xlsx .xls),
         max_entries: 1,
         max_file_size: 50_000_000,  # 50MB
         auto_upload: true
       )}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("process_import", _params, socket) do
    if upload_in_progress?(socket.assigns.uploads.import_file) do
      {:noreply, put_flash(socket, :error, "文件正在上传中，请等待完成")}
    else
      {:noreply, assign(socket, :processing, true)}
    end
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :import_file, ref)}
  end

  def handle_info({:import_progress, progress}, socket) do
    {:noreply, assign(socket, :progress, progress)}
  end

  def handle_info({:import_complete, results}, socket) do
    {:noreply, 
     socket
     |> assign(:import_results, results)
     |> assign(:processing, false)
     |> assign(:progress, 100)}
  end

  # 处理文件上传完成
  def handle_progress(:import_file, entry, socket) do
    if entry.done? do
      # 启动异步处理
      start_async_import(socket, entry)
    end
    {:noreply, socket}
  end

  defp start_async_import(socket, entry) do
    parent = self()
    
    Task.start(fn ->
      uploaded_file = consume_uploaded_entry(socket, entry, fn %{path: path} ->
        file_type = FileProcessor.detect_file_type(entry.client_name)
        
        # 发送进度更新
        send(parent, {:import_progress, 10})
        
        case FileProcessor.process_file(path, file_type, YourSchema, &validation_function/1) do
          {:ok, results} ->
            send(parent, {:import_progress, 50})
            
            # 执行批量插入
            insert_results = insert_valid_records(results.valid)
            send(parent, {:import_progress, 90})
            
            final_results = %{
              total: results.total,
              successful: length(results.valid),
              failed: length(results.invalid),
              errors: results.invalid,
              inserted: insert_results
            }
            
            send(parent, {:import_complete, final_results})
            
          {:error, reason} ->
            send(parent, {:import_complete, %{error: reason}})
        end
        
        {:ok, entry.client_name}
      end)
    end)
    
    socket
  end

  defp validation_function(data) do
    # 根据你的业务逻辑实现验证
    # 例如：
    %YourSchema{}
    |> cast(data, [:field1, :field2, :field3])
    |> validate_required([:field1, :field2])
    |> validate_length(:field1, min: 2, max: 50)
    |> unique_constraint(:field1)
  end

  defp insert_valid_records(valid_records) do
    try do
      entries = Enum.map(valid_records, fn {changes, _index} -> changes end)
      
      case YourApp.Repo.insert_all(YourSchema, entries, returning: true) do
        {count, records} -> {:ok, count, records}
        error -> {:error, error}
      end
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  # 模板渲染函数
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-2xl font-bold mb-6">批量导入数据</h1>
      
      <!-- 文件上传区域 -->
      <div class="mb-8">
        <form id="upload-form" phx-submit="process_import" phx-change="validate">
          <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
            <.live_file_input upload={@uploads.import_file} class="hidden" />
            
            <div class="space-y-2">
              <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
              <div class="text-sm text-gray-600">
                <label for={@uploads.import_file.ref} class="cursor-pointer">
                  <span class="font-medium text-blue-600 hover:text-blue-500">选择文件</span>
                  或拖拽到此处
                </label>
              </div>
              <p class="text-xs text-gray-500">支持 CSV, XLSX, XLS 文件，最大 50MB</p>
            </div>
          </div>
        </form>
      </div>

      <!-- 上传进度 -->
      <%= for entry <- @uploads.import_file.entries do %>
        <div class="mb-4">
          <div class="flex justify-between items-center mb-2">
            <span class="text-sm font-medium"><%= entry.client_name %></span>
            <button phx-click="cancel_upload" phx-value-ref={entry.ref} 
                    class="text-red-600 hover:text-red-800">
              取消
            </button>
          </div>
          
          <div class="w-full bg-gray-200 rounded-full h-2">
            <div class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                 style={"width: #{entry.progress}%"}></div>
          </div>
          
          <%= for err <- upload_errors(@uploads.import_file, entry) do %>
            <p class="text-red-600 text-sm mt-1"><%= error_to_string(err) %></p>
          <% end %>
        </div>
      <% end %>

      <!-- 处理进度 -->
      <%= if @processing do %>
        <div class="mb-6">
          <div class="flex justify-between items-center mb-2">
            <span class="text-sm font-medium">正在处理数据...</span>
            <span class="text-sm text-gray-500"><%= @progress %>%</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-2">
            <div class="bg-green-600 h-2 rounded-full transition-all duration-300"
                 style={"width: #{@progress}%"}></div>
          </div>
        </div>
      <% end %>

      <!-- 导入结果 -->
      <%= if @import_results do %>
        <div class="bg-white border rounded-lg p-6">
          <h3 class="text-lg font-semibold mb-4">导入结果</h3>
          
          <%= if @import_results[:error] do %>
            <div class="bg-red-50 border border-red-200 rounded p-4">
              <p class="text-red-800">错误: <%= @import_results.error %></p>
            </div>
          <% else %>
            <div class="grid grid-cols-4 gap-4 mb-6">
              <div class="text-center">
                <div class="text-2xl font-bold text-gray-900"><%= @import_results.total %></div>
                <div class="text-sm text-gray-500">总记录数</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-green-600"><%= @import_results.successful %></div>
                <div class="text-sm text-gray-500">成功导入</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-red-600"><%= @import_results.failed %></div>
                <div class="text-sm text-gray-500">导入失败</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-blue-600">
                  <%= Float.round(@import_results.successful / @import_results.total * 100, 1) %>%
                </div>
                <div class="text-sm text-gray-500">成功率</div>
              </div>
            </div>

            <!-- 错误详情 -->
            <%= if length(@import_results.errors) > 0 do %>
              <div class="mt-6">
                <h4 class="text-md font-semibold mb-3">错误详情</h4>
                <div class="max-h-64 overflow-y-auto">
                  <%= for error_item <- @import_results.errors do %>
                    <div class="border-b border-gray-200 py-2">
                      <div class="text-sm">
                        <span class="font-medium">第 <%= error_item.row %> 行:</span>
                        <%= for {field, messages} <- error_item.errors do %>
                          <span class="text-red-600"><%= field %>: <%= Enum.join(messages, ", ") %></span>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "文件过大"
  defp error_to_string(:not_accepted), do: "文件类型不支持"
  defp error_to_string(:too_many_files), do: "文件数量过多"
  defp error_to_string(_), do: "上传失败"
end
```

## 6. 路由配置

在 `router.ex` 中添加路由：

```elixir
scope "/", ShopUxPhoenixWeb do
  pipe_through :browser
  
  live "/batch_import", BatchImportLive, :index
end
```

## 7. 使用建议

### 性能优化
1. **流式处理**: 对于大文件，使用流式处理避免内存溢出
2. **分批处理**: 将大量数据分批验证和插入
3. **异步处理**: 使用Task进行异步文件处理
4. **进度反馈**: 提供实时进度更新改善用户体验

### 错误处理
1. **部分成功策略**: 记录成功和失败的记录，允许部分导入
2. **错误报告**: 提供详细的错误信息和行号
3. **回滚机制**: 考虑事务性操作，失败时可以回滚

### 安全考虑
1. **文件类型验证**: 严格验证文件类型和大小
2. **数据清理**: 对导入的数据进行清理和转义
3. **权限控制**: 确保只有授权用户可以执行批量操作

这个实现提供了完整的批量导入功能，包括文件解析、数据验证、进度跟踪和错误处理。你可以根据具体的业务需求调整验证逻辑和数据处理流程。