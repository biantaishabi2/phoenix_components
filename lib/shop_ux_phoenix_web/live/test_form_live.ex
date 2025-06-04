defmodule ShopUxPhoenixWeb.TestFormLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.FormBuilder
  
  alias ShopUxPhoenixWeb.FormStorage
  
  def mount(_params, session, socket) do
    session_id = session["session_id"] || "test-session"
    form_id = "auto-save-form"
    
    # 尝试恢复表单状态
    saved_state = FormStorage.get_form_state(session_id, form_id) || %{}
    
    config = %{
      fields: [
        %{type: "input", name: "name", label: "姓名", required: true},
        %{type: "email", name: "email", label: "邮箱"},
        %{type: "textarea", name: "description", label: "描述"}
      ]
    }
    
    {:ok, 
     socket
     |> assign(:session_id, session_id)
     |> assign(:form_id, form_id)
     |> assign(:config, config)
     |> assign(:form_data, saved_state)
     |> assign(:auto_save, true)
     |> assign(:save_debounce, 300)  # 短防抖用于测试
     |> assign(:save_timer, nil)
     |> assign(:last_saved, nil)}
  end
  
  def handle_event("form_change", params, socket) do
    # 保存表单状态
    schedule_save(socket, params)
    
    {:noreply, 
     socket
     |> assign(:form_data, params)}
  end
  
  def handle_event("form_submit", params, socket) do
    # 表单提交时立即保存并清理
    save_form_state(socket, params)
    FormStorage.delete_form_state(socket.assigns.session_id, socket.assigns.form_id)
    
    {:noreply, 
     socket
     |> assign(:form_data, %{})
     |> assign(:last_saved, "submitted")}
  end
  
  def handle_event("clear_form", _params, socket) do
    # 清除表单和存储状态
    FormStorage.delete_form_state(socket.assigns.session_id, socket.assigns.form_id)
    
    {:noreply, 
     socket
     |> assign(:form_data, %{})
     |> assign(:last_saved, "cleared")}
  end
  
  def handle_info(:save_form, socket) do
    save_form_state(socket, socket.assigns.form_data)
    
    {:noreply, 
     socket
     |> assign(:save_timer, nil)
     |> assign(:last_saved, System.system_time(:millisecond))}
  end
  
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1>自动保存表单测试</h1>
      
      <.form_builder 
        id={@form_id}
        config={@config}
        initial_data={@form_data}
        auto_save={@auto_save}
        save_debounce={@save_debounce}
        on_change="form_change"
        on_submit="form_submit"
      />
      
      <div class="mt-4 space-x-2">
        <button phx-click="clear_form" class="px-4 py-2 bg-red-500 text-white rounded">
          清除表单
        </button>
      </div>
      
      <div class="mt-4 text-sm text-gray-600">
        <div>会话ID: <%= @session_id %></div>
        <div>表单ID: <%= @form_id %></div>
        <%= if @last_saved do %>
          <div>最后保存: <%= @last_saved %></div>
        <% end %>
      </div>
    </div>
    """
  end
  
  defp schedule_save(socket, _params) do
    # 取消旧的定时器
    if socket.assigns.save_timer do
      Process.cancel_timer(socket.assigns.save_timer)
    end
    
    # 设置新的定时器
    timer = Process.send_after(self(), :save_form, socket.assigns.save_debounce)
    assign(socket, :save_timer, timer)
  end
  
  defp save_form_state(socket, params) do
    FormStorage.save_form_state(
      socket.assigns.session_id,
      socket.assigns.form_id,
      params
    )
  end
end