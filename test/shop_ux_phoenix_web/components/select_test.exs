defmodule PetalComponents.Custom.SelectTest do
  use ShopUxPhoenixWeb.ComponentCase, async: true
  
  alias PetalComponents.Custom.Select
  alias Phoenix.LiveView.JS

  describe "select/1" do
    test "renders basic select with options" do
      assigns = %{
        options: [
          %{value: "1", label: "Option 1"},
          %{value: "2", label: "Option 2"},
          %{value: "3", label: "Option 3"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select id="test-select" options={@options} />
      """)
      
      # 检查基本结构
      assert html =~ ~s(id="test-select")
      assert html =~ "请选择"  # 默认placeholder
      assert html =~ ~s(type="button")  # 下拉触发按钮
      assert html =~ "pc-select"  # 检查主要CSS类
    end

    test "renders with custom placeholder" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="placeholder-select" 
          options={@options}
          placeholder="选择一个选项" 
        />
      """)
      
      assert html =~ "选择一个选项"
    end

    test "renders with selected value" do
      assigns = %{
        options: [
          %{value: "active", label: "激活"},
          %{value: "inactive", label: "未激活"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="value-select" 
          options={@options}
          value="active"
        />
      """)
      
      assert html =~ "激活"
      refute html =~ "请选择"
    end

    test "renders disabled select" do
      assigns = %{
        options: [%{value: "1", label: "Option 1"}]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="disabled-select" 
          options={@options}
          disabled
          value="1"
        />
      """)
      
      assert html =~ "disabled"
      assert html =~ "opacity-50"
      assert html =~ "cursor-not-allowed"
    end

    test "renders clearable select with value" do
      assigns = %{
        options: [%{value: "1", label: "Option 1"}]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="clearable-select" 
          options={@options}
          clearable
          value="1"
          on_clear={JS.push("clear")}
        />
      """)
      
      # 应该显示清除按钮
      assert html =~ "pc-select__clear"
      assert html =~ ~s(phx-click)
      assert html =~ "pc-select__clear"  # 检查清除按钮CSS类
    end

    test "renders multiple select" do
      assigns = %{
        options: [
          %{value: "1", label: "Tag 1"},
          %{value: "2", label: "Tag 2"},
          %{value: "3", label: "Tag 3"}
        ],
        selected: ["1", "2"]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="multiple-select" 
          options={@options}
          multiple
          value={@selected}
        />
      """)
      
      # 应该显示多个标签
      assert html =~ "Tag 1"
      assert html =~ "Tag 2"
      assert html =~ "tag"  # 标签样式类
      assert html =~ "pc-select__tag"  # 检查标签CSS类
    end

    test "renders searchable select" do
      assigns = %{
        options: [
          %{value: "1", label: "Option 1"},
          %{value: "2", label: "Option 2"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="searchable-select" 
          options={@options}
          searchable
          on_search={JS.push("search")}
        />
      """)
      
      # 应该有搜索输入框
      assert html =~ ~s(type="text")
      assert html =~ "pc-select__search"
      assert html =~ ~s(phx-keyup)
      assert html =~ "pc-select__search"  # 检查搜索CSS类
    end

    test "renders with different sizes" do
      assigns = %{options: []}
      
      # 小尺寸
      html = rendered_to_string(~H"""
        <Select.select id="small" options={@options} size="small" />
      """)
      assert html =~ "text-sm"
      assert html =~ "py-2 px-3"
      
      # 中尺寸（默认）
      html = rendered_to_string(~H"""
        <Select.select id="medium" options={@options} size="medium" />
      """)
      assert html =~ "text-sm"
      assert html =~ "py-2 px-4"
      
      # 大尺寸
      html = rendered_to_string(~H"""
        <Select.select id="large" options={@options} size="large" />
      """)
      assert html =~ "text-base"
      assert html =~ "py-2.5 px-6"
    end

    test "renders with grouped options" do
      assigns = %{
        grouped_options: [
          %{
            label: "Group 1",
            options: [
              %{value: "1-1", label: "Option 1-1"},
              %{value: "1-2", label: "Option 1-2"}
            ]
          },
          %{
            label: "Group 2",
            options: [
              %{value: "2-1", label: "Option 2-1"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="grouped-select" 
          options={@grouped_options}
        />
      """)
      
      # 检查分组标签
      assert html =~ "Group 1"
      assert html =~ "Group 2"
      assert html =~ "option-group"
    end

    test "renders with loading state" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="loading-select" 
          options={@options}
          loading
        />
      """)
      
      assert html =~ "loading"
      assert html =~ "animate-spin"  # 加载动画
      assert html =~ "pc-select__loading"  # 检查加载CSS类
    end

    test "renders with max tag count in multiple mode" do
      assigns = %{
        options: [
          %{value: "1", label: "Tag 1"},
          %{value: "2", label: "Tag 2"},
          %{value: "3", label: "Tag 3"},
          %{value: "4", label: "Tag 4"}
        ],
        selected: ["1", "2", "3", "4"]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="max-tag-select" 
          options={@options}
          multiple
          max_tag_count={2}
          value={@selected}
        />
      """)
      
      # 应该只显示2个标签和一个计数
      assert html =~ "Tag 1"
      assert html =~ "Tag 2"
      assert html =~ "+2"  # 剩余标签数
    end

    test "renders with custom class and dropdown class" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="custom-class-select" 
          options={@options}
          class="custom-select"
          dropdown_class="custom-dropdown"
        />
      """)
      
      assert html =~ "custom-select"
      assert html =~ "custom-dropdown"
    end

    test "renders with allow create option" do
      assigns = %{
        options: [
          %{value: "existing", label: "Existing Tag"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="creatable-select" 
          options={@options}
          searchable
          allow_create
          multiple
        />
      """)
      
      assert html =~ "pc-select__search"
      # 应该有创建新选项的提示
      assert html =~ "create-option"
    end

    test "renders with form field name" do
      assigns = %{
        options: [
          %{value: "1", label: "Option 1"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="form-select" 
          name="user[role]"
          options={@options}
          value="1"
        />
      """)
      
      # 应该有隐藏的input用于表单提交
      assert html =~ ~s(name="user[role]")
      assert html =~ ~s(type="hidden")
      assert html =~ ~s(value="1")
    end

    test "renders multiple select with array name" do
      assigns = %{
        options: [
          %{value: "1", label: "Option 1"},
          %{value: "2", label: "Option 2"}
        ],
        selected: ["1", "2"]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="multi-form-select" 
          name="user[roles][]"
          options={@options}
          multiple
          value={@selected}
        />
      """)
      
      # 应该有多个隐藏input
      assert html =~ ~s(name="user[roles][]")
      assert String.contains?(html, ~s(value="1"))
      assert String.contains?(html, ~s(value="2"))
    end

    test "renders with disabled options" do
      assigns = %{
        options: [
          %{value: "1", label: "Option 1"},
          %{value: "2", label: "Option 2", disabled: true},
          %{value: "3", label: "Option 3"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="disabled-options-select" 
          options={@options}
        />
      """)
      
      # 禁用的选项应该有特殊样式
      assert html =~ "disabled-option"
      assert html =~ "cursor-not-allowed"
    end
  end

  describe "select/1 with event handlers" do
    test "renders with on_change handler" do
      assigns = %{
        options: [%{value: "1", label: "Option 1"}]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="change-select" 
          options={@options}
          on_change={JS.push("select_changed")}
        />
      """)
      
      assert html =~ ~s(phx-click)
      assert html =~ "select_changed"
    end

    test "renders with on_search handler for searchable" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="search-select" 
          options={@options}
          searchable
          on_search={JS.push("search_options")}
        />
      """)
      
      assert html =~ ~s(phx-keyup)
      assert html =~ "search_options"
    end

    test "renders with on_clear handler for clearable" do
      assigns = %{
        options: [%{value: "1", label: "Option 1"}]
      }
      
      html = rendered_to_string(~H"""
        <Select.select 
          id="clear-select" 
          options={@options}
          clearable
          value="1"
          on_clear={JS.push("clear_selection")}
        />
      """)
      
      assert html =~ "clear_selection"
    end
  end
end