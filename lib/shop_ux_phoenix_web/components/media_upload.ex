defmodule ShopUxPhoenixWeb.Components.MediaUpload do
  @moduledoc """
  媒体上传组件，用于上传图片、视频等媒体文件。

  支持预览、拖拽上传、批量上传等功能。需要在 LiveView 中配合 `allow_upload/3` 使用。
  """
  use Phoenix.Component

  @doc """
  渲染媒体上传组件。

  ## 示例

      <.media_upload 
        id="product-images"
        label="商品图片"
        accept={~w(.jpg .jpeg .png)}
        max_entries={5}
      />

  """
  attr :id, :string, required: true
  attr :label, :string, default: nil
  attr :accept, :list, default: ~w(.jpg .jpeg .png .gif .webp)
  attr :max_entries, :integer, default: 5
  attr :max_file_size, :integer, default: 10_000_000
  attr :auto_upload, :boolean, default: false
  attr :multiple, :boolean, default: true
  attr :draggable, :boolean, default: true
  attr :show_file_list, :boolean, default: true
  attr :show_preview, :boolean, default: true
  attr :preview_size, :string, default: "medium", values: ["small", "medium", "large"]
  attr :layout, :string, default: "grid", values: ["grid", "list", "card"]
  attr :columns, :integer, default: 4
  attr :upload_text, :string, default: "拖拽文件到这里，或点击选择文件"
  attr :uploading_text, :string, default: "上传中..."
  attr :error_text, :string, default: nil
  attr :class, :string, default: ""
  attr :rest, :global

  slot :upload_icon, doc: "自定义上传图标"
  slot :preview, doc: "自定义预览内容" do
    attr :entry, :map, required: true
  end
  slot :file_item, doc: "自定义文件项" do
    attr :entry, :map, required: true
  end
  slot :empty, doc: "空状态内容"

  def media_upload(assigns) do
    ~H"""
    <div 
      id={@id}
      class={[
        "pc-media-upload",
        preview_size_class(@preview_size),
        layout_class(@layout),
        @class
      ]}
      {@rest}
    >
      <%!-- 标签 --%>
      <div :if={@label} class="pc-media-upload__label text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= @label %>
      </div>

      <%!-- 错误提示 --%>
      <div :if={@error_text} class="pc-media-upload__error mb-2 text-sm text-red-600 dark:text-red-400">
        <%= @error_text %>
      </div>

      <%!-- 上传区域 --%>
      <div 
        class={[
          "pc-media-upload__drop-zone",
          "border-2 border-dashed border-gray-300 dark:border-gray-600",
          "rounded-lg p-6 text-center",
          "hover:border-gray-400 dark:hover:border-gray-500",
          "transition-colors cursor-pointer",
          "bg-gray-50 dark:bg-gray-800"
        ]}
        phx-drop-target={@draggable && "#{@id}-upload"}
        data-auto-upload={@auto_upload && "true"}
        data-uploading-text={@uploading_text}
      >
        <%!-- 上传图标 --%>
        <%= if @upload_icon != [] do %>
          <%= render_slot(@upload_icon) %>
        <% else %>
          <svg class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" stroke="currentColor" fill="none" viewBox="0 0 48 48">
            <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" 
              stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        <% end %>

        <%!-- 上传文字 --%>
        <p class="mt-3 text-sm text-gray-600 dark:text-gray-400">
          <%= if @draggable do %>
            <%= @upload_text %>
          <% else %>
            点击选择文件
          <% end %>
        </p>

        <%!-- 文件输入 --%>
        <input
          type="file"
          class="pc-media-upload__input hidden"
          accept={Enum.join(@accept, ",")}
          multiple={@multiple}
          phx-change={"validate-#{@id}"}
        />

        <%!-- 文件限制提示 --%>
        <p class="mt-2 text-xs text-gray-500 dark:text-gray-400">
          支持格式：<%= Enum.join(@accept, ", ") %> | 
          最大 <%= format_file_size(@max_file_size) %> | 
          最多 <%= @max_entries %> 个文件
        </p>
      </div>

      <%!-- 文件列表 --%>
      <div :if={@show_file_list} class={["pc-media-upload__list mt-4", grid_columns_class(@columns) |> String.replace("grid ", "")]}>
        <%!-- 这里需要通过 assigns.uploads 来渲染实际的文件列表 --%>
        <%!-- 在实际使用中，需要从 LiveView 传入 uploads assign --%>
      </div>

      <%!-- 空状态 --%>
      <div :if={@empty != [] && @show_file_list} class="pc-media-upload__empty">
        <%= render_slot(@empty) %>
      </div>
    </div>
    """
  end

  @doc """
  用于 LiveView 的媒体上传组件，包含完整的上传功能。

  需要在 LiveView 中使用 `allow_upload/3` 配置上传。

  ## 示例

      # 在 LiveView 中
      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> allow_upload(:images,
            accept: ~w(.jpg .jpeg .png),
            max_entries: 5
         )}
      end

      # 在模板中
      <.live_media_upload 
        id="images"
        uploads={@uploads}
        label="商品图片"
      />

  """
  attr :id, :any, required: true
  attr :uploads, :map, required: true
  attr :label, :string, default: nil
  attr :preview_size, :string, default: "medium"
  attr :layout, :string, default: "grid"
  attr :columns, :integer, default: 4
  attr :class, :string, default: ""
  attr :rest, :global

  def live_media_upload(assigns) do
    # 确保 columns 的响应式类
    assigns = assign(assigns, :grid_cols_class, grid_columns_class(assigns.columns))
    
    # 获取上传配置，可能为 nil
    upload = Map.get(assigns.uploads, assigns.id)
    assigns = assign(assigns, :upload, upload)
    
    ~H"""
    <div 
      class={[
        "pc-media-upload",
        preview_size_class(@preview_size),
        layout_class(@layout),
        @class
      ]}
      {@rest}
    >
      <%!-- 标签 --%>
      <div :if={@label} class="pc-media-upload__label text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= @label %>
      </div>

      <form id={"#{@id}-form"} phx-submit={"save-#{@id}"} phx-change={"validate-#{@id}"}>
        <%!-- 上传区域 --%>
        <div 
          class={[
            "pc-media-upload__drop-zone",
            "border-2 border-dashed border-gray-300 dark:border-gray-600",
            "rounded-lg p-6 text-center",
            "hover:border-gray-400 dark:hover:border-gray-500",
            "transition-colors cursor-pointer",
            "bg-gray-50 dark:bg-gray-800"
          ]}
          phx-drop-target={@upload && @upload.ref}
        >
          <svg class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500" stroke="currentColor" fill="none" viewBox="0 0 48 48">
            <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" 
              stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
          </svg>

          <p class="mt-3 text-sm text-gray-600 dark:text-gray-400">
            拖拽文件到这里，或
            <label for={@upload && @upload.ref} class="cursor-pointer text-blue-600 hover:text-blue-500 dark:text-blue-400 dark:hover:text-blue-300">
              点击选择文件
            </label>
          </p>

          <%= if @upload do %>
            <.live_file_input upload={@upload} class="hidden" />
          <% end %>

          <p class="mt-2 text-xs text-gray-500 dark:text-gray-400">
            支持格式：<%= Enum.join((@upload && @upload.accept) || [], ", ") %> | 
            最大 <%= format_file_size((@upload && @upload.max_file_size) || 10_000_000) %> | 
            最多 <%= (@upload && @upload.max_entries) || 5 %> 个文件
          </p>
        </div>

        <%!-- 上传中的文件 --%>
        <div :if={@upload && @upload.entries != []} class="mt-4">
          <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">上传队列</h4>
          <div class={[@grid_cols_class, "gap-4"]}>
            <div 
              :for={entry <- (@upload && @upload.entries) || []} 
              class="relative group bg-gray-50 dark:bg-gray-800 rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700"
            >
              <%!-- 图片预览 --%>
              <.live_img_preview 
                entry={entry} 
                class={preview_image_class(@preview_size)}
              />

              <%!-- 文件信息层 --%>
              <div class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-between p-2">
                <div class="text-white text-xs truncate">
                  <%= entry.client_name %>
                </div>

                <%!-- 进度条 --%>
                <div :if={entry.progress < 100} class="w-full bg-gray-200 rounded-full h-1.5">
                  <div 
                    class="bg-blue-600 h-1.5 rounded-full transition-all"
                    style={"width: #{entry.progress}%"}
                  ></div>
                </div>

                <%!-- 操作按钮 --%>
                <button
                  type="button"
                  phx-click={"cancel-upload-#{@id}"}
                  phx-value-ref={entry.ref}
                  class="self-end bg-red-500 hover:bg-red-600 text-white rounded px-2 py-1 text-xs"
                >
                  取消
                </button>
              </div>

              <%!-- 错误提示 --%>
              <div :if={length(upload_errors(@upload, entry)) > 0} class="absolute inset-x-0 bottom-0 bg-red-500 text-white text-xs p-1">
                <%= for err <- upload_errors(@upload, entry) do %>
                  <p><%= upload_error_to_string(err) %></p>
                <% end %>
              </div>
            </div>
          </div>
        </div>

        <%!-- 上传按钮 --%>
        <div :if={@upload && @upload.entries != []} class="mt-4">
          <button 
            type="submit" 
            class="w-full sm:w-auto px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={!@upload || !upload_entries_ready?(@upload)}
          >
            上传 <%= length((@upload && @upload.entries) || []) %> 个文件
          </button>
        </div>
      </form>
    </div>
    """
  end

  # 所有辅助函数
  
  defp preview_size_class("small"), do: "pc-media-upload--preview-small"
  defp preview_size_class("medium"), do: "pc-media-upload--preview-medium"
  defp preview_size_class("large"), do: "pc-media-upload--preview-large"

  defp layout_class("grid"), do: "pc-media-upload--layout-grid"
  defp layout_class("list"), do: "pc-media-upload--layout-list"
  defp layout_class("card"), do: "pc-media-upload--layout-card"

  defp format_file_size(bytes) when bytes >= 1_000_000_000 do
    "#{Float.round(bytes / 1_000_000_000, 1)} GB"
  end

  defp format_file_size(bytes) when bytes >= 1_000_000 do
    "#{Float.round(bytes / 1_000_000, 1)} MB"
  end

  defp format_file_size(bytes) when bytes >= 1_000 do
    "#{Float.round(bytes / 1_000, 1)} KB"
  end

  defp format_file_size(bytes), do: "#{bytes} B"

  defp grid_columns_class(columns) do
    base = "grid grid-cols-2"
    sm = if columns >= 3, do: "sm:grid-cols-3", else: "sm:grid-cols-2"
    md = "md:grid-cols-#{columns}"
    
    Enum.join([base, sm, md], " ")
  end

  defp preview_image_class("small"), do: "w-full h-16 object-cover"
  defp preview_image_class("medium"), do: "w-full h-32 object-cover"
  defp preview_image_class("large"), do: "w-full h-48 object-cover"

  defp upload_entries_ready?(upload) do
    upload.entries != [] and Enum.all?(upload.entries, &(&1.valid?))
  end

  defp upload_error_to_string(:too_large), do: "文件太大"
  defp upload_error_to_string(:not_accepted), do: "不支持的文件类型"
  defp upload_error_to_string(:too_many_files), do: "文件数量超过限制"
  defp upload_error_to_string(error), do: to_string(error)
end