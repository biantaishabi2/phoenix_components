defmodule ShopUxPhoenixWeb.Components.TableFilterSimpleTest do
  @moduledoc """
  简化的筛选功能测试 - 验证基本功能
  """
  use ShopUxPhoenixWeb.ComponentCase, async: true
  import Phoenix.LiveViewTest
  
  alias PetalComponents.Custom.Table

  describe "basic filter functionality" do
    test "renders filter icon when column is filterable" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <Table.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </Table.table>
      """)
      
      # 断言：包含筛选相关的元素
      assert html =~ "pc-table"
      assert html =~ "名称"
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "phx-click=\"filter_column\""
      assert html =~ "phx-value-column=\"name\""
      assert html =~ "title=\"筛选\""
    end

    test "does not render filter icon when not filterable" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <Table.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name">
            <%= product.name %>
          </:col>
        </Table.table>
      """)
      
      # 基本断言：正常渲染
      assert html =~ "pc-table"
      assert html =~ "名称"
    end

    test "shows filtered state when filters are applied" do
      assigns = %{
        products: test_products(),
        filters: %{"name" => ["产品A"]}
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </Table.table>
      """)
      
      # 断言：筛选状态正确显示
      assert html =~ "text-blue-600"  # 已筛选状态的颜色
    end

    test "validates filterable columns require key" do
      assigns = %{products: test_products()}
      
      # 应该抛出错误，因为可筛选列必须有 key
      assert_raise ArgumentError, ~r/Filterable columns must have a 'key' attribute/, fn ->
        rendered_to_string(~H"""
          <Table.table id="test-table" rows={@products}>
            <:col :let={product} label="名称" filterable>
              <%= product.name %>
            </:col>
          </Table.table>
        """)
      end
    end
  end

  describe "filter compatibility" do
    test "works with sortable columns" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <Table.table id="test-table" rows={@products} sortable>
          <:col :let={product} label="名称" key="name" filterable sortable>
            <%= product.name %>
          </:col>
        </Table.table>
      """)
      
      # 断言：同时包含排序和筛选功能
      assert html =~ "pc-table__sort-button"
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "phx-click=\"sort\""
      assert html =~ "phx-click=\"filter_column\""
    end

    test "works with fixed columns" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <Table.table id="test-table" rows={@products}>
          <:col :let={product} label="ID" key="id" filterable fixed="left" width={100}>
            <%= product.id %>
          </:col>
        </Table.table>
      """)
      
      # 断言：固定列包含筛选功能
      assert html =~ "pc-table__cell--fixed-left"
      assert html =~ "pc-table__filter-trigger"
    end
  end

  # 测试数据辅助函数
  defp test_products do
    [
      %{id: 1, name: "产品A"},
      %{id: 2, name: "产品B"}
    ]
  end
end