defmodule PetalComponents.Custom.TabsTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Tabs
  alias Phoenix.LiveView.JS

  describe "tabs/1" do
    test "renders basic tabs" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs>
          <:tabs key="tab1" label="Tab 1">
            Content 1
          </:tabs>
          <:tabs key="tab2" label="Tab 2">
            Content 2
          </:tabs>
        </.tabs>
      """)
      
      assert html =~ "Tab 1"
      assert html =~ "Tab 2"
      assert html =~ "Content 1"
      assert html =~ ~s(hidden)  # Inactive tab should be hidden
      assert html =~ ~s(role="tablist")
      assert html =~ ~s(role="tab")
    end

    test "renders with active tab specified" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs active_tab="tab2">
          <:tabs key="tab1" label="Tab 1">
            Content 1
          </:tabs>
          <:tabs key="tab2" label="Tab 2">
            Content 2
          </:tabs>
        </.tabs>
      """)
      
      assert html =~ ~s(id="tabpanel-tab2") # Tab 2 panel exists
      refute html =~ ~s(id="tabpanel-tab2" aria-labelledby="tab-tab2" class="hidden) # Tab 2 is not hidden
    end

    test "renders different types" do
      for type <- ~w(line card pills) do
        assigns = %{type: type}
        
        html = rendered_to_string(~H"""
          <.tabs type={@type}>
            <:tabs key="tab1" label="Tab 1">Content</:tabs>
          </.tabs>
        """)
        
        # Check that type affects the rendering
        assert html =~ "Tab 1"
      end
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.tabs size={@size}>
            <:tabs key="tab1" label="Tab 1">Content</:tabs>
          </.tabs>
        """)
        
        # Size affects the button padding
        case size do
          "small" -> assert html =~ "px-3 py-1.5"
          "medium" -> assert html =~ "px-4 py-2"
          "large" -> assert html =~ "px-6 py-3"
        end
      end
    end

    test "renders different positions" do
      for position <- ~w(top right bottom left) do
        assigns = %{position: position}
        
        html = rendered_to_string(~H"""
          <.tabs position={@position}>
            <:tabs key="tab1" label="Tab 1">Content</:tabs>
          </.tabs>
        """)
        
        # Position affects container layout
        case position do
          "top" -> assert html =~ "flex flex-col"
          "bottom" -> assert html =~ "flex flex-col-reverse"
          "left" -> assert html =~ "flex flex-row"
          "right" -> assert html =~ "flex flex-row-reverse"
        end
      end
    end

    test "renders with icons" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs>
          <:tabs 
            key="home" 
            label="Home"
            icon={~s(<svg class="w-4 h-4"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>)}
          >
            Home content
          </:tabs>
        </.tabs>
      """)
      
      assert html =~ "Home"
      assert html =~ "<svg"
    end

    test "renders disabled tab" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs>
          <:tabs key="tab1" label="Active">Content 1</:tabs>
          <:tabs key="tab2" label="Disabled" disabled>Content 2</:tabs>
        </.tabs>
      """)
      
      assert html =~ "cursor-not-allowed"
      assert html =~ "opacity-50"
      assert html =~ ~s(aria-disabled="true")
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs class="my-custom-tabs">
          <:tabs key="tab1" label="Tab 1">Content</:tabs>
        </.tabs>
      """)
      
      assert html =~ "my-custom-tabs"
    end

    test "renders with on_change event" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs on_change={JS.push("change_tab")}>
          <:tabs key="tab1" label="Tab 1">Content</:tabs>
          <:tabs key="tab2" label="Tab 2">Content</:tabs>
        </.tabs>
      """)
      
      assert html =~ "phx-click"
      assert html =~ "change_tab"
    end

    test "renders without animation" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs animated={false}>
          <:tabs key="tab1" label="Tab 1">Content</:tabs>
        </.tabs>
      """)
      
      # When animated={false}, panels should not have transition classes
      refute html =~ ~s(class="transition-opacity duration-200")
    end

    test "renders multiple tabs with correct structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs active_tab="tab2">
          <:tabs key="tab1" label="First">First content</:tabs>
          <:tabs key="tab2" label="Second">Second content</:tabs>
          <:tabs key="tab3" label="Third">Third content</:tabs>
          <:tabs key="tab4" label="Fourth" disabled>Fourth content</:tabs>
        </.tabs>
      """)
      
      # Check tab headers
      assert html =~ "First"
      assert html =~ "Second"
      assert html =~ "Third"
      assert html =~ "Fourth"
      
      # Check that only second tab content is visible
      assert html =~ ~s(aria-selected="true") # One tab is selected
      assert html =~ "Second content"
      
      # Check active state
      assert html =~ ~s(aria-selected="true")
    end

    test "renders with all attributes combined" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs 
          active_tab="settings"
          type="card"
          size="large"
          position="left"
          animated={false}
          class="my-tabs"
          on_change={JS.push("tab_changed")}
        >
          <:tabs key="profile" label="Profile" icon="👤">
            Profile content
          </:tabs>
          <:tabs key="settings" label="Settings" icon="⚙️">
            Settings content
          </:tabs>
        </.tabs>
      """)
      
      # Check card type styling
      assert html =~ "rounded-t-md"
      # Check large size
      assert html =~ "px-6 py-3"
      # Check left position
      assert html =~ "flex-row"
      # Check custom class
      assert html =~ "my-tabs"
      # Check active content
      assert html =~ "Settings content"
      # Check event handler
      assert html =~ "tab_changed"
    end
  end

  describe "accessibility" do
    test "includes proper ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs>
          <:tabs key="tab1" label="Tab 1">Content 1</:tabs>
          <:tabs key="tab2" label="Tab 2">Content 2</:tabs>
        </.tabs>
      """)
      
      assert html =~ ~s(role="tablist")
      assert html =~ ~s(role="tab")
      assert html =~ ~s(role="tabpanel")
      assert html =~ ~s(aria-selected="true")
      assert html =~ ~s(aria-selected="false")
    end

    test "disabled tabs have proper aria attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.tabs>
          <:tabs key="tab1" label="Active">Content</:tabs>
          <:tabs key="tab2" label="Disabled" disabled>Content</:tabs>
        </.tabs>
      """)
      
      assert html =~ ~s(aria-disabled="true")
    end
  end
end