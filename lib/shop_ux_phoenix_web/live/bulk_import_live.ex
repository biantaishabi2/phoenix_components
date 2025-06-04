defmodule ShopUxPhoenixWeb.BulkImportLive do
  use ShopUxPhoenixWeb, :live_view
  
  alias ShopUxPhoenixWeb.BulkOperations.BulkImport
  alias ShopUxPhoenixWeb.ExcelHelper
  
  @impl true
  def mount(params, session, socket) do
    # 从session中获取配置，如果没有则从params获取，最后使用默认值
    form_config = Map.get(session, "form_config") || Map.get(params, :form_config, default_form_config())
    bulk_config = Map.get(session, "bulk_config") || Map.get(params, :bulk_config, default_bulk_config())
    
    {:ok,
     socket
     |> assign(:form_config, form_config)
     |> assign(:bulk_config, bulk_config)
     |> assign(:uploaded_file, nil)
     |> assign(:file_info, nil)
     |> assign(:preview_data, nil)
     |> assign(:field_mapping, %{})
     |> assign(:import_status, :idle)
     |> assign(:import_progress, 0)
     |> assign(:import_result, nil)
     |> assign(:errors, [])
     |> allow_upload(:file,
       accept: ~w(.xlsx .csv),
       max_entries: 1,
       max_file_size: 50_000_000
     )}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="bulk-import-container">
      <h2>批量导入</h2>
      
      <div class="import-info">
        <p>支持的文件格式：Excel (.xlsx) 和 CSV (.csv)</p>
        <p>最大文件大小：50MB</p>
        <p>系统将自动进行字段映射，您也可以手动调整映射关系</p>
        <div class="field-list">
          <p>当前表单字段：</p>
          <ul>
            <%= for field <- @form_config.fields do %>
              <li><%= field.label %> (<%= field.name %>)</li>
            <% end %>
          </ul>
        </div>
      </div>
      
      <%= if @import_status == :idle do %>
        <p>选择文件</p>
        <div data-testid="file-upload">
          <.live_file_input upload={@uploads.file} />
        </div>
        <button phx-click="download_template">下载模板</button>
        <button data-testid="import-button" phx-click="start_import" disabled={@preview_data == nil}>
          导入
        </button>
      <% end %>
      
      <%= if @file_info do %>
        <div class="file-info">
          <h3>文件信息</h3>
          <p>文件名：<%= @file_info.filename %></p>
          <p>文件大小：<%= format_file_size(@file_info.size) %></p>
          <p>文件类型：<%= @file_info.type %></p>
        </div>
      <% end %>
      
      <%= if @preview_data do %>
        <div class="data-preview">
          <h3>数据预览</h3>
          <table>
            <thead>
              <tr>
                <%= for header <- @preview_data.headers do %>
                  <th><%= header %></th>
                <% end %>
              </tr>
            </thead>
            <tbody>
              <%= for row <- Enum.take(@preview_data.rows, 5) do %>
                <tr>
                  <%= for cell <- row do %>
                    <td><%= cell %></td>
                  <% end %>
                </tr>
              <% end %>
            </tbody>
          </table>
          <p>共 <%= length(@preview_data.rows) %> 行数据</p>
        </div>
        
        <div class="field-mapping">
          <h3>字段映射</h3>
          <%= for {source, target} <- @field_mapping do %>
            <div>
              <%= source %> → <%= target %>
            </div>
          <% end %>
        </div>
        
        <button phx-click="start_import" disabled={@import_status != :idle}>
          开始导入
        </button>
        <button phx-click="clear_file">清除文件</button>
      <% end %>
      
      <%= if @import_status == :importing do %>
        <div class="import-progress">
          <h3>导入进度</h3>
          <progress value={@import_progress} max="100"><%= @import_progress %>%</progress>
          <p>正在导入... <%= @import_progress %>%</p>
        </div>
      <% end %>
      
      <%= if @import_result do %>
        <div class="import-result">
          <h3>导入结果</h3>
          <div class="statistics">
            <p>总行数：<%= @import_result.total_rows %></p>
            <p>成功：<%= @import_result.success_count %></p>
            <p>失败：<%= @import_result.error_count %></p>
          </div>
          
          <%= if @import_result.error_count > 0 do %>
            <div class="errors">
              <h4>错误详情</h4>
              <%= for error <- Enum.take(@import_result.errors, 10) do %>
                <div class="error-item">
                  行 <%= error.row %>: <%= error.field %> - <%= error.message %>
                </div>
              <% end %>
              <%= if length(@import_result.errors) > 10 do %>
                <p>... 还有 <%= "#{length(@import_result.errors) - 10}" %> 个错误</p>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
  
  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("save", %{"file" => _file_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
        dest = Path.join(System.tmp_dir!(), entry.client_name)
        File.cp!(path, dest)
        {:ok, %{path: dest, filename: entry.client_name, size: entry.client_size}}
      end)
    
    case uploaded_files do
      [file_info | _] ->
        case process_uploaded_file(file_info, socket) do
          {:ok, updated_socket} ->
            {:noreply, updated_socket}
          {:error, reason} ->
            {:noreply, put_flash(socket, :error, reason)}
        end
      [] ->
        {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("start_import", _params, socket) do
    socket = assign(socket, :import_status, :importing)
    send(self(), :perform_import)
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("clear_file", _params, socket) do
    {:noreply,
     socket
     |> assign(:uploaded_file, nil)
     |> assign(:file_info, nil)
     |> assign(:preview_data, nil)
     |> assign(:field_mapping, %{})
     |> assign(:import_status, :idle)
     |> assign(:import_progress, 0)
     |> assign(:import_result, nil)}
  end
  
  @impl true
  def handle_event("download_template", _params, socket) do
    headers = get_template_headers(socket.assigns.form_config)
    sample_data = get_sample_data()
    
    file_path = Path.join(System.tmp_dir!(), "import_template.xlsx")
    ExcelHelper.create_excel_file(file_path, "导入模板", headers, sample_data)
    
    {:noreply, push_event(socket, "download", %{
      url: "/download_template?file=#{file_path}",
      filename: "import_template.xlsx"
    })}
  end
  
  @impl true
  def handle_info(:perform_import, socket) do
    file_path = socket.assigns.uploaded_file.path
    form_config = socket.assigns.form_config
    bulk_config = socket.assigns.bulk_config
    
    # 模拟分步导入进度
    send(self(), {:update_progress, 20})
    
    case BulkImport.import_file(file_path, form_config, bulk_config) do
      {:ok, result} ->
        send(self(), {:import_complete, result})
        {:noreply, socket}
      {:partial, result} ->
        send(self(), {:import_complete, result})
        {:noreply, socket}
      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:import_status, :error)
         |> put_flash(:error, "导入失败: #{reason}")}
    end
  end
  
  @impl true
  def handle_info({:update_progress, progress}, socket) do
    {:noreply, assign(socket, :import_progress, progress)}
  end
  
  @impl true
  def handle_info({:import_complete, result}, socket) do
    {:noreply,
     socket
     |> assign(:import_status, :completed)
     |> assign(:import_progress, 100)
     |> assign(:import_result, result)}
  end
  
  defp process_uploaded_file(file_info, socket) do
    case BulkImport.validate_file(file_info.path, socket.assigns.bulk_config) do
      {:ok, validated_info} ->
        file_info = Map.merge(file_info, validated_info)
        
        case BulkImport.parse_file(file_info.path) do
          {:ok, {headers, rows}} ->
            preview_data = %{headers: headers, rows: rows}
            
            case BulkImport.auto_map_fields(headers, socket.assigns.form_config, socket.assigns.bulk_config) do
              {:ok, mapping} ->
                {:ok,
                 socket
                 |> assign(:uploaded_file, file_info)
                 |> assign(:file_info, file_info)
                 |> assign(:preview_data, preview_data)
                 |> assign(:field_mapping, mapping)}
              {:partial, mapping, _unmapped} ->
                {:ok,
                 socket
                 |> assign(:uploaded_file, file_info)
                 |> assign(:file_info, file_info)
                 |> assign(:preview_data, preview_data)
                 |> assign(:field_mapping, mapping)}
              {:error, reason} ->
                {:error, reason}
            end
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  defp format_file_size(size) when size < 1024, do: "#{size} B"
  defp format_file_size(size) when size < 1024 * 1024, do: "#{div(size, 1024)} KB"
  defp format_file_size(size), do: "#{div(size, 1024 * 1024)} MB"
  
  defp default_form_config do
    %{
      fields: [
        %{name: "name", label: "姓名", type: "input", required: true},
        %{name: "email", label: "邮箱", type: "email", required: true},
        %{name: "phone", label: "电话", type: "tel"},
        %{name: "department", label: "部门", type: "select"}
      ]
    }
  end
  
  defp default_bulk_config do
    %{
      accepted_file_types: [".xlsx", ".csv"],
      max_file_size: 50 * 1024 * 1024,
      batch_size: 1000,
      field_mapping: %{
        "姓名" => "name",
        "邮箱" => "email", 
        "电话" => "phone",
        "部门" => "department"
      },
      save_function: fn data ->
        Enum.map(data, fn item ->
          {:ok, Map.put(item, "id", System.unique_integer())}
        end)
      end
    }
  end
  
  defp get_template_headers(form_config) do
    Enum.map(form_config.fields, & &1.label)
  end
  
  defp get_sample_data do
    [
      ["张三", "zhang@example.com", "13800138000", "技术部"],
      ["李四", "li@example.com", "13900139000", "销售部"]
    ]
  end
end