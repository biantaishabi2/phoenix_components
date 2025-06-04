defmodule ShopUxPhoenixWeb.Components.MediaUploadTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.MediaUpload

  describe "media_upload/1" do
    test "renders basic media upload component" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="basic-upload"
          label="上传图片"
        />
      """)
      
      assert html =~ "pc-media-upload"
      assert html =~ "上传图片"
      assert html =~ "拖拽文件到这里"
    end

    test "renders with custom label" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="custom-label"
          label="商品图片"
        />
      """)
      
      assert html =~ "pc-media-upload__label"
      assert html =~ "商品图片"
    end

    test "renders with custom accept types" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="accept-test"
          label="文档"
          accept={~w(.pdf .doc .docx)}
        />
      """)
      
      assert html =~ "accept=\".pdf,.doc,.docx\""
    end

    test "renders with max entries limit" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="max-entries"
          label="头像"
          max_entries={1}
        />
      """)
      
      assert html =~ "最多 1 个文件"
    end

    test "renders with custom max file size" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="file-size"
          label="小文件"
          max_file_size={1_000_000}
        />
      """)
      
      assert html =~ "最大 1.0 MB"
    end

    test "renders with auto upload enabled" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="auto-upload"
          label="自动上传"
          auto_upload={true}
        />
      """)
      
      assert html =~ "data-auto-upload=\"true\""
    end

    test "renders without multiple selection" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="single-file"
          label="单文件"
          multiple={false}
        />
      """)
      
      refute html =~ "multiple"
    end

    test "renders without drag and drop" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="no-drag"
          label="禁用拖拽"
          draggable={false}
        />
      """)
      
      refute html =~ "phx-drop-target"
      assert html =~ "点击选择文件"
    end

    test "renders without file list" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="no-list"
          label="隐藏列表"
          show_file_list={false}
        />
      """)
      
      refute html =~ "pc-media-upload__list"
    end

    test "renders without preview" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="no-preview"
          label="无预览"
          show_preview={false}
        />
      """)
      
      refute html =~ "pc-media-upload__preview"
    end

    test "renders with different preview sizes" do
      for size <- ["small", "medium", "large"] do
        assigns = %{current_size: size}
        
        html = rendered_to_string(~H"""
          <.media_upload 
            id={"preview-#{@current_size}"}
            label="预览尺寸"
            preview_size={@current_size}
          />
        """)
        
        assert html =~ "pc-media-upload--preview-#{size}"
      end
    end

    test "renders with different layouts" do
      for layout <- ["grid", "list", "card"] do
        assigns = %{current_layout: layout}
        
        html = rendered_to_string(~H"""
          <.media_upload 
            id={"layout-#{@current_layout}"}
            label="布局"
            layout={@current_layout}
          />
        """)
        
        assert html =~ "pc-media-upload--layout-#{layout}"
      end
    end

    test "renders with custom columns" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="custom-columns"
          label="六列"
          columns={6}
        />
      """)
      
      assert html =~ "grid-cols-6"
    end

    test "renders with custom upload text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="custom-text"
          label="自定义文字"
          upload_text="请选择营业执照图片"
        />
      """)
      
      assert html =~ "请选择营业执照图片"
    end

    test "renders with uploading text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="uploading-text"
          label="上传中"
          uploading_text="正在上传，请稍候..."
        />
      """)
      
      assert html =~ "data-uploading-text=\"正在上传，请稍候...\""
    end

    test "renders with error text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="error-text"
          label="错误"
          error_text="上传失败，请重试"
        />
      """)
      
      assert html =~ "上传失败，请重试"
      assert html =~ "pc-media-upload__error"
    end

    test "renders upload icon slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload id="icon-slot" label="自定义图标">
          <:upload_icon>
            <svg class="w-16 h-16 text-blue-500">
              <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
            </svg>
          </:upload_icon>
        </.media_upload>
      """)
      
      assert html =~ "w-16 h-16 text-blue-500"
    end

    test "renders empty slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload id="empty-slot" label="空状态">
          <:empty>
            <p class="text-gray-500">还没有上传任何文件</p>
          </:empty>
        </.media_upload>
      """)
      
      assert html =~ "还没有上传任何文件"
      assert html =~ "text-gray-500"
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="custom-class"
          label="自定义样式"
          class="border-4 border-blue-500"
        />
      """)
      
      assert html =~ "border-4 border-blue-500"
    end

    test "renders with global attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="global-attrs"
          label="属性测试"
          data-testid="media-upload"
          aria-describedby="upload-help"
        />
      """)
      
      assert html =~ ~s(data-testid="media-upload")
      assert html =~ ~s(aria-describedby="upload-help")
    end

    test "renders drop zone structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="drop-zone"
          label="拖拽区域"
        />
      """)
      
      assert html =~ "pc-media-upload__drop-zone"
      assert html =~ "phx-drop-target"
    end

    test "renders file input structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="file-input"
          label="文件输入"
        />
      """)
      
      assert html =~ "type=\"file\""
      assert html =~ "pc-media-upload__input"
    end

    test "renders with form integration" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <form phx-submit="save" phx-change="validate">
          <.media_upload 
            id="form-upload"
            label="表单上传"
          />
        </form>
      """)
      
      assert html =~ "form"
      assert html =~ "phx-submit=\"save\""
      assert html =~ "phx-change=\"validate\""
    end

    test "renders with responsive grid columns" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="responsive"
          label="响应式"
          columns={4}
        />
      """)
      
      assert html =~ "grid-cols-2"
      assert html =~ "sm:grid-cols-3"
      assert html =~ "md:grid-cols-4"
    end

    test "renders upload zone hover state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="hover"
          label="悬停效果"
        />
      """)
      
      assert html =~ "hover:border-gray-400"
      assert html =~ "transition-colors"
    end

    test "renders with all options" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.media_upload 
          id="all-options"
          label="完整配置"
          accept={~w(.jpg .png .gif)}
          max_entries={10}
          max_file_size={20_000_000}
          auto_upload={true}
          multiple={true}
          draggable={true}
          show_file_list={true}
          show_preview={true}
          preview_size="large"
          layout="grid"
          columns={5}
          upload_text="拖拽或选择图片"
          uploading_text="上传中..."
          class="custom-upload"
        />
      """)
      
      assert html =~ "完整配置"
      assert html =~ "accept=\".jpg,.png,.gif\""
      assert html =~ "最多 10 个文件"
      assert html =~ "最大 20.0 MB"
      assert html =~ "data-auto-upload=\"true\""
      assert html =~ "multiple"
      assert html =~ "phx-drop-target"
      assert html =~ "pc-media-upload--preview-large"
      assert html =~ "pc-media-upload--layout-grid"
      assert html =~ "grid-cols-5"
      assert html =~ "拖拽或选择图片"
      assert html =~ "custom-upload"
    end

    test "formats file size correctly" do
      assigns = %{}
      
      # Bytes
      html = rendered_to_string(~H"""
        <.media_upload id="bytes" label="字节" max_file_size={500} />
      """)
      assert html =~ "最大 500 B"
      
      # Kilobytes
      html = rendered_to_string(~H"""
        <.media_upload id="kb" label="KB" max_file_size={2_500} />
      """)
      assert html =~ "最大 2.5 KB"
      
      # Megabytes
      html = rendered_to_string(~H"""
        <.media_upload id="mb" label="MB" max_file_size={5_500_000} />
      """)
      assert html =~ "最大 5.5 MB"
      
      # Gigabytes
      html = rendered_to_string(~H"""
        <.media_upload id="gb" label="GB" max_file_size={2_500_000_000} />
      """)
      assert html =~ "最大 2.5 GB"
    end
  end
end