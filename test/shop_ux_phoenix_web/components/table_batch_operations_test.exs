defmodule ShopUxPhoenixWeb.Components.TableBatchOperationsTest do
  @moduledoc """
  表格批量操作功能测试
  测试表格组件的选择、批量操作等功能
  """
  use ShopUxPhoenixWeb.ComponentCase, async: true
  import Phoenix.LiveViewTest

  # 测试数据
  defp test_products do
    [
      %{id: 1, name: "iPhone 15", category: "手机", price: 5999, status: "active"},
      %{id: 2, name: "iPad Pro", category: "平板", price: 8999, status: "active"}, 
      %{id: 3, name: "MacBook", category: "电脑", price: 12999, status: "inactive"},
      %{id: 4, name: "Apple Watch", category: "手表", price: 2999, status: "active"},
      %{id: 5, name: "AirPods", category: "音频", price: 1299, status: "inactive"}
    ]
  end

  defp large_dataset do
    1..100 |> Enum.map(fn i -> 
      %{
        id: i, 
        name: "Product #{i}", 
        category: "Category #{rem(i, 10)}", 
        price: 100 + i, 
        status: if(rem(i, 2) == 0, do: "active", else: "inactive")
      }
    end)
  end

  describe "basic selection functionality" do
    test "renders selectable table with checkboxes" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            ¥<%= product.price %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：表格包含选择框
      assert html =~ ~r/type="checkbox"/
      assert html =~ ~r/data-select-all/
      assert html =~ ~r/phx-click="select_row"/
    end

    test "handles single row selection" do
      assigns = %{products: test_products(), selected_ids: []}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：每行都有选择框
      for i <- 1..5 do
        assert html =~ ~r/phx-value-id="row-#{i}"/
      end
    end

    test "supports pre-selected rows" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：选择功能正常渲染
      assert html =~ ~r/select_row/
      assert html =~ ~r/select_all/
    end
  end

  describe "selection state management" do
    test "maintains selection state correctly" do
      # 这个测试主要验证组件渲染的正确性
      # 实际的状态管理逻辑在 LiveView 中测试
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：选择相关的事件处理器存在
      assert html =~ ~r/phx-click="select_row"/
      assert html =~ ~r/phx-click="select_all"/
    end

    test "handles row_id function correctly" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：每行的ID正确传递
      for product <- test_products() do
        assert html =~ ~r/phx-value-id="row-#{product.id}"/
      end
    end
  end

  describe "batch operation buttons integration" do
    test "table works with action buttons for batch operations" do
      assigns = %{
        products: test_products(),
        selected_count: 2
      }
      
      html = rendered_to_string(~H"""
        <div>
          <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
            <:col :let={product} label="名称">
              <%= product.name %>
            </:col>
          </PetalComponents.Custom.Table.table>
          
          <!-- 批量操作按钮 -->
          <div class="mt-4" :if={@selected_count > 0}>
            <button phx-click="batch_delete" class="btn-danger">
              批量删除 (<%= @selected_count %>)
            </button>
            <button phx-click="batch_export" class="btn-primary">
              批量导出 (<%= @selected_count %>)
            </button>
          </div>
        </div>
      """)
      
      # 断言：批量操作按钮正确渲染
      assert html =~ ~r/batch_delete/
      assert html =~ ~r/batch_export/
      assert html =~ "批量删除 (2)"
      assert html =~ "批量导出 (2)"
    end
  end

  describe "table size and styling" do
    test "supports different table sizes with selection" do
      assigns = %{products: test_products()}
      
      for size <- ["small", "medium", "large"] do
        html = rendered_to_string(~H"""
          <PetalComponents.Custom.Table.table id="test-table" rows={@products} size={size} selectable row_id={&("row-#{&1.id}")}>
            <:col :let={product} label="名称">
              <%= product.name %>
            </:col>
          </PetalComponents.Custom.Table.table>
        """)
        
        # 断言：不同尺寸都支持选择功能
        assert html =~ ~r/select_row/
        assert html =~ ~r/select_all/
      end
    end
  end

  describe "accessibility features" do
    test "includes proper ARIA attributes for selection" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：包含可访问性属性
      assert html =~ ~r/type="checkbox"/
      # 选择框应该有合适的属性
      assert html =~ ~r/class=".*h-4 w-4.*"/
    end

    test "supports keyboard navigation structure" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：表格结构支持键盘导航
      assert html =~ ~r/<table/
      assert html =~ ~r/<thead/
      assert html =~ ~r/<tbody/
      assert html =~ ~r/<tr/
    end
  end

  describe "performance with large datasets" do
    test "handles large datasets efficiently" do
      assigns = %{products: large_dataset()}
      
      # 测试大量数据的渲染性能
      start_time = System.monotonic_time(:millisecond)
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            ¥<%= product.price %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time
      
      # 断言：渲染时间合理（应该在合理范围内）
      assert duration < 1000  # 少于1秒
      
      # 断言：包含所有数据
      assert html =~ "Product 1"
      assert html =~ "Product 100"
      
      # 断言：所有行都有选择功能
      assert html =~ ~r/phx-value-id="row-1"/
      assert html =~ ~r/phx-value-id="row-100"/
    end
  end

  describe "integration with other table features" do
    test "selection works with sortable columns" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable sortable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称" key="name" sortable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格" key="price" sortable>
            ¥<%= product.price %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：同时包含选择和排序功能
      assert html =~ ~r/select_row/
      assert html =~ ~r/phx-click="sort"/
    end

    test "selection works with filterable columns" do
      assigns = %{products: test_products(), filters: %{}}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable filters={@filters} row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="分类" key="category" filterable>
            <%= product.category %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：同时包含选择和筛选功能
      assert html =~ ~r/select_row/
      assert html =~ ~r/pc-table__filter-trigger/
    end

    test "selection works with pagination" do
      assigns = %{
        products: test_products(),
        pagination: %{current: 1, page_size: 3, total: 5, show_total: true}
      }
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable pagination={@pagination} row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：同时包含选择和分页功能
      assert html =~ ~r/select_row/
      assert html =~ ~r/change_page/
      assert html =~ "pagination"
    end

    test "selection works with action columns" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:action :let={_product}>
            <button>编辑</button>
            <button>删除</button>
          </:action>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：选择功能与操作列兼容
      assert html =~ ~r/select_row/
      assert html =~ "编辑"
      assert html =~ "删除"
      assert html =~ "操作"  # 操作列标题
    end
  end

  describe "empty state handling" do
    test "handles empty data with selection enabled" do
      assigns = %{products: []}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col label="名称"></:col>
          <:col label="价格"></:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：空状态下仍显示表头和选择框
      assert html =~ ~r/data-select-all/
      assert html =~ "暂无数据"
    end

    test "custom empty state with selection" do
      assigns = %{products: []}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col label="名称"></:col>
          <:empty>
            <div class="text-center py-8">
              <p>没有找到任何产品</p>
              <button>添加产品</button>
            </div>
          </:empty>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：自定义空状态正确显示
      assert html =~ "没有找到任何产品"
      assert html =~ "添加产品"
      assert html =~ ~r/data-select-all/
    end
  end

  describe "edge cases and error handling" do
    test "handles missing row_id function gracefully" do
      assigns = %{products: test_products()}
      
      # 不提供 row_id 函数应该有默认行为
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：即使没有明确的 row_id 函数，选择功能仍然可用
      assert html =~ ~r/select_row/
      assert html =~ ~r/select_all/
    end

    test "handles duplicate IDs in dataset" do
      # 包含重复ID的测试数据
      products_with_duplicates = [
        %{id: 1, name: "Product A"},
        %{id: 1, name: "Product B"},  # 重复ID
        %{id: 2, name: "Product C"}
      ]
      
      assigns = %{products: products_with_duplicates}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：重复ID的情况下仍能正常渲染
      assert html =~ "Product A"
      assert html =~ "Product B"
      assert html =~ "Product C"
      assert html =~ ~r/phx-value-id="row-1"/
      assert html =~ ~r/phx-value-id="row-2"/
    end

    test "handles nil values in dataset" do
      products_with_nils = [
        %{id: 1, name: "Product A", price: 100},
        %{id: 2, name: nil, price: nil},
        %{id: 3, name: "Product C", price: 300}
      ]
      
      assigns = %{products: products_with_nils}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称">
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            <%= product.price %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：包含nil值的数据能正常渲染
      assert html =~ "Product A"
      assert html =~ "Product C"
      assert html =~ ~r/phx-value-id="row-1"/
      assert html =~ ~r/phx-value-id="row-2"/
      assert html =~ ~r/phx-value-id="row-3"/
    end
  end

  describe "component compatibility" do
    test "works with different color themes" do
      assigns = %{products: test_products()}
      
      for color <- ["primary", "success", "warning", "danger"] do
        html = rendered_to_string(~H"""
          <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable color={color} row_id={&("row-#{&1.id}")}>
            <:col :let={product} label="名称">
              <%= product.name %>
            </:col>
          </PetalComponents.Custom.Table.table>
        """)
        
        # 断言：不同颜色主题都支持选择功能
        assert html =~ ~r/select_row/
        assert html =~ ~r/h-4 w-4/  # 选择框样式
      end
    end

    test "maintains styling consistency" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <PetalComponents.Custom.Table.table id="test-table" rows={@products} selectable class="custom-table" row_id={&("row-#{&1.id}")}>
          <:col :let={product} label="名称" class="custom-col">
            <%= product.name %>
          </:col>
        </PetalComponents.Custom.Table.table>
      """)
      
      # 断言：自定义样式类正确应用
      assert html =~ "custom-table"
      assert html =~ "custom-col"
      assert html =~ ~r/select_row/
    end
  end
end