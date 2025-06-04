defmodule ShopUxPhoenixWeb.TestImages do
  @moduledoc """
  测试用的图片数据，包含各种格式和大小的图片。
  """

  # 1x1 红色像素 PNG
  @red_dot_png Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
  
  # 10x10 红色方块 PNG
  @red_square_png Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC")
  
  # 10x10 绿色方块 PNG
  @green_square_png Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mNk+M9Qz0AEYBxVSF+FAAhKDveksOjmAAAAAElFTkSuQmCC")
  
  # 10x10 蓝色方块 PNG
  @blue_square_png Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mNkYPhfz0AEYBxVSF+FAP5FDvcfRYWgAAAAAElFTkSuQmCC")
  
  # 1x1 JPEG
  @tiny_jpeg Base.decode64!("/9j/4AAQSkZJRgABAQAAZABkAAD/2wCEABQQEBkSGScXFycyJh8mMi4mJiYmLj41NTU1NT5EQUFBQUFBREREREREREREREREREREREREREREREREREREREQBFRkZIBwgJhgYJjYmICY2RDYrKzZERERCNUJERERERERERERERERERERERERERERERERERERERERERERERERERP/AABEIAAEAAQMBIgACEQEDEQH/xABMAAEBAAAAAAAAAAAAAAAAAAAABQEBAQAAAAAAAAAAAAAAAAAABQYQAQAAAAAAAAAAAAAAAAAAAAARAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AJQA9Yv/2Q==")
  
  # 1x1 白色 GIF
  @white_gif Base.decode64!("R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs=")

  def red_dot_png, do: @red_dot_png
  def red_square_png, do: @red_square_png
  def green_square_png, do: @green_square_png
  def blue_square_png, do: @blue_square_png
  def tiny_jpeg, do: @tiny_jpeg
  def white_gif, do: @white_gif

  @doc """
  创建一个指定大小的假文件内容
  """
  def create_fake_content(size_in_bytes) do
    :crypto.strong_rand_bytes(size_in_bytes)
  end

  @doc """
  获取测试文件列表，用于批量上传测试
  """
  def test_files do
    [
      %{
        name: "red-square.png",
        content: red_square_png(),
        type: "image/png",
        size: byte_size(red_square_png())
      },
      %{
        name: "green-square.png", 
        content: green_square_png(),
        type: "image/png",
        size: byte_size(green_square_png())
      },
      %{
        name: "blue-square.png",
        content: blue_square_png(),
        type: "image/png",
        size: byte_size(blue_square_png())
      }
    ]
  end

  @doc """
  创建一个超大文件用于测试文件大小限制
  """
  def large_file do
    %{
      name: "large-file.jpg",
      content: create_fake_content(15_000_000), # 15MB
      type: "image/jpeg",
      size: 15_000_000
    }
  end

  @doc """
  创建一个不支持的文件类型
  """
  def unsupported_file do
    %{
      name: "document.pdf",
      content: <<"%PDF-1.4">>,
      type: "application/pdf",
      size: 8
    }
  end
end