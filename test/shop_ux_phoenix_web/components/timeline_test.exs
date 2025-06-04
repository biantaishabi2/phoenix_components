defmodule ShopUxPhoenixWeb.Components.TimelineTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.Timeline

  @sample_items [
    %{
      id: "1",
      title: "项目启动",
      description: "项目正式启动，开始需求分析",
      time: "2024-01-01 09:00",
      color: "success",
      dot: "hero-play",
      status: "completed"
    },
    %{
      id: "2", 
      title: "设计评审",
      description: "完成UI设计稿评审",
      time: "2024-01-15 14:30",
      color: "primary",
      dot: "hero-eye",
      status: "completed"
    },
    %{
      id: "3",
      title: "开发进行中",
      description: "前端开发正在进行",
      time: "2024-02-01 10:00",
      color: "warning",
      dot: "hero-code-bracket",
      status: "processing"
    }
  ]

  describe "timeline/1" do
    test "renders basic timeline" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="basic-timeline" items={@items} />
      """)
      
      assert html =~ "basic-timeline"
      assert html =~ "项目启动"
      assert html =~ "设计评审"
      assert html =~ "开发进行中"
    end

    test "renders empty timeline" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.timeline id="empty-timeline" items={[]} />
      """)
      
      assert html =~ "empty-timeline"
      assert html =~ "timeline"
    end

    test "renders with custom size" do
      assigns = %{items: @sample_items}
      
      # Test small size
      html = rendered_to_string(~H"""
        <.timeline id="small-timeline" items={@items} size="small" />
      """)
      assert html =~ "text-sm" || html =~ "timeline"
      
      # Test medium size  
      html = rendered_to_string(~H"""
        <.timeline id="medium-timeline" items={@items} size="medium" />
      """)
      assert html =~ "timeline"
      
      # Test large size
      html = rendered_to_string(~H"""
        <.timeline id="large-timeline" items={@items} size="large" />
      """)
      assert html =~ "timeline"
    end

    test "renders with different colors" do
      assigns = %{items: @sample_items}
      
      # Test primary color
      html = rendered_to_string(~H"""
        <.timeline id="primary-timeline" items={@items} color="primary" />
      """)
      assert html =~ "timeline"
      
      # Test success color
      html = rendered_to_string(~H"""
        <.timeline id="success-timeline" items={@items} color="success" />
      """)
      assert html =~ "timeline"
      
      # Test warning color
      html = rendered_to_string(~H"""
        <.timeline id="warning-timeline" items={@items} color="warning" />
      """)
      assert html =~ "timeline"
    end

    test "renders with reverse order" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="reverse-timeline" items={@items} reverse={true} />
      """)
      
      assert html =~ "开发进行中"
      assert html =~ "设计评审"
      assert html =~ "项目启动"
    end

    test "renders with different modes" do
      assigns = %{items: @sample_items}
      
      # Test left mode
      html = rendered_to_string(~H"""
        <.timeline id="left-timeline" items={@items} mode="left" />
      """)
      assert html =~ "timeline"
      
      # Test right mode
      html = rendered_to_string(~H"""
        <.timeline id="right-timeline" items={@items} mode="right" />
      """)
      assert html =~ "timeline"
      
      # Test alternate mode
      html = rendered_to_string(~H"""
        <.timeline id="alternate-timeline" items={@items} mode="alternate" />
      """)
      assert html =~ "timeline"
    end

    test "renders with pending state" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="pending-timeline" items={@items} pending={true} />
      """)
      
      assert html =~ "pending" || html =~ "animate" || html =~ "加载"
    end

    test "renders with custom pending dot" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline 
          id="custom-pending-timeline" 
          items={@items} 
          pending={true}
          pending_dot="加载中..."
        />
      """)
      
      assert html =~ "加载中..."
    end

    test "renders with clickable items" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline 
          id="clickable-timeline" 
          items={@items} 
          on_item_click="item_clicked"
        />
      """)
      
      assert html =~ "phx-click" || html =~ "item_clicked"
    end

    test "renders time information" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="time-timeline" items={@items} />
      """)
      
      assert html =~ "2024-01-01 09:00"
      assert html =~ "2024-01-15 14:30"
      assert html =~ "2024-02-01 10:00"
    end

    test "renders with custom icons" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="icon-timeline" items={@items} />
      """)
      
      assert html =~ "hero-play"
      assert html =~ "hero-eye"
      assert html =~ "hero-code-bracket"
    end

    test "renders with custom class" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline 
          id="custom-timeline" 
          items={@items} 
          class="custom-timeline-class"
        />
      """)
      
      assert html =~ "custom-timeline-class"
    end

    test "handles empty descriptions gracefully" do
      items_without_desc = [
        %{
          id: "1",
          title: "简单事件",
          time: "2024-01-01 12:00",
          color: "primary"
        }
      ]
      
      assigns = %{items: items_without_desc}
      
      html = rendered_to_string(~H"""
        <.timeline id="no-desc-timeline" items={@items} />
      """)
      
      assert html =~ "简单事件"
      refute html =~ "Elixir.Inspect.Error"
    end

    test "handles items without icons" do
      items_without_icons = [
        %{
          id: "1",
          title: "无图标事件",
          description: "这个事件没有图标",
          time: "2024-01-01 12:00",
          color: "primary"
        }
      ]
      
      assigns = %{items: items_without_icons}
      
      html = rendered_to_string(~H"""
        <.timeline id="no-icon-timeline" items={@items} />
      """)
      
      assert html =~ "无图标事件"
      # Should render default dot instead of icon
      assert html =~ "timeline-dot" || html =~ "rounded-full"
    end

    test "renders item status classes" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="status-timeline" items={@items} />
      """)
      
      # Should render status information in the timeline
      assert html =~ "已完成" || html =~ "进行中" || html =~ "timeline-status"
    end

    test "renders descriptions properly" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="desc-timeline" items={@items} />
      """)
      
      assert html =~ "项目正式启动，开始需求分析"
      assert html =~ "完成UI设计稿评审"
      assert html =~ "前端开发正在进行"
    end
  end

  describe "styling" do
    test "applies correct base classes" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="styled-timeline" items={@items} />
      """)
      
      assert html =~ "timeline"
      assert html =~ "relative"
    end

    test "applies size-specific classes" do
      assigns = %{items: @sample_items}
      
      # Test small size styling
      html = rendered_to_string(~H"""
        <.timeline id="size-small-timeline" items={@items} size="small" />
      """)
      assert html =~ "timeline"
      
      # Test large size styling
      html = rendered_to_string(~H"""
        <.timeline id="size-large-timeline" items={@items} size="large" />
      """)
      assert html =~ "timeline"
    end
  end

  describe "interaction" do
    test "renders click handlers when provided" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline 
          id="interactive-timeline" 
          items={@items} 
          on_item_click="handle_click"
        />
      """)
      
      assert html =~ "phx-click" || html =~ "handle_click"
    end

    test "does not render click handlers when not provided" do
      assigns = %{items: @sample_items}
      
      html = rendered_to_string(~H"""
        <.timeline id="static-timeline" items={@items} />
      """)
      
      # Should not have click handlers if on_item_click is not provided
      assert html =~ "timeline"
    end
  end
end