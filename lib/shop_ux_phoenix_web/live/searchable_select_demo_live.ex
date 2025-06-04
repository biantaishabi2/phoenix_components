defmodule ShopUxPhoenixWeb.SearchableSelectDemoLive do
  use ShopUxPhoenixWeb, :live_view

  alias ShopUxPhoenixWeb.Components.SearchableSelect

  def mount(_params, _session, socket) do
    basic_options = [
      %{value: "tech", label: "Technology"},
      %{value: "design", label: "Design"},
      %{value: "marketing", label: "Marketing"},
      %{value: "sales", label: "Sales"}
    ]

    user_options = [
      %{value: "1", label: "John Doe", email: "john@example.com", avatar: "/images/avatar1.jpg"},
      %{value: "2", label: "Jane Smith", email: "jane@example.com", avatar: "/images/avatar2.jpg"},
      %{value: "3", label: "Bob Wilson", email: "bob@example.com", avatar: "/images/avatar3.jpg"}
    ]

    grouped_options = [
      %{
        label: "Engineering",
        options: [
          %{value: "dev", label: "Development"},
          %{value: "qa", label: "Quality Assurance"},
          %{value: "devops", label: "DevOps"}
        ]
      },
      %{
        label: "Marketing",
        options: [
          %{value: "seo", label: "SEO"},
          %{value: "content", label: "Content Marketing"},
          %{value: "social", label: "Social Media"}
        ]
      }
    ]

    socket = 
      socket
      |> assign(:form, to_form(%{}))
      |> assign(:basic_options, basic_options)
      |> assign(:user_options, user_options)
      |> assign(:grouped_options, grouped_options)
      |> assign(:selected_category, nil)
      |> assign(:selected_skills, [])
      |> assign(:selected_user, nil)
      |> assign(:selected_department, nil)
      |> assign(:search_results, [])
      |> assign(:loading, false)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 w-full">
      <h1 class="text-3xl font-bold mb-8">SearchableSelect 组件演示</h1>
      
      <!-- 基础用法 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">基础用法</h2>
        <.form for={@form} phx-submit="submit_basic" class="space-y-4">
          <SearchableSelect.searchable_select
            id="category-select"
            name="category"
            options={@basic_options}
            value={@selected_category}
            placeholder="选择分类"
            on_change="update_category"
          />
          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
            提交
          </button>
        </.form>
        <%= if @selected_category do %>
          <p class="mt-2 text-sm text-gray-600">已选择: <%= @selected_category %></p>
        <% end %>
      </div>

      <!-- 多选模式 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">多选模式</h2>
        <SearchableSelect.searchable_select
          id="multiple-select"
          name="skills"
          options={@basic_options}
          value={@selected_skills}
          multiple={true}
          max_tag_count={3}
          placeholder="选择技能"
          on_change="update_skills"
        />
        <%= if @selected_skills != [] do %>
          <p class="mt-2 text-sm text-gray-600">已选择: <%= Enum.join(@selected_skills, ", ") %></p>
        <% end %>
      </div>

      <!-- 用户选择器（自定义渲染） -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">自定义选项渲染</h2>
        <SearchableSelect.searchable_select
          id="user-select"
          name="user"
          options={@user_options}
          value={@selected_user}
          placeholder="选择用户"
          on_change="update_user"
        >
          <:option :let={option}>
            <div class="flex items-center gap-3">
              <img src={option.avatar} class="w-8 h-8 rounded-full" />
              <div>
                <div class="font-medium"><%= option.label %></div>
                <div class="text-sm text-gray-500"><%= option.email %></div>
              </div>
            </div>
          </:option>
        </SearchableSelect.searchable_select>
        <%= if @selected_user do %>
          <p class="mt-2 text-sm text-gray-600">已选择用户ID: <%= @selected_user %></p>
        <% end %>
      </div>

      <!-- 分组选项 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">分组选项</h2>
        <SearchableSelect.searchable_select
          id="grouped-select"
          name="department"
          options={@grouped_options}
          value={@selected_department}
          placeholder="选择部门"
          on_change="update_department"
        />
        <%= if @selected_department do %>
          <p class="mt-2 text-sm text-gray-600">已选择: <%= @selected_department %></p>
        <% end %>
      </div>

      <!-- 远程搜索 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">远程搜索</h2>
        <SearchableSelect.searchable_select
          id="remote-select"
          name="product"
          options={@search_results}
          value={nil}
          remote_search={true}
          loading={@loading}
          placeholder="搜索商品..."
          on_search="search_products"
        />
      </div>

      <!-- 禁用状态 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">禁用状态</h2>
        <SearchableSelect.searchable_select
          id="disabled-select"
          name="disabled"
          options={@basic_options}
          value="tech"
          disabled={true}
          placeholder="禁用的选择器"
        />
      </div>

      <!-- 加载状态 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">加载状态</h2>
        <SearchableSelect.searchable_select
          id="loading-select"
          name="loading"
          options={[]}
          value={nil}
          loading={true}
          placeholder="加载中..."
        />
      </div>

      <!-- 不同尺寸 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">不同尺寸</h2>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">小尺寸</label>
            <SearchableSelect.searchable_select
              id="small-select"
              name="small"
              options={@basic_options}
              value={nil}
              size="sm"
              placeholder="小尺寸选择器"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">中等尺寸（默认）</label>
            <SearchableSelect.searchable_select
              id="medium-select"
              name="medium"
              options={@basic_options}
              value={nil}
              size="md"
              placeholder="中等尺寸选择器"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">大尺寸</label>
            <SearchableSelect.searchable_select
              id="large-select"
              name="large"
              options={@basic_options}
              value={nil}
              size="lg"
              placeholder="大尺寸选择器"
            />
          </div>
        </div>
      </div>

      <!-- 验证错误 -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">验证错误</h2>
        <SearchableSelect.searchable_select
          id="error-select"
          name="required_field"
          options={@basic_options}
          value={nil}
          required={true}
          errors={["This field is required"]}
          placeholder="必填字段"
        />
      </div>
    </div>
    """
  end

  def handle_event("update_category", %{"value" => value}, socket) do
    {:noreply, assign(socket, :selected_category, value)}
  end

  def handle_event("update_skills", %{"value" => values}, socket) when is_list(values) do
    {:noreply, assign(socket, :selected_skills, values)}
  end

  def handle_event("update_skills", %{"value" => value}, socket) do
    current = socket.assigns.selected_skills
    new_skills = if value in current do
      List.delete(current, value)
    else
      [value | current]
    end
    {:noreply, assign(socket, :selected_skills, new_skills)}
  end

  def handle_event("update_user", %{"value" => value}, socket) do
    {:noreply, assign(socket, :selected_user, value)}
  end

  def handle_event("update_department", %{"value" => value}, socket) do
    {:noreply, assign(socket, :selected_department, value)}
  end

  def handle_event("search_products", %{"key" => _key, "value" => query}, socket) do
    socket = assign(socket, :loading, true)
    
    # 模拟异步搜索
    Process.send_after(self(), {:search_complete, query}, 500)
    
    {:noreply, socket}
  end

  def handle_event("submit_basic", _params, socket) do
    IO.inspect(socket.assigns.selected_category, label: "Submitted category")
    {:noreply, put_flash(socket, :info, "表单提交成功！")}
  end

  # Catch-all event handler for form changes
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  def handle_info({:search_complete, query}, socket) do
    # 模拟搜索结果
    results = [
      %{value: "product_#{query}_1", label: "#{query} Product 1"},
      %{value: "product_#{query}_2", label: "#{query} Product 2"},
      %{value: "product_#{query}_3", label: "#{query} Product 3"}
    ]
    
    socket = 
      socket
      |> assign(:search_results, results)
      |> assign(:loading, false)
    
    {:noreply, socket}
  end
end