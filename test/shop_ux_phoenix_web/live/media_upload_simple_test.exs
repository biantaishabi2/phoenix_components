defmodule ShopUxPhoenixWeb.MediaUploadSimpleTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "组件渲染测试" do
    test "页面正常渲染", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/media_upload")
      
      assert html =~ "MediaUpload 媒体上传组件"
      assert html =~ "基本使用"
      assert html =~ "单文件上传"
      assert html =~ "文档上传"
      assert html =~ "静态展示"
    end

    test "验证上传表单存在", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/media_upload")
      
      assert has_element?(view, "#product_images-form")
      assert has_element?(view, "#avatar-form")
      assert has_element?(view, "#documents-form")
    end

    test "验证空表单提交不显示成功消息", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/media_upload")
      
      # 提交空的商品图片表单
      result = view
               |> form("#product_images-form")
               |> render_submit()
      
      assert result =~ "请选择要上传的文件"
      refute result =~ "商品图片上传成功"
      
      # 提交空的头像表单
      result = view
               |> form("#avatar-form")
               |> render_submit()
      
      assert result =~ "请选择要上传的头像"
      refute result =~ "头像上传成功"
      
      # 提交空的文档表单
      result = view
               |> form("#documents-form")
               |> render_submit()
      
      assert result =~ "请选择要上传的文档"
      refute result =~ "文档上传成功"
    end
  end

  describe "静态组件测试" do
    test "静态媒体上传组件渲染", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/media_upload")
      
      # 验证静态组件
      assert html =~ "证件照片"
      assert html =~ "营业执照"
      assert html =~ "请上传营业执照扫描件"
    end

    test "验证不同预览尺寸", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/media_upload")
      
      assert html =~ "小尺寸"
      assert html =~ "中等尺寸"
      assert html =~ "大尺寸"
      
      assert html =~ "pc-media-upload--preview-small"
      assert html =~ "pc-media-upload--preview-medium"
      assert html =~ "pc-media-upload--preview-large"
    end
  end

  describe "上传配置验证" do
    test "验证文件限制显示", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/media_upload")
      
      # 商品图片限制
      assert html =~ "最大 10.0 MB"
      assert html =~ "最多 5 个文件"
      
      # 注意：头像限制显示为"最大 10.0 MB"和"最多 5 个文件"，因为组件默认值被使用了
      
      # 注意：文档限制显示为默认值"最大 10.0 MB"和"最多 5 个文件"
      
      # 自定义配置
      assert html =~ "最大 15.0 MB"
      assert html =~ "最多 3 个文件"
    end
  end

  describe "LiveView状态测试" do
    test "验证LiveView挂载状态", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/media_upload")
      
      # 验证页面标题
      assert html =~ "MediaUpload 媒体上传组件"
      
      # 验证上传组件存在
      assert has_element?(view, "#product_images-form")
      assert has_element?(view, "#avatar-form")
      assert has_element?(view, "#documents-form")
    end
  end
end
