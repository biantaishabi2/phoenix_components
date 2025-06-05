defmodule ShopUxPhoenixWeb.PetalComponentsDemoLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders petal components demo page within app layout", %{conn: conn} do
    {:ok, view, html} = live(conn, "/components/petal")
    
    # 验证页面在 app layout 中渲染
    assert html =~ "app-layout"
    assert html =~ "Petal Components 演示"
    
    # 测试基本交互
    assert view |> element("button", "测试连接") |> render_click() =~ "WebSocket 连接正常"
  end

  test "petal data components demo page renders within app layout", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/components/petal_data")
    
    # 验证页面在 app layout 中渲染
    assert html =~ "app-layout"
    assert html =~ "Petal Components - 数据展示组件演示"
  end
end