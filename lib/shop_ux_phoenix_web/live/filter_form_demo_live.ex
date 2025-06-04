defmodule ShopUxPhoenixWeb.FilterFormDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.FilterForm
  
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "FilterForm 筛选表单组件")
     |> assign(:filter_values, %{})
     |> assign(:search_results, nil)
     |> assign(:filter_collapsed, false)
     |> assign(:loading, false)
     |> assign_options()}
  end
  
  def render(assigns) do
    ~H"""
    <div class="w-full px-4 sm:px-6 lg:px-8 py-8">
      <h1 class="text-2xl font-bold mb-6">FilterForm 筛选表单组件</h1>
      
      <div class="space-y-8">
        <!-- 基础筛选表单 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">基础筛选表单</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form
              id="basic-filter"
              fields={[
                %{name: "basic_search", type: "search", placeholder: "搜索订单号、商品名称", width: "300px"},
                %{name: "basic_status", label: "状态", type: "select", options: @status_options},
                %{name: "basic_date", label: "日期", type: "date"}
              ]}
              values={@filter_values}
              on_search="search"
              on_reset="reset"
            />
            
            <div :if={@search_results} class="mt-4 p-4 bg-gray-50 rounded">
              <h4 class="font-medium mb-2">搜索条件：</h4>
              <pre class="text-sm"><%= inspect(@search_results, pretty: true) %></pre>
            </div>
          </div>
        </section>
        
        <!-- 高级筛选表单 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">高级筛选表单</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form
              id="advanced-filter"
              fields={[
                %{name: "adv_keyword", label: "关键词", type: "input", placeholder: "输入关键词"},
                %{name: "adv_categories", label: "分类", type: "select", options: @category_options, props: %{mode: "multiple"}},
                %{name: "adv_brand", label: "品牌", type: "select", options: @brand_options},
                %{name: "adv_date_range", label: "日期范围", type: "date_range"},
                %{name: "adv_price_range", label: "价格范围", type: "number_range", placeholder: ["最低价", "最高价"]},
                %{name: "adv_in_stock", label: "仅显示有货", type: "checkbox"}
              ]}
              on_search="advanced_search"
              on_reset="reset"
            />
          </div>
        </section>
        
        <!-- 可折叠筛选表单 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">可折叠筛选表单</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form
              id="collapsible-filter"
              fields={[
                %{name: "coll_search", type: "search", placeholder: "搜索"},
                %{name: "coll_type", label: "类型", type: "select", options: @type_options},
                %{name: "coll_priority", label: "优先级", type: "select", options: @priority_options}
              ]}
              collapsible={true}
              collapsed={@filter_collapsed}
              on_toggle="toggle_filter"
              on_search="search"
              on_reset="reset"
              data-collapsible-filter
            />
          </div>
        </section>
        
        <!-- 响应式布局 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">响应式布局</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form
              id="responsive-filter"
              fields={[
                %{name: "field1", label: "字段1", type: "input"},
                %{name: "field2", label: "字段2", type: "select", options: @status_options},
                %{name: "field3", label: "字段3", type: "date"},
                %{name: "field4", label: "字段4", type: "input"},
                %{name: "field5", label: "字段5", type: "select", options: @type_options},
                %{name: "field6", label: "字段6", type: "checkbox"}
              ]}
              responsive={%{sm: 1, md: 2, lg: 3, xl: 4}}
              on_search="search"
              on_reset="reset"
            />
          </div>
        </section>
        
        <!-- 自定义操作按钮 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">自定义操作按钮</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form id="custom-actions-filter" fields={[
              %{name: "custom_search", type: "search", placeholder: "搜索内容"},
              %{name: "custom_status", label: "状态", type: "select", options: @status_options}
            ]}>
              <:actions>
                <.button type="submit" phx-click="search">
                  <.icon name="hero-magnifying-glass" class="w-4 h-4" />
                  搜索
                </.button>
                <.button phx-click="reset">重置</.button>
                <.button phx-click="export">
                  <.icon name="hero-arrow-down-tray" class="w-4 h-4" />
                  导出
                </.button>
              </:actions>
            </.filter_form>
          </div>
        </section>
        
        <!-- 树形选择示例 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">树形选择示例</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form
              id="tree-select-filter"
              fields={[
                %{name: "tree_department", label: "部门", type: "tree_select", options: @department_tree},
                %{name: "tree_region", label: "地区", type: "tree_select", options: @region_tree, props: %{multiple: true}}
              ]}
              on_search="search"
              on_reset="reset"
            />
          </div>
        </section>
        
        <!-- 验证示例 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">表单验证示例</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form
              id="validation-filter"
              fields={[
                %{name: "val_required_field", label: "必填字段", type: "input", required: true},
                %{name: "val_min_price", label: "最低价格", type: "number", props: %{min: 0}},
                %{name: "val_max_price", label: "最高价格", type: "number", props: %{min: 0}}
              ]}
              on_search="validate_search"
              on_reset="reset"
            />
          </div>
        </section>
        
        <!-- 加载状态 -->
        <section>
          <h2 class="text-xl font-semibold mb-4">加载状态示例</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.filter_form id="loading-filter" fields={[
              %{name: "load_search", type: "search", placeholder: "搜索"}
            ]}>
              <:actions>
                <.button
                  type="button"
                  phx-click="slow_search"
                  disabled={@loading}
                >
                  <%= if @loading do %>
                    <span data-loading>正在搜索...</span>
                  <% else %>
                    模拟慢速搜索
                  <% end %>
                </.button>
              </:actions>
            </.filter_form>
          </div>
        </section>
      </div>
    </div>
    """
  end
  
  def handle_event("search", %{"filters" => filters}, socket) do
    {:noreply,
     socket
     |> assign(:search_results, filters)
     |> put_flash(:info, "搜索条件已更新")}
  end
  
  def handle_event("search", _, socket) do
    {:noreply, put_flash(socket, :error, "请输入搜索条件")}
  end
  
  def handle_event("advanced_search", %{"filters" => filters}, socket) do
    {:noreply,
     socket
     |> assign(:search_results, filters)
     |> put_flash(:info, "高级搜索已执行")}
  end
  
  def handle_event("reset", _, socket) do
    {:noreply,
     socket
     |> assign(:filter_values, %{})
     |> assign(:search_results, nil)
     |> put_flash(:info, "筛选条件已重置")}
  end
  
  def handle_event("toggle_filter", _, socket) do
    {:noreply, update(socket, :filter_collapsed, &(!&1))}
  end
  
  def handle_event("export", %{"filters" => filters}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "正在导出数据... 筛选条件: #{inspect(filters)}")}
  end
  
  def handle_event("export", _, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "正在导出数据...")}
  end
  
  def handle_event("validate_search", %{"filters" => filters}, socket) do
    min_price = String.to_integer(filters["val_min_price"] || "0")
    max_price = String.to_integer(filters["val_max_price"] || "0")
    
    if min_price > 0 && max_price > 0 && max_price < min_price do
      {:noreply, put_flash(socket, :error, "最高价格不能小于最低价格")}
    else
      {:noreply,
       socket
       |> assign(:search_results, filters)
       |> put_flash(:info, "搜索成功")}
    end
  end
  
  def handle_event("slow_search", _, socket) do
    # 模拟异步搜索
    self = self()
    
    Task.start(fn ->
      Process.sleep(2000)
      send(self, :search_complete)
    end)
    
    {:noreply, assign(socket, :loading, true)}
  end
  
  def handle_event("search_change", %{"filters" => filters}, socket) do
    # 实时更新筛选值（可选）
    {:noreply, assign(socket, :filter_values, filters)}
  end
  
  def handle_info(:search_complete, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> put_flash(:info, "搜索完成")}
  end
  
  defp assign_options(socket) do
    socket
    |> assign(:status_options, [
      %{value: "active", label: "启用"},
      %{value: "inactive", label: "禁用"},
      %{value: "pending", label: "待审核"}
    ])
    |> assign(:category_options, [
      %{value: "electronics", label: "电子产品"},
      %{value: "clothing", label: "服装"},
      %{value: "food", label: "食品"},
      %{value: "books", label: "图书"}
    ])
    |> assign(:brand_options, [
      %{value: "apple", label: "Apple"},
      %{value: "samsung", label: "Samsung"},
      %{value: "huawei", label: "华为"},
      %{value: "xiaomi", label: "小米"}
    ])
    |> assign(:type_options, [
      %{value: "normal", label: "普通"},
      %{value: "urgent", label: "紧急"},
      %{value: "important", label: "重要"}
    ])
    |> assign(:priority_options, [
      %{value: "high", label: "高"},
      %{value: "medium", label: "中"},
      %{value: "low", label: "低"}
    ])
    |> assign(:department_tree, [
      %{
        value: "tech",
        label: "技术部",
        children: [
          %{value: "tech-dev", label: "开发组"},
          %{value: "tech-qa", label: "测试组"},
          %{value: "tech-ops", label: "运维组"}
        ]
      },
      %{
        value: "product",
        label: "产品部",
        children: [
          %{value: "product-design", label: "设计组"},
          %{value: "product-pm", label: "产品经理组"}
        ]
      }
    ])
    |> assign(:region_tree, [
      %{
        value: "china",
        label: "中国",
        children: [
          %{
            value: "beijing",
            label: "北京",
            children: [
              %{value: "chaoyang", label: "朝阳区"},
              %{value: "haidian", label: "海淀区"}
            ]
          },
          %{
            value: "shanghai",
            label: "上海",
            children: [
              %{value: "pudong", label: "浦东新区"},
              %{value: "huangpu", label: "黄浦区"}
            ]
          }
        ]
      }
    ])
  end
end