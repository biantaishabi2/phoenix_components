defmodule ShopUxPhoenixWeb.DocController do
  use ShopUxPhoenixWeb, :controller
  
  def show(conn, %{"path" => path}) do
    # 构建文档文件的完整路径
    doc_path = Path.join([File.cwd!(), "docs"] ++ path)
    
    # 确保路径以 .md 结尾
    doc_path = if String.ends_with?(doc_path, ".md"), do: doc_path, else: doc_path <> ".md"
    
    # 检查文件是否存在并且在 docs 目录内
    if File.exists?(doc_path) && String.starts_with?(doc_path, Path.join(File.cwd!(), "docs")) do
      markdown_content = File.read!(doc_path)
      
      # 将 Markdown 转换为 HTML
      {:ok, html_content, _} = Earmark.as_html(markdown_content)
      
      # 获取文档标题（使用文件名）
      title = path 
        |> List.last() 
        |> String.replace("_", " ")
        |> String.replace(".md", "")
        |> String.capitalize()
      
      # 渲染 HTML 页面
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, """
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{title} - Documentation</title>
        <link href="/assets/app.css" rel="stylesheet">
        <style>
          .markdown-body {
            max-width: 900px;
            margin: 0 auto;
            padding: 2rem;
          }
          .markdown-body h1, .markdown-body h2, .markdown-body h3 {
            margin-top: 2rem;
            margin-bottom: 1rem;
          }
          .markdown-body pre {
            background-color: #f3f4f6;
            padding: 1rem;
            border-radius: 0.5rem;
            overflow-x: auto;
          }
          .markdown-body code {
            background-color: #f3f4f6;
            padding: 0.2rem 0.4rem;
            border-radius: 0.25rem;
            font-size: 0.875rem;
          }
          .markdown-body pre code {
            background-color: transparent;
            padding: 0;
          }
          .markdown-body table {
            border-collapse: collapse;
            width: 100%;
            margin: 1rem 0;
          }
          .markdown-body th, .markdown-body td {
            border: 1px solid #e5e7eb;
            padding: 0.5rem 1rem;
            text-align: left;
          }
          .markdown-body th {
            background-color: #f9fafb;
            font-weight: 600;
          }
        </style>
      </head>
      <body class="bg-white">
        <div class="markdown-body">
          #{html_content}
        </div>
      </body>
      </html>
      """)
    else
      conn
      |> put_status(:not_found)
      |> put_resp_content_type("text/html")
      |> send_resp(404, """
      <!DOCTYPE html>
      <html>
      <head>
        <title>Document Not Found</title>
        <link href="/assets/app.css" rel="stylesheet">
      </head>
      <body class="bg-gray-50 flex items-center justify-center min-h-screen">
        <div class="text-center">
          <h1 class="text-4xl font-bold text-gray-800 mb-4">404</h1>
          <p class="text-gray-600">Document not found</p>
          <a href="/components" class="mt-4 inline-block text-blue-600 hover:text-blue-800">
            Back to Components
          </a>
        </div>
      </body>
      </html>
      """)
    end
  end
end