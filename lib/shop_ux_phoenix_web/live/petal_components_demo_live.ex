defmodule ShopUxPhoenixWeb.PetalComponentsDemoLive do
  use Phoenix.LiveView, layout: {ShopUxPhoenixWeb.Layouts, :app}
  use PetalComponents
  
  alias Phoenix.LiveView.JS
  
  @impl true
  def mount(_params, _session, socket) do
    # 使用字符串键的 map 作为表单数据
    form_data = %{
      "email" => "",
      "password" => "",
      "name" => "",
      "message" => "",
      "age" => "",
      "website" => ""
    }
    
    {:ok, assign(socket,
      form: to_form(form_data, as: "user"),
      input_value: "",
      disabled_input: false,
      loading_input: false,
      loading_demo: false,
      progress_value: 65,
      current_time: DateTime.utc_now() |> DateTime.to_string(), # 将时间移到 assigns 中
      alerts: %{
        "info" => true,
        "success" => true,
        "warning" => true,
        "danger" => true
      },
      # 数据展示组件的数据
      table_data: [
        %{id: 1, name: "张三", email: "zhangsan@example.com", status: "active", role: "管理员"},
        %{id: 2, name: "李四", email: "lisi@example.com", status: "inactive", role: "用户"},
        %{id: 3, name: "王五", email: "wangwu@example.com", status: "active", role: "编辑"},
        %{id: 4, name: "赵六", email: "zhaoliu@example.com", status: "pending", role: "用户"}
      ],
      selected_row: nil,
      rating_value: 3.5,
      # 导航组件的数据
      current_page: 3,
      total_pages: 10,
      current_tab: "tab1",
      current_step: 2,
      menu_items: [
        %{
          name: :dashboard,
          label: "仪表盘",
          path: "/dashboard",
          icon: "hero-home"
        },
        %{
          name: :users,
          label: "用户管理",
          path: "/users",
          icon: "hero-users",
          menu_items: [
            %{name: :all_users, label: "所有用户", path: "/users"},
            %{name: :add_user, label: "添加用户", path: "/users/new"}
          ]
        },
        %{
          name: :settings,
          label: "设置",
          path: "/settings",
          icon: "hero-cog"
        }
      ]
    )}
  end
  
  @impl true
  def handle_event("test_connection", _params, socket) do
    # 更新时间
    current_time = DateTime.utc_now() |> DateTime.to_string()
    {:noreply, 
     socket
     |> assign(:current_time, current_time)
     |> put_flash(:info, "WebSocket 连接正常！LiveView 事件处理成功。")}
  end
  
  @impl true
  def handle_event("button_click", %{"type" => type}, socket) do
    {:noreply, put_flash(socket, :info, "点击了 #{type} 按钮")}
  end
  
  @impl true
  def handle_event("form_submit", params, socket) do
    IO.inspect(params, label: "表单提交数据")
    {:noreply, put_flash(socket, :info, "表单已提交")}
  end
  
  @impl true
  def handle_event("input_change", %{"value" => value}, socket) do
    {:noreply, assign(socket, input_value: value)}
  end
  
  @impl true
  def handle_event("toggle_disabled", _, socket) do
    {:noreply, assign(socket, disabled_input: !socket.assigns.disabled_input)}
  end
  
  @impl true
  def handle_event("toggle_loading", _, socket) do
    {:noreply, assign(socket, loading_input: !socket.assigns.loading_input)}
  end
  
  @impl true
  def handle_event("loading_demo", _, socket) do
    Process.send_after(self(), :stop_loading, 3000)
    {:noreply, assign(socket, loading_demo: true)}
  end
  
  @impl true
  def handle_event("close_alert", %{"type" => type}, socket) do
    alerts = Map.put(socket.assigns.alerts, type, false)
    {:noreply, assign(socket, alerts: alerts)}
  end
  
  @impl true
  def handle_event("row_click", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_row: String.to_integer(id))}
  end
  
  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    {:noreply, assign(socket, current_page: String.to_integer(page))}
  end
  
  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, current_tab: tab)}
  end
  
  @impl true
  def handle_event("change_step", %{"step" => step}, socket) do
    {:noreply, assign(socket, current_step: String.to_integer(step))}
  end
  
  @impl true
  def handle_event("toggle_menu", %{"name" => name}, socket) do
    # 实际应用中这里应该管理菜单展开/收起状态
    {:noreply, put_flash(socket, :info, "切换菜单: #{name}")}
  end
  
  @impl true
  def handle_event("menu_click", %{"name" => name}, socket) do
    {:noreply, put_flash(socket, :info, "点击菜单: #{name}")}
  end
  
  @impl true
  def handle_event("dropdown_click", %{"action" => action}, socket) do
    {:noreply, put_flash(socket, :info, "下拉菜单操作: #{action}")}
  end
  
  @impl true
  def handle_info(:stop_loading, socket) do
    {:noreply, assign(socket, loading_demo: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-8">Petal Components 演示（修复版）</h1>
      
      <div class="text-gray-600 mb-8">
        这是修复后的 Petal Components 库演示页面。已解决编译错误和连接问题。
      </div>
      
      <!-- LiveView 连接测试 -->
      <div class="mb-8 p-4 bg-gray-100 rounded">
        <p class="text-sm font-semibold mb-2">LiveView 连接测试</p>
        <div class="flex items-center gap-4">
          <.button phx-click="test_connection" size="sm">
            测试连接
          </.button>
          <span class="text-sm text-gray-600">
            当前时间: <%= @current_time %>
          </span>
        </div>
        <p class="text-xs text-gray-600 mt-2">
          点击按钮测试 LiveView WebSocket 连接是否正常。
        </p>
      </div>
      
      <!-- Button 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Button 按钮</h2>
        
        <!-- 基础按钮 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">基础用法</h3>
          <div class="flex flex-wrap gap-3">
            <.button>默认按钮</.button>
            <.button color="primary">主要按钮</.button>
            <.button color="secondary">次要按钮</.button>
            <.button color="success">成功按钮</.button>
            <.button color="danger">危险按钮</.button>
            <.button color="warning">警告按钮</.button>
            <.button color="info">信息按钮</.button>
          </div>
        </div>
        
        <!-- 按钮尺寸 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">按钮尺寸</h3>
          <div class="flex flex-wrap items-center gap-3">
            <.button size="xs">超小按钮</.button>
            <.button size="sm">小按钮</.button>
            <.button size="md">中等按钮</.button>
            <.button size="lg">大按钮</.button>
            <.button size="xl">超大按钮</.button>
          </div>
        </div>
        
        <!-- 按钮状态 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">按钮状态</h3>
          <div class="flex flex-wrap gap-3">
            <.button disabled>禁用按钮</.button>
            <.button loading>加载中按钮</.button>
            <.button variant="outline">轮廓按钮</.button>
            <.button variant="ghost">幽灵按钮</.button>
          </div>
        </div>
        
        <!-- 带图标的按钮 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">带图标的按钮</h3>
          <div class="flex flex-wrap gap-3">
            <.button>
              <.icon name="hero-plus" class="w-4 h-4 mr-2" />
              添加
            </.button>
            <.button color="danger">
              <.icon name="hero-trash" class="w-4 h-4 mr-2" />
              删除
            </.button>
            <.button color="success">
              <.icon name="hero-check" class="w-4 h-4 mr-2" />
              确认
            </.button>
          </div>
        </div>
      </section>
      
      <!-- Form 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Form 表单</h2>
        
        <!-- 基础表单 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">基础表单</h3>
          <.form for={@form} phx-submit="form_submit" class="max-w-md space-y-4">
            <.field field={@form[:email]} type="email" label="邮箱" placeholder="请输入邮箱" />
            <.field field={@form[:password]} type="password" label="密码" placeholder="请输入密码" />
            
            <.button type="submit" color="primary">提交</.button>
          </.form>
        </div>
      </section>
      
      <!-- Field 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Field 表单字段</h2>
        
        <!-- 字段类型 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">字段类型</h3>
          <div class="max-w-md space-y-4">
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">文本输入</p>
              <.field field={@form[:name]} label="姓名" placeholder="请输入姓名" />
            </div>
            
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">密码输入</p>
              <.field field={@form[:password]} type="password" label="密码" placeholder="请输入密码" />
            </div>
            
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">文本域</p>
              <.field field={@form[:message]} type="textarea" label="留言" placeholder="请输入留言内容" />
            </div>
            
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">选择框</p>
              <.field 
                field={@form[:role]} 
                type="select" 
                label="角色"
                options={[{"管理员", "admin"}, {"用户", "user"}, {"访客", "guest"}]}
              />
            </div>
          </div>
        </div>
        
        <!-- 字段状态 -->
        <div class="mb-6">
          <h3 class="text-lg font-medium mb-3">字段状态</h3>
          <div class="max-w-md space-y-4">
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">带错误的字段</p>
              <.field 
                field={@form[:email]} 
                label="邮箱" 
                errors={["邮箱格式不正确"]} 
                placeholder="请输入邮箱"
              />
            </div>
            
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">带帮助文本的字段</p>
              <.field 
                field={@form[:website]} 
                label="网站" 
                placeholder="https://example.com"
                help_text="请输入完整的网址，包含 http:// 或 https://"
              />
            </div>
            
            <div>
              <p class="text-sm font-medium text-gray-700 mb-2">禁用的字段</p>
              <.field 
                field={@form[:disabled]} 
                label="禁用字段" 
                disabled={true}
                value="这是一个禁用的字段"
              />
            </div>
          </div>
        </div>
      </section>
      
      <!-- Alert 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Alert 警告提示</h2>
        
        <div class="space-y-3">
          <%= if @alerts["info"] do %>
            <.alert color="info" close_button_properties={[{"phx-click", "close_alert"}, {"phx-value-type", "info"}]}>
              <.icon name="hero-information-circle" class="w-5 h-5 mr-2" />
              这是一条信息提示
            </.alert>
          <% end %>
          
          <%= if @alerts["success"] do %>
            <.alert color="success" close_button_properties={[{"phx-click", "close_alert"}, {"phx-value-type", "success"}]}>
              <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
              这是一条成功提示
            </.alert>
          <% end %>
          
          <%= if @alerts["warning"] do %>
            <.alert color="warning" close_button_properties={[{"phx-click", "close_alert"}, {"phx-value-type", "warning"}]}>
              <.icon name="hero-exclamation-triangle" class="w-5 h-5 mr-2" />
              这是一条警告提示
            </.alert>
          <% end %>
          
          <%= if @alerts["danger"] do %>
            <.alert color="danger" close_button_properties={[{"phx-click", "close_alert"}, {"phx-value-type", "danger"}]}>
              <.icon name="hero-x-circle" class="w-5 h-5 mr-2" />
              这是一条错误提示
            </.alert>
          <% end %>
        </div>
      </section>
      
      <!-- Badge 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Badge 徽章</h2>
        
        <div class="flex flex-wrap gap-3">
          <.badge>默认</.badge>
          <.badge color="primary">主要</.badge>
          <.badge color="secondary">次要</.badge>
          <.badge color="success">成功</.badge>
          <.badge color="danger">危险</.badge>
          <.badge color="warning">警告</.badge>
          <.badge color="info">信息</.badge>
          <.badge color="gray">灰色</.badge>
          <.badge color="light">浅色</.badge>
          <.badge color="dark">深色</.badge>
        </div>
        
        <div class="mt-4 flex flex-wrap gap-3">
          <.badge size="sm">小尺寸</.badge>
          <.badge size="md">中尺寸</.badge>
          <.badge size="lg">大尺寸</.badge>
        </div>
      </section>
      
      <!-- Card 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Card 卡片</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-4xl">
          <.card>
            <.card_content heading="基础卡片">
              <p class="text-gray-600">这是一个基础的卡片组件，可以包含任何内容。</p>
            </.card_content>
          </.card>
          
          <.card>
            <.card_media src="https://via.placeholder.com/400x200" />
            <.card_content heading="带图片的卡片">
              <p class="text-gray-600">这个卡片包含了一个媒体区域。</p>
            </.card_content>
          </.card>
        </div>
      </section>
      
      <!-- Modal 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Modal 模态框</h2>
        
        <div class="flex gap-3">
          <.button phx-click={PetalComponents.Modal.show_modal("demo-modal")}>
            打开模态框
          </.button>
          
          <.button phx-click={PetalComponents.Modal.show_modal("large-modal")} color="primary">
            打开大模态框
          </.button>
        </div>
        
        <.modal id="demo-modal">
          <div class="mb-4">
            <h3 class="text-lg font-semibold">模态框标题</h3>
          </div>
          <p class="text-gray-600 mb-4">这是模态框的内容区域。</p>
          <div class="flex justify-end gap-3">
            <.button phx-click={PetalComponents.Modal.hide_modal("demo-modal")} variant="ghost">
              取消
            </.button>
            <.button phx-click={PetalComponents.Modal.hide_modal("demo-modal")} color="primary">
              确认
            </.button>
          </div>
        </.modal>
        
        <.modal id="large-modal" max_width="lg">
          <div class="mb-4">
            <h3 class="text-lg font-semibold">大尺寸模态框</h3>
          </div>
          <p class="text-gray-600 mb-4">这是一个更大的模态框，可以容纳更多内容。</p>
          <p class="text-gray-600 mb-4">你可以在这里放置表单、图片或任何其他内容。</p>
          <div class="flex justify-end">
            <.button phx-click={PetalComponents.Modal.hide_modal("large-modal")} color="primary">
              关闭
            </.button>
          </div>
        </.modal>
      </section>
      
      <!-- Progress 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Progress 进度条</h2>
        
        <div class="space-y-4 max-w-md">
          <div>
            <p class="text-sm font-medium text-gray-700 mb-2">基础进度条</p>
            <.progress value={@progress_value} />
          </div>
          
          <div>
            <p class="text-sm font-medium text-gray-700 mb-2">不同颜色</p>
            <div class="space-y-2">
              <.progress value={20} color="primary" />
              <.progress value={40} color="success" />
              <.progress value={60} color="warning" />
              <.progress value={80} color="danger" />
            </div>
          </div>
          
          <div>
            <p class="text-sm font-medium text-gray-700 mb-2">不同尺寸</p>
            <div class="space-y-2">
              <.progress value={50} size="sm" />
              <.progress value={50} size="md" />
              <.progress value={50} size="lg" />
            </div>
          </div>
        </div>
      </section>
      
      <!-- Spinner 组件 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Spinner 加载动画</h2>
        
        <div class="flex items-center gap-4">
          <.spinner size="sm" />
          <.spinner size="md" />
          <.spinner size="lg" />
          <.spinner size="xl" />
        </div>
        
        <div class="mt-4 flex items-center gap-4">
          <.spinner color="primary" />
          <.spinner color="secondary" />
          <.spinner color="success" />
          <.spinner color="danger" />
          <.spinner color="warning" />
          <.spinner color="info" />
        </div>
      </section>
      
      <!-- Heroicons 图标展示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold mb-4">Heroicons 图标库</h2>
        
        <div class="mb-6">
          <p class="text-gray-600 mb-4">
            PetalComponents 使用 Heroicons 图标库。以下是常用的图标示例，图标名称格式为 "hero-[icon-name]"。
          </p>
        </div>
        
        <!-- 常用图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">常用图标</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-home" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">home</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-user" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">user</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-users" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">users</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-cog" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">cog</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-cog-6-tooth" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">cog-6-tooth</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-heart" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">heart</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-star" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">star</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-bell" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">bell</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-envelope" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">envelope</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-phone" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">phone</span>
            </div>
          </div>
        </div>
        
        <!-- 操作图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">操作图标</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-plus" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">plus</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-minus" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">minus</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-x-mark" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">x-mark</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-check" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">check</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-pencil" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">pencil</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-pencil-square" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">pencil-square</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-trash" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">trash</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-document-duplicate" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">document-duplicate</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-clipboard" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">clipboard</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-arrow-path" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">arrow-path</span>
            </div>
          </div>
        </div>
        
        <!-- 导航图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">导航图标</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-arrow-left" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">arrow-left</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-arrow-right" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">arrow-right</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-arrow-up" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">arrow-up</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-arrow-down" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">arrow-down</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-chevron-left" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">chevron-left</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-chevron-right" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">chevron-right</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-chevron-up" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">chevron-up</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-chevron-down" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">chevron-down</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-bars-3" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">bars-3</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-ellipsis-horizontal" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">ellipsis-horizontal</span>
            </div>
          </div>
        </div>
        
        <!-- 状态图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">状态图标</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-check-circle" class="w-6 h-6 mb-1 text-green-500" />
              <span class="text-xs text-gray-600">check-circle</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-x-circle" class="w-6 h-6 mb-1 text-red-500" />
              <span class="text-xs text-gray-600">x-circle</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-exclamation-circle" class="w-6 h-6 mb-1 text-yellow-500" />
              <span class="text-xs text-gray-600">exclamation-circle</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-information-circle" class="w-6 h-6 mb-1 text-blue-500" />
              <span class="text-xs text-gray-600">information-circle</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-exclamation-triangle" class="w-6 h-6 mb-1 text-orange-500" />
              <span class="text-xs text-gray-600">exclamation-triangle</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-question-mark-circle" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">question-mark-circle</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-lock-closed" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">lock-closed</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-lock-open" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">lock-open</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-shield-check" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">shield-check</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-eye" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">eye</span>
            </div>
          </div>
        </div>
        
        <!-- 文件和文档图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">文件和文档</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-document" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">document</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-document-text" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">document-text</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-folder" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">folder</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-folder-open" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">folder-open</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-paper-clip" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">paper-clip</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-photo" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">photo</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-cloud-arrow-up" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">cloud-arrow-up</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-cloud-arrow-down" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">cloud-arrow-down</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-archive-box" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">archive-box</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-printer" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">printer</span>
            </div>
          </div>
        </div>
        
        <!-- 商务和金融图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">商务和金融</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-shopping-cart" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">shopping-cart</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-shopping-bag" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">shopping-bag</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-credit-card" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">credit-card</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-banknotes" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">banknotes</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-chart-bar" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">chart-bar</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-chart-pie" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">chart-pie</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-presentation-chart-line" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">presentation-chart-line</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-calculator" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">calculator</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-receipt-percent" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">receipt-percent</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-building-office" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">building-office</span>
            </div>
          </div>
        </div>
        
        <!-- 媒体图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">媒体控制</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-play" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">play</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-pause" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">pause</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-stop" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">stop</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-forward" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">forward</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-backward" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">backward</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-speaker-wave" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">speaker-wave</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-speaker-x-mark" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">speaker-x-mark</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-microphone" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">microphone</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-camera" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">camera</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-video-camera" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">video-camera</span>
            </div>
          </div>
        </div>
        
        <!-- 其他实用图标 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">其他实用图标</h3>
          <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-4">
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-magnifying-glass" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">magnifying-glass</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-magnifying-glass-plus" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">magnifying-glass-plus</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-globe-alt" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">globe-alt</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-map-pin" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">map-pin</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-calendar" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">calendar</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-clock" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">clock</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-tag" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">tag</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-hashtag" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">hashtag</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-at-symbol" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">at-symbol</span>
            </div>
            <div class="flex flex-col items-center p-3 bg-gray-50 rounded">
              <.icon name="hero-link" class="w-6 h-6 mb-1 text-gray-700" />
              <span class="text-xs text-gray-600">link</span>
            </div>
          </div>
        </div>
        
        <!-- 图标尺寸示例 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">图标尺寸</h3>
          <div class="flex items-center gap-6">
            <div class="text-center">
              <.icon name="hero-heart" class="w-4 h-4 text-red-500 mb-1" />
              <p class="text-xs text-gray-600">w-4 h-4</p>
            </div>
            <div class="text-center">
              <.icon name="hero-heart" class="w-5 h-5 text-red-500 mb-1" />
              <p class="text-xs text-gray-600">w-5 h-5</p>
            </div>
            <div class="text-center">
              <.icon name="hero-heart" class="w-6 h-6 text-red-500 mb-1" />
              <p class="text-xs text-gray-600">w-6 h-6</p>
            </div>
            <div class="text-center">
              <.icon name="hero-heart" class="w-8 h-8 text-red-500 mb-1" />
              <p class="text-xs text-gray-600">w-8 h-8</p>
            </div>
            <div class="text-center">
              <.icon name="hero-heart" class="w-10 h-10 text-red-500 mb-1" />
              <p class="text-xs text-gray-600">w-10 h-10</p>
            </div>
            <div class="text-center">
              <.icon name="hero-heart" class="w-12 h-12 text-red-500 mb-1" />
              <p class="text-xs text-gray-600">w-12 h-12</p>
            </div>
          </div>
        </div>
        
        <!-- 使用说明 -->
        <div class="bg-blue-50 p-4 rounded-lg">
          <h4 class="font-medium text-blue-900 mb-2">使用说明</h4>
          <ul class="text-sm text-blue-800 space-y-1">
            <li>• 图标名称格式：<code class="bg-blue-100 px-1 rounded">hero-[icon-name]</code></li>
            <li>• 可以通过 class 属性设置尺寸和颜色：<code class="bg-blue-100 px-1 rounded">class="w-6 h-6 text-blue-500"</code></li>
            <li>• 支持所有 Tailwind CSS 的工具类</li>
            <li>• 完整图标列表请访问：<a href="https://heroicons.com/" target="_blank" class="underline">heroicons.com</a></li>
          </ul>
        </div>
      </section>
    </div>
    """
  end
  
  # 辅助函数已经被 PetalComponents.Modal 提供，无需重复定义
end