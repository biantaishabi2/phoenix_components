# MediaUpload 媒体上传组件

## 概述
媒体上传组件，用于上传图片、视频等媒体文件，支持预览、拖拽上传、批量上传等功能。

## 何时使用
- 需要上传图片、视频等媒体文件时
- 需要预览已上传的文件时
- 需要支持拖拽上传功能时
- 需要批量上传多个文件时
- 商品图片、用户头像、文件附件等场景

## 特性
- 支持图片预览
- 支持拖拽上传
- 支持批量上传
- 支持自定义上传限制
- 支持进度显示
- 支持文件类型验证
- 支持文件大小限制
- 支持已上传文件管理
- 支持自定义上传处理
- 支持响应式布局

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| id | 组件唯一标识 | string | 必填 |
| label | 上传区域标签 | string | - |
| accept | 接受的文件类型 | list | ~w(.jpg .jpeg .png .gif .webp) |
| max_entries | 最大文件数量 | integer | 5 |
| max_file_size | 最大文件大小(字节) | integer | 10_000_000 (10MB) |
| auto_upload | 是否自动上传 | boolean | false |
| multiple | 是否支持多选 | boolean | true |
| draggable | 是否支持拖拽 | boolean | true |
| show_file_list | 是否显示文件列表 | boolean | true |
| show_preview | 是否显示预览 | boolean | true |
| preview_size | 预览图尺寸 | string | "medium" |
| layout | 布局方式 | string | "grid" |
| columns | 网格列数 | integer | 4 |
| upload_text | 上传区域文字 | string | "拖拽文件到这里，或点击选择文件" |
| uploading_text | 上传中文字 | string | "上传中..." |
| error_text | 错误提示文字 | string | - |
| class | 自定义CSS类 | string | "" |
| rest | 其他HTML属性 | global | - |

### 插槽
| 插槽 | 说明 | 参数 |
|-----|------|------|
| upload_icon | 自定义上传图标 | - |
| preview | 自定义预览内容 | entry |
| file_item | 自定义文件项 | entry |
| empty | 空状态内容 | - |

### 事件回调
| 事件 | 说明 | 参数 |
|-----|------|------|
| validate | 文件验证时触发 | - |
| save | 提交上传时触发 | entries |
| cancel-upload | 取消上传时触发 | ref |
| remove-file | 删除已上传文件时触发 | index |
| preview | 预览文件时触发 | entry |

### 尺寸值
| 值 | 说明 | 预览图大小 |
|----|------|----------|
| small | 小尺寸 | 64x64px |
| medium | 中等尺寸(默认) | 128x128px |
| large | 大尺寸 | 192x192px |

### 布局方式
| 值 | 说明 |
|----|------|
| grid | 网格布局(默认) |
| list | 列表布局 |
| card | 卡片布局 |

## 示例

### 基本使用
```heex
<.media_upload 
  id="basic-upload"
  label="商品图片"
/>
```

### 限制文件类型和大小
```heex
<.media_upload 
  id="limited-upload"
  label="用户头像"
  accept={~w(.jpg .jpeg .png)}
  max_entries={1}
  max_file_size={2_000_000}
/>
```

### 自动上传
```heex
<.media_upload 
  id="auto-upload"
  label="附件"
  auto_upload={true}
/>
```

### 禁用拖拽
```heex
<.media_upload 
  id="no-drag"
  label="证件照"
  draggable={false}
/>
```

### 自定义布局
```heex
<.media_upload 
  id="list-layout"
  label="文档上传"
  layout="list"
  accept={~w(.pdf .doc .docx)}
/>
```

### 自定义列数
```heex
<.media_upload 
  id="custom-columns"
  label="相册"
  columns={6}
  max_entries={12}
/>
```

### 自定义上传文字
```heex
<.media_upload 
  id="custom-text"
  label="营业执照"
  upload_text="点击或拖拽营业执照图片到这里"
  max_entries={1}
/>
```

### 不同预览尺寸
```heex
<.media_upload 
  id="small-preview"
  label="缩略图"
  preview_size="small"
/>

<.media_upload 
  id="large-preview"
  label="大图预览"
  preview_size="large"
/>
```

### 隐藏文件列表
```heex
<.media_upload 
  id="no-list"
  label="背景图"
  show_file_list={false}
/>
```

### 自定义上传图标
```heex
<.media_upload id="custom-icon" label="视频上传">
  <:upload_icon>
    <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
    </svg>
  </:upload_icon>
</.media_upload>
```

