defmodule ShopUxPhoenixWeb.MediaUploadDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.MediaUpload

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "MediaUpload 媒体上传组件")
     |> assign(:uploaded_files, [])
     |> assign(:avatar_files, [])
     |> assign(:document_files, [])
     |> allow_upload(:product_images,
        accept: ~w(.jpg .jpeg .png .gif .webp),
        max_entries: 5,
        max_file_size: 10_000_000
     )
     |> allow_upload(:avatar,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 2_000_000
     )
     |> allow_upload(:documents,
        accept: ~w(.pdf .doc .docx .xls .xlsx),
        max_entries: 10,
        max_file_size: 20_000_000
     )}
  end

  @impl true
  def handle_event("validate-product_images", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate-avatar", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate-documents", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload-product_images", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_images, ref)}
  end

  @impl true
  def handle_event("cancel-upload-avatar", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl true
  def handle_event("cancel-upload-documents", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :documents, ref)}
  end

  @impl true
  def handle_event("save-product_images", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :product_images, fn %{path: _path}, entry ->
        # 在实际应用中，这里应该将文件保存到合适的位置
        # 例如上传到云存储服务
        {:ok, %{url: "/uploads/#{entry.uuid}.#{ext(entry)}", name: entry.client_name}}
      end)

    if uploaded_files == [] do
      {:noreply, put_flash(socket, :error, "请选择要上传的文件")}
    else
      {:noreply,
       socket
       |> update(:uploaded_files, &(&1 ++ uploaded_files))
       |> put_flash(:info, "商品图片上传成功！")}
    end
  end

  @impl true
  def handle_event("save-avatar", _params, socket) do
    avatar_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: _path}, entry ->
        {:ok, %{url: "/uploads/avatar/#{entry.uuid}.#{ext(entry)}", name: entry.client_name}}
      end)

    if avatar_files == [] do
      {:noreply, put_flash(socket, :error, "请选择要上传的头像")}
    else
      {:noreply,
       socket
       |> assign(:avatar_files, avatar_files)
       |> put_flash(:info, "头像上传成功！")}
    end
  end

  @impl true
  def handle_event("save-documents", _params, socket) do
    document_files =
      consume_uploaded_entries(socket, :documents, fn %{path: _path}, entry ->
        {:ok, %{url: "/uploads/docs/#{entry.uuid}.#{ext(entry)}", name: entry.client_name}}
      end)

    if document_files == [] do
      {:noreply, put_flash(socket, :error, "请选择要上传的文档")}
    else
      {:noreply,
       socket
       |> update(:document_files, &(&1 ++ document_files))
       |> put_flash(:info, "文档上传成功！")}
    end
  end

  @impl true
  def handle_event("remove-file-product_images", %{"index" => index}, socket) do
    {index, _} = Integer.parse(index)
    updated_files = List.delete_at(socket.assigns.uploaded_files, index)
    {:noreply, assign(socket, :uploaded_files, updated_files)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full px-4 sm:px-6 lg:px-8 py-8">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-8">
        MediaUpload 媒体上传组件
      </h1>

      <div class="space-y-12">
        <!-- 基本使用 -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-4">基本使用</h2>
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <.live_media_upload 
              id="product_images"
              uploads={@uploads}
              label="商品图片"
            />
            
            <!-- 已上传的文件 -->
            <div :if={@uploaded_files != []} class="mt-6">
              <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">已上传的文件</h4>
              <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                <div :for={{file, index} <- Enum.with_index(@uploaded_files)} class="relative group">
                  <div class="bg-gray-100 dark:bg-gray-700 rounded-lg p-4 text-center">
                    <svg class="w-12 h-12 mx-auto text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <p class="mt-2 text-xs text-gray-600 dark:text-gray-400 truncate">
                      <%= file.name %>
                    </p>
                  </div>
                  <button
                    type="button"
                    phx-click="remove-file-product_images"
                    phx-value-index={index}
                    class="absolute top-2 right-2 bg-red-500 hover:bg-red-600 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- 单文件上传（头像） -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-4">单文件上传</h2>
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <.live_media_upload 
              id="avatar"
              uploads={@uploads}
              label="用户头像"
              preview_size="large"
            />
            
            <div :if={@avatar_files != []} class="mt-4">
              <p class="text-sm text-gray-600 dark:text-gray-400">
                已上传头像：<%= Enum.at(@avatar_files, 0).name %>
              </p>
            </div>
          </div>
        </section>

        <!-- 文档上传 -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-4">文档上传</h2>
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <.live_media_upload 
              id="documents"
              uploads={@uploads}
              label="上传文档"
              layout="list"
            />
            
            <div :if={@document_files != []} class="mt-4">
              <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">已上传文档</h4>
              <ul class="space-y-2">
                <li :for={doc <- @document_files} class="flex items-center text-sm text-gray-600 dark:text-gray-400">
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  <%= doc.name %>
                </li>
              </ul>
            </div>
          </div>
        </section>

        <!-- 静态展示（不需要实际上传功能） -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-4">静态展示</h2>
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <.media_upload 
              id="static-demo"
              label="证件照片"
              accept={~w(.jpg .jpeg .png)}
              max_entries={2}
              max_file_size={5_000_000}
            />
          </div>
        </section>

        <!-- 不同预览尺寸 -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-4">预览尺寸</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <h3 class="text-lg font-medium mb-4">小尺寸</h3>
              <.media_upload 
                id="small-preview"
                label="小图预览"
                preview_size="small"
              />
            </div>
            
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <h3 class="text-lg font-medium mb-4">中等尺寸</h3>
              <.media_upload 
                id="medium-preview"
                label="中图预览"
                preview_size="medium"
              />
            </div>
            
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <h3 class="text-lg font-medium mb-4">大尺寸</h3>
              <.media_upload 
                id="large-preview"
                label="大图预览"
                preview_size="large"
              />
            </div>
          </div>
        </section>

        <!-- 自定义配置 -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-4">自定义配置</h2>
          <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <.media_upload 
              id="custom-config"
              label="营业执照"
              accept={~w(.jpg .jpeg .png .pdf)}
              max_entries={3}
              max_file_size={15_000_000}
              upload_text="请上传营业执照扫描件（支持JPG、PNG、PDF格式）"
              class="border-4 border-blue-200"
            />
          </div>
        </section>
      </div>
    </div>
    """
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end