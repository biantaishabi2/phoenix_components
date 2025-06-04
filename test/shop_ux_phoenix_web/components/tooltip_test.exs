defmodule PetalComponents.Custom.TooltipTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Tooltip

  describe "tooltip/1" do
    test "renders basic tooltip" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="test-tooltip" title="This is a tooltip">
          <span>Hover me</span>
        </.tooltip>
      """)
      
      assert html =~ "data-tooltip-container"
      assert html =~ "Hover me"
      assert html =~ "This is a tooltip"
      assert html =~ ~s(data-placement="top")
    end

    test "renders with different placements" do
      for placement <- ~w(top bottom left right top-start top-end bottom-start bottom-end left-start left-end right-start right-end) do
        assigns = %{placement: placement}
        
        html = rendered_to_string(~H"""
          <.tooltip id="test" title="Tooltip" placement={@placement}>
            <span>Content</span>
          </.tooltip>
        """)
        
        assert html =~ ~s(data-placement="#{placement}")
      end
    end

    test "renders with different triggers" do
      for trigger <- ~w(hover click focus) do
        assigns = %{trigger: trigger}
        
        html = rendered_to_string(~H"""
          <.tooltip id="test" title="Tooltip" trigger={@trigger}>
            <span>Content</span>
          </.tooltip>
        """)
        
        assert html =~ ~s(data-trigger="#{trigger}")
      end
    end

    test "renders with custom content slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="custom-tooltip">
          <:content>
            <div class="custom-content">
              <h4>Custom Title</h4>
              <p>Custom description</p>
            </div>
          </:content>
          <button>Click me</button>
        </.tooltip>
      """)
      
      assert html =~ "custom-content"
      assert html =~ "Custom Title"
      assert html =~ "Custom description"
      assert html =~ "Click me"
    end

    test "renders with custom color" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="colored" title="Colored tooltip" color="#eb2f96">
          <span>Pink tooltip</span>
        </.tooltip>
      """)
      
      assert html =~ ~s(data-color="#eb2f96")
    end

    test "renders with controlled visibility" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="controlled" title="Controlled" visible={true}>
          <span>Always visible</span>
        </.tooltip>
      """)
      
      assert html =~ ~s(data-visible="true")
    end

    test "renders with delays" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip 
          id="delayed" 
          title="Delayed tooltip"
          mouse_enter_delay={500}
          mouse_leave_delay={1000}
        >
          <span>Delayed</span>
        </.tooltip>
      """)
      
      assert html =~ ~s(data-mouse-enter-delay="500")
      assert html =~ ~s(data-mouse-leave-delay="1000")
    end

    test "renders with arrow pointing at center" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="arrow-center" title="Centered arrow" arrow_point_at_center={true}>
          <span>Centered</span>
        </.tooltip>
      """)
      
      assert html =~ ~s(data-arrow-point-at-center="true")
    end

    test "renders disabled tooltip" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="disabled" title="Disabled tooltip" disabled={true}>
          <span>No tooltip</span>
        </.tooltip>
      """)
      
      assert html =~ ~s(data-disabled="true")
    end

    test "renders with custom z-index" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="z-indexed" title="High z-index" z_index={2000}>
          <span>High priority</span>
        </.tooltip>
      """)
      
      assert html =~ ~s(data-z-index="2000")
    end

    test "renders with custom overlay classes and styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip 
          id="styled" 
          title="Styled tooltip"
          overlay_class="custom-tooltip-class"
          overlay_style="max-width: 300px;"
        >
          <span>Styled</span>
        </.tooltip>
      """)
      
      assert html =~ "custom-tooltip-class"
      assert html =~ "max-width: 300px;"
    end

    test "renders with custom class on container" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="classed" title="Tooltip" class="inline-block">
          <span>Content</span>
        </.tooltip>
      """)
      
      assert html =~ "inline-block"
    end

    test "requires id attribute" do
      # Test that the component properly validates required attributes
      # We can't easily test missing required attributes without compile warnings,
      # so we test that the component works correctly with the id attribute
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="test-tooltip" title="Test">
          <span>Content</span>
        </.tooltip>
      """)
      
      # The component should render correctly with required id
      assert html =~ "test-tooltip"
      assert html =~ "Test"
    end

    test "handles multiple children in inner_block" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="multi-child" title="Tooltip">
          <div>
            <span>Line 1</span>
            <span>Line 2</span>
          </div>
        </.tooltip>
      """)
      
      assert html =~ "Line 1"
      assert html =~ "Line 2"
    end

    test "escapes HTML in title" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="escaped" title="<script>alert('xss')</script>">
          <span>Safe</span>
        </.tooltip>
      """)
      
      refute html =~ "<script>"
      assert html =~ "&lt;script&gt;"
    end
  end

  describe "accessibility" do
    test "includes ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="accessible" title="Accessible tooltip">
          <button>Accessible button</button>
        </.tooltip>
      """)
      
      assert html =~ ~s(role="tooltip")
      assert html =~ "aria-describedby"
    end

    test "supports keyboard navigation with focus trigger" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tooltip id="keyboard" title="Keyboard accessible" trigger="focus">
          <input type="text" placeholder="Focus me" />
        </.tooltip>
      """)
      
      assert html =~ ~s(data-trigger="focus")
      assert html =~ "Focus me"
    end
  end
end