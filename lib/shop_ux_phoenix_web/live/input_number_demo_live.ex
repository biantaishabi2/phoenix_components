defmodule ShopUxPhoenixWeb.InputNumberDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.InputNumber
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "InputNumber 组件")
     |> assign(:basic_value, 1)
     |> assign(:price_value, 99.99)
     |> assign(:age_value, 18)
     |> assign(:rate_value, 0.5)
     |> assign(:score_value, 60)
     |> assign(:currency_value, 1000)
     |> assign(:percent_value, 50)
     |> assign(:weight_value, 50)
     |> assign(:temperature_value, 25)
     |> assign(:quantity_value, 1)
     |> assign(:stock, 100)
     |> assign(:min_price, 0)
     |> assign(:max_price, 1000)
     |> assign(:form_submitted, false)
     |> assign(:form_data, %{
       "price" => 99.99,
       "stock" => 100,
       "discount" => 10
     })
     |> assign(:selected_province, nil)
     |> assign(:selected_city, nil)
     |> assign(:precision_test_value, 10.999)
     |> assign(:validation_error, nil)
     |> assign(:clearable_value, nil)}
  end

  def handle_event("update_basic", %{"value" => value}, socket) do
    {:noreply, assign(socket, :basic_value, parse_number(value))}
  end

  def handle_event("update_price", %{"value" => value}, socket) do
    {:noreply, assign(socket, :price_value, parse_float(value))}
  end

  def handle_event("update_quantity", %{"value" => value}, socket) do
    {:noreply, assign(socket, :quantity_value, parse_number(value))}
  end

  def handle_event("submit_form", params, socket) do
    form_data = params["product"] || %{}
    
    {:noreply,
     socket
     |> assign(:form_submitted, true)
     |> assign(:form_data, form_data)}
  end

  def handle_event("validate", params, socket) do
    # Simple validation example
    value = params["value"]
    
    error = cond do
      is_nil(value) || value == "" -> nil
      String.to_float(value) > 100 -> "Value must be less than or equal to 100"
      true -> nil
    end
    
    {:noreply, assign(socket, :validation_error, error)}
  end

  defp parse_number(value) when is_binary(value) do
    case Integer.parse(value) do
      {num, _} -> num
      :error -> 0
    end
  end
  defp parse_number(value), do: value || 0

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> 0.0
    end
  end
  defp parse_float(value), do: value || 0.0

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">InputNumber 数字输入框组件</h1>
      
      <div class="space-y-12">
        <!-- 基础用法 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">基础用法</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.input_number 
              id="basic-number"
              name="quantity"
              value={@basic_value}
              min={1}
              max={10}
              on_change={JS.push("update_basic")}
            />
            <p class="mt-2 text-sm text-gray-600">当前值: {@basic_value}</p>
          </div>
        </section>

        <!-- 设置精度 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">设置精度</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">保留两位小数</label>
              <.input_number 
                id="price-input"
                name="price"
                value={@price_value}
                precision={2}
                step={0.01}
                on_change={JS.push("update_price")}
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">整数输入</label>
              <.input_number 
                id="age-input"
                name="age"
                value={@age_value}
                precision={0}
                min={0}
                max={150}
              />
            </div>
          </div>
        </section>

        <!-- 设置步长 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">设置步长</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">每次增减0.1</label>
              <.input_number 
                id="rate-input"
                name="rate"
                value={@rate_value}
                min={0}
                max={1}
                step={0.1}
                precision={1}
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">每次增减5</label>
              <.input_number 
                id="score-input"
                name="score"
                value={@score_value}
                min={0}
                max={100}
                step={5}
              />
            </div>
          </div>
        </section>

        <!-- 带前缀和后缀 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">带前缀和后缀</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">货币格式</label>
              <.input_number 
                id="currency-input"
                name="amount"
                value={@currency_value}
                precision={2}
              >
                <:prefix>¥</:prefix>
              </.input_number>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">百分比格式</label>
              <.input_number 
                id="percent-input"
                name="percent"
                value={@percent_value}
                min={0}
                max={100}
              >
                <:suffix>%</:suffix>
              </.input_number>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">重量输入</label>
              <.input_number 
                id="weight-input"
                name="weight"
                value={@weight_value}
                min={0}
              >
                <:suffix>kg</:suffix>
              </.input_number>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">温度输入</label>
              <.input_number 
                id="temperature"
                name="temperature"
                value={@temperature_value}
                min={-50}
                max={50}
              >
                <:suffix>°C</:suffix>
              </.input_number>
            </div>
          </div>
        </section>

        <!-- 禁用和只读状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">禁用和只读状态</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">禁用状态</label>
              <.input_number 
                id="disabled-input"
                name="disabled"
                value={100}
                disabled
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">只读状态</label>
              <.input_number 
                id="readonly-input"
                name="readonly"
                value={50}
                readonly
              />
            </div>
          </div>
        </section>

        <!-- 不显示控制按钮 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不显示控制按钮</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.input_number 
              id="no-controls"
              name="custom"
              value={10}
              controls={false}
            />
          </div>
        </section>

        <!-- 不同尺寸 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同尺寸</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <.input_number 
              id="small-input"
              size="small"
              value={1}
              placeholder="小尺寸"
            />
            
            <.input_number 
              id="medium-input"
              size="medium"
              value={2}
              placeholder="中等尺寸"
            />
            
            <.input_number 
              id="large-input"
              size="large"
              value={3}
              placeholder="大尺寸"
            />
          </div>
        </section>

        <!-- 不同颜色 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同颜色主题</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Primary</label>
              <.input_number id="color-primary" color="primary" value={1} />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Info</label>
              <.input_number id="color-info" color="info" value={2} />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Success</label>
              <.input_number id="color-success" color="success" value={3} />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Warning</label>
              <.input_number id="color-warning" color="warning" value={4} />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Danger</label>
              <.input_number id="color-danger" color="danger" value={5} />
            </div>
          </div>
        </section>

        <!-- 在表单中使用 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">在表单中使用</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <form id="demo-form" phx-submit="submit_form">
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">商品价格</label>
                  <.input_number 
                    id="product-price"
                    name="product[price]"
                    value={@form_data["price"]}
                    min={0}
                    precision={2}
                  >
                    <:prefix>¥</:prefix>
                  </.input_number>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">库存数量</label>
                  <.input_number 
                    id="product-stock"
                    name="product[stock]"
                    value={@form_data["stock"]}
                    min={0}
                    precision={0}
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">折扣率</label>
                  <.input_number 
                    id="discount-rate"
                    name="product[discount]"
                    value={@form_data["discount"]}
                    min={0}
                    max={100}
                    precision={0}
                  >
                    <:suffix>%</:suffix>
                  </.input_number>
                </div>
              </div>
              
              <button type="submit" class="mt-4 px-4 py-2 bg-primary text-white rounded hover:bg-primary/90">
                保存
              </button>
            </form>
            
            <%= if @form_submitted do %>
              <div class="mt-4 p-4 bg-green-50 text-green-700 rounded">
                Form submitted with: <%= inspect(@form_data) %>
              </div>
            <% end %>
          </div>
        </section>

        <!-- 购物车数量选择 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">购物车数量选择</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex items-center gap-4">
              <span>购买数量：</span>
              <.input_number 
                id="cart-quantity"
                name="quantity"
                value={@quantity_value}
                min={1}
                max={@stock}
                on_change={JS.push("update_quantity")}
              />
              <span class="text-sm text-gray-500">库存：{@stock}件</span>
            </div>
            <p class="mt-2 text-sm text-gray-600">当前选择: {@quantity_value} 件</p>
          </div>
        </section>

        <!-- 价格区间输入 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">价格区间输入</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex items-center gap-2">
              <.input_number 
                id="min-price"
                name="min_price"
                value={@min_price}
                min={0}
                max={@max_price}
                placeholder="最低价"
              >
                <:prefix>¥</:prefix>
              </.input_number>
              
              <span>-</span>
              
              <.input_number 
                id="max-price"
                name="max_price"
                value={@max_price}
                min={@min_price}
                placeholder="最高价"
              >
                <:prefix>¥</:prefix>
              </.input_number>
            </div>
          </div>
        </section>

        <!-- 带验证的输入 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">带验证的输入</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                输入一个小于等于100的数字
              </label>
              <.input_number 
                id="validated-input"
                max={100}
                on_change={JS.push("validate")}
              />
              <%= if @validation_error do %>
                <p class="mt-1 text-sm text-red-600"><%= @validation_error %></p>
              <% end %>
            </div>
          </div>
        </section>

        <!-- 精度测试 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">精度处理</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                输入 10.999，应该显示 11.00
              </label>
              <.input_number 
                id="precision-test"
                value={@precision_test_value}
                precision={2}
              />
              <p class="mt-2 text-sm text-gray-600">
                精度处理后: <%= Float.round(@precision_test_value, 2) %>
              </p>
            </div>
          </div>
        </section>

        <!-- 键盘快捷键说明 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">键盘快捷键</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.input_number id="keyboard-test" value={10} />
            <div class="mt-4 text-sm text-gray-600">
              <p>• ↑ - 增加一个步长</p>
              <p>• ↓ - 减少一个步长</p>
              <p>• Ctrl/Cmd + ↑ - 增加十个步长</p>
              <p>• Ctrl/Cmd + ↓ - 减少十个步长</p>
            </div>
          </div>
        </section>

        <!-- 边缘案例 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">边缘案例测试</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">空值处理</label>
              <.input_number id="clearable-input" placeholder="请输入数字" />
              <p class="mt-1 text-sm text-gray-600">
                <%= if is_nil(@clearable_value) || @clearable_value == "" do %>
                  No value selected
                <% else %>
                  Value: <%= @clearable_value %>
                <% end %>
              </p>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                无效输入过滤（尝试输入字母）
              </label>
              <.input_number id="edge-case-input" />
            </div>
          </div>
        </section>

        <!-- 可访问性测试 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">可访问性</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.input_number 
              id="a11y-test"
              value={50}
              min={0}
              max={100}
            />
            <p class="mt-2 text-sm text-gray-600">
              此输入框包含完整的 ARIA 属性，支持屏幕阅读器
            </p>
          </div>
        </section>
      </div>
    </div>
    """
  end
end