### 自定义预览
```heex
<.media_upload id="custom-preview" label="产品图">
  <:preview :let={entry}>
    <div class="relative">
      <.live_img_preview entry={entry} class="rounded-lg shadow-md" />
      <div class="absolute bottom-0 left-0 right-0 bg-black bg-opacity-50 text-white p-2 text-xs">
        <%= entry.client_name %>
      </div>
    </div>
  </:preview>
</.media_upload>
```

### 空状态
```heex
<.media_upload id="empty-state" label="作品集">
  <:empty>
    <div class="text-center py-8">
      <svg class="mx-auto h-12 w-12 text-gray-300" fill="none" stroke="currentColor">
        <!-- 图标 -->
      </svg>
      <p class="mt-2 text-sm text-gray-500">还没有上传任何作品</p>
    </div>
  </:empty>
</.media_upload>
```

### 完整示例
```heex
<.media_upload 
  id="product-images"
  label="商品图片"
  accept={~w(.jpg .jpeg .png .webp)}
  max_entries={8}
  max_file_size={5_000_000}
  preview_size="medium"
  layout="grid"
  columns={4}
  upload_text="拖拽商品图片到这里，或点击选择"
  class="border-2 border-dashed border-gray-300 rounded-lg"
/>
```

### 与表单结合使用
```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.field field={@form[:name]} label="商品名称" />
  
  <.media_upload 
    id="form-images"
    label="商品图片"
    max_entries={5}
  />
  
  <.field field={@form[:description]} type="textarea" label="商品描述" />
  
  <:actions>
    <.button phx-disable-with="保存中...">保存商品</.button>
  </:actions>
</.form>
```

## 高级用法

### 在 LiveView 中使用
```elixir
defmodule MyAppWeb.ProductLive do
  use MyAppWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:images,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 5,
        max_file_size: 5_000_000
     )}
  end
  
  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("cancel-upload-images", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end
  
  @impl true
  def handle_event("save-images", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :images, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)
    
    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> put_flash(:info, "图片上传成功！")}
  end
  
  @impl true
  def handle_event("remove-file-images", %{"index" => index}, socket) do
    {index, _} = Integer.parse(index)
    updated_files = List.delete_at(socket.assigns.uploaded_files, index)
    
    {:noreply, assign(socket, :uploaded_files, updated_files)}
  end
end
```

### 自定义上传处理
```elixir
defmodule MyApp.S3Uploader do
  def upload_to_s3(path, filename) do
    # 上传到 S3 的逻辑
    bucket = "my-bucket"
    key = "uploads/#{filename}"
    
    ExAws.S3.put_object(bucket, key, File.read!(path))
    |> ExAws.request!()
    
    {:ok, "https://#{bucket}.s3.amazonaws.com/#{key}"}
  end
end

# 在 LiveView 中使用
def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
      MyApp.S3Uploader.upload_to_s3(path, entry.client_name)
    end)
  
  {:noreply, assign(socket, :uploaded_files, uploaded_files)}
end
```

### 图片压缩处理
```elixir
def process_image(path, entry) do
  # 使用 Mogrify 压缩图片
  import Mogrify
  
  dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", entry.uuid <> ".jpg"])
  
  path
  |> open()
  |> resize_to_limit("1200x1200")
  |> quality(85)
  |> save(path: dest)
  
  {:ok, ~p"/uploads/#{Path.basename(dest)}"}
end
```

### 批量操作
```elixir
def handle_event("delete-all", _params, socket) do
  {:noreply, assign(socket, :uploaded_files, [])}
end

def handle_event("upload-all", _params, socket) do
  # 触发所有待上传文件的上传
  {:noreply, socket}
end
```

## 可访问性
- 使用语义化的HTML结构
- 提供清晰的标签和说明
- 支持键盘操作
- 提供适当的ARIA属性
- 支持屏幕阅读器

## 设计规范
- 上传区域应该明显且易于识别
- 提供清晰的文件类型和大小限制提示
- 使用进度条显示上传进度
- 错误信息应该清晰明确
- 预览图应该清晰可见

## 注意事项
- 确保服务器配置支持所需的文件大小
- 考虑使用云存储服务处理大量文件
- 实现适当的文件类型验证
- 考虑图片压缩以节省存储空间
- 处理网络中断等异常情况
- 注意文件上传的安全性