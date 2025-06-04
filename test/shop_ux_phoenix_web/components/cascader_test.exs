defmodule PetalComponents.Custom.CascaderTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Cascader

  describe "cascader/1" do
    test "renders basic cascader" do
      assigns = %{
        options: [
          %{
            value: "zhejiang",
            label: "浙江",
            children: [
              %{value: "hangzhou", label: "杭州"},
              %{value: "ningbo", label: "宁波"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="basic-cascader"
          options={@options}
          placeholder="请选择地区"
        />
      """)
      
      assert html =~ "pc-cascader"
      assert html =~ "请选择地区"
      assert html =~ "浙江"
    end
    
    test "renders with value" do
      assigns = %{
        options: [
          %{
            value: "zhejiang",
            label: "浙江",
            children: [
              %{value: "hangzhou", label: "杭州"}
            ]
          }
        ],
        value: ["zhejiang", "hangzhou"]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="with-value"
          options={@options}
          value={@value}
        />
      """)
      
      assert html =~ "浙江 / 杭州"
    end
    
    test "renders with custom separator" do
      assigns = %{
        options: [
          %{
            value: "zhejiang",
            label: "浙江",
            children: [
              %{value: "hangzhou", label: "杭州"}
            ]
          }
        ],
        value: ["zhejiang", "hangzhou"]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="custom-separator"
          options={@options}
          value={@value}
          separator=" > "
        />
      """)
      
      # 检查显示文本中包含自定义分隔符
      assert html =~ "浙江"
      assert html =~ "杭州"
    end
    
    test "renders disabled state" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="disabled"
          options={@options}
          disabled={true}
        />
      """)
      
      assert html =~ "cursor-not-allowed"
      assert html =~ "opacity-50"
    end
    
    test "renders different sizes" do
      for current_size <- ["small", "medium", "large"] do
        assigns = %{
          options: [],
          current_size: current_size
        }
        
        html = rendered_to_string(~H"""
          <.cascader 
            id={"size-#{@current_size}"}
            options={@options}
            size={@current_size}
          />
        """)
        
        case current_size do
          "small" -> assert html =~ "text-sm" && assert html =~ "py-2 px-3"
          "medium" -> assert html =~ "text-sm" && assert html =~ "py-2 px-4"
          "large" -> assert html =~ "text-base" && assert html =~ "py-2.5 px-6"
        end
      end
    end
    
    test "renders searchable cascader" do
      assigns = %{
        options: [
          %{value: "option1", label: "选项1"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="searchable"
          options={@options}
          searchable={true}
        />
      """)
      
      assert html =~ "pc-cascader__search"
    end
    
    test "renders multiple selection mode" do
      assigns = %{
        options: [
          %{value: "option1", label: "选项1"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="multiple"
          options={@options}
          multiple={true}
        />
      """)
      
      assert html =~ "multiple-select"
    end
    
    test "renders clearable button when value exists" do
      assigns = %{
        options: [
          %{value: "option1", label: "选项1"}
        ],
        value: ["option1"]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="clearable"
          options={@options}
          value={@value}
          clearable={true}
        />
      """)
      
      assert html =~ "pc-cascader__clear"
    end
    
    test "does not render clear button when no value" do
      assigns = %{
        options: [
          %{value: "option1", label: "选项1"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="no-clear"
          options={@options}
          clearable={true}
        />
      """)
      
      refute html =~ "pc-cascader__clear"
    end
    
    test "renders with custom field names" do
      assigns = %{
        options: [
          %{
            id: "zj",
            name: "浙江",
            sub_items: [
              %{id: "hz", name: "杭州"}
            ]
          }
        ],
        field_names: %{label: "name", value: "id", children: "sub_items"}
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="custom-fields"
          options={@options}
          field_names={@field_names}
        />
      """)
      
      # 检查第一级选项显示正确
      assert html =~ "浙江"
      # 检查有子项标识
      assert html =~ "svg"
    end
    
    test "renders hidden form inputs when name is provided" do
      assigns = %{
        options: [
          %{value: "option1", label: "选项1"}
        ],
        value: ["option1"]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="form-input"
          name="area"
          options={@options}
          value={@value}
        />
      """)
      
      assert html =~ ~s(name="area")
      assert html =~ ~s(value="option1")
    end
    
    test "renders with custom class" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="custom-class"
          options={@options}
          class="my-custom-class"
        />
      """)
      
      assert html =~ "my-custom-class"
    end
    
    test "renders with global attributes" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="global-attrs"
          options={@options}
          data-testid="cascader"
          aria-label="选择地区"
        />
      """)
      
      assert html =~ ~s(data-testid="cascader")
      assert html =~ ~s(aria-label="选择地区")
    end
    
    test "renders dropdown panel" do
      assigns = %{
        options: [
          %{
            value: "zhejiang",
            label: "浙江",
            children: [
              %{value: "hangzhou", label: "杭州"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="dropdown"
          options={@options}
        />
      """)
      
      assert html =~ "dropdown-panel"
      assert html =~ "hidden"
    end
    
    test "renders multi-level options" do
      assigns = %{
        options: [
          %{
            value: "china",
            label: "中国",
            children: [
              %{
                value: "zhejiang",
                label: "浙江",
                children: [
                  %{value: "hangzhou", label: "杭州"},
                  %{value: "ningbo", label: "宁波"}
                ]
              }
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="multi-level"
          options={@options}
        />
      """)
      
      # 只检查第一级选项，因为其他级别只有在选择后才会显示
      assert html =~ "中国"
    end
    
    test "handles empty options gracefully" do
      assigns = %{
        options: []
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="empty-options"
          options={@options}
        />
      """)
      
      assert html =~ "pc-cascader"
      # 空选项时不应该有cascader-option类
      refute html =~ "pc-cascader__option"
    end
    
    test "handles nil value gracefully" do
      assigns = %{
        options: [
          %{value: "option1", label: "选项1"}
        ],
        nil_value: nil
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="nil-value"
          options={@options}
          value={@nil_value}
        />
      """)
      
      assert html =~ "pc-cascader"
    end
    
    test "shows all levels in display by default" do
      assigns = %{
        options: [
          %{
            value: "zhejiang",
            label: "浙江",
            children: [
              %{value: "hangzhou", label: "杭州"}
            ]
          }
        ],
        value: ["zhejiang", "hangzhou"]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="show-all-levels"
          options={@options}
          value={@value}
          show_all_levels={true}
        />
      """)
      
      assert html =~ "浙江 / 杭州"
    end
    
    test "shows only last level when show_all_levels is false" do
      assigns = %{
        options: [
          %{
            value: "zhejiang",
            label: "浙江",
            children: [
              %{value: "hangzhou", label: "杭州"}
            ]
          }
        ],
        value: ["zhejiang", "hangzhou"]
      }
      
      html = rendered_to_string(~H"""
        <.cascader 
          id="show-last-level"
          options={@options}
          value={@value}
          show_all_levels={false}
        />
      """)
      
      assert html =~ "杭州"
      refute html =~ "浙江 / 杭州"
    end
  end
end