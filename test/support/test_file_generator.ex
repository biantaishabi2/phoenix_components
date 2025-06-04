defmodule ShopUxPhoenixWeb.TestFileGenerator do
  @moduledoc """
  生成测试用的图片文件
  """

  @fixtures_path "test/fixtures"

  def generate_all do
    ensure_fixtures_dir()
    
    # 生成各种测试图片
    generate_red_square()
    generate_green_square()
    generate_blue_square()
    generate_tiny_jpeg()
    generate_large_image()
    generate_pdf_file()
  end

  defp ensure_fixtures_dir do
    File.mkdir_p!(@fixtures_path)
  end

  # 10x10 红色方块 PNG
  defp generate_red_square do
    content = Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC")
    File.write!(Path.join(@fixtures_path, "red-square.png"), content)
  end

  # 10x10 绿色方块 PNG
  defp generate_green_square do
    content = Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mNk+M9Qz0AEYBxVSF+FAAhKDveksOjmAAAAAElFTkSuQmCC")
    File.write!(Path.join(@fixtures_path, "green-square.png"), content)
  end

  # 10x10 蓝色方块 PNG
  defp generate_blue_square do
    content = Base.decode64!("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mNkYPhfz0AEYBxVSF+FAP5FDvcfRYWgAAAAAElFTkSuQmCC")
    File.write!(Path.join(@fixtures_path, "blue-square.png"), content)
  end

  # 1x1 JPEG
  defp generate_tiny_jpeg do
    content = Base.decode64!("/9j/4AAQSkZJRgABAQAAZABkAAD/2wCEABQQEBkSGScXFycyJh8mMi4mJiYmLj41NTU1NT5EQUFBQUFBREREREREREREREREREREREREREREREREREREREQBFRkZIBwgJhgYJjYmICY2RDYrKzZERERCNUJERERERERERERERERERERERERERERERERERERERERERERERERERP/AABEIAAEAAQMBIgACEQEDEQH/xABMAAEBAAAAAAAAAAAAAAAAAAAABQEBAQAAAAAAAAAAAAAAAAAABQYQAQAAAAAAAAAAAAAAAAAAAAARAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AJQA9Yv/2Q==")
    File.write!(Path.join(@fixtures_path, "tiny.jpg"), content)
  end

  # 生成一个稍大的测试图片（100x100 渐变色）
  defp generate_large_image do
    # 创建一个简单的 100x100 PNG 图片
    # PNG 文件头
    png_header = <<137, 80, 78, 71, 13, 10, 26, 10>>
    
    # IHDR chunk - 定义图片尺寸
    width = 100
    height = 100
    ihdr_data = <<width::32, height::32, 8, 2, 0, 0, 0>>
    ihdr = create_chunk("IHDR", ihdr_data)
    
    # IDAT chunk - 图片数据（简单的红色渐变）
    scanlines = for y <- 0..(height-1) do
      # 每行的过滤器类型（0 = 无过滤）
      filter = <<0>>
      # RGB 像素数据
      pixels = for x <- 0..(width-1) do
        r = min(255, x * 2 + y)
        g = min(255, y * 2)
        b = min(255, 255 - x * 2)
        <<r, g, b>>
      end
      [filter | pixels]
    end
    
    # 压缩图片数据
    raw_data = IO.iodata_to_binary(scanlines)
    compressed = :zlib.compress(raw_data)
    idat = create_chunk("IDAT", compressed)
    
    # IEND chunk
    iend = create_chunk("IEND", <<>>)
    
    # 组合所有部分
    png_data = IO.iodata_to_binary([png_header, ihdr, idat, iend])
    File.write!(Path.join(@fixtures_path, "large-image.png"), png_data)
  end

  # 生成一个假的 PDF 文件
  defp generate_pdf_file do
    pdf_content = """
    %PDF-1.4
    1 0 obj
    << /Type /Catalog /Pages 2 0 R >>
    endobj
    2 0 obj
    << /Type /Pages /Kids [3 0 R] /Count 1 >>
    endobj
    3 0 obj
    << /Type /Page /Parent 2 0 R /Resources 4 0 R /MediaBox [0 0 612 792] /Contents 5 0 R >>
    endobj
    4 0 obj
    << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >>
    endobj
    5 0 obj
    << /Length 44 >>
    stream
    BT
    /F1 12 Tf
    100 700 Td
    (Test PDF) Tj
    ET
    endstream
    endobj
    xref
    0 6
    0000000000 65535 f
    0000000009 00000 n
    0000000058 00000 n
    0000000115 00000 n
    0000000229 00000 n
    0000000328 00000 n
    trailer
    << /Size 6 /Root 1 0 R >>
    startxref
    434
    %%EOF
    """
    File.write!(Path.join(@fixtures_path, "test.pdf"), pdf_content)
  end

  # 创建 PNG chunk
  defp create_chunk(type, data) do
    length = byte_size(data)
    crc_data = type <> data
    crc = :erlang.crc32(crc_data)
    <<length::32, type::binary, data::binary, crc::32>>
  end
end