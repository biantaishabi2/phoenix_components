defmodule PetalComponents.Custom.InputNumberTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.InputNumber
  alias Phoenix.LiveView.JS

  describe "input_number/1" do
    test "renders basic input number" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="basic" />
      """)
      
      assert html =~ ~s(id="basic")
      assert html =~ ~s(type="number")
      assert html =~ ~s(step="1")
      assert html =~ "inline-block relative"
    end

    test "renders with value" do
      assigns = %{value: 42}
      
      html = rendered_to_string(~H"""
        <.input_number id="with-value" value={@value} />
      """)
      
      assert html =~ ~s(value="42")
    end

    test "renders with min and max constraints" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="constrained" min={0} max={100} />
      """)
      
      assert html =~ ~s(min="0")
      assert html =~ ~s(max="100")
    end

    test "renders with custom step" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="step-test" step={0.1} />
      """)
      
      assert html =~ ~s(step="0.1")
    end

    test "renders with precision" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="precision-test" precision={2} />
      """)
      
      assert html =~ ~s(data-precision="2")
    end

    test "renders with placeholder" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="placeholder-test" placeholder="Enter number" />
      """)
      
      assert html =~ ~s(placeholder="Enter number")
    end

    test "renders disabled state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="disabled-test" disabled />
      """)
      
      assert html =~ "disabled"
      assert html =~ "opacity-50"
      assert html =~ "cursor-not-allowed"
    end

    test "renders readonly state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="readonly-test" readonly />
      """)
      
      assert html =~ "readonly"
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.input_number id={"size-#{@size}"} size={@size} />
        """)
        
        case size do
          "small" -> 
            assert html =~ "h-8"
            assert html =~ "text-sm"
          "medium" -> 
            assert html =~ "h-10"
            assert html =~ "text-sm"
          "large" -> 
            assert html =~ "h-12"
            assert html =~ "text-base"
        end
      end
    end

    test "renders different colors" do
      for color <- ~w(primary info success warning danger) do
        assigns = %{color: color}
        
        html = rendered_to_string(~H"""
          <.input_number id={"color-#{@color}"} color={@color} />
        """)
        
        # Verify color-specific focus classes exist
        assert html =~ "focus:ring-2"
        case color do
          "primary" -> assert html =~ "focus:ring-primary"
          "info" -> assert html =~ "focus:ring-blue-500"
          "success" -> assert html =~ "focus:ring-green-500"
          "warning" -> assert html =~ "focus:ring-yellow-500"
          "danger" -> assert html =~ "focus:ring-red-500"
        end
      end
    end

    test "renders with controls" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="controls-test" controls />
      """)
      
      # Should have increment and decrement buttons
      assert html =~ "aria-label=\"Increase\""
      assert html =~ "aria-label=\"Decrease\""
      # Check for the SVG path instead of the icon name
      assert html =~ "M5 15l7-7 7 7"  # up arrow path
      assert html =~ "M19 9l-7 7-7-7"  # down arrow path
    end

    test "renders without controls" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="no-controls-test" controls={false} />
      """)
      
      # Should not have increment and decrement buttons
      refute html =~ "aria-label=\"Increase\""
      refute html =~ "aria-label=\"Decrease\""
    end

    test "renders with prefix slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="prefix-test">
          <:prefix>$</:prefix>
        </.input_number>
      """)
      
      assert html =~ "$"
      assert html =~ "flex items-center px-3 text-gray-500 pr-0"
    end

    test "renders with suffix slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="suffix-test">
          <:suffix>%</:suffix>
        </.input_number>
      """)
      
      assert html =~ "%"
      assert html =~ "flex items-center px-3 text-gray-500 pl-0"
    end

    test "renders with both prefix and suffix" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="both-test">
          <:prefix>¥</:prefix>
          <:suffix>元</:suffix>
        </.input_number>
      """)
      
      assert html =~ "¥"
      assert html =~ "元"
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="custom-class" class="custom-input" />
      """)
      
      assert html =~ "custom-input"
    end

    test "renders with name attribute" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="named" name="quantity" />
      """)
      
      assert html =~ ~s(name="quantity")
    end

    test "renders with on_change event" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="change-test" on_change={JS.push("update_value")} />
      """)
      
      assert html =~ "phx-change"
      assert html =~ "update_value"
    end

    test "renders with on_focus event" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="focus-test" on_focus={JS.push("handle_focus")} />
      """)
      
      assert html =~ "phx-focus"
      assert html =~ "handle_focus"
    end

    test "renders with on_blur event" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="blur-test" on_blur={JS.push("handle_blur")} />
      """)
      
      assert html =~ "phx-blur"
      assert html =~ "handle_blur"
    end

    test "renders with formatter and parser" do
      formatter = fn value -> "$ #{value}" end
      parser = fn value -> String.replace(value, ~r/[^\d.]/, "") end
      
      assigns = %{formatter: formatter, parser: parser}
      
      html = rendered_to_string(~H"""
        <.input_number 
          id="format-test" 
          formatter={@formatter} 
          parser={@parser} 
        />
      """)
      
      # Verify data attributes for JS handling
      assert html =~ "data-formatter"
      assert html =~ "data-parser"
    end

    test "applies correct classes for disabled controls" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="disabled-controls" disabled controls />
      """)
      
      # Control buttons should also be disabled
      assert html =~ "cursor-not-allowed"
      assert html =~ "opacity-50"
    end

    test "combines multiple attributes correctly" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number 
          id="complex"
          name="price"
          value={99.99}
          min={0}
          max={1000}
          step={0.01}
          precision={2}
          size="large"
          color="success"
          placeholder="Enter price"
          controls
          on_change={JS.push("update_price")}
        >
          <:prefix>$</:prefix>
          <:suffix>USD</:suffix>
        </.input_number>
      """)
      
      # Verify all attributes are present
      assert html =~ ~s(id="complex")
      assert html =~ ~s(name="price")
      assert html =~ ~s(value="99.99")
      assert html =~ ~s(min="0")
      assert html =~ ~s(max="1000")
      assert html =~ ~s(step="0.01")
      assert html =~ ~s(data-precision="2")
      assert html =~ "h-12"  # large size
      assert html =~ "focus:ring-green-500"  # success color
      assert html =~ ~s(placeholder="Enter price")
      assert html =~ "$"  # prefix
      assert html =~ "USD"  # suffix
      assert html =~ "update_price"  # on_change
    end

    test "renders with keyboard attribute" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="keyboard-test" keyboard={false} />
      """)
      
      assert html =~ ~s(data-keyboard="false")
    end

    test "handles nil value gracefully" do
      assigns = %{value: nil}
      
      html = rendered_to_string(~H"""
        <.input_number id="nil-value" value={@value} />
      """)
      
      refute html =~ ~s(value=")
    end

    test "validates required id attribute" do
      # Test that the component properly uses the id attribute
      # We can't easily test missing required attributes without compile warnings
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="test-number" />
      """)
      
      # The component should render correctly with required id
      assert html =~ "test-number"
      assert html =~ ~s(id="test-number")
    end
  end

  describe "accessibility" do
    test "includes proper ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number 
          id="a11y-test" 
          min={0} 
          max={100}
          value={50}
        />
      """)
      
      assert html =~ ~s(role="spinbutton")
      assert html =~ ~s(aria-valuemin="0")
      assert html =~ ~s(aria-valuemax="100")
      assert html =~ ~s(aria-valuenow="50")
    end

    test "control buttons have proper ARIA labels" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.input_number id="a11y-controls" controls />
      """)
      
      assert html =~ "aria-label=\"Increase\""
      assert html =~ "aria-label=\"Decrease\""
    end
  end
end