defmodule ShopUxPhoenixWeb.SwitchDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Switch
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Switch 组件")
     |> assign(:basic_checked, false)
     |> assign(:with_text_checked, true)
     |> assign(:notifications_enabled, true)
     |> assign(:auto_save_enabled, false)
     |> assign(:dark_mode, false)
     |> assign(:airplane_mode, false)
     |> assign(:loading_switch, false)
     |> assign(:form_data, %{
       "enable_specs" => false,
       "is_active" => true,
       "allow_comments" => true
     })}
  end

  def handle_event("toggle_basic", _, socket) do
    {:noreply, update(socket, :basic_checked, &(!&1))}
  end

  def handle_event("toggle_notifications", _, socket) do
    {:noreply, update(socket, :notifications_enabled, &(!&1))}
  end

  def handle_event("toggle_auto_save", _, socket) do
    {:noreply, update(socket, :auto_save_enabled, &(!&1))}
  end

  def handle_event("toggle_dark_mode", _, socket) do
    {:noreply, update(socket, :dark_mode, &(!&1))}
  end

  def handle_event("toggle_airplane_mode", _, socket) do
    {:noreply, update(socket, :airplane_mode, &(!&1))}
  end

  def handle_event("toggle_loading", _, socket) do
    # Simulate loading for 2 seconds
    Process.send_after(self(), :loading_complete, 2000)
    
    {:noreply,
     socket
     |> assign(:loading_switch, true)}
  end

  def handle_event("submit_form", %{"form" => form_params}, socket) do
    # Handle form submission
    {:noreply,
     socket
     |> assign(:form_data, form_params)
     |> put_flash(:info, "表单已提交：#{inspect(form_params)}")}
  end

  def handle_info(:loading_complete, socket) do
    {:noreply, 
     socket
     |> assign(:loading_switch, false)
     |> update(:basic_checked, &(!&1))}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">Switch 开关组件</h1>
      
      <div class="space-y-12">
        <!-- 基础用法 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">基础用法</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex items-center gap-4">
              <.switch 
                id="basic-switch"
                checked={@basic_checked}
                on_change={JS.push("toggle_basic")}
              />
              <span>状态：{@basic_checked && "开启" || "关闭"}</span>
            </div>
          </div>
        </section>

        <!-- 带文字和图标 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">带文字和图标</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <.switch 
                id="text-switch"
                checked={@with_text_checked}
                checked_text="开"
                unchecked_text="关"
              />
            </div>
            
            <div>
              <.switch id="icon-switch" checked>
                <:checked_children>
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                  </svg>
                </:checked_children>
                <:unchecked_children>
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                  </svg>
                </:unchecked_children>
              </.switch>
            </div>
            
            <div>
              <.switch 
                id="number-switch"
                checked
                checked_text="1"
                unchecked_text="0"
              />
            </div>
          </div>
        </section>

        <!-- 不同尺寸 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同尺寸</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div class="flex items-center gap-4">
              <.switch id="small-switch" size="small" checked />
              <span>小尺寸</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="medium-switch" size="medium" checked />
              <span>中等尺寸（默认）</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="large-switch" size="large" checked />
              <span>大尺寸</span>
            </div>
          </div>
        </section>

        <!-- 不同颜色 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同颜色主题</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div class="flex items-center gap-4">
              <.switch id="primary-switch" color="primary" checked />
              <span>Primary（默认）</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="info-switch" color="info" checked />
              <span>Info</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="success-switch" color="success" checked />
              <span>Success</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="warning-switch" color="warning" checked />
              <span>Warning</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="danger-switch" color="danger" checked />
              <span>Danger</span>
            </div>
          </div>
        </section>

        <!-- 禁用状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">禁用状态</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div class="flex items-center gap-4">
              <.switch id="disabled-off" disabled />
              <span>禁用状态（关）</span>
            </div>
            
            <div class="flex items-center gap-4">
              <.switch id="disabled-on" checked disabled />
              <span>禁用状态（开）</span>
            </div>
          </div>
        </section>

        <!-- 加载状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">加载状态</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex items-center gap-4">
              <.switch 
                id="loading-switch"
                checked={@loading_switch}
                loading={@loading_switch}
                on_change={JS.push("toggle_loading")}
              />
              <span>点击后显示加载状态</span>
            </div>
          </div>
        </section>

        <!-- 实际应用场景 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">实际应用场景</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-6">
            <!-- 通知设置 -->
            <div class="flex items-center justify-between p-4 border rounded">
              <div>
                <h4 class="font-semibold">推送通知</h4>
                <p class="text-sm text-gray-500">接收应用推送通知</p>
              </div>
              <.switch 
                id="notification-switch"
                checked={@notifications_enabled}
                on_change={JS.push("toggle_notifications")}
              />
            </div>
            
            <!-- 自动保存 -->
            <div class="flex items-center justify-between p-4 border rounded">
              <div>
                <h4 class="font-semibold">自动保存</h4>
                <p class="text-sm text-gray-500">自动保存您的更改</p>
              </div>
              <.switch 
                id="auto-save-switch"
                checked={@auto_save_enabled}
                on_change={JS.push("toggle_auto_save")}
                checked_text="ON"
                unchecked_text="OFF"
              />
            </div>
            
            <!-- 深色模式 -->
            <div class="flex items-center justify-between p-4 border rounded">
              <div>
                <h4 class="font-semibold">深色模式</h4>
                <p class="text-sm text-gray-500">切换应用外观主题</p>
              </div>
              <.switch 
                id="dark-mode-switch"
                checked={@dark_mode}
                on_change={JS.push("toggle_dark_mode")}
                color="info"
              />
            </div>
            
            <!-- 飞行模式 -->
            <div class="flex items-center justify-between p-4 border rounded">
              <div>
                <h4 class="font-semibold">飞行模式</h4>
                <p class="text-sm text-gray-500">关闭所有无线连接</p>
              </div>
              <.switch 
                id="airplane-mode-switch"
                checked={@airplane_mode}
                on_change={JS.push("toggle_airplane_mode")}
                color="warning"
              />
            </div>
          </div>
        </section>

        <!-- 在表单中使用 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">在表单中使用</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <form phx-submit="submit_form">
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    产品设置
                  </label>
                  <div class="space-y-3">
                    <div class="flex items-center justify-between">
                      <span>启用规格</span>
                      <.switch 
                        id="enable-specs"
                        name="form[enable_specs]"
                        checked={@form_data["enable_specs"]}
                      />
                    </div>
                    
                    <div class="flex items-center justify-between">
                      <span>上架状态</span>
                      <.switch 
                        id="is-active"
                        name="form[is_active]"
                        checked={@form_data["is_active"]}
                        checked_text="上架"
                        unchecked_text="下架"
                        color="success"
                      />
                    </div>
                    
                    <div class="flex items-center justify-between">
                      <span>允许评论</span>
                      <.switch 
                        id="allow-comments"
                        name="form[allow_comments]"
                        checked={@form_data["allow_comments"]}
                      />
                    </div>
                  </div>
                </div>
                
                <button type="submit" class="px-4 py-2 bg-primary text-white rounded hover:bg-primary/90">
                  提交表单
                </button>
              </div>
            </form>
            
            <%= if @form_data do %>
              <div class="mt-4 p-4 bg-gray-50 rounded">
                <p class="text-sm text-gray-600">表单数据：</p>
                <pre class="text-xs"><%= inspect(@form_data, pretty: true) %></pre>
              </div>
            <% end %>
          </div>
        </section>

        <!-- 与 Checkbox 的对比 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">与 Checkbox 的对比</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="grid grid-cols-2 gap-8">
              <div>
                <h3 class="font-semibold mb-3">Switch 开关</h3>
                <div class="space-y-3">
                  <.switch id="switch-demo-1" checked />
                  <p class="text-sm text-gray-600">
                    用于触发状态改变，立即生效
                  </p>
                </div>
              </div>
              
              <div>
                <h3 class="font-semibold mb-3">Checkbox 复选框</h3>
                <div class="space-y-3">
                  <.input type="checkbox" id="checkbox-demo-1" name="agree" value="true" checked label="同意协议" />
                  <p class="text-sm text-gray-600">
                    用于在表单中标记选择，提交后生效
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end
end