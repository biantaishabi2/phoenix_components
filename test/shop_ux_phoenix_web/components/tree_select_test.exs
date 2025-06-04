defmodule PetalComponents.Custom.TreeSelectTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.TreeSelect

  describe "tree_select/1" do
    test "renders basic tree select" do
      assigns = %{
        tree_data: [
          %{
            title: "Node1",
            key: "0-0",
            children: [
              %{title: "Child Node1", key: "0-0-1"},
              %{title: "Child Node2", key: "0-0-2"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="basic-tree"
          tree_data={@tree_data}
          placeholder="请选择节点"
        />
      """)
      
      assert html =~ "pc-tree-select"
      assert html =~ "请选择节点"
      assert html =~ "Node1"
    end
    
    test "renders with selected value" do
      assigns = %{
        tree_data: [
          %{
            title: "Node1",
            key: "0-0",
            children: [
              %{title: "Child Node1", key: "0-0-1"}
            ]
          }
        ],
        value: "0-0-1"
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="with-value"
          tree_data={@tree_data}
          value={@value}
        />
      """)
      
      assert html =~ "Child Node1"
    end
    
    test "renders multiple selection mode" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"},
          %{title: "Node2", key: "0-1"}
        ],
        values: ["0-0", "0-1"]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="multiple-tree"
          tree_data={@tree_data}
          value={@values}
          multiple={true}
        />
      """)
      
      assert html =~ "multiple-select"
      assert html =~ "Node1"
      assert html =~ "Node2"
    end
    
    test "renders with checkable nodes" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="checkable-tree"
          tree_data={@tree_data}
          checkable={true}
        />
      """)
      
      assert html =~ "pc-tree-select__checkbox"
    end
    
    test "renders with search functionality" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="searchable-tree"
          tree_data={@tree_data}
          show_search={true}
          search_placeholder="搜索节点"
        />
      """)
      
      assert html =~ "pc-tree-select__search"
      assert html =~ "搜索节点"
    end
    
    test "renders disabled state" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="disabled-tree"
          tree_data={@tree_data}
          disabled={true}
        />
      """)
      
      assert html =~ "cursor-not-allowed"
      assert html =~ "opacity-50"
    end
    
    test "renders different sizes" do
      for current_size <- ["small", "medium", "large"] do
        assigns = %{
          tree_data: [],
          current_size: current_size
        }
        
        html = rendered_to_string(~H"""
          <.tree_select 
            id={"size-#{@current_size}"}
            tree_data={@tree_data}
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
    
    test "renders with custom field names" do
      assigns = %{
        tree_data: [
          %{
            name: "Custom Node",
            id: "custom-1",
            sub_nodes: [
              %{name: "Custom Child", id: "custom-1-1"}
            ]
          }
        ],
        field_names: %{title: "name", key: "id", children: "sub_nodes"}
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="custom-fields"
          tree_data={@tree_data}
          field_names={@field_names}
        />
      """)
      
      assert html =~ "Custom Node"
    end
    
    test "renders with max tag count" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"},
          %{title: "Node2", key: "0-1"},
          %{title: "Node3", key: "0-2"}
        ],
        values: ["0-0", "0-1", "0-2"]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="limited-tags"
          tree_data={@tree_data}
          value={@values}
          multiple={true}
          max_tag_count={2}
          max_tag_placeholder="+ {count} 项"
        />
      """)
      
      assert html =~ "max-tag-placeholder"
    end
    
    test "renders with allow clear" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ],
        value: "0-0"
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="clearable"
          tree_data={@tree_data}
          value={@value}
          allow_clear={true}
        />
      """)
      
      assert html =~ "pc-tree-select__clear"
    end
    
    test "does not render clear button when allow_clear is false" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ],
        value: "0-0"
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="no-clear"
          tree_data={@tree_data}
          value={@value}
          allow_clear={false}
        />
      """)
      
      refute html =~ "pc-tree-select__clear"
    end
    
    test "renders expanded tree by default" do
      assigns = %{
        tree_data: [
          %{
            title: "Parent",
            key: "parent",
            children: [
              %{title: "Child", key: "child"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="expanded-tree"
          tree_data={@tree_data}
          tree_default_expand_all={true}
        />
      """)
      
      assert html =~ "tree-expanded"
    end
    
    test "renders with specific expanded keys" do
      assigns = %{
        tree_data: [
          %{
            title: "Parent1",
            key: "parent1",
            children: [
              %{title: "Child1", key: "child1"}
            ]
          },
          %{
            title: "Parent2", 
            key: "parent2",
            children: [
              %{title: "Child2", key: "child2"}
            ]
          }
        ],
        expanded_keys: ["parent1"]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="specific-expanded"
          tree_data={@tree_data}
          tree_default_expanded_keys={@expanded_keys}
        />
      """)
      
      assert html =~ "Parent1"
      assert html =~ "Parent2"
    end
    
    test "renders hidden form inputs when name is provided" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ],
        value: "0-0"
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="form-input"
          name="tree_value"
          tree_data={@tree_data}
          value={@value}
        />
      """)
      
      assert html =~ ~s(name="tree_value")
      assert html =~ ~s(value="0-0")
    end
    
    test "renders with custom class" do
      assigns = %{
        tree_data: []
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="custom-class"
          tree_data={@tree_data}
          class="my-custom-class"
        />
      """)
      
      assert html =~ "my-custom-class"
    end
    
    test "renders with global attributes" do
      assigns = %{
        tree_data: []
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="global-attrs"
          tree_data={@tree_data}
          data-testid="tree-select"
          aria-label="选择树节点"
        />
      """)
      
      assert html =~ ~s(data-testid="tree-select")
      assert html =~ ~s(aria-label="选择树节点")
    end
    
    test "renders tree dropdown panel" do
      assigns = %{
        tree_data: [
          %{
            title: "Node1",
            key: "0-0",
            children: [
              %{title: "Child1", key: "0-0-1"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="dropdown"
          tree_data={@tree_data}
        />
      """)
      
      assert html =~ "tree-dropdown-panel"
      assert html =~ "hidden"
    end
    
    test "renders tree nodes with proper structure" do
      assigns = %{
        tree_data: [
          %{
            title: "Parent",
            key: "parent",
            children: [
              %{
                title: "Child",
                key: "child",
                disabled: true
              }
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="tree-structure"
          tree_data={@tree_data}
          tree_default_expand_all={true}
        />
      """)
      
      assert html =~ "pc-tree-select__node"
      assert html =~ "Parent"
      assert html =~ "Child"
      assert html =~ "node-disabled"
    end
    
    test "handles empty tree data gracefully" do
      assigns = %{
        tree_data: []
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="empty-tree"
          tree_data={@tree_data}
        />
      """)
      
      assert html =~ "pc-tree-select"
      refute html =~ "pc-tree-select__node"
    end
    
    test "handles nil value gracefully" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ],
        nil_value: nil
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="nil-value"
          tree_data={@tree_data}
          value={@nil_value}
        />
      """)
      
      assert html =~ "pc-tree-select"
    end
    
    test "renders with tree check strictly mode" do
      assigns = %{
        tree_data: [
          %{
            title: "Parent",
            key: "parent",
            children: [
              %{title: "Child", key: "child"}
            ]
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="check-strictly"
          tree_data={@tree_data}
          checkable={true}
          tree_check_strictly={true}
        />
      """)
      
      assert html =~ "tree-check-strictly"
    end
    
    test "renders with custom drop down style" do
      assigns = %{
        tree_data: [
          %{title: "Node1", key: "0-0"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.tree_select 
          id="custom-dropdown"
          tree_data={@tree_data}
          drop_down_style="max-height: 300px"
        />
      """)
      
      assert html =~ "max-height: 300px"
    end
  end
end