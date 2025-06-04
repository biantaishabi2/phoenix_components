defmodule PetalComponents.Custom.SwitchTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Switch
  alias Phoenix.LiveView.JS

  describe "switch/1" do
    test "renders basic switch" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="basic" />
      """)
      
      assert html =~ ~s(id="basic")
      assert html =~ ~s(type="checkbox")
      assert html =~ ~s(role="switch")
      assert html =~ "relative inline-flex items-center cursor-pointer select-none"
    end

    test "renders with checked state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="checked" checked />
      """)
      
      assert html =~ "checked"
      assert html =~ "bg-orange-500"
    end

    test "renders with unchecked state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="unchecked" checked={false} />
      """)
      
      refute html =~ "bg-orange-500"
    end

    test "renders disabled state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="disabled" disabled />
      """)
      
      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed opacity-50"
    end

    test "renders loading state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="loading" loading />
      """)
      
      assert html =~ "pointer-events-none"
      assert html =~ "animate-spin"
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.switch id={"size-#{@size}"} size={@size} />
        """)
        
        case size do
          "small" -> assert html =~ "w-7 h-4"
          "medium" -> assert html =~ "w-11 h-6"
          "large" -> assert html =~ "w-14 h-7"
        end
      end
    end

    test "renders different colors" do
      for color <- ~w(primary info success warning danger) do
        assigns = %{color: color}
        
        html = rendered_to_string(~H"""
          <.switch id={"color-#{@color}"} color={@color} checked />
        """)
        
        # Should have color-specific classes when checked
        case color do
          "primary" -> assert html =~ "bg-orange-500"
          "info" -> assert html =~ "bg-blue-500"
          "success" -> assert html =~ "bg-green-500"
          "warning" -> assert html =~ "bg-yellow-500"
          "danger" -> assert html =~ "bg-red-500"
        end
      end
    end

    test "renders with checked children text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="with-text" checked checked_text="ON" />
      """)
      
      assert html =~ "ON"
      assert html =~ "absolute inset-0 flex items-center text-white font-medium"
    end

    test "renders with unchecked children text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="with-text" checked={false} unchecked_text="OFF" />
      """)
      
      assert html =~ "OFF"
      assert html =~ "absolute inset-0 flex items-center text-white font-medium"
    end

    test "renders with checked children slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="with-slot" checked>
          <:checked_children>
            <span class="custom-checked">✓</span>
          </:checked_children>
        </.switch>
      """)
      
      assert html =~ "custom-checked"
      assert html =~ "✓"
    end

    test "renders with unchecked children slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="with-slot" checked={false}>
          <:unchecked_children>
            <span class="custom-unchecked">✗</span>
          </:unchecked_children>
        </.switch>
      """)
      
      assert html =~ "custom-unchecked"
      assert html =~ "✗"
    end

    test "renders with both children slots" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="both-slots" checked>
          <:checked_children>ON</:checked_children>
          <:unchecked_children>OFF</:unchecked_children>
        </.switch>
      """)
      
      assert html =~ "ON"
      refute html =~ "OFF"  # Only checked content should be visible
    end

    test "renders with name attribute" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="named" name="settings[notifications]" />
      """)
      
      assert html =~ ~s(name="settings[notifications]")
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="custom" class="custom-switch" />
      """)
      
      assert html =~ "custom-switch"
    end

    test "renders with on_change event" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="change" on_change={JS.push("toggle")} />
      """)
      
      assert html =~ "phx-click"
      assert html =~ "toggle"
    end

    test "disabled switch with checked state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="disabled-checked" checked disabled />
      """)
      
      assert html =~ "checked"
      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed opacity-50"
    end

    test "loading switch prevents interaction" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="loading-interaction" loading checked />
      """)
      
      assert html =~ "pointer-events-none"
      assert html =~ "animate-spin"
    end

    test "validates id is required" do
      # Test that the component properly uses the id attribute
      # We can't easily test missing required attributes without compile warnings
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="test-switch" />
      """)
      
      # The component should render correctly with required id
      assert html =~ "test-switch"
      assert html =~ ~s(id="test-switch")
    end

    test "renders with all attributes combined" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch 
          id="complex"
          name="feature[enabled]"
          checked
          size="large"
          color="success"
          checked_text="Active"
          unchecked_text="Inactive"
          class="my-switch"
          on_change={JS.push("update_feature")}
        />
      """)
      
      assert html =~ ~s(id="complex")
      assert html =~ ~s(name="feature[enabled]")
      assert html =~ "checked"
      assert html =~ "w-14 h-7"
      assert html =~ "bg-green-500"
      assert html =~ "Active"
      assert html =~ "my-switch"
      assert html =~ "update_feature"
    end
  end

  describe "accessibility" do
    test "includes proper ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="a11y" checked />
      """)
      
      assert html =~ ~s(role="switch")
      assert html =~ ~s(aria-checked="true")
    end

    test "includes aria-checked false when unchecked" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="a11y-unchecked" checked={false} />
      """)
      
      assert html =~ ~s(aria-checked="false")
    end

    test "supports keyboard navigation" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.switch id="keyboard" />
      """)
      
      # Should be focusable
      refute html =~ ~s(tabindex="-1")
    end
  end
end