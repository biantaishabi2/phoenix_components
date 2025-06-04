# Phoenix LiveView 上传组件文档

## 概述

Phoenix LiveView 提供了强大的文件上传功能，支持直接上传到服务器或云存储、交互式进度跟踪、拖拽上传等特性。本文档详细介绍了 LiveView 上传组件的使用方法。

## 主要特性

- **文件规格验证**: 自动验证文件类型、大小、数量等
- **响应式上传条目**: 上传状态自动更新，包括进度、错误、取消等
- **拖拽上传**: 支持拖拽文件到指定区域
- **进度跟踪**: 实时显示上传进度
- **直接上传到云存储**: 支持直接上传到 S3 等云服务
- **自动上传**: 选择文件后自动开始上传

## 基本使用

### 1. 启用上传

在 LiveView 的 `mount/3` 回调中使用 `allow_upload/3` 函数启用上传：

```elixir
@impl Phoenix.LiveView
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> assign(:uploaded_files, [])
   |> allow_upload(:avatar, 
      accept: ~w(.jpg .jpeg .png .gif),  # 接受的文件扩展名
      max_entries: 2,                    # 最大文件数量
      max_file_size: 10_000_000          # 最大文件大小（字节）
   )}
end
```

### 2. 添加文件输入组件

在模板中使用 `live_file_input/1` 组件：

```heex
<form id="upload-form" phx-submit="save" phx-change="validate">
  <.live_file_input upload={@uploads.avatar} />
  <button type="submit">上传</button>
</form>
```

**重要**: 必须在表单上绑定 `phx-submit` 和 `phx-change` 事件。

### 3. 处理验证事件

实现 `validate` 事件处理器：

```elixir
@impl Phoenix.LiveView
def handle_event("validate", _params, socket) do
  {:noreply, socket}
end
```

### 4. 处理上传提交

使用 `consume_uploaded_entries/3` 处理上传的文件：

```elixir
@impl Phoenix.LiveView
def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      dest = Path.join(Application.app_dir(:my_app, "priv/static/uploads"), Path.basename(path))
      # 确保目录存在
      File.mkdir_p!(Path.dirname(dest))
      # 复制文件到目标位置
      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)

  {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
end
```

## 高级功能

### 显示上传进度和预览

```heex
<section phx-drop-target={@uploads.avatar.ref}>
  <article :for={entry <- @uploads.avatar.entries} class="upload-entry">
    <!-- 图片预览 -->
    <.live_img_preview entry={entry} />
    
    <!-- 文件信息 -->
    <figcaption><%= entry.client_name %></figcaption>
    
    <!-- 进度条 -->
    <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
    
    <!-- 取消按钮 -->
    <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
      取消
    </button>
    
    <!-- 错误信息 -->
    <p :for={err <- upload_errors(@uploads.avatar, entry)} class="alert alert-danger">
      <%= error_to_string(err) %>
    </p>
  </article>
</section>
```

### 处理取消上传

```elixir
def handle_event("cancel-upload", %{"ref" => ref}, socket) do
  {:noreply, cancel_upload(socket, :avatar, ref)}
end
```

### 拖拽上传

使用 `phx-drop-target` 属性启用拖拽功能：

```heex
<div phx-drop-target={@uploads.avatar.ref} class="drop-zone">
  拖拽文件到这里或
  <.live_file_input upload={@uploads.avatar} />
</div>
```

### 显示错误信息

```elixir
defp error_to_string(:too_large), do: "文件太大"
defp error_to_string(:not_accepted), do: "不支持的文件类型"
defp error_to_string(:too_many_files), do: "文件数量超过限制"
```

## API 参考

### allow_upload/3

配置上传规格：

```elixir
allow_upload(socket, name, opts)
```

**选项**：
- `:accept` - 接受的文件类型（扩展名列表或 MIME 类型）
- `:max_entries` - 最大文件数量（默认：1）
- `:max_file_size` - 最大文件大小（字节，默认：8MB）
- `:chunk_size` - 上传块大小（默认：64KB）
- `:chunk_timeout` - 块超时时间（默认：10秒）
- `:auto_upload` - 是否自动上传（默认：false）
- `:external` - 外部上传配置（用于直接上传到云存储）
- `:progress` - 进度回调函数
- `:writer` - 自定义上传写入器

### consume_uploaded_entries/3

处理已上传的文件：

```elixir
consume_uploaded_entries(socket, name, func)
```

函数接收 `%{path: path}` 和 entry 作为参数，返回 `{:ok, value}` 或 `{:postpone, value}`。

### cancel_upload/3

取消特定的上传条目：

```elixir
cancel_upload(socket, name, entry_ref)
```

### uploaded_entries/2

获取已完成的上传条目：

```elixir
uploaded_entries(socket, name)
```

### upload_errors/1 和 upload_errors/2

获取上传错误：

```elixir
# 获取所有错误
upload_errors(@uploads.avatar)

# 获取特定条目的错误
upload_errors(@uploads.avatar, entry)
```

