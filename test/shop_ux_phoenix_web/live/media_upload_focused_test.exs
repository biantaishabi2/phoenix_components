defmodule ShopUxPhoenixWeb.MediaUploadFocusedTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "业务逻辑测试" do
    test "空文件提交显示正确错误消息", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/media_upload")
      
      # 测试商品图片
      result = view |> form("#product_images-form") |> render_submit()
      assert result =~ "请选择要上传的文件"
      refute result =~ "商品图片上传成功"
      
      # 测试头像
      result = view |> form("#avatar-form") |> render_submit()
      assert result =~ "请选择要上传的头像"
      
      # 测试文档
      result = view |> form("#documents-form") |> render_submit()
      assert result =~ "请选择要上传的文档"
    end

    test "删除文件事件处理", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/media_upload")
      
      # 测试删除不存在的文件不会崩溃
      result = render_click(view, "remove-file-product_images", %{"index" => "0"})
      assert result =~ "MediaUpload"
    end
  end

  describe "组件渲染测试" do
    test "静态组件参数处理", _context do
      assigns = %{
        id: "test",
        label: "测试上传",
        preview_size: "small",
        layout: "list",
        accept: ~w(.jpg .png),
        max_entries: 3,
        max_file_size: 5_000_000,
        upload_text: "自定义文本",
        class: "custom-class"
      }
      
      html = Phoenix.LiveViewTest.render_component(
        &ShopUxPhoenixWeb.Components.MediaUpload.media_upload/1,
        assigns
      )
      
      assert html =~ "测试上传"
      assert html =~ "pc-media-upload--preview-small"
      assert html =~ "pc-media-upload--layout-list"
      assert html =~ "自定义文本"
      assert html =~ "custom-class"
      assert html =~ "最大 5.0 MB"
      assert html =~ "最多 3 个文件"
    end

    test "LiveView 组件 nil uploads 处理", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/media_upload")
      
      # 验证页面正常渲染
      assert html =~ "MediaUpload 媒体上传组件"
      assert html =~ "基本使用"
    end
  end
end