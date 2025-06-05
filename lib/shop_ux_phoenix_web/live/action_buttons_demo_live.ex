defmodule ShopUxPhoenixWeb.ActionButtonsDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.ActionButtons

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "ActionButtons 操作按钮组组件")
     |> assign(:selected_items, [])
     |> assign(:show_edit, true)
     |> assign(:show_delete, true)
     |> assign(:show_publish, false)
     |> assign(:dropdown_open, false)
     |> assign(:items, [
       %{id: 1, name: "商品 A", status: "active", price: "¥99.00"},
       %{id: 2, name: "商品 B", status: "inactive", price: "¥199.00"},
       %{id: 3, name: "商品 C", status: "active", price: "¥299.00"}
     ])}
  end

  def handle_event("toggle_selection", %{"id" => id}, socket) do
    id = String.to_integer(id)
    selected = socket.assigns.selected_items
    
    new_selected = if id in selected do
      Enum.reject(selected, &(&1 == id))
    else
      [id | selected]
    end
    
    {:noreply, assign(socket, :selected_items, new_selected)}
  end

  def handle_event("action", %{"type" => action_type} = params, socket) do
    message = case action_type do
      "edit" -> "编辑操作: #{params["id"] || "批量"}"
      "delete" -> "删除操作: #{params["id"] || "批量"}"
      "view" -> "查看操作: #{params["id"]}"
      "save" -> "保存操作"
      "cancel" -> "取消操作"
      "save_draft" -> "保存草稿"
      _ -> "未知操作: #{action_type}"
    end
    
    {:noreply, put_flash(socket, :info, message)}
  end

  def handle_event("toggle_buttons", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_edit, !socket.assigns.show_edit)
     |> assign(:show_publish, !socket.assigns.show_publish)}
  end

  def handle_event("toggle_dropdown", _params, socket) do
    {:noreply, assign(socket, :dropdown_open, !socket.assigns.dropdown_open)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 w-full">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">ActionButtons 操作按钮组组件</h1>
      
      <!-- 基础用法 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础用法</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.action_buttons>
            <.button phx-click="action" phx-value-type="edit">编辑</.button>
            <.button phx-click="action" phx-value-type="delete">删除</.button>
            <.button phx-click="action" phx-value-type="view">查看详情</.button>
          </.action_buttons>
        </div>
      </section>

      <!-- 表格操作列 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">表格操作列</h2>
        <div class="bg-white rounded-lg shadow overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">名称</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">状态</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">价格</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">操作</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for item <- @items do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap"><%= item.name %></td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class={[
                      "px-2 py-1 text-xs rounded-full",
                      item.status == "active" && "bg-green-100 text-green-800",
                      item.status == "inactive" && "bg-gray-100 text-gray-800"
                    ]}>
                      <%= item.status %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap"><%= item.price %></td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <.action_buttons size="small" spacing="small">
                      <.link navigate="#" class="text-blue-600 hover:text-blue-700">查看</.link>
                      <.link navigate="#" class="text-blue-600 hover:text-blue-700">编辑</.link>
                      <.link 
                        phx-click="action" 
                        phx-value-type="delete"
                        phx-value-id={item.id}
                        data-confirm="确定要删除吗？"
                        class="text-red-600 hover:text-red-700"
                      >
                        删除
                      </.link>
                    </.action_buttons>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 表单按钮 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">表单按钮</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <form phx-submit="action" phx-value-type="save">
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                示例表单字段
              </label>
              <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            
            <.action_buttons align="right">
              <.button type="button" phx-click="action" phx-value-type="cancel">
                取消
              </.button>
              <.button type="button" phx-click="action" phx-value-type="save_draft">
                保存草稿
              </.button>
              <.button type="submit">
                提交
              </.button>
            </.action_buttons>
          </form>
        </div>
      </section>

      <!-- 按钮间距 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">按钮间距</h2>
        <div class="space-y-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">紧凑间距 (small)</p>
            <.action_buttons spacing="small">
              <.button>按钮 1</.button>
              <.button>按钮 2</.button>
              <.button>按钮 3</.button>
            </.action_buttons>
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">标准间距 (medium)</p>
            <.action_buttons spacing="medium">
              <.button>按钮 1</.button>
              <.button>按钮 2</.button>
              <.button>按钮 3</.button>
            </.action_buttons>
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">宽松间距 (large)</p>
            <.action_buttons spacing="large">
              <.button>按钮 1</.button>
              <.button>按钮 2</.button>
              <.button>按钮 3</.button>
            </.action_buttons>
          </div>
        </div>
      </section>

      <!-- 对齐方式 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">对齐方式</h2>
        <div class="space-y-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">左对齐</p>
            <.action_buttons align="left">
              <.button>操作 1</.button>
              <.button>操作 2</.button>
            </.action_buttons>
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">居中</p>
            <.action_buttons align="center">
              <.button>操作 1</.button>
              <.button>操作 2</.button>
            </.action_buttons>
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">右对齐</p>
            <.action_buttons align="right">
              <.button>操作 1</.button>
              <.button>操作 2</.button>
            </.action_buttons>
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <p class="text-sm text-gray-600 mb-2">两端对齐</p>
            <.action_buttons align="between">
              <div>
                <.button>左侧按钮 1</.button>
                <.button>左侧按钮 2</.button>
              </div>
              <:extra>
                <.button>右侧按钮</.button>
              </:extra>
            </.action_buttons>
          </div>
        </div>
      </section>

      <!-- 垂直布局 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">垂直布局</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.action_buttons direction="vertical" spacing="small">
            <.button class="w-full justify-start">
              <.icon name="hero-user" class="w-4 h-4 mr-2" />
              编辑资料
            </.button>
            <.button class="w-full justify-start">
              <.icon name="hero-key" class="w-4 h-4 mr-2" />
              修改密码
            </.button>
            <.button class="w-full justify-start">
              <.icon name="hero-bell" class="w-4 h-4 mr-2" />
              通知设置
            </.button>
            <.button class="w-full justify-start">
              <.icon name="hero-shield-check" class="w-4 h-4 mr-2" />
              隐私设置
            </.button>
          </.action_buttons>
        </div>
      </section>

      <!-- 带分隔符 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">带分隔符</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.action_buttons divider spacing="none">
            <.link navigate="#" class="text-gray-700 hover:text-gray-900">首页</.link>
            <.link navigate="#" class="text-gray-700 hover:text-gray-900">产品</.link>
            <.link navigate="#" class="text-gray-700 hover:text-gray-900">服务</.link>
            <.link navigate="#" class="text-gray-700 hover:text-gray-900">关于</.link>
            <.link navigate="#" class="text-gray-700 hover:text-gray-900">联系</.link>
          </.action_buttons>
        </div>
      </section>


      <!-- 批量操作 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">批量操作</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="mb-4">
            <label class="flex items-center">
              <input 
                type="checkbox" 
                phx-click="toggle_selection" 
                phx-value-id="1"
                checked={1 in @selected_items}
                class="mr-2"
              />
              选择项目 1
            </label>
            <label class="flex items-center">
              <input 
                type="checkbox" 
                phx-click="toggle_selection" 
                phx-value-id="2"
                checked={2 in @selected_items}
                class="mr-2"
              />
              选择项目 2
            </label>
          </div>
          
          <.batch_actions 
            selected_count={length(@selected_items)}
            create_path="#"
            create_label="新建项目"
          />
        </div>
      </section>

      <!-- 条件渲染 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">条件渲染</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="mb-4">
            <.button phx-click="toggle_buttons" class="mb-4">
              切换按钮显示状态
            </.button>
          </div>
          
          <.action_buttons>
            <.button :if={@show_edit} phx-click="action" phx-value-type="edit">
              编辑（可见按钮）
            </.button>
            <.button :if={@show_delete} phx-click="action" phx-value-type="delete">
              删除（可见按钮）
            </.button>
            <.button :if={@show_publish} phx-click="action" phx-value-type="publish">
              发布（隐藏按钮）
            </.button>
            <.button phx-click="action" phx-value-type="view">
              查看（始终可见）
            </.button>
          </.action_buttons>
        </div>
      </section>

      <!-- 内置模板 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">内置模板</h2>
        
        <div class="space-y-4">
          <div class="bg-white p-6 rounded-lg shadow">
            <h3 class="text-lg font-medium mb-3">CRUD 操作模板</h3>
            <.crud_actions
              id={1}
              view_path="#"
              edit_path="#"
              can_edit={true}
              can_delete={true}
            />
          </div>
          
          <div class="bg-white p-6 rounded-lg shadow">
            <h3 class="text-lg font-medium mb-3">表单操作模板</h3>
            <.form_actions
              cancel_path="#"
              can_save_draft={true}
            />
          </div>
        </div>
      </section>

      <!-- 混合内容 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">混合内容</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.action_buttons>
            <.button>Phoenix 按钮</.button>
            <button class="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300">
              HTML 按钮
            </button>
            <a href="#" class="text-blue-600 hover:text-blue-700">
              普通链接
            </a>
            <.link navigate="#" class="text-purple-600 hover:text-purple-700">
              Phoenix 链接
            </.link>
          </.action_buttons>
        </div>
      </section>
    </div>
    """
  end
end