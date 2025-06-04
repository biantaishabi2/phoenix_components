defmodule ShopUxPhoenixWeb.TooltipDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Tooltip

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Tooltip 文字提示组件")
     |> assign(:tooltip_visible, false)}
  end

  def handle_event("toggle_tooltip", _params, socket) do
    {:noreply, update(socket, :tooltip_visible, &(!&1))}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">Tooltip 文字提示组件</h1>
      
      <div class="space-y-12">
        <!-- 基础用法 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">基础用法</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex gap-4">
              <.tooltip id="basic-hover" title="这是一个提示">
                <span class="text-primary cursor-pointer">悬停查看提示</span>
              </.tooltip>
              
              <.tooltip id="basic-click" title="点击触发的提示" trigger="click">
                <.button>点击触发</.button>
              </.tooltip>
              
              <.tooltip id="basic-focus" title="聚焦触发的提示" trigger="focus">
                <input 
                  type="text" 
                  placeholder="聚焦触发" 
                  class="px-3 py-1.5 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </.tooltip>
            </div>
          </div>
        </section>

        <!-- 位置 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">位置</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex gap-4 justify-center">
              <.tooltip id="placement-top" title="提示内容" placement="top">
                <.button>上方</.button>
              </.tooltip>
              
              <.tooltip id="placement-bottom" title="提示内容" placement="bottom">
                <.button>下方</.button>
              </.tooltip>
              
              <.tooltip id="placement-left" title="提示内容" placement="left">
                <.button>左侧</.button>
              </.tooltip>
              
              <.tooltip id="placement-right" title="提示内容" placement="right">
                <.button>右侧</.button>
              </.tooltip>
            </div>
          </div>
        </section>

        <!-- 12个方向 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">12个方向</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="w-96 mx-auto">
              <div class="grid grid-cols-3 gap-2">
                <!-- 第一行 -->
                <.tooltip id="tl" title="提示内容" placement="top-start">
                  <.button class="w-full">TL</.button>
                </.tooltip>
                
                <.tooltip id="top" title="提示内容" placement="top">
                  <.button class="w-full">Top</.button>
                </.tooltip>
                
                <.tooltip id="tr" title="提示内容" placement="top-end">
                  <.button class="w-full">TR</.button>
                </.tooltip>
                
                <!-- 第二行 -->
                <.tooltip id="lt" title="提示内容" placement="left-start">
                  <.button class="w-full">LT</.button>
                </.tooltip>
                
                <div></div>
                
                <.tooltip id="rt" title="提示内容" placement="right-start">
                  <.button class="w-full">RT</.button>
                </.tooltip>
                
                <!-- 第三行 -->
                <.tooltip id="left" title="提示内容" placement="left">
                  <.button class="w-full">Left</.button>
                </.tooltip>
                
                <div></div>
                
                <.tooltip id="right" title="提示内容" placement="right">
                  <.button class="w-full">Right</.button>
                </.tooltip>
                
                <!-- 第四行 -->
                <.tooltip id="lb" title="提示内容" placement="left-end">
                  <.button class="w-full">LB</.button>
                </.tooltip>
                
                <div></div>
                
                <.tooltip id="rb" title="提示内容" placement="right-end">
                  <.button class="w-full">RB</.button>
                </.tooltip>
                
                <!-- 第五行 -->
                <.tooltip id="bl" title="提示内容" placement="bottom-start">
                  <.button class="w-full">BL</.button>
                </.tooltip>
                
                <.tooltip id="bottom" title="提示内容" placement="bottom">
                  <.button class="w-full">Bottom</.button>
                </.tooltip>
                
                <.tooltip id="br" title="提示内容" placement="bottom-end">
                  <.button class="w-full">BR</.button>
                </.tooltip>
              </div>
            </div>
          </div>
        </section>

        <!-- 自定义内容 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">自定义内容</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tooltip id="custom-content">
              <:content>
                <div class="space-y-1">
                  <p class="font-semibold">自定义标题</p>
                  <p class="text-gray-300 text-xs">这是一段自定义的内容</p>
                  <div class="flex gap-2 mt-2">
                    <span class="inline-block w-2 h-2 bg-green-400 rounded-full"></span>
                    <span class="inline-block w-2 h-2 bg-yellow-400 rounded-full"></span>
                    <span class="inline-block w-2 h-2 bg-red-400 rounded-full"></span>
                  </div>
                </div>
              </:content>
              <.button>自定义内容示例</.button>
            </.tooltip>
          </div>
        </section>

        <!-- 多彩文字提示 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">多彩文字提示</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex gap-4 flex-wrap">
              <.tooltip id="pink" title="Pink" color="#eb2f96">
                <.button>Pink</.button>
              </.tooltip>
              
              <.tooltip id="blue" title="Blue" color="#1890ff">
                <.button>Blue</.button>
              </.tooltip>
              
              <.tooltip id="green" title="Green" color="#52c41a">
                <.button>Green</.button>
              </.tooltip>
              
              <.tooltip id="yellow" title="Yellow" color="#faad14">
                <.button>Yellow</.button>
              </.tooltip>
              
              <.tooltip id="purple" title="Purple" color="#722ed1">
                <.button>Purple</.button>
              </.tooltip>
              
              <.tooltip id="cyan" title="Cyan" color="#13c2c2">
                <.button>Cyan</.button>
              </.tooltip>
            </div>
          </div>
        </section>

        <!-- 手动控制显示 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">手动控制显示</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tooltip 
              id="controlled" 
              title="受控的提示" 
              visible={@tooltip_visible}
              trigger="click"
            >
              <.button phx-click="toggle_tooltip">
                点击切换
              </.button>
            </.tooltip>
            
            <p class="mt-4 text-sm text-gray-600">
              当前状态：<%= if @tooltip_visible, do: "显示", else: "隐藏" %>
            </p>
          </div>
        </section>

        <!-- 延迟显示 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">延迟显示</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex gap-4">
              <.tooltip 
                id="delay-enter" 
                title="延迟0.5秒显示" 
                mouse_enter_delay={500}
              >
                <span class="text-primary cursor-pointer">延迟0.5秒显示</span>
              </.tooltip>
              
              <.tooltip 
                id="delay-leave" 
                title="延迟1秒隐藏" 
                mouse_leave_delay={1000}
              >
                <span class="text-primary cursor-pointer">延迟1秒隐藏</span>
              </.tooltip>
              
              <.tooltip 
                id="delay-both" 
                title="延迟显示和隐藏" 
                mouse_enter_delay={500}
                mouse_leave_delay={500}
              >
                <span class="text-primary cursor-pointer">延迟0.5秒显示和隐藏</span>
              </.tooltip>
            </div>
          </div>
        </section>

        <!-- 禁用状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">禁用状态</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.tooltip id="disabled" title="这个提示被禁用了" disabled={true}>
              <span class="text-gray-400">禁用的提示（悬停无效果）</span>
            </.tooltip>
          </div>
        </section>

        <!-- 箭头指向 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">箭头指向</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex gap-8">
              <.tooltip 
                id="arrow-normal" 
                title="默认情况下，箭头跟随内容位置" 
                placement="top-start"
              >
                <.button class="w-48">箭头跟随内容</.button>
              </.tooltip>
              
              <.tooltip 
                id="arrow-center" 
                title="箭头始终指向中心" 
                arrow_point_at_center={true}
                placement="top-start"
              >
                <.button class="w-48">箭头始终指向中心</.button>
              </.tooltip>
            </div>
          </div>
        </section>

        <!-- 实际应用场景 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">实际应用场景</h2>
          
          <!-- 表单字段说明 -->
          <div class="bg-white p-6 rounded-lg shadow mb-4">
            <h3 class="text-lg font-medium mb-4">表单字段说明</h3>
            <form class="space-y-4">
              <div>
                <label class="flex items-center gap-1 text-sm font-medium mb-1">
                  用户名
                  <.tooltip id="username-tip" title="用户名必须是3-20个字符，只能包含字母、数字和下划线">
                    <.icon name="hero-question-mark-circle" class="w-4 h-4 text-gray-400" />
                  </.tooltip>
                </label>
                <input type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary" />
              </div>
              
              <div>
                <label class="flex items-center gap-1 text-sm font-medium mb-1">
                  密码
                  <.tooltip id="password-tip" placement="right">
                    <:content>
                      <div class="space-y-1 text-xs">
                        <p class="font-semibold">密码要求：</p>
                        <ul class="space-y-0.5 list-disc list-inside">
                          <li>至少8个字符</li>
                          <li>包含大小写字母</li>
                          <li>包含数字</li>
                          <li>包含特殊字符</li>
                        </ul>
                      </div>
                    </:content>
                    <.icon name="hero-information-circle" class="w-4 h-4 text-primary" />
                  </.tooltip>
                </label>
                <input type="password" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary" />
              </div>
            </form>
          </div>
          
          <!-- 图标提示 -->
          <div class="bg-white p-6 rounded-lg shadow mb-4">
            <h3 class="text-lg font-medium mb-4">图标提示</h3>
            <div class="flex gap-4">
              <.tooltip id="edit-tip" title="编辑">
                <button class="p-2 hover:bg-gray-100 rounded">
                  <.icon name="hero-pencil" class="w-4 h-4" />
                </button>
              </.tooltip>
              
              <.tooltip id="copy-tip" title="复制">
                <button class="p-2 hover:bg-gray-100 rounded">
                  <.icon name="hero-clipboard-document" class="w-4 h-4" />
                </button>
              </.tooltip>
              
              <.tooltip id="share-tip" title="分享" placement="bottom">
                <button class="p-2 hover:bg-gray-100 rounded">
                  <.icon name="hero-share" class="w-4 h-4" />
                </button>
              </.tooltip>
              
              <.tooltip id="delete-tip" title="删除" placement="bottom" color="#ff4d4f">
                <button class="p-2 hover:bg-gray-100 rounded text-red-500">
                  <.icon name="hero-trash" class="w-4 h-4" />
                </button>
              </.tooltip>
            </div>
          </div>
          
          <!-- 省略文字提示 -->
          <div class="bg-white p-6 rounded-lg shadow">
            <h3 class="text-lg font-medium mb-4">省略文字提示</h3>
            <div class="w-64">
              <.tooltip id="ellipsis" title="这是一段很长的文字，当文字超出容器宽度时会显示省略号，鼠标悬停可以查看完整内容">
                <p class="truncate">
                  这是一段很长的文字，当文字超出容器宽度时会显示省略号，鼠标悬停可以查看完整内容
                </p>
              </.tooltip>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end
end