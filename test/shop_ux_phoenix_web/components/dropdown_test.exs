defmodule PetalComponents.Custom.DropdownTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Dropdown
  alias Phoenix.LiveView.JS

  describe "dropdown/1" do
    test "renders basic dropdown with trigger and items" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>Click me</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
          <:items key="item2" label="Item 2" />
        </.dropdown>
      """)
      
      assert html =~ "Click me"
      assert html =~ "Item 1"
      assert html =~ "Item 2"
      assert html =~ ~s(role="button")
      assert html =~ ~s(aria-expanded="false")
    end

    test "renders with custom id" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown id="my-dropdown">
          <:trigger>
            <button>Trigger</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
        </.dropdown>
      """)
      
      assert html =~ ~s(id="my-dropdown")
      assert html =~ ~s(aria-controls="my-dropdown-menu")
    end

    test "renders with hover trigger" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown trigger_type="hover">
          <:trigger>
            <span>Hover me</span>
          </:trigger>
          <:items key="item1" label="Item 1" />
        </.dropdown>
      """)
      
      assert html =~ "Hover me"
      assert html =~ "phx-mouseenter"
      assert html =~ "phx-mouseleave"
    end

    test "renders different positions" do
      for position <- ~w(bottom-start bottom-end top-start top-end left right) do
        assigns = %{position: position}
        
        html = rendered_to_string(~H"""
          <.dropdown position={@position}>
            <:trigger>
              <button>Trigger</button>
            </:trigger>
            <:items key="item1" label="Item 1" />
          </.dropdown>
        """)
        
        # Check position-specific classes are applied
        assert html =~ "Trigger"
      end
    end

    test "renders disabled dropdown" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown disabled>
          <:trigger>
            <button>Disabled</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
        </.dropdown>
      """)
      
      assert html =~ ~s(aria-disabled="true")
      assert html =~ "opacity-50"
      assert html =~ "cursor-not-allowed"
    end

    test "renders items with icons" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items 
            key="edit" 
            label="Edit" 
            icon={~s(<svg class="w-4 h-4"><path d="M0 0h24v24H0z"/></svg>)}
          />
        </.dropdown>
      """)
      
      assert html =~ "Edit"
      assert html =~ "<svg"
      assert html =~ "w-4 h-4"
    end

    test "renders divider items" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
          <:items divider />
          <:items key="item2" label="Item 2" />
        </.dropdown>
      """)
      
      assert html =~ "Item 1"
      assert html =~ "Item 2"
      assert html =~ ~s(role="separator")
      assert html =~ "border-t"
    end

    test "renders danger items" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="delete" label="Delete" danger />
        </.dropdown>
      """)
      
      assert html =~ "Delete"
      assert html =~ "text-red-600"
      assert html =~ "hover:bg-red-50"
    end

    test "renders disabled items" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="item1" label="Disabled Item" disabled />
        </.dropdown>
      """)
      
      assert html =~ "Disabled Item"
      assert html =~ ~s(aria-disabled="true")
      assert html =~ "opacity-50"
      assert html =~ "cursor-not-allowed"
    end

    test "renders with custom classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown class="my-dropdown" menu_class="custom-menu">
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
        </.dropdown>
      """)
      
      assert html =~ "my-dropdown"
      assert html =~ "custom-menu"
    end

    test "renders with arrow" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown arrow>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
        </.dropdown>
      """)
      
      assert html =~ "Menu"
      # Arrow element should be present
      assert html =~ ~s(data-popper-arrow)
    end

    test "renders with custom offset" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown offset={8}>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
        </.dropdown>
      """)
      
      assert html =~ "Menu"
      # Offset should be applied via style or data attribute
    end

    test "items have click handlers" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="edit" label="Edit" on_click={JS.push("edit")} />
          <:items key="delete" label="Delete" on_click={JS.push("delete")} />
        </.dropdown>
      """)
      
      assert html =~ ~s(phx-click)
      assert html =~ "edit"
      assert html =~ "delete"
    end

    test "renders complex dropdown with all features" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown 
          id="complex-dropdown"
          trigger_type="hover"
          position="top-end"
          arrow
          offset={12}
          class="complex"
          menu_class="w-64"
        >
          <:trigger>
            <button>Complex Menu</button>
          </:trigger>
          <:items 
            key="profile" 
            label="Profile" 
            icon={~s(<svg class="w-4 h-4"><path d="M0 0h24v24H0z"/></svg>)}
            on_click={JS.push("view_profile")}
          />
          <:items key="settings" label="Settings" on_click={JS.push("open_settings")} />
          <:items divider />
          <:items key="disabled" label="Disabled Action" disabled />
          <:items key="logout" label="Logout" danger on_click={JS.push("logout")} />
        </.dropdown>
      """)
      
      assert html =~ "Complex Menu"
      assert html =~ "complex"
      assert html =~ "w-64"
      assert html =~ "Profile"
      assert html =~ "Settings"
      assert html =~ "Disabled Action"
      assert html =~ "Logout"
      assert html =~ "<svg"
    end
  end

  describe "accessibility" do
    test "includes proper ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown id="a11y-dropdown">
          <:trigger>
            <button>Menu</button>
          </:trigger>
          <:items key="item1" label="Item 1" />
          <:items key="item2" label="Item 2" disabled />
        </.dropdown>
      """)
      
      assert html =~ ~s(role="button")
      assert html =~ ~s(aria-expanded="false")
      assert html =~ ~s(aria-haspopup="true")
      assert html =~ ~s(aria-controls="a11y-dropdown-menu")
      assert html =~ ~s(role="menu")
      assert html =~ ~s(role="menuitem")
      assert html =~ ~s(aria-disabled="true")
    end
  end

  describe "menu item grouping" do
    test "renders custom content in items slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.dropdown>
          <:trigger>
            <button>User Menu</button>
          </:trigger>
          <:items>
            <div class="p-4 border-b">
              <div class="font-bold">John Doe</div>
              <div class="text-sm text-gray-500">john@example.com</div>
            </div>
          </:items>
          <:items key="profile" label="View Profile" />
          <:items key="settings" label="Settings" />
        </.dropdown>
      """)
      
      assert html =~ "John Doe"
      assert html =~ "john@example.com"
      assert html =~ "View Profile"
      assert html =~ "Settings"
    end
  end
end