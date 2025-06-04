defmodule ShopUxPhoenixWeb.Components.TableFilterTest do
  @moduledoc """
  表格筛选功能专项测试
  """
  use ShopUxPhoenixWeb.ComponentCase, async: true
  import Phoenix.LiveViewTest
  
  alias PetalComponents.Custom.Table, as: CustomTable

  describe "table/1 filter functionality" do
    test "renders filter icon when column is filterable" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <CustomTable.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="价格">
            <%= product.price %>
          </:col>
        </CustomTable.table>
      """)
      
      # 断言：可筛选列包含筛选图标
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "phx-click=\"filter_column\""
      assert html =~ "phx-value-column=\"name\""
      
      # 断言：不可筛选列不包含筛选图标
      refute html =~ "phx-value-column=\"price\""
    end

    test "does not render filter icon when filterable is false" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable={false}>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      refute html =~ "pc-table__filter-trigger"
    end

    test "does not render filter icon when filterable is not specified" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name">
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      refute html =~ "pc-table__filter-trigger"
    end

    test "renders custom filter icon when provided" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="状态" key="status" filterable filter_icon={~H"<span class=\"custom-icon\">F</span>"}>
            <%= product.status %>
          </:col>
        </.table>
      """)
      
      assert html =~ "custom-icon"
      assert html =~ ">F</span>"
      assert html =~ "pc-table__filter-trigger"
    end

    test "renders default filter icon when no custom icon provided" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：包含默认的 SVG 筛选图标
      assert html =~ "<svg"
      assert html =~ "fill-rule=\"evenodd\""
      assert html =~ "clip-rule=\"evenodd\""
    end
  end

  describe "filter state management" do
    test "applies filtered state to columns" do
      assigns = %{
        products: test_products(),
        filters: %{"name" => ["产品A"], "category" => ["电子"]}
      }
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="分类" key="category" filterable>
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" key="price" filterable>
            <%= product.price %>
          </:col>
        </.table>
      """)
      
      # 断言：已筛选的列有对应的CSS类
      assert html =~ ~r/phx-value-column="name".*?text-blue-600/s
      assert html =~ ~r/phx-value-column="category".*?text-blue-600/s
      
      # 断言：未筛选的列使用默认样式
      assert html =~ ~r/phx-value-column="price".*?text-gray-400/s
    end

    test "handles empty filters gracefully" do
      assigns = %{products: test_products(), filters: %{}}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：无筛选时使用默认样式
      assert html =~ "text-gray-400"
      refute html =~ "text-blue-600"
    end

    test "handles nil filters gracefully" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：组件正常渲染
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "text-gray-400"
    end

    test "handles filters with partial matches" do
      assigns = %{
        products: test_products(),
        filters: %{"name" => ["产品A"]}  # 只有 name 列有筛选
      }
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="分类" key="category" filterable>
            <%= product.category %>
          </:col>
        </.table>
      """)
      
      # 断言：只有有筛选的列显示已筛选状态
      assert html =~ ~r/phx-value-column="name".*?text-blue-600/s
      assert html =~ ~r/phx-value-column="category".*?text-gray-400/s
    end
  end

  describe "filter compatibility with other features" do
    test "works with sortable columns" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} sortable>
          <:col :let={product} label="名称" key="name" filterable sortable>
            <%= product.name %>
          </:col>
        </.table>
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
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="ID" key="id" filterable fixed="left" width={100}>
            <%= product.id %>
          </:col>
        </.table>
      """)
      
      # 断言：包含筛选功能（注意：core_components不支持固定列，只测试筛选功能）
      assert html =~ "pc-table__filter-trigger"
    end

    test "works with ellipsis columns" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="描述" key="description" filterable ellipsis width={200}>
            <%= product.description %>
          </:col>
        </.table>
      """)
      
      # 断言：包含筛选功能（注意：core_components不支持椭圆功能，只测试筛选功能）
      assert html =~ "pc-table__filter-trigger"
    end

    test "works with multiple features combined" do
      assigns = %{
        products: test_products(),
        filters: %{"name" => ["产品A"]}
      }
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} sortable filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable sortable fixed="left" ellipsis width={150}>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：排序和筛选功能都正常工作
      assert html =~ "pc-table__sort-button"
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "text-blue-600"  # 筛选状态
    end
  end

  describe "edge cases" do
    test "handles columns without key attribute for filterable columns" do
      assigns = %{products: test_products()}
      
      # 应该抛出错误，因为可筛选列必须有 key
      assert_raise ArgumentError, ~r/Filterable columns must have a 'key' attribute/, fn ->
        rendered_to_string(~H"""
          <.table id="test-table" rows={@products}>
            <:col :let={product} label="名称" filterable>
              <%= product.name %>
            </:col>
          </.table>
        """)
      end
    end

    test "handles columns with key but not filterable" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name">
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：有 key 但不是 filterable 的列不显示筛选图标
      refute html =~ "pc-table__filter-trigger"
    end

    test "handles empty data with filters" do
      assigns = %{products: [], filters: %{"name" => ["测试"]}}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：空数据时筛选图标仍然显示
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "text-blue-600"  # 筛选状态
      assert html =~ "暂无数据"
    end

    test "handles action column with filters" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
          <:action :let={product}>
            <button>编辑</button>
          </:action>
        </.table>
      """)
      
      # 断言：操作列不受筛选功能影响
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "<button>编辑</button>"
      refute html =~ ~r/操作.*pc-table__filter-trigger/s
    end

    test "handles very long filter values" do
      assigns = %{
        products: test_products(),
        filters: %{"description" => ["这是一个非常非常长的筛选值" <> String.duplicate("很长", 100)]}
      }
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="描述" key="description" filterable>
            <%= product.description %>
          </:col>
        </.table>
      """)
      
      # 断言：长筛选值不影响渲染
      assert html =~ "pc-table__filter-trigger"
      assert html =~ "text-blue-600"
    end
  end

  describe "accessibility" do
    test "filter button has proper accessibility attributes" do
      assigns = %{products: test_products()}
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：筛选按钮有适当的可访问性属性
      assert html =~ ~r/button.*type="button"/s
      assert html =~ ~r/title="筛选"/
      assert html =~ "pc-table__filter-trigger"
    end

    test "filter button has proper ARIA attributes for filtered state" do
      assigns = %{
        products: test_products(),
        filters: %{"name" => ["产品A"]}
      }
      
      html = rendered_to_string(~H"""
        <.table id="test-table" rows={@products} filters={@filters}>
          <:col :let={product} label="名称" key="name" filterable>
            <%= product.name %>
          </:col>
        </.table>
      """)
      
      # 断言：筛选状态有视觉指示
      assert html =~ "text-blue-600"
      assert html =~ "title=\"筛选\""
    end
  end

  # 测试数据辅助函数
  defp test_products do
    [
      %{
        id: 1, 
        name: "产品A", 
        category: "电子", 
        price: 100, 
        status: "在售", 
        description: "这是一个很长的产品描述，用来测试文本省略功能"
      },
      %{
        id: 2, 
        name: "产品B", 
        category: "服装", 
        price: 200, 
        status: "缺货", 
        description: "另一个产品的描述信息"
      },
      %{
        id: 3, 
        name: "产品C", 
        category: "电子", 
        price: 150, 
        status: "在售", 
        description: "第三个产品的详细描述"
      }
    ]
  end
end