## 在组件中使用

在 LiveView 组件中使用上传功能时，需要在 `update/2` 回调中配置：

```elixir
def update(%{id: id} = assigns, socket) do
  {:ok,
   socket
   |> assign(assigns)
   |> allow_upload(:avatar,
      accept: ~w(.jpg .jpeg),
      max_entries: 1
   )}
end
```

## 外部上传（直接上传到云存储）

配置直接上传到 S3：

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> allow_upload(:avatar,
      accept: ~w(.jpg .jpeg),
      max_entries: 3,
      external: &presign_upload/2
   )}
end

defp presign_upload(entry, socket) do
  uploads = socket.assigns.uploads
  bucket = "my-bucket"
  key = "uploads/#{entry.uuid}.#{ext(entry)}"

  config = %{
    region: "us-east-1",
    access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
  }

  {:ok, fields} =
    SimpleS3Upload.sign_form_upload(config, bucket,
      key: key,
      content_type: entry.client_type,
      max_file_size: uploads[entry.upload_config].max_file_size,
      expires_in: :timer.hours(1)
    )

  meta = %{uploader: "S3", key: key, url: "https://#{bucket}.s3.amazonaws.com", fields: fields}
  {:ok, meta, socket}
end

defp ext(entry) do
  [ext | _] = MIME.extensions(entry.client_type)
  ext
end
```

## 自定义上传写入器

实现 `Phoenix.LiveView.UploadWriter` 行为：

```elixir
defmodule MyApp.CustomUploadWriter do
  @behaviour Phoenix.LiveView.UploadWriter

  @impl true
  def init(opts) do
    # 初始化写入器
    {:ok, opts}
  end

  @impl true
  def meta(state) do
    # 返回元数据
    %{path: state.path}
  end

  @impl true
  def write_chunk(data, state) do
    # 写入数据块
    :ok = File.write(state.file, data)
    {:ok, state}
  end

  @impl true
  def close(state, reason) do
    # 关闭写入器
    :ok = File.close(state.file)
    {:ok, state}
  end
end
```

使用自定义写入器：

```elixir
allow_upload(socket, :avatar,
  accept: ~w(.jpg .jpeg),
  writer: &MyApp.CustomUploadWriter.init/1
)
```

## 最佳实践

1. **文件存储**：生产环境中避免将文件存储在本地文件系统，推荐使用云存储服务
2. **安全性**：始终验证文件类型和大小，避免安全风险
3. **用户体验**：提供清晰的进度反馈和错误提示
4. **性能**：对于大文件上传，考虑使用外部上传直接传输到云存储
5. **错误处理**：实现完善的错误处理机制，包括网络中断、文件损坏等情况

## 示例：完整的图片上传组件

```elixir
defmodule MyAppWeb.ImageUploadLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:images,
        accept: ~w(.jpg .jpeg .png .gif),
        max_entries: 5,
        max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :images, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> put_flash(:info, "文件上传成功！")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>图片上传示例</h1>
      
      <form id="upload-form" phx-submit="save" phx-change="validate">
        <div class="drop-zone" phx-drop-target={@uploads.images.ref}>
          <p>拖拽图片到这里或点击选择</p>
          <.live_file_input upload={@uploads.images} />
        </div>
        
        <div class="upload-entries">
          <div :for={entry <- @uploads.images.entries} class="upload-entry">
            <.live_img_preview entry={entry} width="100" />
            <div class="entry-info">
              <p><%= entry.client_name %></p>
              <p><%= Float.round(entry.client_size / 1_000_000, 2) %> MB</p>
              <progress value={entry.progress} max="100">
                <%= entry.progress %>%
              </progress>
              <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
                取消
              </button>
            </div>
            <div :for={err <- upload_errors(@uploads.images, entry)} class="error">
              <%= error_to_string(err) %>
            </div>
          </div>
        </div>
        
        <button type="submit" disabled={@uploads.images.entries == []}>
          上传图片
        </button>
      </form>
      
      <div class="uploaded-files">
        <h2>已上传的文件</h2>
        <div :for={file <- @uploaded_files} class="uploaded-file">
          <img src={file} width="200" />
        </div>
      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "文件太大"
  defp error_to_string(:not_accepted), do: "不支持的文件类型"
  defp error_to_string(:too_many_files), do: "文件数量超过限制"
end
```

## 故障排查

1. **上传无响应**：确保表单绑定了 `phx-submit` 和 `phx-change` 事件
2. **文件验证失败**：检查 `accept` 选项是否正确配置
3. **进度不更新**：确保使用了 `@uploads` 分配的数据
4. **文件保存失败**：检查目标目录权限和磁盘空间

## 相关资源

- [Phoenix LiveView 官方文档](https://hexdocs.pm/phoenix_live_view)
- [Phoenix.Component 文档](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html)
- [示例项目](https://github.com/phoenixframework/phoenix_live_view/tree/main/examples)