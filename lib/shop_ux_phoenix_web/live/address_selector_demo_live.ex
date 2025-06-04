defmodule ShopUxPhoenixWeb.AddressSelectorDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.AddressSelector

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "AddressSelector 地址选择器组件")
     |> assign(:basic_address, [])
     |> assign(:detail_address, "")
     |> assign(:form_address, [])
     |> assign(:form_detail, "")
     |> assign(:searchable_address, [])
     |> assign(:clearable_address, ["110000", "110100", "110101"])
     |> assign(:loading, false)
     |> assign(:custom_address, [])
     |> assign(:search_keyword, "")
     |> assign(:validation_errors, %{})
     |> assign(:custom_locations, get_custom_locations())}
  end

  def handle_event("select_address", %{"code" => code, "label" => label, "level" => level}, socket) do
    IO.puts("Address selected: #{level} - #{code} (#{label})")
    
    # 这里需要根据不同的选择器来更新对应的值
    # 简化版本，实际应该根据 target 参数区分
    current_value = socket.assigns.basic_address
    
    new_value = case level do
      "province" -> [code]
      "city" -> [List.first(current_value), code]
      "district" -> [List.first(current_value), Enum.at(current_value, 1), code]
      _ -> current_value
    end
    
    {:noreply, assign(socket, :basic_address, new_value)}
  end

  def handle_event("toggle_dropdown", params, socket) do
    IO.puts("Toggle dropdown: #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event("clear_address", params, socket) do
    IO.puts("Clear address: #{inspect(params)}")
    # Simple implementation - in real app would handle multiple selectors
    {:noreply, assign(socket, :clearable_address, [])}
  end

  def handle_event("address_changed", params, socket) do
    IO.inspect(params, label: "Address changed")
    {:noreply, socket}
  end

  def handle_event("detail_changed", params, socket) do
    detail = params["value"] || params["detail"] || ""
    {:noreply, assign(socket, :detail_address, detail)}
  end

  def handle_event("search_address", %{"value" => keyword}, socket) do
    {:noreply, assign(socket, :search_keyword, keyword)}
  end

  def handle_event("save_address", params, socket) do
    IO.inspect(params, label: "Save address")
    
    # 简单的验证示例
    errors = %{}
    errors = if socket.assigns.form_address == [], do: Map.put(errors, :address, "请选择地址"), else: errors
    
    if errors == %{} do
      {:noreply,
       socket
       |> put_flash(:info, "地址保存成功！")
       |> assign(:validation_errors, %{})}
    else
      {:noreply, assign(socket, :validation_errors, errors)}
    end
  end

  def handle_event("load_async_data", _params, socket) do
    send(self(), :finish_loading)
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_info(:finish_loading, socket) do
    {:noreply, assign(socket, :loading, false)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 w-full">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">AddressSelector 地址选择器组件</h1>
      
      <!-- 基础用法 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础用法</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">选择地址</label>
              <.address_selector 
                data-testid="basic-selector"
                value={@basic_address}
              />
              <%= if @basic_address != [] do %>
                <p class="mt-2 text-sm text-gray-600">
                  已选择：<%= Enum.join(@basic_address, " / ") %>
                </p>
              <% end %>
            </div>
          </div>
        </div>
      </section>

      <!-- 带详细地址 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">带详细地址</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">地址信息</label>
              <.address_selector 
                show_detail={true}
                detail_value={@detail_address}
                detail_placeholder="请输入街道、门牌号等详细地址"
                data-testid="detail-input"
              />
              <%= if @detail_address != "" do %>
                <p class="mt-2 text-sm text-gray-600">
                  详细地址：<%= @detail_address %>
                </p>
              <% end %>
            </div>
          </div>
        </div>
      </section>

      <!-- 不同尺寸 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">不同尺寸</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">小尺寸</label>
              <.address_selector size="small" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">默认尺寸</label>
              <.address_selector size="medium" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">大尺寸</label>
              <.address_selector size="large" />
            </div>
          </div>
        </div>
      </section>

      <!-- 禁用状态 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">禁用状态</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">禁用选择器</label>
              <.address_selector 
                disabled={true}
                value={["110000", "110100", "110101"]}
                data-testid="disabled-selector"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">禁用带详细地址</label>
              <.address_selector 
                disabled={true}
                show_detail={true}
                detail_value="朝阳门街道1号"
              />
            </div>
          </div>
        </div>
      </section>

      <!-- 可清除 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">可清除</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">带清除按钮</label>
            <.address_selector 
              value={@clearable_address}
              clearable={true}
              data-testid="clearable-selector"
            />
            <p class="mt-2 text-sm text-gray-500">
              选择器有值时会显示清除按钮
            </p>
          </div>
        </div>
      </section>

      <!-- 搜索功能 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">搜索功能</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">可搜索选择器</label>
            <.address_selector 
              searchable={true}
              value={@searchable_address}
              data-testid="searchable-selector"
            />
            <%= if @search_keyword != "" do %>
              <p class="mt-2 text-sm text-gray-600">
                搜索关键词：<%= @search_keyword %>
              </p>
            <% end %>
          </div>
        </div>
      </section>

      <!-- 自定义数据源 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">自定义数据源</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">自定义地区数据</label>
            <.address_selector 
              options={@custom_locations}
              value={@custom_address}
              data-testid="custom-data-selector"
            />
            <p class="mt-2 text-sm text-gray-500">
              使用自定义的地区数据源
            </p>
          </div>
        </div>
      </section>

      <!-- 加载状态 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">加载状态</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="space-y-4">
            <div>
              <.button phx-click="load_async_data">
                模拟异步加载
              </.button>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">加载中的选择器</label>
              <.address_selector loading={@loading} />
            </div>
          </div>
        </div>
      </section>

      <!-- 表单验证 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">表单验证</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <form phx-submit="save_address">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  地址 <span class="text-red-500">*</span>
                </label>
                <.address_selector 
                  name="address"
                  value={@form_address}
                  required={true}
                  error={@validation_errors[:address]}
                  />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">详细地址</label>
                <input
                  type="text"
                  name="detail"
                  value={@form_detail}
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  placeholder="请输入详细地址"
                />
              </div>
              
              <div>
                <.button type="submit">
                  保存地址
                </.button>
              </div>
            </div>
          </form>
        </div>
      </section>

      <!-- 错误状态 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">错误状态</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">有错误的选择器</label>
            <.address_selector 
              error="请选择完整的地址信息"
              required={true}
            />
          </div>
        </div>
      </section>

      <!-- 使用示例代码 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">使用示例</h2>
        <div class="bg-gray-100 p-6 rounded-lg">
          <h3 class="text-lg font-medium mb-3">基础用法</h3>
          <pre class="text-sm text-gray-800 overflow-x-auto"><code>&lt;.address_selector 
            value={@basic_address}
            phx-change="address_changed"
          /&gt;</code></pre>
          
          <h3 class="text-lg font-medium mb-3 mt-6">带详细地址</h3>
          <pre class="text-sm text-gray-800 overflow-x-auto"><code>&lt;.address_selector 
            show_detail={true}
            detail_value={@detail_address}
            required={true}
          /&gt;</code></pre>
        </div>
      </section>
    </div>
    """
  end

  defp get_custom_locations do
    [
      %{
        value: "test001",
        label: "测试省份",
        children: [
          %{
            value: "test002",
            label: "测试城市",
            children: [
              %{value: "test003", label: "测试区县1"},
              %{value: "test004", label: "测试区县2"}
            ]
          }
        ]
      },
      %{
        value: "demo001",
        label: "演示省份",
        children: [
          %{
            value: "demo002",
            label: "演示城市",
            children: [
              %{value: "demo003", label: "演示区县"}
            ]
          }
        ]
      }
    ]
  end
end