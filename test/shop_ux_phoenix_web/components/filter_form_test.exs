defmodule ShopUxPhoenixWeb.Components.FilterFormTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.FilterForm

  describe "filter_form/1" do
    test "renders basic filter form" do
      assigns = %{
        id: "test-filter",
        fields: [
          %{name: "search", type: "input", placeholder: "搜索"},
          %{name: "status", label: "状态", type: "select", options: [
            %{value: "active", label: "启用"},
            %{value: "inactive", label: "禁用"}
          ]}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id={@id} fields={@fields} />
      """)
      
      assert html =~ "filter-form"
      assert html =~ "test-filter"
      assert html =~ "搜索"
      assert html =~ "状态"
    end

    test "renders search input field" do
      assigns = %{
        fields: [
          %{name: "keyword", type: "search", placeholder: "输入关键词", width: "300px"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="search-form" fields={@fields} />
      """)
      
      assert html =~ "type=\"search\""
      assert html =~ "输入关键词"
      assert html =~ "width: 300px"
    end

    test "renders select field with options" do
      assigns = %{
        fields: [
          %{
            name: "category",
            label: "分类",
            type: "select",
            options: [
              %{value: "electronics", label: "电子产品"},
              %{value: "clothing", label: "服装"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="select-form" fields={@fields} />
      """)
      
      assert html =~ "分类"
      assert html =~ "电子产品"
      assert html =~ "服装"
      assert html =~ "select"
    end

    test "renders date range picker" do
      assigns = %{
        fields: [
          %{
            name: "date_range",
            label: "日期范围",
            type: "date_range",
            placeholder: ["开始日期", "结束日期"]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="date-form" fields={@fields} />
      """)
      
      assert html =~ "日期范围"
      assert html =~ "开始日期"
      assert html =~ "结束日期"
      assert html =~ "date-range"
    end

    test "renders with custom actions" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.filter_form id="custom-actions">
          <:actions>
            <button>自定义搜索</button>
            <button>导出</button>
          </:actions>
        </.filter_form>
      """)
      
      assert html =~ "自定义搜索"
      assert html =~ "导出"
    end

    test "renders with form values" do
      assigns = %{
        fields: [
          %{name: "status", type: "input"},
          %{name: "category", type: "select", options: []}
        ],
        values: %{
          "status" => "active",
          "category" => "electronics"
        }
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="form-with-values" fields={@fields} values={@values} />
      """)
      
      assert html =~ "value=\"active\""
    end

    test "renders checkbox field" do
      assigns = %{
        fields: [
          %{name: "only_active", label: "仅显示启用", type: "checkbox"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="checkbox-form" fields={@fields} />
      """)
      
      assert html =~ "type=\"checkbox\""
      assert html =~ "仅显示启用"
    end

    test "renders number range fields" do
      assigns = %{
        fields: [
          %{
            name: "price_range",
            label: "价格范围",
            type: "number_range",
            placeholder: ["最低价", "最高价"]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="number-range-form" fields={@fields} />
      """)
      
      assert html =~ "价格范围"
      assert html =~ "最低价"
      assert html =~ "最高价"
      assert html =~ "number"
    end

    test "renders with event handlers" do
      assigns = %{
        fields: [
          %{name: "test", type: "input"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form
          id="event-form"
          fields={@fields}
          on_search="handle_search"
          on_reset="handle_reset"
        />
      """)
      
      assert html =~ "phx-submit=\"handle_search\""
      assert html =~ "phx-click=\"handle_reset\""
    end

    test "renders responsive layout" do
      assigns = %{
        fields: [
          %{name: "field1", type: "input"},
          %{name: "field2", type: "input"},
          %{name: "field3", type: "input"}
        ],
        responsive: %{
          sm: 1,
          md: 2,
          lg: 3
        }
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="responsive-form" fields={@fields} responsive={@responsive} />
      """)
      
      assert html =~ "sm:grid-cols-1"
      assert html =~ "md:grid-cols-2"
      assert html =~ "lg:grid-cols-3"
    end

    test "applies custom classes" do
      assigns = %{
        fields: []
      }
      
      html = rendered_to_string(~H"""
        <.filter_form
          id="styled-form"
          fields={@fields}
          class="bg-gray-100 p-4"
          field_class="mb-3"
        />
      """)
      
      assert html =~ "bg-gray-100"
      assert html =~ "p-4"
    end

    test "handles tree select field" do
      assigns = %{
        fields: [
          %{
            name: "category",
            label: "分类",
            type: "tree_select",
            options: [
              %{
                value: "1",
                label: "电子产品",
                children: [
                  %{value: "1-1", label: "手机"},
                  %{value: "1-2", label: "电脑"}
                ]
              }
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="tree-select-form" fields={@fields} />
      """)
      
      assert html =~ "tree-select"
      assert html =~ "电子产品"
    end

    test "handles collapsible mode" do
      assigns = %{
        fields: [
          %{name: "field1", type: "input"},
          %{name: "field2", type: "input"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form
          id="collapsible-form"
          fields={@fields}
          collapsible={true}
          collapsed={false}
        />
      """)
      
      assert html =~ "collapsible"
    end
  end

  describe "field validation" do
    test "handles required fields" do
      assigns = %{
        fields: [
          %{name: "required_field", type: "input", required: true, label: "必填字段"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="required-form" fields={@fields} />
      """)
      
      assert html =~ "required"
      assert html =~ "必填字段"
    end

    test "handles field with custom props" do
      assigns = %{
        fields: [
          %{
            name: "custom",
            type: "input",
            props: %{
              maxlength: 50,
              pattern: "[A-Za-z]+"
            }
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="props-form" fields={@fields} />
      """)
      
      assert html =~ "maxlength=\"50\""
    end
  end

  describe "inline layout" do
    test "renders inline form by default" do
      assigns = %{
        fields: [
          %{name: "field1", type: "input"},
          %{name: "field2", type: "input"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="inline-form" fields={@fields} />
      """)
      
      assert html =~ "inline"
    end

    test "supports vertical layout" do
      assigns = %{
        fields: [
          %{name: "field1", type: "input"},
          %{name: "field2", type: "input"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.filter_form id="vertical-form" fields={@fields} layout="vertical" />
      """)
      
      assert html =~ "vertical"
    end
  end
end