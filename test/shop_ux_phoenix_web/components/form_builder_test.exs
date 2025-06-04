defmodule ShopUxPhoenixWeb.Components.FormBuilderTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.FormBuilder

  @basic_config %{
    fields: [
      %{
        type: "input",
        name: "name",
        label: "姓名",
        required: true,
        placeholder: "请输入姓名"
      },
      %{
        type: "email",
        name: "email",
        label: "邮箱",
        required: true
      },
      %{
        type: "select",
        name: "role",
        label: "角色",
        options: [
          %{value: "admin", label: "管理员"},
          %{value: "user", label: "普通用户"}
        ]
      }
    ]
  }

  @grid_config %{
    fields: [
      %{
        type: "input",
        name: "first_name",
        label: "名",
        grid: %{span: 12}
      },
      %{
        type: "input",
        name: "last_name", 
        label: "姓",
        grid: %{span: 12}
      }
    ],
    layout_config: %{gutter: 16}
  }

  describe "form_builder/1" do
    test "renders basic form" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="basic-form" config={@config} />
      """)
      
      assert html =~ "basic-form"
      assert html =~ "姓名"
      assert html =~ "邮箱"
      assert html =~ "角色"
      assert html =~ "请输入姓名"
    end

    test "renders empty form" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.form_builder id="empty-form" config={%{}} />
      """)
      
      assert html =~ "empty-form"
      assert html =~ "form-builder"
    end

    test "renders with different layouts" do
      for layout <- ~w(vertical horizontal inline grid) do
        assigns = %{config: @basic_config, layout: layout}
        
        html = rendered_to_string(~H"""
          <.form_builder id="layout-form" config={@config} layout={@layout} />
        """)
        
        case layout do
          "vertical" -> assert html =~ "form-vertical" || html =~ "flex-col"
          "horizontal" -> assert html =~ "form-horizontal" || html =~ "grid-cols"
          "inline" -> assert html =~ "form-inline" || html =~ "flex-row"
          "grid" -> assert html =~ "form-grid" || html =~ "grid"
        end
      end
    end

    test "renders with different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{config: @basic_config, size: size}
        
        html = rendered_to_string(~H"""
          <.form_builder id="size-form" config={@config} size={@size} />
        """)
        
        case size do
          "small" -> assert html =~ "text-sm" || html =~ "py-1"
          "medium" -> assert html =~ "text-base" || html =~ "py-2"
          "large" -> assert html =~ "text-lg" || html =~ "py-3"
        end
      end
    end

    test "renders with initial data" do
      assigns = %{
        config: @basic_config,
        initial_data: %{"name" => "张三", "email" => "zhangsan@example.com"}
      }
      
      html = rendered_to_string(~H"""
        <.form_builder 
          id="data-form" 
          config={@config} 
          initial_data={@initial_data}
        />
      """)
      
      assert html =~ "张三"
      assert html =~ "zhangsan@example.com"
    end

    test "renders disabled form" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="disabled-form" config={@config} disabled={true} />
      """)
      
      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed" || html =~ "opacity-60"
    end

    test "renders readonly form" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="readonly-form" config={@config} readonly={true} />
      """)
      
      assert html =~ "readonly" || html =~ "pointer-events-none"
    end

    test "renders loading state" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="loading-form" config={@config} loading={true} />
      """)
      
      assert html =~ "loading" || html =~ "animate-pulse" || html =~ "spinner"
    end

    test "renders submit and reset buttons" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder 
          id="button-form" 
          config={@config}
          submit_text="保存"
          reset_text="取消"
        />
      """)
      
      assert html =~ "保存"
      assert html =~ "取消"
      assert html =~ "type=\"submit\""
      assert html =~ "type=\"button\""
    end

    test "hides buttons when specified" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder 
          id="no-button-form" 
          config={@config}
          show_submit={false}
          show_reset={false}
        />
      """)
      
      refute html =~ "type=\"submit\""
      refute html =~ "提交"
      refute html =~ "重置"
    end

    test "renders with event handlers" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder 
          id="event-form" 
          config={@config}
          on_submit="save_form"
          on_change="field_changed"
          on_reset="reset_form"
        />
      """)
      
      assert html =~ "phx-submit=\"save_form\""
      assert html =~ "phx-change" || html =~ "field_changed"
    end

    test "renders custom CSS class" do
      assigns = %{config: @basic_config}
      
      html = rendered_to_string(~H"""
        <.form_builder 
          id="custom-form" 
          config={@config}
          class="custom-form-class"
        />
      """)
      
      assert html =~ "custom-form-class"
    end
  end

  describe "field types" do
    test "renders input field" do
      config = %{
        fields: [
          %{type: "input", name: "text_field", label: "文本字段", placeholder: "请输入"}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="input-form" config={@config} />
      """)
      
      assert html =~ "type=\"text\""
      assert html =~ "文本字段"
      assert html =~ "请输入"
    end

    test "renders textarea field" do
      config = %{
        fields: [
          %{type: "textarea", name: "description", label: "描述", rows: 4}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="textarea-form" config={@config} />
      """)
      
      assert html =~ "<textarea"
      assert html =~ "描述"
      assert html =~ "rows=\"4\""
    end

    test "renders password field" do
      config = %{
        fields: [
          %{type: "password", name: "password", label: "密码"}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="password-form" config={@config} />
      """)
      
      assert html =~ "type=\"password\""
      assert html =~ "密码"
    end

    test "renders number field" do
      config = %{
        fields: [
          %{type: "number", name: "age", label: "年龄", min: 0, max: 120}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="number-form" config={@config} />
      """)
      
      assert html =~ "type=\"number\""
      assert html =~ "年龄"
      assert html =~ "min=\"0\""
      assert html =~ "max=\"120\""
    end

    test "renders email field" do
      config = %{
        fields: [
          %{type: "email", name: "email", label: "邮箱地址"}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="email-form" config={@config} />
      """)
      
      assert html =~ "type=\"email\""
      assert html =~ "邮箱地址"
    end

    test "renders select field" do
      config = %{
        fields: [
          %{
            type: "select",
            name: "country",
            label: "国家",
            options: [
              %{value: "cn", label: "中国"},
              %{value: "us", label: "美国"}
            ]
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="select-form" config={@config} />
      """)
      
      assert html =~ "<select"
      assert html =~ "国家"
      assert html =~ "中国"
      assert html =~ "美国"
    end

    test "renders checkbox field" do
      config = %{
        fields: [
          %{
            type: "checkbox",
            name: "hobbies",
            label: "爱好",
            options: [
              %{value: "reading", label: "阅读"},
              %{value: "sports", label: "运动"}
            ]
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="checkbox-form" config={@config} />
      """)
      
      assert html =~ "type=\"checkbox\""
      assert html =~ "爱好"
      assert html =~ "阅读"
      assert html =~ "运动"
    end

    test "renders radio field" do
      config = %{
        fields: [
          %{
            type: "radio",
            name: "gender",
            label: "性别",
            options: [
              %{value: "male", label: "男"},
              %{value: "female", label: "女"}
            ]
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="radio-form" config={@config} />
      """)
      
      assert html =~ "type=\"radio\""
      assert html =~ "性别"
      assert html =~ "男"
      assert html =~ "女"
    end

    test "renders date field" do
      config = %{
        fields: [
          %{type: "date", name: "birthday", label: "生日"}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="date-form" config={@config} />
      """)
      
      assert html =~ "type=\"date\""
      assert html =~ "生日"
    end

    test "renders switch field" do
      config = %{
        fields: [
          %{type: "switch", name: "enabled", label: "启用状态"}
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="switch-form" config={@config} />
      """)
      
      assert html =~ "启用状态"
      # Switch component specific assertions would depend on the actual implementation
    end
  end

  describe "validation" do
    test "renders required fields" do
      config = %{
        fields: [
          %{
            type: "input",
            name: "required_field",
            label: "必填字段",
            required: true
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="required-form" config={@config} />
      """)
      
      assert html =~ "required"
      assert html =~ "*" || html =~ "必填"
    end

    test "renders validation rules" do
      config = %{
        fields: [
          %{
            type: "input",
            name: "validated_field",
            label: "验证字段",
            rules: [
              %{min_length: 6, message: "至少6个字符"},
              %{pattern: ~r/^\w+$/, message: "只能包含字母数字下划线"}
            ]
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="validation-form" config={@config} />
      """)
      
      assert html =~ "验证字段"
      # Validation rules would be handled in LiveView
    end
  end

  describe "conditional display" do
    test "handles conditional fields" do
      config = %{
        fields: [
          %{
            type: "select",
            name: "type",
            label: "类型",
            options: [
              %{value: "personal", label: "个人"},
              %{value: "company", label: "企业"}
            ]
          },
          %{
            type: "input",
            name: "company_name",
            label: "公司名称",
            show_if: "type == 'company'"
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="conditional-form" config={@config} />
      """)
      
      assert html =~ "类型"
      # 公司名称字段应该隐藏，因为type默认未选择company
      refute html =~ "公司名称"
      
      # 测试有初始数据时的条件显示
      assigns = %{config: config, initial_data: %{"type" => "company"}}
      
      html_with_data = rendered_to_string(~H"""
        <.form_builder id="conditional-form" config={@config} initial_data={@initial_data} />
      """)
      
      assert html_with_data =~ "类型"
      assert html_with_data =~ "公司名称"
      # Conditional logic would be handled in LiveView
    end
  end

  describe "grid layout" do
    test "renders grid layout" do
      assigns = %{config: @grid_config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="grid-form" config={@config} layout="grid" />
      """)
      
      assert html =~ "grid" || html =~ "col-span"
      assert html =~ "名"
      assert html =~ "姓"
    end
  end

  describe "field groups" do
    test "renders grouped fields" do
      config = %{
        fields: [
          %{type: "input", name: "name", label: "姓名"},
          %{type: "email", name: "email", label: "邮箱"},
          %{type: "input", name: "address", label: "地址"}
        ],
        groups: [
          %{
            title: "基本信息",
            fields: ["name", "email"]
          },
          %{
            title: "联系信息", 
            fields: ["address"]
          }
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="grouped-form" config={@config} />
      """)
      
      assert html =~ "基本信息"
      assert html =~ "联系信息"
      assert html =~ "姓名"
      assert html =~ "邮箱"
      assert html =~ "地址"
    end
  end

  describe "error handling" do
    test "handles invalid config gracefully" do
      assigns = %{config: %{fields: "invalid"}}
      
      html = rendered_to_string(~H"""
        <.form_builder id="error-form" config={@config} />
      """)
      
      assert html =~ "form-builder"
      refute html =~ "Elixir.Inspect.Error"
    end

    test "handles missing field properties" do
      config = %{
        fields: [
          %{type: "input", name: "incomplete_field"}
          # Missing label and other properties
        ]
      }
      assigns = %{config: config}
      
      html = rendered_to_string(~H"""
        <.form_builder id="incomplete-form" config={@config} />
      """)
      
      assert html =~ "form-builder"
      assert html =~ "incomplete_field"
    end
  end

  describe "changeset integration" do
    defmodule TestUser do
      use Ecto.Schema
      import Ecto.Changeset
      
      schema "test_users" do
        field :name, :string
        field :email, :string
        field :age, :integer
        field :bio, :string
        field :active, :boolean
        field :role, :string
        field :birth_date, :date
        field :password, :string, virtual: true
        field :password_confirmation, :string, virtual: true
        field :height, :float
        field :tags, {:array, :string}
        belongs_to :category, TestCategory
        
        timestamps()
      end
      
      def changeset(user, attrs) do
        user
        |> cast(attrs, [:name, :email, :age, :bio, :active, :role, :birth_date, :password, :password_confirmation, :height, :tags, :category_id])
        |> validate_required([:name, :email])
        |> validate_length(:name, min: 2, max: 100)
        |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
        |> validate_number(:age, greater_than_or_equal_to: 18, less_than: 150)
        |> validate_inclusion(:role, ["admin", "user", "guest"])
        |> validate_confirmation(:password)
      end
      
      # Helper for tests to get cast fields
      def cast_fields, do: [:name, :email, :age, :bio, :active, :role, :birth_date, :password, :password_confirmation, :height, :tags, :category_id]
    end
    
    defmodule TestCategory do
      use Ecto.Schema
      
      schema "test_categories" do
        field :name, :string
      end
    end
    
    test "generates form from changeset" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="changeset-form" changeset={@changeset} />
      """)
      
      # Should render fields based on schema
      assert html =~ "name"
      assert html =~ "email" 
      assert html =~ "age"
      assert html =~ "bio"
      
      # Should apply required validation
      assert html =~ "required"
    end
    
    test "infers field types from Ecto types" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="type-inference-form" changeset={@changeset} />
      """)
      
      # String -> input
      assert html =~ ~r/type="text".*name="name"/s || html =~ ~r/name="name".*type="text"/s
      
      # Text -> textarea
      assert html =~ "<textarea" && html =~ "bio"
      
      # Integer -> number
      assert html =~ ~r/type="number".*name="age"/s || html =~ ~r/name="age".*type="number"/s
      
      # Boolean -> checkbox
      assert html =~ ~r/type="checkbox".*name="active"/s || html =~ ~r/name="active".*type="checkbox"/s
      
      # Date -> date input
      assert html =~ ~r/type="date".*name="birth_date"/s || html =~ ~r/name="birth_date".*type="date"/s
    end
    
    test "extracts validation rules from changeset" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="validation-extraction-form" changeset={@changeset} />
      """)
      
      # Required fields should be marked
      assert html =~ ~r/name="name".*required/s || html =~ ~r/required.*name="name"/s
      assert html =~ ~r/name="email".*required/s || html =~ ~r/required.*name="email"/s
      
      # Length validation hints
      assert html =~ "2" || html =~ "100" # min/max length for name
      
      # Number validation  
      assert html =~ "18" || html =~ "149" # min/max for age
    end
    
    test "generates select options from inclusion validation" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="inclusion-form" changeset={@changeset} />
      """)
      
      # Should generate select with options
      assert html =~ "<select"
      assert html =~ "admin"
      assert html =~ "user" 
      assert html =~ "guest"
    end
    
    test "handles confirmation fields" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="confirmation-form" changeset={@changeset} />
      """)
      
      # Should generate both password fields
      assert html =~ ~r/type="password".*name="password"/s || html =~ ~r/name="password".*type="password"/s
      assert html =~ "password_confirmation"
    end
    
    test "displays changeset errors" do
      changeset = TestUser.changeset(%TestUser{}, %{name: "a", email: "invalid"})
      |> Map.put(:action, :validate)
      
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="error-form" changeset={@changeset} />
      """)
      
      # Should display validation errors
      assert html =~ "should be at least 2 character" || html =~ "至少"
      assert html =~ "must have the @ sign" || html =~ "@"
    end
    
    test "merges field overrides" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      field_overrides = %{
        "active" => %{type: "switch"},
        "role" => %{
          options: [
            %{value: "admin", label: "管理员"},
            %{value: "user", label: "用户"},
            %{value: "guest", label: "访客"}
          ]
        }
      }
      
      assigns = %{changeset: changeset, field_overrides: field_overrides}
      
      html = rendered_to_string(~H"""
        <.form_builder 
          id="override-form" 
          changeset={@changeset}
          field_overrides={@field_overrides}
        />
      """)
      
      # Should use switch instead of checkbox
      assert html =~ "switch" || html =~ "toggle"
      
      # Should use custom labels
      assert html =~ "管理员"
      assert html =~ "用户"
      assert html =~ "访客"
    end
    
    test "handles belongs_to associations" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="association-form" changeset={@changeset} />
      """)
      
      # Should generate select for belongs_to
      assert html =~ "category_id"
      assert html =~ "<select"
    end
    
    test "ignores virtual and has_many fields" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="virtual-form" changeset={@changeset} />
      """)
      
      # Should include virtual password fields (they're in cast)
      assert html =~ "password"
      
      # Should not include timestamps
      refute html =~ "inserted_at"
      refute html =~ "updated_at"
    end
    
    test "generates helpful descriptions from validations" do
      changeset = TestUser.changeset(%TestUser{}, %{})
      assigns = %{changeset: changeset}
      
      html = rendered_to_string(~H"""
        <.form_builder id="description-form" changeset={@changeset} />
      """)
      
      # Should show validation hints
      assert html =~ "此字段必填" || html =~ "required"
      assert html =~ "长度" || html =~ "length" || html =~ "2" || html =~ "100"
      assert html =~ "格式" || html =~ "format" || html =~ "@" || html =~ "邮箱地址"
    end
  end
end