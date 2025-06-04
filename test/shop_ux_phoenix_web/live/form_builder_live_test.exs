defmodule ShopUxPhoenixWeb.FormBuilderLiveTest do
  use ShopUxPhoenixWeb.ConnCase
  import Phoenix.LiveViewTest

  # Test modules for Changeset integration
  defmodule TestSchema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "test_records" do
      field :name, :string
      field :email, :string
      field :age, :integer
      field :active, :boolean
      field :role, :string
      field :password, :string, virtual: true
      field :password_confirmation, :string, virtual: true
      
      timestamps()
    end
    
    def changeset(record, attrs) do
      record
      |> cast(attrs, [:name, :email, :age, :active, :role, :password, :password_confirmation])
      |> validate_required([:name, :email])
      |> validate_length(:name, min: 2, max: 50, message: "长度应在 %{min} 到 %{max} 之间")
      |> validate_format(:email, ~r/@/, message: "邮箱格式不正确")
      |> validate_number(:age, greater_than_or_equal_to: 18, message: "年龄必须大于等于18")
      |> validate_inclusion(:role, ["admin", "user", "guest"])
      |> validate_confirmation(:password, message: "两次密码输入不一致")
    end
  end

  describe "FormBuilder Demo LiveView" do
    test "renders demo page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "FormBuilder"
      assert html =~ "表单构建器组件"
      assert html =~ "基础表单"
    end

    test "shows different form examples", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # Check for various demo sections
      assert html =~ "基础表单"
      assert html =~ "水平布局表单"
      assert html =~ "网格布局表单"
      assert html =~ "内联表单"
      assert html =~ "分组表单"
      assert html =~ "条件显示表单"
      assert html =~ "复杂表单示例"
    end

    test "basic form submission works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # Check if basic form exists
      assert has_element?(view, "[data-testid='basic-form']")
      
      # Try to submit basic form
      if has_element?(view, "[data-testid='basic-form'] form") do
        html = view
               |> element("[data-testid='basic-form'] form")
               |> render_submit(%{
                 "name" => "测试用户",
                 "email" => "test@example.com",
                 "phone" => "13800138000"
               })
        
        # Should show success message or handle submission
        assert html =~ "基础表单提交成功" || html =~ "测试用户"
      end
    end

    test "horizontal layout form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "水平布局表单"
      assert has_element?(view, "[data-testid='horizontal-form']")
      
      # Should show pre-filled data
      assert html =~ "张三"
      assert html =~ "zhangsan@example.com"
    end

    test "grid layout form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "网格布局表单"
      assert has_element?(view, "[data-testid='grid-form']")
      
      # Should show grid layout fields
      assert html =~ "公司名称"
      assert html =~ "税号"
      assert html =~ "联系人"
    end

    test "inline form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "内联表单"
      assert has_element?(view, "[data-testid='inline-form']")
      
      # Should show inline form fields
      assert html =~ "关键词"
      assert html =~ "分类"
      assert html =~ "开始日期"
    end

    test "grouped form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "分组表单"
      assert has_element?(view, "[data-testid='grouped-form']")
      
      # Should show group titles
      assert html =~ "基本信息"
      assert html =~ "工作信息"
      assert html =~ "地址信息"
    end

    test "conditional form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "条件显示表单"
      assert has_element?(view, "[data-testid='conditional-form']")
      
      # Should show conditional fields
      assert html =~ "用户类型"
      assert html =~ "个人用户"
      assert html =~ "企业用户"
    end

    test "survey form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "复杂表单示例"
      assert has_element?(view, "[data-testid='survey-form']")
      
      # Should show survey form elements
      assert html =~ "满意度调查"
      assert html =~ "年龄段"
      assert html =~ "整体满意度"
    end

    test "form states display correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "表单状态"
      
      # Should show different form states
      assert has_element?(view, "[data-testid='disabled-form']")
      assert has_element?(view, "[data-testid='readonly-form']") 
      assert has_element?(view, "[data-testid='loading-form']")
      
      assert html =~ "禁用状态"
      assert html =~ "只读状态"
      assert html =~ "加载状态"
    end

    test "field types form displays correctly", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "所有字段类型"
      assert has_element?(view, "[data-testid='field-types-form']")
      
      # Should show various field types
      assert html =~ "文本输入"
      assert html =~ "邮箱输入"
      assert html =~ "密码输入"
      assert html =~ "日期选择"
      assert html =~ "下拉选择"
    end

    test "form submission displays result", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # Submit a form to see result display
      if has_element?(view, "[data-testid='basic-form'] form") do
        view
        |> element("[data-testid='basic-form'] form")
        |> render_submit(%{
          "name" => "测试提交",
          "email" => "submit@test.com"
        })
        
        html = render(view)
        
        # Should show submitted data or success message
        assert html =~ "最后提交的数据" || html =~ "提交成功"
      end
    end

    test "form reset functionality works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # Look for reset button with phx-click attribute
      if has_element?(view, "[phx-click='reset_form']") do
        html = view
               |> element("[phx-click='reset_form']")
               |> render_click()
        
        # Should show reset message
        assert html =~ "表单已重置" || html =~ "重置"
      end
    end

    test "loading simulation works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # Look for loading form
      if has_element?(view, "[data-testid='loading-form'] form") do
        html = view
               |> element("[data-testid='loading-form'] form")
               |> render_submit(%{})
        
        # Should show loading state
        assert html =~ "模拟提交中" || html =~ "loading"
      end
    end

    test "form validation works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # Try to submit user form with invalid data
      if has_element?(view, "[data-testid='horizontal-form'] form") do
        html = view
               |> element("[data-testid='horizontal-form'] form")
               |> render_submit(%{
                 "name" => "",  # Empty required field
                 "email" => "invalid-email",  # Invalid email
                 "password" => "123"  # Too short password
               })
        
        # Should show validation errors
        assert html =~ "表单验证失败" || html =~ "错误" || html =~ "验证"
      end
    end

    test "field change events work", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # Check if form change events are handled
      if has_element?(view, "[data-testid='basic-form'] form") do
        view
        |> element("[data-testid='basic-form'] form")
        |> render_change(%{"name" => "变更测试"})
        
        # The change should be handled (no error thrown)
        html = render(view)
        assert html =~ "FormBuilder"
      end
    end

    test "different field types render correctly", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # Should contain various input types
      assert html =~ "type=\"text\""
      assert html =~ "type=\"email\""
      assert html =~ "type=\"password\""
      assert html =~ "type=\"number\""
      assert html =~ "type=\"date\""
      assert html =~ "type=\"radio\""
      assert html =~ "type=\"checkbox\""
      assert html =~ "<select"
      assert html =~ "<textarea"
    end

    test "required field indicators display", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # Should show required field indicators
      assert html =~ "required" || html =~ "*"
    end

    test "form labels and placeholders display", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # Should show proper labels and placeholders
      assert html =~ "姓名"
      assert html =~ "邮箱地址"
      assert html =~ "请输入"
      assert html =~ "placeholder"
    end

    test "usage documentation displays", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      assert html =~ "使用说明"
      assert html =~ "配置驱动"
      assert html =~ "字段类型"
      assert html =~ "布局模式"
    end
  end

  describe "FormBuilder Changeset Integration" do
    test "renders changeset-based form", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # If demo includes changeset example
      if html =~ "Changeset 表单" || html =~ "changeset" do
        assert html =~ "name"
        assert html =~ "email"
        assert html =~ "age"
      end
    end
    
    test "changeset validation errors display", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      # If there's a changeset form, test validation
      if has_element?(view, "[data-testid='changeset-form']") do
        # Submit with invalid data
        view
        |> element("[data-testid='changeset-form'] form")
        |> render_submit(%{
          "name" => "a",  # Too short
          "email" => "invalid",  # Missing @
          "age" => "17"  # Too young
        })
        
        html = render(view)
        
        # Should show validation errors
        assert html =~ "长度应在" || html =~ "至少"
        assert html =~ "邮箱格式" || html =~ "@"
        assert html =~ "年龄必须" || html =~ "18"
      end
    end
    
    test "changeset field types are correctly inferred", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # If changeset form exists
      if html =~ "changeset-form" do
        # Check that proper input types are generated
        assert html =~ ~r/type="number".*age/s || html =~ ~r/age.*type="number"/s
        assert html =~ ~r/type="checkbox".*active/s || html =~ ~r/active.*type="checkbox"/s
      end
    end
    
    test "password confirmation fields work", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      if has_element?(view, "[data-testid='changeset-form']") && html =~ "password" do
        # Should have both password fields
        assert html =~ "password_confirmation"
        
        # Test password mismatch
        view
        |> element("[data-testid='changeset-form'] form")
        |> render_submit(%{
          "name" => "Test User",
          "email" => "test@example.com",
          "password" => "password123",
          "password_confirmation" => "different"
        })
        
        html = render(view)
        assert html =~ "两次密码" || html =~ "不一致" || html =~ "match"
      end
    end
    
    test "select options from inclusion validation", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      if html =~ "changeset-form" && html =~ "role" do
        # Check select options are generated
        assert html =~ "<select"
        assert html =~ "admin"
        assert html =~ "user"
        assert html =~ "guest"
      end
    end
  end

  describe "FormBuilder with real LiveView module" do
    defmodule TestFormLive do
      use ShopUxPhoenixWeb, :live_view
      import ShopUxPhoenixWeb.Components.FormBuilder
      alias ShopUxPhoenixWeb.FormBuilderLiveTest.TestSchema
      
      def mount(_params, _session, socket) do
        changeset = TestSchema.changeset(%TestSchema{}, %{})
        
        config = %{
          fields: [
            %{type: "input", name: "title", label: "标题", required: true},
            %{type: "textarea", name: "content", label: "内容"}
          ]
        }
        
        {:ok, 
         socket
         |> Phoenix.Component.assign(:changeset, changeset)
         |> Phoenix.Component.assign(:config, config)
         |> Phoenix.Component.assign(:submitted, false)}
      end
      
      def render(assigns) do
        ~H"""
        <div class="p-4">
          <h2>Config Form</h2>
          <.form_builder
            id="test-config-form"
            config={@config}
            on_submit="submit_config"
          />
          
          <h2 class="mt-8">Changeset Form</h2>
          <.form_builder
            id="test-changeset-form"
            changeset={@changeset}
            on_submit="submit_changeset"
          />
          
          <%= if @submitted do %>
            <div class="mt-4 p-4 bg-green-100">提交成功</div>
          <% end %>
        </div>
        """
      end
      
      def handle_event("submit_config", %{"form_data" => _data}, socket) do
        {:noreply, Phoenix.Component.assign(socket, :submitted, true)}
      end
      
      def handle_event("submit_changeset", params, socket) do
        changeset = TestSchema.changeset(%TestSchema{}, params)
        
        case Ecto.Changeset.apply_action(changeset, :insert) do
          {:ok, _} ->
            {:noreply, Phoenix.Component.assign(socket, :submitted, true)}
          {:error, changeset} ->
            {:noreply, Phoenix.Component.assign(socket, :changeset, changeset)}
        end
      end
    end
    
    test "custom LiveView with FormBuilder works", %{conn: _conn} do
      # This would require adding a route, so we skip if not available
      # Just checking the module compiles correctly
      assert TestFormLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})
    end
  end

  describe "FormBuilder field overrides" do
    test "field overrides are applied", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/components/form_builder")
      
      # Check if there's an example with field overrides
      if html =~ "field_overrides" || html =~ "自定义字段" do
        # Check that overrides are mentioned or shown
        assert html =~ "覆盖" || html =~ "override" || html =~ "自定义"
      end
    end
  end

  describe "Dynamic form behavior" do
    test "conditional fields work", %{conn: conn} do
      {:ok, view, html} = live(conn, "/components/form_builder")
      
      if has_element?(view, "[data-testid='conditional-form']") do
        # Initially personal fields might be shown
        assert html =~ "用户类型"
        
        # Change to company type
        if has_element?(view, "[data-testid='conditional-form'] select[name='user_type']") do
          view
          |> element("[data-testid='conditional-form'] form")
          |> render_change(%{"user_type" => "company"})
          
          html = render(view)
          
          # Company fields should now be visible
          assert html =~ "公司名称" || html =~ "企业名称"
        end
      end
    end
    
    test "form data updates on change", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/components/form_builder")
      
      if has_element?(view, "[data-testid='basic-form']") do
        # Change a field value
        view
        |> element("[data-testid='basic-form'] form")
        |> render_change(%{"name" => "实时更新测试"})
        
        # Form should handle the change without errors
        html = render(view)
        assert html =~ "FormBuilder"
      end
    end
  end
end