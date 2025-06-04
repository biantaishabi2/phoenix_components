defmodule ShopUxPhoenixWeb.TableDemoLive do
  use ShopUxPhoenixWeb, :live_view
  alias ShopUxPhoenixWeb.Components.Table.BatchOperations

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       products: [
         %{
           id: 1, 
           name: "iPhone 15 Pro Max", 
           description: "This is a very long product description that demonstrates the text ellipsis functionality in table cells. It contains detailed information about the product features and specifications.",
           price: 1299,
           category: "Smartphones",
           status: "active",
           stock: 120,
           created_at: ~D[2024-01-15]
         },
         %{
           id: 2, 
           name: "MacBook Pro 16-inch", 
           description: "Another detailed product description with comprehensive information about the laptop's capabilities, performance metrics, and technical specifications.",
           price: 2499,
           category: "Laptops",
           status: "active",
           stock: 45,
           created_at: ~D[2024-01-10]
         },
         %{
           id: 3, 
           name: "iPad Pro", 
           description: "Professional tablet with advanced features for creative professionals and power users who need maximum performance.",
           price: 1099,
           category: "Tablets",
           status: "inactive",
           stock: 0,
           created_at: ~D[2024-01-05]
         },
         %{
           id: 4, 
           name: "Apple Watch Ultra", 
           description: "Premium smartwatch designed for extreme conditions and professional athletes with extended battery life.",
           price: 799,
           category: "Wearables",
           status: "active",
           stock: 200,
           created_at: ~D[2024-01-20]
         },
         %{
           id: 5, 
           name: "AirPods Pro", 
           description: "Premium wireless earbuds with active noise cancellation and spatial audio support.",
           price: 249,
           category: "Audio",
           status: "active",
           stock: 500,
           created_at: ~D[2024-01-18]
         },
         %{
           id: 6, 
           name: "Mac Studio", 
           description: "High-performance desktop computer for professionals requiring maximum computing power.",
           price: 1999,
           category: "Desktops",
           status: "active",
           stock: 30,
           created_at: ~D[2024-01-12]
         }
       ],
       selected_ids: [],
       pagination: %{current: 1, page_size: 10, total: 30, show_total: true},
       sort_by: nil,
       sort_order: nil,
       filters: %{},
       batch_operation: nil,
       # 批量操作配置
       batch_operations: [
         %{key: "delete", label: "删除", color: "danger", confirm: true, icon: "hero-trash"},
         %{key: "export", label: "导出", color: "primary", icon: "hero-arrow-down-tray"},
         %{key: "archive", label: "归档", color: "warning", icon: "hero-archive-box"}
       ]
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 space-y-8">
      <div>
        <h1 class="text-2xl font-bold mb-4">Table 组件演示</h1>
        <p class="text-gray-600 mb-6">展示列宽控制和文本省略功能</p>
      </div>

      <!-- 状态信息 -->
      <div class="bg-gray-100 p-4 rounded-lg">
        <p id="selection-info" class="text-sm">选中: <%= length(@selected_ids) %> 项</p>
        <p id="page-info" class="text-sm">当前页: <%= @pagination.current %></p>
        <p id="sort-info" class="text-sm">排序: <%= @sort_by %> <%= @sort_order %></p>
        <p id="filter-info" class="text-sm">筛选: <%= inspect(@filters) %></p>
      </div>

      <!-- 基础表格演示 -->
      <div>
        <h2 class="text-xl font-semibold mb-4">基础表格 - 批量操作演示</h2>
        
        <!-- 批量操作反馈 -->
        <BatchOperations.operation_feedback 
          batch_operation={@batch_operation} />
        
        <!-- 批量操作栏 -->
        <BatchOperations.batch_action_bar 
          selected_count={length(@selected_ids)}
          total_count={length(@products)}
          batch_operations={@batch_operations}
          batch_operation={@batch_operation} />
        
        <PetalComponents.Custom.Table.table 
          id="basic-table"
          rows={@products}
          selectable
          row_id={&(&1.id)}
          sortable
          filters={@filters}>
          <:col :let={product} label="商品名称" key="name" sortable filterable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="分类" key="category" filterable>
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" key="price" sortable>
            ¥<%= product.price %>
          </:col>
          <:col :let={product} label="状态">
            <span class={[
              "px-2 py-1 text-xs rounded-full",
              product.status == "active" && "bg-green-100 text-green-800",
              product.status == "inactive" && "bg-red-100 text-red-800"
            ]}>
              <%= if product.status == "active", do: "活跃", else: "停用" %>
            </span>
          </:col>
          <:action>
            <button class="text-blue-600 hover:text-blue-800 text-sm">编辑</button>
            <button class="text-red-600 hover:text-red-800 text-sm ml-2">删除</button>
          </:action>
        </PetalComponents.Custom.Table.table>
      </div>

      <!-- 列宽控制演示 -->
      <div>
        <h2 class="text-xl font-semibold mb-4">列宽控制演示</h2>
        <p class="text-gray-600 mb-4">演示固定宽度、百分比宽度和响应式宽度的使用</p>
        <PetalComponents.Custom.Table.table 
          id="width-demo-table"
          rows={@products}>
          <:col :let={product} label="ID" width={60}>
            <%= product.id %>
          </:col>
          <:col :let={product} label="商品名称" width={200}>
            <%= product.name %>
          </:col>
          <:col :let={product} label="商品描述" width="40%">
            <%= product.description %>
          </:col>
          <:col :let={product} label="分类" width={120}>
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" width={100}>
            ¥<%= product.price %>
          </:col>
          <:action width={150}>
            <button class="text-blue-600 hover:text-blue-800 text-sm">操作</button>
          </:action>
        </PetalComponents.Custom.Table.table>
      </div>

      <!-- 文本省略演示 -->
      <div>
        <h2 class="text-xl font-semibold mb-4">文本省略演示</h2>
        <p class="text-gray-600 mb-4">演示长文本的省略显示效果</p>
        <PetalComponents.Custom.Table.table 
          id="ellipsis-demo-table"
          rows={@products}>
          <:col :let={product} label="商品名称" width={150} ellipsis>
            <%= product.name %>
          </:col>
          <:col :let={product} label="详细描述" width={300} ellipsis>
            <%= product.description %>
          </:col>
          <:col :let={product} label="分类" width={100}>
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" width={80}>
            ¥<%= product.price %>
          </:col>
        </PetalComponents.Custom.Table.table>
      </div>

      <!-- 响应式宽度演示 -->
      <div>
        <h2 class="text-xl font-semibold mb-4">响应式宽度演示</h2>
        <p class="text-gray-600 mb-4">演示 min-width 和 max-width 的响应式效果</p>
        <PetalComponents.Custom.Table.table 
          id="responsive-demo-table"
          rows={@products}>
          <:col :let={product} label="商品名称" min_width={150} max_width={250}>
            <%= product.name %>
          </:col>
          <:col :let={product} label="商品描述" min_width={200} ellipsis>
            <%= product.description %>
          </:col>
          <:col :let={product} label="分类" width={120}>
            <%= product.category %>
          </:col>
          <:col :let={product} label="价格" width={100}>
            ¥<%= product.price %>
          </:col>
        </PetalComponents.Custom.Table.table>
      </div>

      <!-- 固定列演示 -->
      <div>
        <h2 class="text-xl font-semibold mb-4">固定列演示</h2>
        <p class="text-gray-600 mb-4">演示左右固定列功能，适用于横向滚动的大表格</p>
        
        <!-- 左固定列演示 -->
        <div class="mb-8">
          <h3 class="text-lg font-semibold mb-3">左固定列</h3>
          <p class="text-gray-600 mb-3">ID 和商品名称固定在左侧</p>
          <div class="overflow-hidden border border-gray-200 rounded-lg">
            <PetalComponents.Custom.Table.table 
              id="left-fixed-table"
              rows={@products}>
              <:col :let={product} label="ID" fixed="left" width={60}>
                <%= product.id %>
              </:col>
              <:col :let={product} label="商品名称" fixed="left" width={180}>
                <%= product.name %>
              </:col>
              <:col :let={product} label="商品描述" width={300}>
                <%= product.description %>
              </:col>
              <:col :let={product} label="分类" width={120}>
                <%= product.category %>
              </:col>
              <:col :let={product} label="库存" width={80}>
                <%= product.stock %>
              </:col>
              <:col :let={product} label="创建时间" width={120}>
                <%= product.created_at %>
              </:col>
              <:col :let={product} label="价格" width={100}>
                ¥<%= product.price %>
              </:col>
              <:col :let={product} label="状态" width={80}>
                <span class={[
                  "px-2 py-1 text-xs rounded-full",
                  product.status == "active" && "bg-green-100 text-green-800",
                  product.status == "inactive" && "bg-red-100 text-red-800"
                ]}>
                  <%= if product.status == "active", do: "活跃", else: "停用" %>
                </span>
              </:col>
            </PetalComponents.Custom.Table.table>
          </div>
        </div>

        <!-- 右固定列演示 -->
        <div class="mb-8">
          <h3 class="text-lg font-semibold mb-3">右固定列</h3>
          <p class="text-gray-600 mb-3">价格和操作列固定在右侧</p>
          <div class="overflow-hidden border border-gray-200 rounded-lg">
            <PetalComponents.Custom.Table.table 
              id="right-fixed-table"
              rows={@products}>
              <:col :let={product} label="ID" width={60}>
                <%= product.id %>
              </:col>
              <:col :let={product} label="商品名称" width={200}>
                <%= product.name %>
              </:col>
              <:col :let={product} label="商品描述" width={350}>
                <%= product.description %>
              </:col>
              <:col :let={product} label="分类" width={120}>
                <%= product.category %>
              </:col>
              <:col :let={product} label="库存" width={80}>
                <%= product.stock %>
              </:col>
              <:col :let={product} label="价格" fixed="right" width={100}>
                ¥<%= product.price %>
              </:col>
              <:action fixed="right" width={120}>
                <button class="text-blue-600 hover:text-blue-800 text-sm">编辑</button>
                <button class="text-red-600 hover:text-red-800 text-sm ml-2">删除</button>
              </:action>
            </PetalComponents.Custom.Table.table>
          </div>
        </div>

        <!-- 左右固定列组合演示 -->
        <div class="mb-8">
          <h3 class="text-lg font-semibold mb-3">左右固定列组合</h3>
          <p class="text-gray-600 mb-3">ID和名称固定在左侧，价格、状态和操作固定在右侧</p>
          <div class="overflow-hidden border border-gray-200 rounded-lg">
            <PetalComponents.Custom.Table.table 
              id="mixed-fixed-table"
              rows={@products}
              selectable
              sortable>
              <:col :let={product} label="ID" key="id" fixed="left" width={60} sortable>
                <%= product.id %>
              </:col>
              <:col :let={product} label="商品名称" key="name" fixed="left" width={180} ellipsis sortable>
                <%= product.name %>
              </:col>
              <:col :let={product} label="商品描述" width={300} ellipsis>
                <%= product.description %>
              </:col>
              <:col :let={product} label="分类" key="category" width={120} sortable>
                <%= product.category %>
              </:col>
              <:col :let={product} label="库存" key="stock" width={80} sortable>
                <%= product.stock %>
              </:col>
              <:col :let={product} label="创建时间" width={120}>
                <%= product.created_at %>
              </:col>
              <:col :let={product} label="价格" key="price" fixed="right" width={100} sortable>
                ¥<%= product.price %>
              </:col>
              <:col :let={product} label="状态" fixed="right" width={80}>
                <span class={[
                  "px-2 py-1 text-xs rounded-full",
                  product.status == "active" && "bg-green-100 text-green-800",
                  product.status == "inactive" && "bg-red-100 text-red-800"
                ]}>
                  <%= if product.status == "active", do: "活跃", else: "停用" %>
                </span>
              </:col>
              <:action fixed="right" width={150}>
                <button class="text-blue-600 hover:text-blue-800 text-sm">编辑</button>
                <button class="text-red-600 hover:text-red-800 text-sm ml-2">删除</button>
              </:action>
            </PetalComponents.Custom.Table.table>
          </div>
        </div>
      </div>

      <!-- 完整功能演示 -->
      <div>
        <h2 class="text-xl font-semibold mb-4">完整功能演示</h2>
        <p class="text-gray-600 mb-4">结合选择、排序、分页、列宽、省略和固定列功能</p>
        <PetalComponents.Custom.Table.table 
          id="full-feature-table"
          rows={@products}
          selectable
          row_id={&(&1.id)}
          pagination={@pagination}
          sortable>
          <:col :let={product} label="ID" key="id" fixed="left" width={60} sortable>
            <%= product.id %>
          </:col>
          <:col :let={product} label="商品名称" key="name" fixed="left" width={180} ellipsis sortable>
            <%= product.name %>
          </:col>
          <:col :let={product} label="商品描述" width={250} ellipsis>
            <%= product.description %>
          </:col>
          <:col :let={product} label="分类" key="category" sortable width={120}>
            <%= product.category %>
          </:col>
          <:col :let={product} label="库存" key="stock" sortable width={80}>
            <%= product.stock %>
          </:col>
          <:col :let={product} label="价格" key="price" fixed="right" width={100} sortable>
            ¥<%= product.price %>
          </:col>
          <:col :let={product} label="状态" fixed="right" width={80}>
            <span class={[
              "px-2 py-1 text-xs rounded-full",
              product.status == "active" && "bg-green-100 text-green-800",
              product.status == "inactive" && "bg-red-100 text-red-800"
            ]}>
              <%= if product.status == "active", do: "活跃", else: "停用" %>
            </span>
          </:col>
          <:action fixed="right" width={150} ellipsis>
            <button class="text-blue-600 hover:text-blue-800 text-sm mr-2">编辑商品信息</button>
            <button class="text-red-600 hover:text-red-800 text-sm">删除商品</button>
          </:action>
        </PetalComponents.Custom.Table.table>
      </div>
    </div>
    """
  end

  def handle_event("change_page", %{"page" => page}, socket) do
    pagination = %{socket.assigns.pagination | current: String.to_integer(page)}
    {:noreply, assign(socket, pagination: pagination)}
  end

  def handle_event("sort", %{"field" => field}, socket) do
    {sort_by, sort_order} = 
      if socket.assigns.sort_by == field do
        {field, if(socket.assigns.sort_order == "asc", do: "desc", else: "asc")}
      else
        {field, "asc"}
      end
    
    {:noreply, assign(socket, sort_by: sort_by, sort_order: sort_order)}
  end

  def handle_event("filter_column", %{"column" => column_key}, socket) do
    # 简单的筛选切换逻辑：如果已筛选则取消，否则添加预设筛选
    current_filters = socket.assigns.filters
    
    new_filters = 
      if Map.has_key?(current_filters, column_key) do
        # 取消筛选
        Map.delete(current_filters, column_key)
      else
        # 添加预设筛选值
        filter_values = get_filter_values(column_key)
        Map.put(current_filters, column_key, filter_values)
      end
    
    {:noreply, assign(socket, filters: new_filters)}
  end

  # 批量操作事件处理
  def handle_event("select_row", %{"id" => id}, socket) do
    id = String.to_integer(id)
    selected_ids = 
      if id in socket.assigns.selected_ids do
        List.delete(socket.assigns.selected_ids, id)
      else
        [id | socket.assigns.selected_ids]
      end
    
    {:noreply, assign(socket, selected_ids: selected_ids)}
  end

  def handle_event("select_all", _params, socket) do
    current_page_ids = Enum.map(socket.assigns.products, & &1.id)
    
    selected_ids = 
      if length(socket.assigns.selected_ids) == length(current_page_ids) &&
         Enum.all?(current_page_ids, &(&1 in socket.assigns.selected_ids)) do
        # 当前页全选 -> 取消全选
        socket.assigns.selected_ids -- current_page_ids
      else
        # 未全选 -> 全选当前页
        (socket.assigns.selected_ids ++ current_page_ids) |> Enum.uniq()
      end
    
    {:noreply, assign(socket, selected_ids: selected_ids)}
  end

  def handle_event("clear_selection", _params, socket) do
    {:noreply, assign(socket, selected_ids: [])}
  end

  def handle_event("batch_delete", _params, socket) do
    selected_count = length(socket.assigns.selected_ids)
    
    if selected_count > 0 do
      # 模拟批量删除操作
      socket = assign(socket, batch_operation: %{
        type: "delete",
        status: :processing,
        progress: 0,
        message: "正在删除 #{selected_count} 项...",
        cancelable: true
      })
      
      # 模拟异步处理
      Process.send_after(self(), {:batch_delete_progress, 0}, 100)
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("batch_export", _params, socket) do
    selected_count = length(socket.assigns.selected_ids)
    
    if selected_count > 0 do
      # 模拟批量导出操作
      socket = assign(socket, batch_operation: %{
        type: "export", 
        status: :processing,
        progress: 0,
        message: "正在导出 #{selected_count} 项...",
        cancelable: false
      })
      
      # 模拟异步处理
      Process.send_after(self(), {:batch_export_progress, 0}, 200)
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("batch_archive", _params, socket) do
    selected_count = length(socket.assigns.selected_ids)
    
    if selected_count > 0 do
      # 模拟批量归档操作
      _selected_items = Enum.filter(socket.assigns.products, &(&1.id in socket.assigns.selected_ids))
      
      # 直接完成操作（不需要进度条）
      socket = 
        socket
        |> assign(batch_operation: %{
          type: "archive",
          status: :completed,
          progress: 100,
          message: "成功归档 #{selected_count} 项"
        })
        |> assign(selected_ids: [])
      
      # 3秒后自动清除提示
      Process.send_after(self(), :clear_feedback, 3000)
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("cancel_batch_operation", _params, socket) do
    socket = assign(socket, batch_operation: %{
      type: nil,
      status: :cancelled,
      progress: 0,
      message: "操作已取消"
    })
    
    Process.send_after(self(), :clear_feedback, 2000)
    
    {:noreply, socket}
  end

  def handle_event("dismiss_feedback", _params, socket) do
    {:noreply, assign(socket, batch_operation: nil)}
  end

  # 处理异步消息
  def handle_info({:batch_delete_progress, progress}, socket) do
    if socket.assigns.batch_operation && socket.assigns.batch_operation.status == :processing do
      new_progress = progress + 20
      
      if new_progress >= 100 do
        # 完成删除操作
        remaining_products = Enum.reject(socket.assigns.products, &(&1.id in socket.assigns.selected_ids))
        deleted_count = length(socket.assigns.selected_ids)
        
        socket = 
          socket
          |> assign(products: remaining_products)
          |> assign(selected_ids: [])
          |> assign(batch_operation: %{
            type: "delete",
            status: :completed,
            progress: 100,
            message: "成功删除 #{deleted_count} 项"
          })
        
        # 3秒后清除提示
        Process.send_after(self(), :clear_feedback, 3000)
        
        {:noreply, socket}
      else
        # 更新进度
        socket = assign(socket, batch_operation: %{
          socket.assigns.batch_operation | 
          progress: new_progress,
          message: "正在删除... #{new_progress}%"
        })
        
        # 继续进度更新
        Process.send_after(self(), {:batch_delete_progress, new_progress}, 100)
        
        {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info({:batch_export_progress, progress}, socket) do
    if socket.assigns.batch_operation && socket.assigns.batch_operation.status == :processing do
      new_progress = progress + 25
      
      if new_progress >= 100 do
        # 完成导出操作
        export_count = length(socket.assigns.selected_ids)
        
        socket = 
          socket
          |> assign(selected_ids: [])
          |> assign(batch_operation: %{
            type: "export",
            status: :completed,
            progress: 100,
            message: "成功导出 #{export_count} 项",
            download_url: "/downloads/export_#{:rand.uniform(1000)}.csv"
          })
        
        # 5秒后清除提示
        Process.send_after(self(), :clear_feedback, 5000)
        
        {:noreply, socket}
      else
        # 更新进度
        socket = assign(socket, batch_operation: %{
          socket.assigns.batch_operation | 
          progress: new_progress,
          message: "正在导出... #{new_progress}%"
        })
        
        # 继续进度更新
        Process.send_after(self(), {:batch_export_progress, new_progress}, 200)
        
        {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info(:clear_feedback, socket) do
    {:noreply, assign(socket, batch_operation: nil)}
  end

  # 获取不同列的预设筛选值
  defp get_filter_values("name"), do: ["iPhone 15 Pro Max", "MacBook Pro 16-inch"]
  defp get_filter_values("category"), do: ["Smartphones", "Laptops"]
  defp get_filter_values("status"), do: ["active"]
  defp get_filter_values(_), do: []
end