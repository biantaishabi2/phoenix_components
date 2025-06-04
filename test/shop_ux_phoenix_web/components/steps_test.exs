defmodule PetalComponents.Custom.StepsTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Steps

  describe "steps/1" do
    test "renders basic steps" do
      assigns = %{
        steps: [
          %{title: "已完成", description: "这是第一步", status: "finish"},
          %{title: "进行中", description: "这是第二步", status: "process"},
          %{title: "等待中", description: "这是第三步", status: "wait"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="basic-steps"
          current={1}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps"
      assert html =~ "已完成"
      assert html =~ "进行中"
      assert html =~ "等待中"
    end
    
    test "renders with current step highlighted" do
      assigns = %{
        steps: [
          %{title: "第一步", status: "finish"},
          %{title: "第二步", status: "process"},
          %{title: "第三步", status: "wait"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="current-step"
          current={1}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__item--current"
    end
    
    test "renders horizontal direction by default" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="horizontal-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps--horizontal"
    end
    
    test "renders vertical direction" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="vertical-steps"
          direction="vertical"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps--vertical"
    end
    
    test "renders different sizes" do
      for current_size <- ["default", "small"] do
        assigns = %{
          steps: [%{title: "步骤", status: "process"}],
          current_size: current_size
        }
        
        html = rendered_to_string(~H"""
          <.steps 
            id={"size-#{@current_size}"}
            size={@current_size}
            steps={@steps}
          />
        """)
        
        case current_size do
          "default" -> assert html =~ "pc-steps--default"
          "small" -> assert html =~ "pc-steps--small"
        end
      end
    end
    
    test "renders different statuses" do
      for current_status <- ["wait", "process", "finish", "error"] do
        assigns = %{
          steps: [%{title: "步骤", status: "process"}],
          current_status: current_status
        }
        
        html = rendered_to_string(~H"""
          <.steps 
            id={"status-#{@current_status}"}
            status={@current_status}
            steps={@steps}
          />
        """)
        
        assert html =~ "pc-steps--status-#{current_status}"
      end
    end
    
    test "renders with custom icons" do
      assigns = %{
        steps: [
          %{
            title: "登录",
            description: "用户登录",
            icon: "user-icon",
            status: "finish"
          },
          %{
            title: "验证",
            description: "身份验证",
            icon: "check-icon",
            status: "process"
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="icon-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "user-icon"
      assert html =~ "check-icon"
    end
    
    test "renders progress dot style" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="dot-steps"
          progress_dot={true}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps--dot"
    end
    
    test "renders with progress percentage" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="progress-steps"
          current={1}
          percent={60}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__progress"
      assert html =~ "60%"
    end
    
    test "renders navigation type as clickable" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="nav-steps"
          type="navigation"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps--navigation"
      assert html =~ "cursor-pointer"
    end
    
    test "renders with custom initial step" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="initial-steps"
          initial={1}
          current={2}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps"
    end
    
    test "renders with descriptions" do
      assigns = %{
        steps: [
          %{
            title: "第一步",
            description: "这是详细的描述信息",
            status: "finish"
          },
          %{
            title: "第二步",
            description: "第二步的描述",
            status: "process"
          }
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="desc-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "这是详细的描述信息"
      assert html =~ "第二步的描述"
      assert html =~ "pc-steps__description"
    end
    
    test "renders step numbers correctly" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"},
          %{title: "步骤3", status: "wait"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="numbered-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__number"
    end
    
    test "renders error status correctly" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "error"},
          %{title: "步骤3", status: "wait"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="error-steps"
          current={1}
          status="error"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps--status-error"
      assert html =~ "pc-steps__item--error"
    end
    
    test "renders with custom class" do
      assigns = %{
        steps: [%{title: "步骤", status: "process"}]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="custom-class"
          steps={@steps}
          class="my-custom-class"
        />
      """)
      
      assert html =~ "my-custom-class"
    end
    
    test "renders with global attributes" do
      assigns = %{
        steps: [%{title: "步骤", status: "process"}]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="global-attrs"
          steps={@steps}
          data-testid="steps"
          aria-label="步骤条"
        />
      """)
      
      assert html =~ ~s(data-testid="steps")
      assert html =~ ~s(aria-label="步骤条")
    end
    
    test "renders responsive layout" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="responsive-steps"
          responsive={true}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps--responsive"
    end
    
    test "renders step connectors" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"},
          %{title: "步骤3", status: "wait"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="connector-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__connector"
    end
    
    test "handles empty steps gracefully" do
      assigns = %{
        steps: []
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="empty-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps"
    end
    
    test "renders with label placement" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="label-placement"
          label_placement="vertical"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps"
    end
    
    test "renders completed steps with check icon" do
      assigns = %{
        steps: [
          %{title: "已完成", status: "finish"},
          %{title: "进行中", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="completed-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__item--finish"
      assert html =~ "svg" # check icon
    end
    
    test "renders process step with number" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "finish"},
          %{title: "步骤2", status: "process"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="process-steps"
          current={1}
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__item--process"
    end
    
    test "renders wait step with number" do
      assigns = %{
        steps: [
          %{title: "步骤1", status: "process"},
          %{title: "步骤2", status: "wait"}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.steps 
          id="wait-steps"
          steps={@steps}
        />
      """)
      
      assert html =~ "pc-steps__item--wait"
    end
  end
end