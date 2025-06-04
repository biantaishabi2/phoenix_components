defmodule ShopUxPhoenixWeb.ProgressDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.Progress

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Progress 进度条组件")
     |> assign(:dynamic_percent, 0)
     |> assign(:dynamic_timer, nil)
     |> assign(:password, "")
     |> assign(:password_strength, 0)
     |> assign(:upload_progress, 0)
     |> assign(:batch_progress, 0)
     |> assign(:batch_processed, 0)
     |> assign(:batch_total, 100)}
  end

  def handle_event("start_progress", _params, socket) do
    timer = Process.send_after(self(), :tick, 100)
    {:noreply, assign(socket, dynamic_percent: 0, dynamic_timer: timer)}
  end

  def handle_event("reset_progress", _params, socket) do
    if socket.assigns.dynamic_timer do
      Process.cancel_timer(socket.assigns.dynamic_timer)
    end
    {:noreply, assign(socket, dynamic_percent: 0, dynamic_timer: nil)}
  end

  def handle_event("check_password", %{"password" => %{"value" => password}}, socket) do
    strength = calculate_password_strength(password)
    {:noreply, assign(socket, password: password, password_strength: strength)}
  end

  def handle_event("simulate_upload", _params, socket) do
    Process.send_after(self(), :upload_tick, 100)
    {:noreply, assign(socket, upload_progress: 0)}
  end

  def handle_event("simulate_batch", _params, socket) do
    Process.send_after(self(), :batch_tick, 50)
    {:noreply, assign(socket, batch_progress: 0, batch_processed: 0)}
  end

  def handle_info(:tick, socket) do
    percent = min(socket.assigns.dynamic_percent + 2, 100)
    
    timer = if percent < 100 do
      Process.send_after(self(), :tick, 100)
    else
      nil
    end
    
    {:noreply, assign(socket, dynamic_percent: percent, dynamic_timer: timer)}
  end

  def handle_info(:upload_tick, socket) do
    progress = min(socket.assigns.upload_progress + 5, 100)
    
    if progress < 100 do
      Process.send_after(self(), :upload_tick, 100)
    end
    
    {:noreply, assign(socket, upload_progress: progress)}
  end

  def handle_info(:batch_tick, socket) do
    progress = min(socket.assigns.batch_progress + 1, 100)
    processed = div(progress * socket.assigns.batch_total, 100)
    
    if progress < 100 do
      Process.send_after(self(), :batch_tick, 50)
    end
    
    {:noreply, assign(socket, batch_progress: progress, batch_processed: processed)}
  end

  defp calculate_password_strength(password) do
    length = String.length(password)
    has_lowercase = password =~ ~r/[a-z]/
    has_uppercase = password =~ ~r/[A-Z]/
    has_number = password =~ ~r/[0-9]/
    has_special = password =~ ~r/[!@#$%^&*(),.?":{}|<>]/
    
    score = 0
    score = score + min(length * 5, 20)  # Max 20 points for length (reduced)
    score = if has_lowercase, do: score + 20, else: score
    score = if has_uppercase, do: score + 20, else: score
    score = if has_number, do: score + 20, else: score
    score = if has_special, do: score + 20, else: score
    
    min(score, 100)
  end

  defp password_status(strength) when strength < 40, do: "exception"
  defp password_status(strength) when strength < 70, do: "normal"
  defp password_status(_), do: "success"

  defp password_text(strength) when strength < 40, do: "弱"
  defp password_text(strength) when strength < 70, do: "中"
  defp password_text(_), do: "强"

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">Progress 进度条组件</h1>
      
      <style>
        @keyframes progress-active {
          0% {
            background-position: 0 0;
          }
          100% {
            background-position: 32px 0;
          }
        }
        
        .pc-progress__bar--active {
          background-image: linear-gradient(
            45deg,
            rgba(255, 255, 255, 0.15) 25%,
            transparent 25%,
            transparent 50%,
            rgba(255, 255, 255, 0.15) 50%,
            rgba(255, 255, 255, 0.15) 75%,
            transparent 75%,
            transparent
          );
          background-size: 32px 32px;
          animation: progress-active 0.5s linear infinite;
        }
        
        .pc-progress {
          @apply flex items-center gap-2;
        }
        
        .pc-progress--line .pc-progress__outer {
          @apply flex-1;
        }
        
        .pc-progress--circle {
          @apply relative;
        }
        
        .pc-progress__circle-info {
          @apply absolute inset-0 flex items-center justify-center;
        }
      </style>
      
      <div class="space-y-12">
        <!-- 基础用法 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">基础用法</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <.progress percent={30} />
            <.progress percent={50} />
            <.progress percent={70} />
            <.progress percent={100} />
          </div>
        </section>

        <!-- 不同状态 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同状态</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <p class="text-sm text-gray-600 mb-2">普通状态</p>
              <.progress percent={30} status="normal" />
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-2">激活状态（动画效果）</p>
              <.progress percent={50} status="active" />
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-2">成功状态</p>
              <.progress percent={100} status="success" />
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-2">异常状态</p>
              <.progress percent={70} status="exception" />
            </div>
          </div>
        </section>

        <!-- 不同尺寸 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不同尺寸</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <div>
              <p class="text-sm text-gray-600 mb-2">小尺寸</p>
              <.progress percent={30} size="small" />
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-2">中等尺寸（默认）</p>
              <.progress percent={30} size="medium" />
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-2">大尺寸</p>
              <.progress percent={30} size="large" />
            </div>
          </div>
        </section>

        <!-- 不显示进度数值 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">不显示进度数值</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <.progress percent={75} show_info={false} />
          </div>
        </section>

        <!-- 自定义颜色 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">自定义颜色</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <.progress percent={50} stroke_color="#87d068" />
            <.progress percent={30} stroke_color="#ff4d4f" trail_color="#ffe58f" />
          </div>
        </section>

        <!-- 自定义格式 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">自定义格式</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <.progress percent={90} format_fn={fn percent -> "#{percent} Days" end} />
            <.progress percent={60} format_fn={fn _percent -> "完成" end} />
            <.progress percent={80}>
              <:format :let={percent}>
                <%= if percent >= 80 do %>
                  <span class="text-success flex items-center gap-1">
                    <.icon name="hero-check-circle-mini" class="w-4 h-4" />
                    优秀
                  </span>
                <% else %>
                  <span><%= percent %>%</span>
                <% end %>
              </:format>
            </.progress>
          </div>
        </section>

        <!-- 环形进度条 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">环形进度条</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex items-center gap-8">
              <.progress type="circle" percent={75} />
              <.progress type="circle" percent={100} status="success" />
              <.progress type="circle" percent={70} status="exception" />
              <.progress type="circle" percent={50} status="active" />
            </div>
          </div>
        </section>

        <!-- 环形尺寸 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">环形尺寸</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="flex items-center gap-8">
              <.progress type="circle" percent={30} width={80} />
              <.progress type="circle" percent={30} width={120} />
              <.progress type="circle" percent={30} width={160} />
            </div>
          </div>
        </section>

        <!-- 环形进度条缺口 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">环形进度条缺口</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
              <div class="text-center">
                <.progress type="circle" percent={75} gap_degree={90} gap_position="bottom" />
                <p class="mt-2 text-sm text-gray-600">缺口在底部</p>
              </div>
              <div class="text-center">
                <.progress type="circle" percent={75} gap_degree={90} gap_position="top" />
                <p class="mt-2 text-sm text-gray-600">缺口在顶部</p>
              </div>
              <div class="text-center">
                <.progress type="circle" percent={75} gap_degree={90} gap_position="left" />
                <p class="mt-2 text-sm text-gray-600">缺口在左侧</p>
              </div>
              <div class="text-center">
                <.progress type="circle" percent={75} gap_degree={90} gap_position="right" />
                <p class="mt-2 text-sm text-gray-600">缺口在右侧</p>
              </div>
            </div>
          </div>
        </section>

        <!-- 动态进度 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">动态进度</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <.progress 
              percent={@dynamic_percent} 
              status={if @dynamic_percent < 100, do: "active", else: "success"} 
            />
            <div class="flex gap-2">
              <button
                phx-click="start_progress"
                disabled={@dynamic_timer != nil}
                class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <%= if @dynamic_timer, do: "进行中...", else: "开始" %>
              </button>
              <button
                phx-click="reset_progress"
                class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600"
              >
                重置
              </button>
            </div>
          </div>
        </section>

        <!-- 密码强度指示器 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">密码强度指示器</h2>
          <div class="bg-white p-6 rounded-lg shadow">
            <form id="password-form" phx-change="check_password">
              <div class="space-y-3">
                <input
                  type="password"
                  name="password[value]"
                  value={@password}
                  placeholder="请输入密码"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
                <.progress 
                  percent={@password_strength} 
                  status={password_status(@password_strength)}
                >
                  <:format :let={_percent}>
                    <%= password_text(@password_strength) %>
                  </:format>
                </.progress>
              </div>
            </form>
          </div>
        </section>

        <!-- 渐变色进度条 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">渐变色进度条</h2>
          <div class="bg-white p-6 rounded-lg shadow space-y-4">
            <.progress percent={80} stroke_color="linear-gradient(to right, #108ee9, #87d068)" />
            <.progress percent={60} stroke_color="linear-gradient(to right, #ff4d4f, #ff7a45)" />
            <.progress percent={90} stroke_color="linear-gradient(to right, #722ed1, #eb2f96)" />
          </div>
        </section>

        <!-- 实际应用场景 -->
        <section>
          <h2 class="text-2xl font-semibold mb-4">实际应用场景</h2>
          
          <!-- 文件上传 -->
          <div class="bg-white p-6 rounded-lg shadow mb-6">
            <h3 class="text-lg font-medium mb-4">文件上传</h3>
            <div class="space-y-3">
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600">document.pdf</span>
                <span class="text-sm font-medium"><%= @upload_progress %>%</span>
              </div>
              <.progress 
                percent={@upload_progress} 
                status={if @upload_progress < 100, do: "active", else: "success"}
                show_info={false}
              />
              <button
                phx-click="simulate_upload"
                disabled={@upload_progress > 0 && @upload_progress < 100}
                class="text-sm text-primary hover:text-primary-dark disabled:opacity-50"
              >
                模拟上传
              </button>
            </div>
          </div>

          <!-- 批量操作 -->
          <div class="bg-white p-6 rounded-lg shadow mb-6">
            <h3 class="text-lg font-medium mb-4">批量操作</h3>
            <div class="space-y-3">
              <.progress 
                percent={@batch_progress} 
                status={if @batch_progress < 100, do: "active", else: "success"}
                format_fn={fn _percent -> "已处理 #{@batch_processed}/#{@batch_total} 条" end}
              />
              <button
                phx-click="simulate_batch"
                disabled={@batch_progress > 0 && @batch_progress < 100}
                class="text-sm text-primary hover:text-primary-dark disabled:opacity-50"
              >
                开始批量处理
              </button>
            </div>
          </div>

          <!-- 步骤进度 -->
          <div class="bg-white p-6 rounded-lg shadow">
            <h3 class="text-lg font-medium mb-4">步骤进度</h3>
            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-gray-600">第 3 步，共 4 步</span>
                <span class="font-medium">75%</span>
              </div>
              <.progress percent={75} show_info={false} />
              <p class="text-sm text-gray-500">正在处理订单信息...</p>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end
end