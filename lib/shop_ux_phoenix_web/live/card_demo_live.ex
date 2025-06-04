defmodule ShopUxPhoenixWeb.CardDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.Card

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Card 卡片组件")
     |> assign(:loading_demo, false)
     |> assign(:recent_orders, [
       %{number: "ORD-2024-001", customer: "张三", amount: "299.00", status: "已完成"},
       %{number: "ORD-2024-002", customer: "李四", amount: "599.00", status: "处理中"},
       %{number: "ORD-2024-003", customer: "王五", amount: "1299.00", status: "待发货"}
     ])}
  end

  def handle_event("toggle_loading", _params, socket) do
    {:noreply, assign(socket, :loading_demo, !socket.assigns.loading_demo)}
  end

  def handle_event("save", _params, socket) do
    {:noreply, put_flash(socket, :info, "保存成功！")}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, put_flash(socket, :info, "已取消")}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 max-w-7xl mx-auto">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Card 卡片组件</h1>
      
      <!-- 基础用法 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础用法</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <.card title="基础卡片">
            <p>这是一个基础的卡片组件，包含标题和内容。</p>
          </.card>
          
          <.card>
            <p>这是一个没有标题的卡片，只有内容区域。</p>
          </.card>
        </div>
      </section>

      <!-- 不同尺寸 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">不同尺寸</h2>
        <div class="space-y-6">
          <.card title="小尺寸卡片" size="small">
            <p>内容区域较小，适合紧凑的布局。</p>
          </.card>
          
          <.card title="中等尺寸卡片（默认）" size="medium">
            <p>标准尺寸的卡片，适合大多数场景。</p>
          </.card>
          
          <.card title="大尺寸卡片" size="large">
            <p>内容区域较大，适合需要更多留白的场景。</p>
          </.card>
        </div>
      </section>

      <!-- 边框和悬停效果 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">边框和悬停效果</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <.card title="无边框卡片" bordered={false}>
            <p>这个卡片没有边框，适合某些特殊的设计需求。</p>
          </.card>
          
          <.card title="可悬停卡片" hoverable>
            <p>鼠标悬停时会有阴影效果，增强交互感。</p>
          </.card>
        </div>
      </section>

      <!-- 加载状态 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">加载状态</h2>
        <div class="space-y-4">
          <.button phx-click="toggle_loading">
            切换加载状态
          </.button>
          
          <.card title="加载中..." loading={@loading_demo}>
            <p>这里是卡片内容，加载时会显示骨架屏。</p>
            <p>可以包含多行内容。</p>
          </.card>
        </div>
      </section>

      <!-- 额外内容 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">额外内容</h2>
        <.card title="订单信息">
          <:extra>
            <.link navigate="#" class="text-blue-600 hover:text-blue-800">
              更多 →
            </.link>
          </:extra>
          
          <div class="space-y-2">
            <p><span class="font-semibold">订单号：</span>ORD-2024-001</p>
            <p><span class="font-semibold">下单时间：</span>2024-01-15 10:30:00</p>
            <p><span class="font-semibold">订单金额：</span>¥299.00</p>
          </div>
        </.card>
      </section>

      <!-- 操作区域 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">操作区域</h2>
        <.card title="商品信息">
          <:extra>
            <button class="text-gray-400 hover:text-gray-600">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </button>
          </:extra>
          
          <div class="space-y-2">
            <p><span class="font-semibold">商品名称：</span>iPhone 15 Pro Max</p>
            <p><span class="font-semibold">商品编号：</span>SKU-001234</p>
            <p><span class="font-semibold">库存数量：</span>128</p>
            <p><span class="font-semibold">售价：</span>¥8,999.00</p>
          </div>
          
          <:actions>
            <.button type="primary">编辑</.button>
            <.button>删除</.button>
            <.button>分享</.button>
          </:actions>
        </.card>
      </section>

      <!-- 封面卡片 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">封面卡片</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <.card hoverable>
            <:cover>
              <img 
                src="https://via.placeholder.com/300x200/4F46E5/FFFFFF?text=Product" 
                alt="产品图片"
                class="w-full h-48 object-cover"
              />
            </:cover>
            
            <h3 class="text-lg font-semibold mb-2">产品名称</h3>
            <p class="text-gray-600 text-sm mb-4">
              这是产品的描述信息，可以简要介绍产品的特点和优势。
            </p>
            <div class="flex justify-between items-center">
              <span class="text-xl font-bold text-red-600">¥299</span>
              <.button>购买</.button>
            </div>
          </.card>
          
          <.card hoverable>
            <:cover>
              <img 
                src="https://via.placeholder.com/300x200/10B981/FFFFFF?text=Service" 
                alt="服务图片"
                class="w-full h-48 object-cover"
              />
            </:cover>
            
            <h3 class="text-lg font-semibold mb-2">服务套餐</h3>
            <p class="text-gray-600 text-sm mb-4">
              专业的服务套餐，为您提供全方位的解决方案。
            </p>
            <div class="flex justify-between items-center">
              <span class="text-xl font-bold text-red-600">¥599/月</span>
              <.button>订购</.button>
            </div>
          </.card>
          
          <.card hoverable>
            <:cover>
              <img 
                src="https://via.placeholder.com/300x200/F59E0B/FFFFFF?text=Course" 
                alt="课程图片"
                class="w-full h-48 object-cover"
              />
            </:cover>
            
            <h3 class="text-lg font-semibold mb-2">在线课程</h3>
            <p class="text-gray-600 text-sm mb-4">
              精品在线课程，助您提升专业技能。
            </p>
            <div class="flex justify-between items-center">
              <span class="text-xl font-bold text-red-600">¥199</span>
              <.button>学习</.button>
            </div>
          </.card>
        </div>
      </section>

      <!-- 自定义样式 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">自定义样式</h2>
        <.card 
          title="自定义样式卡片"
          class="bg-gradient-to-r from-blue-50 to-indigo-50"
          header_class="bg-gradient-to-r from-blue-100 to-indigo-100"
          body_style="text-blue-900"
        >
          <p>这是一个使用自定义样式的卡片，包含渐变背景色。</p>
          <p class="mt-2">可以通过 class、header_class 和 body_style 属性自定义样式。</p>
        </.card>
      </section>

      <!-- 嵌套卡片 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">嵌套卡片</h2>
        <.card title="父卡片" size="large">
          <p class="mb-4">这是父卡片的内容，下面包含了一个嵌套的子卡片。</p>
          
          <.card title="子卡片" size="small" class="bg-gray-50">
            <p>这是嵌套在父卡片中的子卡片，可以用于展示层级关系。</p>
          </.card>
        </.card>
      </section>

      <!-- 实际应用示例 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">实际应用示例</h2>
        
        <!-- 数据统计卡片 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-4">数据统计卡片</h3>
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <.card hoverable class="text-center">
              <div class="text-3xl font-bold text-blue-600 mb-2">1,234</div>
              <div class="text-gray-600">今日订单</div>
              <div class="text-sm text-green-600 mt-2">↑ 12.5%</div>
            </.card>
            
            <.card hoverable class="text-center">
              <div class="text-3xl font-bold text-green-600 mb-2">¥28,459</div>
              <div class="text-gray-600">营业额</div>
              <div class="text-sm text-green-600 mt-2">↑ 8.2%</div>
            </.card>
            
            <.card hoverable class="text-center">
              <div class="text-3xl font-bold text-purple-600 mb-2">567</div>
              <div class="text-gray-600">新增用户</div>
              <div class="text-sm text-red-600 mt-2">↓ 3.1%</div>
            </.card>
            
            <.card hoverable class="text-center">
              <div class="text-3xl font-bold text-orange-600 mb-2">89.2%</div>
              <div class="text-gray-600">转化率</div>
              <div class="text-sm text-green-600 mt-2">↑ 1.2%</div>
            </.card>
          </div>
        </div>

        <!-- 订单详情卡片 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-4">订单详情卡片</h3>
          <.card title="订单详情" hoverable>
            <:extra>
              <span class="text-sm text-gray-500">订单号：ORD-2024-001</span>
            </:extra>
            
            <div class="space-y-4">
              <div>
                <h4 class="font-semibold text-gray-900 mb-2">收货信息</h4>
                <p class="text-gray-600">张三 138****5678</p>
                <p class="text-gray-600">北京市朝阳区建国路88号SOHO现代城A座2801</p>
              </div>
              
              <div>
                <h4 class="font-semibold text-gray-900 mb-2">商品信息</h4>
                <div class="space-y-2">
                  <div class="flex justify-between py-2 border-b">
                    <span>iPhone 15 Pro Max 256GB 钛蓝色</span>
                    <span>¥8999 × 1</span>
                  </div>
                  <div class="flex justify-between py-2 border-b">
                    <span>Apple 原装硅胶保护壳</span>
                    <span>¥399 × 1</span>
                  </div>
                  <div class="flex justify-between py-2 border-b">
                    <span>20W USB-C 电源适配器</span>
                    <span>¥149 × 2</span>
                  </div>
                </div>
              </div>
              
              <div class="border-t pt-4">
                <div class="flex justify-between text-sm">
                  <span>商品总额</span>
                  <span>¥9,696</span>
                </div>
                <div class="flex justify-between text-sm">
                  <span>运费</span>
                  <span>¥0</span>
                </div>
                <div class="flex justify-between text-sm">
                  <span>优惠</span>
                  <span class="text-red-600">-¥100</span>
                </div>
                <div class="flex justify-between font-semibold text-lg mt-2 pt-2 border-t">
                  <span>实付金额</span>
                  <span class="text-red-600">¥9,596</span>
                </div>
              </div>
            </div>
            
            <:actions>
              <.button type="primary">确认收货</.button>
              <.button>查看物流</.button>
              <.button>申请售后</.button>
            </:actions>
          </.card>
        </div>

        <!-- 表单卡片 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium text-gray-900 mb-4">表单卡片</h3>
          <.card title="基本信息">
            <.form for={%{}} phx-submit="save">
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    姓名
                  </label>
                  <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    邮箱
                  </label>
                  <input type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    电话
                  </label>
                  <input type="tel" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" />
                </div>
              </div>
            </.form>
            
            <:actions>
              <.button type="submit" form="basic-info-form" phx-disable-with="保存中...">保存</.button>
              <.button type="button" phx-click="cancel">取消</.button>
            </:actions>
          </.card>
        </div>

        <!-- 列表卡片 -->
        <div>
          <h3 class="text-lg font-medium text-gray-900 mb-4">列表卡片</h3>
          <.card title="最新订单" size="medium">
            <:extra>
              <.link navigate="#" class="text-sm text-blue-600 hover:text-blue-800">
                查看全部
              </.link>
            </:extra>
            
            <div class="space-y-2">
              <%= for order <- @recent_orders do %>
                <div class="flex justify-between py-3 border-b last:border-0">
                  <div>
                    <div class="font-medium text-gray-900"><%= order.number %></div>
                    <div class="text-sm text-gray-500"><%= order.customer %></div>
                  </div>
                  <div class="text-right">
                    <div class="font-medium text-gray-900">¥<%= order.amount %></div>
                    <div class="text-sm">
                      <span class={[
                        "px-2 py-1 rounded-full text-xs",
                        order.status == "已完成" && "bg-green-100 text-green-800",
                        order.status == "处理中" && "bg-blue-100 text-blue-800",
                        order.status == "待发货" && "bg-yellow-100 text-yellow-800"
                      ]}>
                        <%= order.status %>
                      </span>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </.card>
        </div>
      </section>
    </div>
    """
  end
end