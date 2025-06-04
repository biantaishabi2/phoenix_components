defmodule ShopUxPhoenixWeb.FormBuilderDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import ShopUxPhoenixWeb.Components.FormBuilder
  
  alias ShopUxPhoenixWeb.FormStorage

  def mount(_params, session, socket) do
    session_id = session["session_id"] || "demo-session"
    
    # 恢复自动保存表单的状态
    auto_save_data = FormStorage.get_form_state(session_id, "auto-save-demo-form") || %{}
    
    {:ok,
     socket
     |> assign(:page_title, "FormBuilder 表单构建器组件")
     |> assign(:basic_form_data, %{})
     |> assign(:user_form_data, %{})
     |> assign(:company_form_data, %{})
     |> assign(:survey_form_data, %{})
     |> assign(:auto_save_data, auto_save_data)
     |> assign(:session_id, session_id)
     |> assign(:form_errors, %{})
     |> assign(:form_loading, false)
     |> assign(:submitted_data, nil)
     |> assign(:auto_save_timer, nil)
     |> assign(:last_save_time, nil)
     |> assign(:smart_linkage_data, %{})
     |> assign(:dynamic_options, %{})}
  end

  # 所有 handle_event 函数
  
  def handle_event("basic_form_submit", params, socket) do
    IO.inspect(params, label: "Basic form submitted")
    
    {:noreply,
     socket
     |> assign(:submitted_data, params)
     |> put_flash(:info, "基础表单提交成功！")}
  end

  def handle_event("user_form_submit", params, socket) do
    IO.inspect(params, label: "User form submitted")
    
    # 模拟验证
    case validate_user_form(params) do
      {:ok, data} ->
        {:noreply,
         socket
         |> assign(:submitted_data, data)
         |> assign(:form_errors, %{})
         |> put_flash(:info, "用户表单提交成功！")}
      
      {:error, errors} ->
        {:noreply,
         socket
         |> assign(:form_errors, errors)
         |> put_flash(:error, "表单验证失败，请检查输入")}
    end
  end

  def handle_event("company_form_submit", params, socket) do
    IO.inspect(params, label: "Company form submitted")
    
    {:noreply,
     socket
     |> assign(:submitted_data, params)
     |> put_flash(:info, "企业表单提交成功！")}
  end

  def handle_event("survey_form_submit", params, socket) do
    IO.inspect(params, label: "Survey form submitted")
    
    {:noreply,
     socket
     |> assign(:submitted_data, params)
     |> put_flash(:info, "调查表单提交成功！")}
  end

  def handle_event("form_field_changed", params, socket) do
    IO.inspect(params, label: "Form field changed")
    {:noreply, socket}
  end

  def handle_event("reset_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:submitted_data, nil)
     |> assign(:form_errors, %{})
     |> put_flash(:info, "表单已重置")}
  end

  def handle_event("simulate_loading", _params, socket) do
    send(self(), :stop_loading)
    
    {:noreply,
     socket
     |> assign(:form_loading, true)
     |> put_flash(:info, "模拟提交中...")}
  end

  # 自动保存相关事件处理
  def handle_event("auto_save_form_change", params, socket) do
    # 防抖保存
    schedule_auto_save(socket, params)
    
    {:noreply, 
     socket
     |> assign(:auto_save_data, params)}
  end
  
  def handle_event("auto_save_form_submit", params, socket) do
    # 提交时立即保存并清理
    FormStorage.save_form_state(socket.assigns.session_id, "auto-save-demo-form", params)
    FormStorage.delete_form_state(socket.assigns.session_id, "auto-save-demo-form")
    
    {:noreply,
     socket
     |> assign(:auto_save_data, %{})
     |> assign(:last_save_time, nil)
     |> put_flash(:info, "表单提交成功，自动保存已清理！")}
  end
  
  def handle_event("clear_auto_save", _params, socket) do
    FormStorage.delete_form_state(socket.assigns.session_id, "auto-save-demo-form")
    
    {:noreply,
     socket
     |> assign(:auto_save_data, %{})
     |> assign(:last_save_time, nil)
     |> put_flash(:info, "自动保存数据已清理！")}
  end
  
  def handle_event("smart_linkage_change", params, socket) do
    # 处理字段变化，更新依赖字段的选项
    old_data = socket.assigns.smart_linkage_data
    
    # 检测哪个字段发生了变化
    changed_fields = detect_changed_fields(old_data, params)
    
    # 处理每个变化的字段
    socket = Enum.reduce(changed_fields, socket, fn field_name, acc_socket ->
      case field_name do
        "province" ->
          # 更新城市选项
          cities = get_cities_for_province(params["province"])
          acc_socket
          |> update_dynamic_options("city", cities)
          |> update_dynamic_options("district", [%{value: "", label: "请先选择城市"}])  # 重置区县
        
        "city" ->
          # 更新区县选项
          districts = get_districts_for_city(params["city"])
          update_dynamic_options(acc_socket, "district", districts)
        
        "product_type" ->
          # 根据产品类型显示不同字段
          acc_socket
        
        "category" ->
          # 处理类别选择（用于错误恢复演示）
          if params["category"] == "invalid" do
            acc_socket
            |> put_flash(:error, "加载选项失败")
            |> assign(:form_errors, Map.put(acc_socket.assigns.form_errors, "subcategory", "加载选项失败"))
          else
            acc_socket
            |> clear_flash(:error)
            |> assign(:form_errors, Map.delete(acc_socket.assigns.form_errors, "subcategory"))
          end
        
        _ ->
          acc_socket
      end
    end)
    
    {:noreply, assign(socket, :smart_linkage_data, params)}
  end
  
  def handle_event("order_form_submit", _params, socket) do
    # 模拟订单提交成功
    {:noreply,
     socket
     |> put_flash(:info, "订单提交成功！")
     |> push_navigate(to: "/orders/success")}
  end
  
  def handle_event("validate_username_change", params, socket) do
    # 处理表单 change 事件，检查用户名
    username = params["username"]
    
    if username && String.length(username) > 0 do
      # 模拟用户名验证
      is_valid = !Enum.member?(["admin", "john", "test"], username)
      error = if is_valid, do: nil, else: "用户名已存在"
      
      {:noreply,
       socket
       |> assign(:form_errors, Map.put(socket.assigns.form_errors, "username", error))}
    else
      {:noreply, socket}
    end
  end
  
  def handle_event("validate_field", params, socket) when is_map(params) do
    # 处理包含整个表单数据的参数格式
    # 这种格式来自于表单的 phx-change 事件
    {:noreply, socket}
  end
  
  def handle_event("validate_field", %{"field" => field_name, "value" => value}, socket) do
    # 异步验证字段
    case field_name do
      "username" ->
        # 模拟用户名验证
        is_valid = !Enum.member?(["admin", "john", "test"], value)
        error = if is_valid, do: nil, else: "用户名已存在"
        
        {:noreply,
         socket
         |> assign(:form_errors, Map.put(socket.assigns.form_errors, field_name, error))}
      
      _ ->
        {:noreply, socket}
    end
  end
  
  # 所有 handle_info 函数
  
  def handle_info(:stop_loading, socket) do
    Process.sleep(2000)  # 模拟网络延迟
    
    {:noreply,
     socket
     |> assign(:form_loading, false)
     |> put_flash(:info, "提交完成！")}
  end
  
  def handle_info(:auto_save, socket) do
    FormStorage.save_form_state(
      socket.assigns.session_id, 
      "auto-save-demo-form", 
      socket.assigns.auto_save_data
    )
    
    {:noreply,
     socket
     |> assign(:auto_save_timer, nil)
     |> assign(:last_save_time, DateTime.utc_now() |> DateTime.to_string())}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 max-w-7xl mx-auto">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">FormBuilder 表单构建器组件</h1>
      
      <!-- 基础表单 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">基础表单</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="basic-form"
            config={get_basic_form_config()}
            on_submit="basic_form_submit"
            on_change="form_field_changed"
            on_reset="reset_form"
            data-testid="basic-form"
          />
        </div>
      </section>

      <!-- 水平布局表单 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">水平布局表单</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="horizontal-form"
            layout="horizontal"
            config={get_user_form_config()}
            initial_data={%{"name" => "张三", "email" => "zhangsan@example.com"}}
            on_submit="user_form_submit"
            data-testid="horizontal-form"
          />
        </div>
      </section>

      <!-- 网格布局表单 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">网格布局表单</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="grid-form"
            layout="grid"
            config={get_grid_form_config()}
            on_submit="company_form_submit"
            data-testid="grid-form"
          />
        </div>
      </section>

      <!-- 内联表单 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">内联表单（搜索过滤）</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="inline-form"
            layout="inline"
            config={get_inline_form_config()}
            size="small"
            submit_text="搜索"
            reset_text="清空"
            data-testid="inline-form"
          />
        </div>
      </section>

      <!-- 分组表单 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">分组表单</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="grouped-form"
            config={get_grouped_form_config()}
            data-testid="grouped-form"
          />
        </div>
      </section>

      <!-- 条件显示表单 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">条件显示表单</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="conditional-form"
            config={get_conditional_form_config()}
            data-testid="conditional-form"
          />
        </div>
      </section>

      <!-- 复杂表单（调查问卷） -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">复杂表单示例</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="survey-form"
            config={get_survey_form_config()}
            size="large"
            on_submit="survey_form_submit"
            data-testid="survey-form"
          />
        </div>
      </section>

      <!-- 表单状态演示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">表单状态</h2>
        <div class="bg-white p-6 rounded-lg shadow grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <h3 class="text-lg font-medium mb-3">禁用状态</h3>
            <.form_builder
              id="disabled-form"
              config={get_basic_form_config()}
              disabled={true}
              data-testid="disabled-form"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">只读状态</h3>
            <.form_builder
              id="readonly-form"
              config={get_basic_form_config()}
              readonly={true}
              initial_data={%{"name" => "只读数据", "email" => "readonly@example.com"}}
              data-testid="readonly-form"
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-3">加载状态</h3>
            <.form_builder
              id="loading-form"
              config={get_basic_form_config()}
              loading={@form_loading}
              on_submit="simulate_loading"
              data-testid="loading-form"
            />
          </div>
        </div>
      </section>

      <!-- 智能字段联动演示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">智能字段联动</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <!-- 省市区三级联动 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">省市区三级联动</h3>
            <.form_builder
              id="address-linkage-form"
              config={get_address_linkage_config(@dynamic_options)}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="address-linkage-form"
            />
          </div>
          
          <!-- 动态表单 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">动态表单（根据产品类型显示不同字段）</h3>
            <.form_builder
              id="product-type-form"
              config={get_product_type_config()}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="product-type-form"
            />
          </div>
          
          <!-- 计算字段 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">实时计算</h3>
            <.form_builder
              id="calculation-form"
              config={get_calculation_config()}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="calculation-form"
            />
          </div>
          
          <!-- 用户类型动态表单 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">动态显示隐藏字段</h3>
            <.form_builder
              id="user-type-form"
              config={get_user_type_config()}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="user-type-form"
            />
          </div>
          
          <!-- 会员特权 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">复杂条件联动 - 会员特权</h3>
            <.form_builder
              id="member-privilege-form"
              config={get_member_privilege_config()}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="member-privilege-form"
            />
          </div>
          
          <!-- 防抖搜索 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">防抖机制演示</h3>
            <.form_builder
              id="search-form"
              config={get_search_form_config()}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="search-form"
            />
          </div>
          
          <!-- 错误恢复 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">错误恢复演示</h3>
            <.form_builder
              id="error-recovery-form"
              config={get_error_recovery_config()}
              on_change="smart_linkage_change"
              errors={@form_errors}
              data-testid="error-recovery-form"
            />
          </div>
          
          <!-- 异步验证 -->
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">异步验证</h3>
            <.form_builder
              id="async-validation-form"
              config={get_async_validation_config()}
              errors={@form_errors}
              on_change="validate_username_change"
              data-testid="async-validation-form"
            />
          </div>
        </div>
      </section>

      <!-- 自动保存功能演示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">自动保存功能</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <div class="mb-4 p-4 bg-blue-50 rounded-lg">
            <h3 class="text-lg font-medium text-blue-900 mb-2">🔄 实时自动保存演示</h3>
            <p class="text-blue-700 text-sm mb-2">
              此表单开启了自动保存功能，您的输入会在停止1秒后自动保存到浏览器会话中。
              即使刷新页面，您的输入也会被恢复。
            </p>
            <div class="flex items-center space-x-4 text-sm">
              <div class="flex items-center">
                <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                <span class="text-gray-600">会话ID: <%= String.slice(@session_id, 0, 8) %>...</span>
              </div>
              <%= if @last_save_time do %>
                <div class="flex items-center">
                  <span class="w-2 h-2 bg-blue-500 rounded-full mr-2"></span>
                  <span class="text-gray-600">最后保存: <%= String.slice(@last_save_time, 11, 8) %></span>
                </div>
              <% else %>
                <div class="flex items-center">
                  <span class="w-2 h-2 bg-gray-400 rounded-full mr-2"></span>
                  <span class="text-gray-500">尚未保存</span>
                </div>
              <% end %>
            </div>
          </div>
          
          <.form_builder
            id="auto-save-demo-form"
            config={get_auto_save_form_config()}
            initial_data={@auto_save_data}
            auto_save={true}
            save_debounce={1000}
            on_change="auto_save_form_change"
            on_submit="auto_save_form_submit"
            submit_text="发布文章"
            data-testid="auto-save-form"
          />
          
          <div class="mt-4 flex space-x-3">
            <button 
              phx-click="clear_auto_save"
              class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm"
            >
              🗑️ 清除草稿
            </button>
            <div class="text-sm text-gray-500 py-2">
              提示：尝试输入内容，然后刷新页面查看自动保存效果
            </div>
          </div>
        </div>
      </section>

      <!-- 集成场景演示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">集成场景演示</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <!-- 完整订单表单 -->
          <div class="mb-8">
            <h3 class="text-lg font-medium text-gray-900 mb-4">完整订单表单流程</h3>
            <.form_builder
              id="order-form"
              config={get_order_form_config(@dynamic_options)}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              on_submit="order_form_submit"
              data-testid="order-form"
            />
          </div>
          
          <!-- 动态问卷调查 -->
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">动态问卷调查</h3>
            <.form_builder
              id="survey-dynamic-form"
              config={get_dynamic_survey_config()}
              initial_data={@smart_linkage_data}
              on_change="smart_linkage_change"
              data-testid="survey-dynamic-form"
            />
          </div>
        </div>
      </section>

      <!-- 字段类型展示 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">所有字段类型</h2>
        <div class="bg-white p-6 rounded-lg shadow">
          <.form_builder
            id="field-types-form"
            config={get_field_types_config()}
            layout="grid"
            data-testid="field-types-form"
          />
        </div>
      </section>

      <!-- 提交结果显示 -->
      <%= if @submitted_data do %>
        <section class="mb-12">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">最后提交的数据</h2>
          <div class="bg-green-50 border border-green-200 rounded-lg p-4">
            <pre class="text-sm text-green-800 overflow-x-auto"><%= Jason.encode!(@submitted_data, pretty: true) %></pre>
          </div>
        </section>
      <% end %>

      <!-- 使用说明 -->
      <section class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-900 mb-4">使用说明</h2>
        <div class="bg-gray-100 p-6 rounded-lg">
          <p class="text-gray-700 mb-4">
            FormBuilder 组件通过配置驱动的方式快速生成表单界面。支持20+种字段类型、多种布局模式、智能验证和条件显示。
          </p>
          <ul class="list-disc list-inside text-gray-700 space-y-1">
            <li>支持垂直、水平、内联、网格四种布局模式</li>
            <li>提供丰富的字段类型：文本、选择、日期、文件等</li>
            <li>支持字段分组和条件显示</li>
            <li>内置表单验证和错误处理</li>
            <li>响应式设计，适配各种屏幕尺寸</li>
          </ul>
        </div>
      </section>
    </div>
    """
  end

  # 私有函数 - 表单配置

  defp get_basic_form_config do
    %{
      fields: [
        %{
          type: "input",
          name: "name",
          label: "姓名",
          placeholder: "请输入您的姓名",
          required: true
        },
        %{
          type: "email",
          name: "email",
          label: "邮箱地址",
          placeholder: "example@domain.com",
          required: true
        },
        %{
          type: "tel",
          name: "phone",
          label: "联系电话",
          placeholder: "请输入手机号码"
        }
      ]
    }
  end

  defp get_user_form_config do
    %{
      fields: [
        %{
          type: "input",
          name: "name",
          label: "用户名",
          required: true,
          description: "用户名将用于登录系统"
        },
        %{
          type: "email",
          name: "email",
          label: "邮箱地址",
          required: true
        },
        %{
          type: "password",
          name: "password",
          label: "密码",
          required: true,
          description: "密码长度至少8位"
        },
        %{
          type: "select",
          name: "role",
          label: "用户角色",
          options: [
            %{value: "admin", label: "管理员"},
            %{value: "manager", label: "经理"},
            %{value: "user", label: "普通用户"}
          ],
          required: true
        }
      ],
      layout_config: %{
        label_col: %{span: 4},
        wrapper_col: %{span: 20}
      }
    }
  end

  defp get_grid_form_config do
    %{
      fields: [
        %{
          type: "input",
          name: "company_name",
          label: "公司名称",
          grid: %{span: 12},
          required: true
        },
        %{
          type: "input",
          name: "tax_number",
          label: "税号",
          grid: %{span: 12}
        },
        %{
          type: "input",
          name: "contact_person",
          label: "联系人",
          grid: %{span: 8}
        },
        %{
          type: "tel",
          name: "contact_phone",
          label: "联系电话",
          grid: %{span: 8}
        },
        %{
          type: "email",
          name: "contact_email",
          label: "联系邮箱",
          grid: %{span: 8}
        },
        %{
          type: "textarea",
          name: "address",
          label: "公司地址",
          grid: %{span: 24},
          rows: 3
        }
      ],
      layout_config: %{gutter: 16}
    }
  end

  defp get_inline_form_config do
    %{
      fields: [
        %{
          type: "input",
          name: "keyword",
          label: "关键词",
          placeholder: "搜索关键词"
        },
        %{
          type: "select",
          name: "category",
          label: "分类",
          placeholder: "选择分类",
          options: [
            %{value: "product", label: "产品"},
            %{value: "service", label: "服务"},
            %{value: "support", label: "支持"}
          ]
        },
        %{
          type: "date",
          name: "start_date",
          label: "开始日期"
        },
        %{
          type: "date",
          name: "end_date",
          label: "结束日期"
        }
      ]
    }
  end

  defp get_grouped_form_config do
    %{
      fields: [
        %{type: "input", name: "name", label: "姓名", required: true},
        %{type: "email", name: "email", label: "邮箱", required: true},
        %{type: "tel", name: "phone", label: "电话"},
        %{type: "date", name: "birthday", label: "生日"},
        %{type: "input", name: "company", label: "公司"},
        %{type: "input", name: "position", label: "职位"},
        %{type: "textarea", name: "address", label: "地址", rows: 2},
        %{type: "input", name: "city", label: "城市"},
        %{type: "input", name: "postal_code", label: "邮编"}
      ],
      groups: [
        %{
          title: "基本信息",
          fields: ["name", "email", "phone", "birthday"]
        },
        %{
          title: "工作信息",
          fields: ["company", "position"]
        },
        %{
          title: "地址信息",
          fields: ["address", "city", "postal_code"]
        }
      ]
    }
  end

  defp get_conditional_form_config do
    %{
      fields: [
        %{
          type: "radio",
          name: "user_type",
          label: "用户类型",
          options: [
            %{value: "personal", label: "个人用户"},
            %{value: "company", label: "企业用户"}
          ],
          required: true
        },
        %{
          type: "input",
          name: "personal_name",
          label: "个人姓名",
          show_if: "user_type == 'personal'",
          required: true
        },
        %{
          type: "input",
          name: "company_name",
          label: "企业名称",
          show_if: "user_type == 'company'",
          required: true
        },
        %{
          type: "input",
          name: "tax_number",
          label: "税务登记号",
          show_if: "user_type == 'company'"
        },
        %{
          type: "email",
          name: "email",
          label: "邮箱地址",
          required: true
        }
      ]
    }
  end

  defp get_survey_form_config do
    %{
      fields: [
        %{
          type: "text",
          label: "满意度调查",
          content: "感谢您参与我们的产品满意度调查，您的反馈对我们非常重要。"
        },
        %{
          type: "divider",
          title: "基本信息"
        },
        %{
          type: "input",
          name: "participant_name",
          label: "姓名",
          required: true
        },
        %{
          type: "radio",
          name: "age_group",
          label: "年龄段",
          options: [
            %{value: "18-25", label: "18-25岁"},
            %{value: "26-35", label: "26-35岁"},
            %{value: "36-45", label: "36-45岁"},
            %{value: "46-60", label: "46-60岁"},
            %{value: "60+", label: "60岁以上"}
          ],
          required: true
        },
        %{
          type: "divider",
          title: "产品评价"
        },
        %{
          type: "range",
          name: "satisfaction",
          label: "整体满意度",
          min: 1,
          max: 10,
          step: 1,
          show_value: true
        },
        %{
          type: "checkbox",
          name: "features",
          label: "您最喜欢的功能",
          options: [
            %{value: "ease_of_use", label: "易用性"},
            %{value: "performance", label: "性能"},
            %{value: "design", label: "设计"},
            %{value: "support", label: "客户支持"},
            %{value: "price", label: "价格"}
          ]
        },
        %{
          type: "textarea",
          name: "suggestions",
          label: "改进建议",
          placeholder: "请分享您对产品的改进建议...",
          rows: 4
        },
        %{
          type: "checkbox",
          name: "recommend",
          label: "推荐意愿",
          options: [
            %{value: "yes", label: "我愿意向朋友推荐这个产品"}
          ]
        }
      ]
    }
  end

  defp get_field_types_config do
    %{
      fields: [
        %{type: "input", name: "text_input", label: "文本输入", grid: %{span: 6}},
        %{type: "email", name: "email_input", label: "邮箱输入", grid: %{span: 6}},
        %{type: "password", name: "password_input", label: "密码输入", grid: %{span: 6}},
        %{type: "number", name: "number_input", label: "数字输入", grid: %{span: 6}},
        %{type: "tel", name: "tel_input", label: "电话输入", grid: %{span: 6}},
        %{type: "url", name: "url_input", label: "网址输入", grid: %{span: 6}},
        %{type: "date", name: "date_input", label: "日期选择", grid: %{span: 6}},
        %{type: "time", name: "time_input", label: "时间选择", grid: %{span: 6}},
        %{
          type: "select",
          name: "select_input",
          label: "下拉选择",
          grid: %{span: 6},
          options: [
            %{value: "option1", label: "选项1"},
            %{value: "option2", label: "选项2"}
          ]
        },
        %{type: "color", name: "color_input", label: "颜色选择", grid: %{span: 6}},
        %{type: "range", name: "range_input", label: "滑动条", grid: %{span: 6}, show_value: true},
        %{type: "file", name: "file_input", label: "文件上传", grid: %{span: 6}},
        %{
          type: "radio",
          name: "radio_input",
          label: "单选框",
          grid: %{span: 12},
          options: [
            %{value: "radio1", label: "单选1"},
            %{value: "radio2", label: "单选2"}
          ]
        },
        %{
          type: "checkbox",
          name: "checkbox_input",
          label: "复选框",
          grid: %{span: 12},
          options: [
            %{value: "check1", label: "复选1"},
            %{value: "check2", label: "复选2"}
          ]
        },
        %{type: "textarea", name: "textarea_input", label: "多行文本", grid: %{span: 24}, rows: 3}
      ],
      layout_config: %{gutter: 16}
    }
  end

  # 简单的表单验证示例
  defp validate_user_form(params) do
    errors = %{}
    
    errors = if !params["name"] || String.trim(params["name"]) == "" do
      Map.put(errors, "name", "用户名不能为空")
    else
      errors
    end
    
    errors = if !params["email"] || !String.contains?(params["email"], "@") do
      Map.put(errors, "email", "请输入有效的邮箱地址")
    else
      errors
    end
    
    errors = if !params["password"] || String.length(params["password"]) < 8 do
      Map.put(errors, "password", "密码长度至少8位")
    else
      errors
    end
    
    if errors == %{} do
      {:ok, params}
    else
      {:error, errors}
    end
  end
  
  # 自动保存防抖函数
  defp schedule_auto_save(socket, _params) do
    # 取消旧的定时器
    if socket.assigns.auto_save_timer do
      Process.cancel_timer(socket.assigns.auto_save_timer)
    end
    
    # 设置新的定时器（1秒防抖）
    timer = Process.send_after(self(), :auto_save, 1000)
    assign(socket, :auto_save_timer, timer)
  end
  
  # 智能联动配置函数
  
  defp get_address_linkage_config(dynamic_options) do
    %{
      fields: [
        %{
          type: "select",
          name: "province",
          label: "省份",
          required: true,
          options: [
            %{value: "", label: "请选择省份"},
            %{value: "guangdong", label: "广东"},
            %{value: "beijing", label: "北京"},
            %{value: "shanghai", label: "上海"}
          ]
        },
        %{
          type: "select",
          name: "city",
          label: "城市",
          required: true,
          depends_on: ["province"],
          options: Map.get(dynamic_options, "city", [%{value: "", label: "请先选择省份"}])
        },
        %{
          type: "select", 
          name: "district",
          label: "区县",
          required: true,
          depends_on: ["city"],
          options: Map.get(dynamic_options, "district", [%{value: "", label: "请先选择城市"}])
        }
      ]
    }
  end
  
  defp get_product_type_config do
    %{
      fields: [
        %{
          type: "radio",
          name: "product_type",
          label: "产品类型",
          options: [
            %{value: "physical", label: "实物商品"},
            %{value: "virtual", label: "虚拟商品"},
            %{value: "service", label: "服务"}
          ],
          required: true
        },
        # 实物商品字段
        %{
          type: "input",
          name: "weight",
          label: "重量(kg)",
          show_if: "product_type == 'physical'",
          required: true
        },
        %{
          type: "input",
          name: "dimensions",
          label: "尺寸",
          show_if: "product_type == 'physical'",
          placeholder: "长x宽x高"
        },
        # 虚拟商品字段
        %{
          type: "input",
          name: "download_link",
          label: "下载链接",
          show_if: "product_type == 'virtual'",
          required: true
        },
        %{
          type: "number",
          name: "download_limit",
          label: "下载次数限制",
          show_if: "product_type == 'virtual'",
          min: 1
        },
        # 服务字段
        %{
          type: "number",
          name: "service_hours",
          label: "服务时长(小时)",
          show_if: "product_type == 'service'",
          required: true,
          min: 1
        },
        %{
          type: "select",
          name: "service_type",
          label: "服务类型",
          show_if: "product_type == 'service'",
          options: [
            %{value: "consultation", label: "咨询"},
            %{value: "training", label: "培训"},
            %{value: "support", label: "技术支持"}
          ]
        }
      ]
    }
  end
  
  defp get_calculation_config do
    %{
      fields: [
        %{
          type: "number",
          name: "unit_price", 
          label: "单价",
          required: true,
          min: 0,
          step: 0.01
        },
        %{
          type: "number",
          name: "quantity",
          label: "数量",
          required: true,
          min: 1
        },
        %{
          type: "number",
          name: "discount",
          label: "折扣(%)",
          min: 0,
          max: 100
        },
        %{
          type: "number",
          name: "subtotal",
          label: "小计",
          readonly: true,
          computed: %{
            formula: "unit_price * quantity",
            depends_on: ["unit_price", "quantity"]
          }
        },
        %{
          type: "number",
          name: "total",
          label: "总计",
          readonly: true,
          computed: %{
            formula: "unit_price * quantity",
            depends_on: ["unit_price", "quantity"]
          }
        },
        %{
          type: "number",
          name: "final_price",
          label: "最终价格",
          readonly: true,
          computed: %{
            compute: fn form_data ->
              subtotal = parse_number(form_data["subtotal"])
              discount = parse_number(form_data["discount"])
              subtotal * (1 - discount / 100)
            end,
            depends_on: ["subtotal", "discount"]
          }
        }
      ]
    }
  end
  
  defp get_user_type_config do
    %{
      fields: [
        %{
          name: "user_type",
          type: "radio",
          label: "用户类型",
          options: [
            %{value: "personal", label: "个人用户"},
            %{value: "company", label: "企业用户"}
          ],
          required: true
        },
        %{
          name: "company_name",
          type: "input",
          label: "公司名称",
          show_if: "user_type == 'company'",
          required: true
        },
        %{
          name: "tax_number",
          type: "input",
          label: "税号",
          show_if: "user_type == 'company'"
        }
      ]
    }
  end
  
  defp get_member_privilege_config do
    %{
      fields: [
        %{
          name: "member_level",
          type: "select",
          label: "会员等级",
          options: [
            %{value: "normal", label: "普通会员"},
            %{value: "vip", label: "VIP会员"},
            %{value: "svip", label: "超级VIP"}
          ]
        },
        %{
          name: "total_spent",
          type: "number",
          label: "累计消费金额"
        },
        %{
          name: "vip_discount",
          type: "number",
          label: "VIP折扣(%)",
          show_if: %{
            and: [
              "member_level == 'vip'",
              "total_spent > 10000"
            ]
          }
        },
        %{
          name: "priority_support",
          type: "checkbox",
          label: "优先支持服务",
          show_if: %{
            and: [
              "member_level == 'vip'",
              "total_spent > 10000"
            ]
          }
        }
      ]
    }
  end
  
  defp get_search_form_config do
    %{
      fields: [
        %{
          name: "search",
          type: "input",
          label: "搜索",
          placeholder: "输入搜索关键词...",
          async_validation: %{
            debounce: 300
          }
        }
      ]
    }
  end
  
  defp get_error_recovery_config do
    %{
      fields: [
        %{
          name: "category",
          type: "select",
          label: "类别",
          options: [
            %{value: "valid", label: "有效类别"},
            %{value: "invalid", label: "无效类别（会触发错误）"}
          ],
          on_change: %{
            update: [%{field: "subcategory", action: "load_options"}]
          }
        },
        %{
          name: "subcategory",
          type: "select",
          label: "子类别",
          depends_on: ["category"],
          load_options: fn form_data ->
            case form_data["category"] do
              "valid" -> [
                %{value: "sub1", label: "子类别1"},
                %{value: "sub2", label: "子类别2"}
              ]
              "invalid" -> raise "加载选项失败"
              _ -> []
            end
          end
        }
      ]
    }
  end
  
  defp get_async_validation_config do
    %{
      fields: [
        %{
          type: "input",
          name: "username",
          label: "用户名",
          required: true,
          placeholder: "请输入用户名（admin、john、test 已被占用）",
          async_validation: %{
            endpoint: "/api/check_username",
            debounce: 500
          }
        },
        %{
          type: "email",
          name: "email",
          label: "邮箱",
          required: true
        },
        %{
          type: "password",
          name: "password",
          label: "密码",
          required: true,
          min_length: 8
        }
      ]
    }
  end
  
  # 辅助函数
  
  defp detect_changed_fields(old_data, new_data) do
    # 比较新旧数据，找出发生变化的字段
    Map.keys(new_data)
    |> Enum.filter(fn key ->
      old_value = Map.get(old_data, key)
      new_value = Map.get(new_data, key)
      old_value != new_value
    end)
  end
  
  defp update_dynamic_options(socket, field_name, options) do
    dynamic_options = Map.put(socket.assigns.dynamic_options, field_name, options)
    assign(socket, :dynamic_options, dynamic_options)
  end
  
  defp get_cities_for_province(province) do
    case province do
      "guangdong" -> [
        %{value: "", label: "请选择城市"},
        %{value: "guangzhou", label: "广州"},
        %{value: "shenzhen", label: "深圳"},
        %{value: "zhuhai", label: "珠海"}
      ]
      "beijing" -> [
        %{value: "", label: "请选择城市"},
        %{value: "beijing", label: "北京"}
      ]
      "shanghai" -> [
        %{value: "", label: "请选择城市"},
        %{value: "shanghai", label: "上海"}
      ]
      _ -> [%{value: "", label: "请选择城市"}]
    end
  end
  
  defp get_districts_for_city(city) do
    case city do
      "guangzhou" -> [
        %{value: "", label: "请选择区县"},
        %{value: "tianhe", label: "天河区"},
        %{value: "yuexiu", label: "越秀区"},
        %{value: "haizhu", label: "海珠区"}
      ]
      "shenzhen" -> [
        %{value: "", label: "请选择区县"},
        %{value: "nanshan", label: "南山区"},
        %{value: "futian", label: "福田区"},
        %{value: "luohu", label: "罗湖区"}
      ]
      _ -> [%{value: "", label: "请选择区县"}]
    end
  end
  
  defp parse_number(nil), do: 0.0
  defp parse_number(""), do: 0.0
  defp parse_number(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> 
        case Integer.parse(value) do
          {num, _} -> num * 1.0
          :error -> 0.0
        end
    end
  end
  defp parse_number(value) when is_number(value), do: value * 1.0
  defp parse_number(_), do: 0.0
  
  defp get_order_form_config(dynamic_options) do
    %{
      fields: [
        %{
          name: "customer_type",
          type: "radio",
          label: "客户类型",
          options: [
            %{value: "personal", label: "个人"},
            %{value: "company", label: "企业"}
          ],
          required: true
        },
        %{
          name: "company_name",
          type: "input",
          label: "公司名称",
          show_if: "customer_type == 'company'",
          required: true
        },
        %{
          name: "tax_number",
          type: "input",
          label: "税号",
          show_if: "customer_type == 'company'"
        },
        %{
          name: "product",
          type: "select",
          label: "产品",
          options: [
            %{value: "laptop", label: "笔记本电脑"},
            %{value: "phone", label: "手机"},
            %{value: "tablet", label: "平板"}
          ]
        },
        %{
          name: "quantity",
          type: "number",
          label: "数量",
          min: 1
        },
        %{
          name: "unit_price",
          type: "number",
          label: "单价",
          readonly: true,
          computed: %{
            compute: fn form_data ->
              case form_data["product"] do
                "laptop" -> 5000
                "phone" -> 3000
                "tablet" -> 2000
                _ -> 0
              end
            end,
            depends_on: ["product"]
          }
        },
        %{
          name: "subtotal",
          type: "number",
          label: "小计",
          readonly: true,
          computed: %{
            formula: "quantity * unit_price",
            depends_on: ["quantity", "unit_price"]
          }
        },
        %{
          name: "enterprise_discount",
          type: "number",
          label: "企业折扣(%)",
          show_if: "customer_type == 'company'"
        },
        %{
          name: "final_price",
          type: "number",
          label: "最终价格",
          readonly: true,
          computed: %{
            compute: fn form_data ->
              subtotal = parse_number(form_data["subtotal"])
              discount = parse_number(form_data["enterprise_discount"])
              if discount > 0 do
                subtotal * (1 - discount / 100)
              else
                subtotal
              end
            end,
            depends_on: ["subtotal", "enterprise_discount"]
          }
        },
        %{
          name: "province",
          type: "select",
          label: "省份",
          options: [
            %{value: "guangdong", label: "广东"},
            %{value: "beijing", label: "北京"}
          ]
        },
        %{
          name: "city",
          type: "select",
          label: "城市",
          depends_on: ["province"],
          options: Map.get(dynamic_options, "city", [%{value: "", label: "请先选择省份"}])
        },
        %{
          name: "district",
          type: "select",
          label: "区县",
          depends_on: ["city"],
          options: Map.get(dynamic_options, "district", [%{value: "", label: "请先选择城市"}])
        },
        %{
          name: "corporate_payment",
          type: "checkbox",
          label: "企业支付",
          show_if: %{
            and: [
              "customer_type == 'company'",
              "final_price > 10000"
            ]
          }
        },
        %{
          name: "installment",
          type: "checkbox",
          label: "分期付款",
          show_if: "final_price > 5000"
        },
        %{
          name: "payment_method",
          type: "select",
          label: "支付方式",
          options: [
            %{value: "alipay", label: "支付宝"},
            %{value: "wechat", label: "微信支付"},
            %{value: "corporate_payment", label: "企业支付"}
          ]
        },
        %{
          name: "agree_terms",
          type: "checkbox",
          label: "同意条款",
          required: true
        }
      ]
    }
  end
  
  defp get_dynamic_survey_config do
    %{
      fields: [
        %{
          name: "role",
          type: "select",
          label: "您的角色",
          options: [
            %{value: "developer", label: "开发者"},
            %{value: "designer", label: "设计师"},
            %{value: "manager", label: "管理者"}
          ]
        },
        %{
          name: "programming_languages",
          type: "checkbox",
          label: "编程语言",
          show_if: "role == 'developer'",
          options: [
            %{value: "elixir", label: "Elixir"},
            %{value: "javascript", label: "JavaScript"},
            %{value: "python", label: "Python"}
          ]
        },
        %{
          name: "years_experience",
          type: "select",
          label: "工作经验",
          show_if: "role == 'developer'",
          options: [
            %{value: "0-2", label: "0-2年"},
            %{value: "3-5", label: "3-5年"},
            %{value: "5-10", label: "5-10年"},
            %{value: "10+", label: "10年以上"}
          ]
        },
        %{
          name: "elixir_frameworks",
          type: "checkbox",
          label: "Elixir框架",
          show_if: %{
            expression: "'elixir' in programming_languages"
          },
          options: [
            %{value: "phoenix", label: "Phoenix"},
            %{value: "liveview", label: "LiveView"}
          ]
        },
        %{
          name: "js_frameworks",
          type: "checkbox",
          label: "JavaScript框架",
          show_if: %{
            expression: "'javascript' in programming_languages"
          },
          options: [
            %{value: "react", label: "React"},
            %{value: "vue", label: "Vue"},
            %{value: "angular", label: "Angular"}
          ]
        },
        %{
          name: "architecture_preferences",
          type: "textarea",
          label: "架构偏好",
          show_if: %{
            or: [
              "years_experience == '5-10'",
              "years_experience == '10+'"
            ]
          }
        },
        %{
          name: "team_size",
          type: "number",
          label: "团队规模",
          show_if: %{
            or: [
              "years_experience == '5-10'",
              "years_experience == '10+'"
            ]
          }
        },
        %{
          type: "text",
          label: "完成度: 75%",
          content: "您已完成问卷的75%"
        }
      ]
    }
  end
  
  # 自动保存表单配置
  defp get_auto_save_form_config do
    %{
      fields: [
        %{
          type: "input",
          name: "title",
          label: "文章标题",
          required: true,
          placeholder: "请输入文章标题..."
        },
        %{
          type: "input",
          name: "author",
          label: "作者",
          placeholder: "请输入作者姓名"
        },
        %{
          type: "textarea",
          name: "content",
          label: "文章内容",
          rows: 6,
          placeholder: "开始写作吧，内容会自动保存..."
        },
        %{
          type: "select",
          name: "category",
          label: "分类",
          options: [
            %{value: "tech", label: "技术"},
            %{value: "life", label: "生活"},
            %{value: "travel", label: "旅行"},
            %{value: "food", label: "美食"}
          ]
        },
        %{
          type: "checkbox",
          name: "published",
          label: "立即发布"
        }
      ]
    }
  end
end