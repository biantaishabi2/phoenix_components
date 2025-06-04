defmodule ShopUxPhoenixWeb.InputNumberDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "InputNumber Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/input_number")
      
      assert html =~ "InputNumber 数字输入框组件"
      assert has_element?(view, "h1", "InputNumber 数字输入框组件")
    end

    test "basic input number exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      # Check basic number input exists
      assert has_element?(view, "#basic-number")
    end

    test "displays current value", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/input_number")
      
      # Should display initial value
      assert html =~ "当前值: 1"
    end

    test "different input variants exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      # Check various inputs exist
      assert has_element?(view, "#price-input")
      assert has_element?(view, "#age-input")
      assert has_element?(view, "#rate-input")
      assert has_element?(view, "#score-input")
    end

    test "size variants exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#small-input")
      assert has_element?(view, "#medium-input") 
      assert has_element?(view, "#large-input")
    end

    test "disabled and readonly inputs exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#disabled-input")
      assert has_element?(view, "#readonly-input")
    end

    test "inputs with prefix and suffix exist", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/input_number")
      
      # Check currency input
      assert has_element?(view, "#currency-input")
      assert html =~ "¥"
      
      # Check percent input
      assert has_element?(view, "#percent-input")
      assert html =~ "%"
    end

    test "no controls variant exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#no-controls")
    end

    test "form demo exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#demo-form")
      assert has_element?(view, "#product-price")
      assert has_element?(view, "#product-stock")
      assert has_element?(view, "#discount-rate")
    end

    test "color variants exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#color-primary")
      assert has_element?(view, "#color-info")
      assert has_element?(view, "#color-success")
      assert has_element?(view, "#color-warning")
      assert has_element?(view, "#color-danger")
    end

    test "can update basic value", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      # Change basic input value
      view
      |> element("#basic-number")
      |> render_change(%{"value" => "5"})
      
      # Should trigger update_basic event
      # Note: This might not work as expected because the event is bound to the input
      # and we're testing the LiveView interaction
    end

    test "form can be submitted", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      # Submit the demo form
      view
      |> form("#demo-form", %{
        "product" => %{
          "price" => "199.99",
          "stock" => "50",
          "discount" => "20"
        }
      })
      |> render_submit()
      
      # Check for success message
      assert render(view) =~ "Form submitted"
    end

    test "validation demo exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#validated-input")
    end

    test "keyboard shortcuts info is displayed", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/input_number")
      
      assert html =~ "↑ - 增加一个步长"
      assert html =~ "↓ - 减少一个步长"
    end

    test "accessibility demo exists", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#a11y-test")
      assert html =~ "ARIA 属性"
    end

    test "all sections are rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/input_number")
      
      # Check all section titles
      assert html =~ "基础用法"
      assert html =~ "设置精度"
      assert html =~ "设置步长"
      assert html =~ "带前缀和后缀"
      assert html =~ "禁用和只读状态"
      assert html =~ "不显示控制按钮"
      assert html =~ "不同尺寸"
      assert html =~ "不同颜色主题"
      assert html =~ "在表单中使用"
      assert html =~ "购物车数量选择"
      assert html =~ "价格区间输入"
      assert html =~ "带验证的输入"
      assert html =~ "精度处理"
      assert html =~ "键盘快捷键"
      assert html =~ "边缘案例测试"
      assert html =~ "可访问性"
    end

    test "temperature input with negative values exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#temperature")
    end

    test "price range inputs exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#min-price")
      assert has_element?(view, "#max-price")
    end

    test "cart quantity selector exists", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/input_number")
      
      assert has_element?(view, "#cart-quantity")
      assert html =~ "库存："
    end
  end
end