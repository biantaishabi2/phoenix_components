defmodule ShopUxPhoenixWeb.Components.TableFixedColumnsTest do
  use ShopUxPhoenixWeb.ComponentCase, async: true
  
  alias PetalComponents.Custom.Table

  describe "table/1 with fixed columns" do
    test "renders left fixed column with correct CSS classes" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", description: "Long description", price: 100}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="left-fixed-table" rows={@products}>
          <:col :let={product} label="ID" fixed="left" width={80}>
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称" fixed="left" width={150}>
            <%= product.name %>
          </:col>
          <:col :let={product} label="描述">
            <%= product.description %>
          </:col>
          <:col :let={product} label="价格">
            <%= product.price %>
          </:col>
        </Table.table>
      """)
      
      # 检查固定列的 CSS 类
      assert html =~ "pc-table__cell--fixed-left"
      # 检查宽度和位置样式
      assert html =~ "width: 80px"
      assert html =~ "width: 150px"
      assert html =~ "left: 0px"
      assert html =~ "left: 80px"
    end

    test "renders right fixed column with correct CSS classes" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", price: 100, status: "active"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="right-fixed-table" rows={@products}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格" fixed="right" width={100}>
            <%= product.price %>
          </:col>
          <:col :let={product} label="状态" fixed="right" width={80}>
            <%= product.status %>
          </:col>
        </Table.table>
      """)
      
      # 检查右固定列的 CSS 类
      assert html =~ "pc-table__cell--fixed-right"
      # 检查宽度和位置样式
      assert html =~ "width: 100px"
      assert html =~ "width: 80px"
      assert html =~ "right: 0px"
    end

    test "renders mixed fixed columns (left and right)" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", description: "Description", price: 100, status: "active"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="mixed-fixed-table" rows={@products}>
          <:col :let={product} label="ID" fixed="left" width={60}>
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称" fixed="left" width={150}>
            <%= product.name %>
          </:col>
          <:col :let={product} label="描述">
            <%= product.description %>
          </:col>
          <:col :let={product} label="价格" fixed="right" width={100}>
            <%= product.price %>
          </:col>
          <:col :let={product} label="状态" fixed="right" width={80}>
            <%= product.status %>
          </:col>
        </Table.table>
      """)
      
      # 检查左固定列
      assert html =~ "pc-table__cell--fixed-left"
      # 检查右固定列
      assert html =~ "pc-table__cell--fixed-right"
      # 检查正常列（不应该有固定类）
      refute html =~ ~r/pc-table__cell--fixed-(left|right).*描述/
    end

    test "renders fixed action column" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", price: 100}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="fixed-action-table" rows={@products}>
          <:col :let={product} label="ID" fixed="left" width={60}>
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            <%= product.price %>
          </:col>
          <:action fixed="right" width={120}>
            <button>编辑</button>
            <button>删除</button>
          </:action>
        </Table.table>
      """)
      
      # 检查固定的操作列
      assert html =~ "pc-table__cell--fixed-right"
      assert html =~ "编辑"
      assert html =~ "删除"
    end

    test "fixed column with ellipsis" do
      assigns = %{
        products: [
          %{id: 1, name: "Product with very long name that should be truncated", price: 100}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="fixed-ellipsis-table" rows={@products}>
          <:col :let={product} label="名称" fixed="left" width={200} ellipsis>
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            <%= product.price %>
          </:col>
        </Table.table>
      """)
      
      # 检查固定列和省略号的组合
      assert html =~ "pc-table__cell--fixed-left"
      assert html =~ "pc-table__cell--ellipsis"
      assert html =~ "width: 200px"
    end

    test "fixed column with sortable" do
      assigns = %{
        products: [
          %{id: 2, name: "B Product", price: 200},
          %{id: 1, name: "A Product", price: 100}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="fixed-sortable-table" rows={@products} sortable>
          <:col :let={product} label="ID" key="id" fixed="left" width={80} sortable>
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称" key="name" sortable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格" key="price" fixed="right" width={100} sortable>
            <%= product.price %>
          </:col>
        </Table.table>
      """)
      
      # 检查固定列和排序功能的组合
      assert html =~ "pc-table__cell--fixed-left"
      assert html =~ "pc-table__cell--fixed-right"
      assert html =~ "sort-icon"
      assert html =~ ~s(phx-value-field="id")
      assert html =~ ~s(phx-value-field="price")
    end

    test "fixed column boundary classes" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", category: "Electronics", price: 100, status: "active"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="boundary-fixed-table" rows={@products}>
          <:col :let={product} label="ID" fixed="left" width={60}>
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称" fixed="left" width={150}>
            <%= product.name %>
          </:col>
          <:col :let={product} label="分类">
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" fixed="right" width={100}>
            <%= product.price %>
          </:col>
          <:col :let={product} label="状态" fixed="right" width={80}>
            <%= product.status %>
          </:col>
        </Table.table>
      """)
      
      # 检查边界类（需要在实现中添加）
      # 最后一个左固定列应该有 pc-table__cell--fixed-left-last
      # 第一个右固定列应该有 pc-table__cell--fixed-right-first
      # TODO: 这些类需要在实现时添加
    end

    test "fixed column without width should not be rendered as fixed" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", price: 100}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="no-width-fixed-table" rows={@products}>
          <:col :let={product} label="ID" fixed="left">
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            <%= product.price %>
          </:col>
        </Table.table>
      """)
      
      # 没有设置 width 的固定列不应该渲染固定效果
      # TODO: 实现时需要决定是否忽略没有 width 的 fixed 属性
      refute html =~ "pc-table__cell--fixed-left"
    end

    test "table with many fixed columns" do
      assigns = %{
        data: [
          %{
            id: 1,
            col1: "A1", col2: "B1", col3: "C1", col4: "D1", col5: "E1",
            col6: "F1", col7: "G1", col8: "H1", col9: "I1", col10: "J1"
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="many-fixed-table" rows={@data}>
          <:col :let={item} label="Col1" fixed="left" width={60}>
            <%= item.col1 %>
          </:col>
          <:col :let={item} label="Col2" fixed="left" width={60}>
            <%= item.col2 %>
          </:col>
          <:col :let={item} label="Col3" fixed="left" width={60}>
            <%= item.col3 %>
          </:col>
          <:col :let={item} label="Col4"><%= item.col4 %></:col>
          <:col :let={item} label="Col5"><%= item.col5 %></:col>
          <:col :let={item} label="Col6"><%= item.col6 %></:col>
          <:col :let={item} label="Col7"><%= item.col7 %></:col>
          <:col :let={item} label="Col8" fixed="right" width={60}>
            <%= item.col8 %>
          </:col>
          <:col :let={item} label="Col9" fixed="right" width={60}>
            <%= item.col9 %>
          </:col>
          <:col :let={item} label="Col10" fixed="right" width={60}>
            <%= item.col10 %>
          </:col>
        </Table.table>
      """)
      
      # 检查多个固定列
      fixed_left_count = length(String.split(html, "pc-table__cell--fixed-left")) - 1
      fixed_right_count = length(String.split(html, "pc-table__cell--fixed-right")) - 1
      
      # 应该有 3 个左固定列
      assert fixed_left_count >= 3
      # 应该有 3 个右固定列
      assert fixed_right_count >= 3
    end

    test "fixed column position calculation" do
      assigns = %{
        products: [
          %{id: 1, name: "Product 1", category: "Electronics", price: 100}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Table.table id="position-fixed-table" rows={@products}>
          <:col :let={product} label="ID" fixed="left" width={80}>
            <%= product.id %>
          </:col>
          <:col :let={product} label="名称" fixed="left" width={150}>
            <%= product.name %>
          </:col>
          <:col :let={product} label="分类">
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" fixed="right" width={100}>
            <%= product.price %>
          </:col>
        </Table.table>
      """)
      
      # TODO: 检查位置计算样式
      # 第一个左固定列应该有 left: 0px
      # 第二个左固定列应该有 left: 80px
      # 右固定列应该有 right: 0px
    end
  end
end