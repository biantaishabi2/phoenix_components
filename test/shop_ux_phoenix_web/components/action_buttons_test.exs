defmodule ShopUxPhoenixWeb.Components.ActionButtonsTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.ActionButtons
  import ShopUxPhoenixWeb.CoreComponents

  describe "action_buttons/1" do
    test "renders basic action buttons" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons>
          <button>Edit</button>
          <button>Delete</button>
        </.action_buttons>
      """)
      
      assert html =~ "Edit"
      assert html =~ "Delete"
      assert html =~ ~s(class=)
    end

    test "renders with different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.action_buttons size={@size}>
            <button>Action</button>
          </.action_buttons>
        """)
        
        assert html =~ "Action"
      end
    end

    test "renders with different spacing" do
      for spacing <- ~w(small medium large none) do
        assigns = %{spacing: spacing}
        
        html = rendered_to_string(~H"""
          <.action_buttons spacing={@spacing}>
            <button>Button 1</button>
            <button>Button 2</button>
          </.action_buttons>
        """)
        
        assert html =~ "Button 1"
        assert html =~ "Button 2"
        
        case spacing do
          "small" -> assert html =~ "gap-1" || html =~ "space-x-1"
          "medium" -> assert html =~ "gap-2" || html =~ "space-x-2"
          "large" -> assert html =~ "gap-4" || html =~ "space-x-4"
          "none" -> assert html =~ "gap-0" || html =~ "space-x-0"
        end
      end
    end

    test "renders with different alignments" do
      for align <- ~w(left center right between) do
        assigns = %{align: align}
        
        html = rendered_to_string(~H"""
          <.action_buttons align={@align}>
            <button>Action</button>
          </.action_buttons>
        """)
        
        assert html =~ "Action"
        
        case align do
          "left" -> assert html =~ "justify-start"
          "center" -> assert html =~ "justify-center"
          "right" -> assert html =~ "justify-end"
          "between" -> assert html =~ "justify-between"
        end
      end
    end

    test "renders with vertical direction" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons direction="vertical">
          <button>Button 1</button>
          <button>Button 2</button>
        </.action_buttons>
      """)
      
      assert html =~ "Button 1"
      assert html =~ "Button 2"
      assert html =~ "flex-col"
    end

    test "renders in compact mode" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons compact>
          <button>A</button>
          <button>B</button>
          <button>C</button>
        </.action_buttons>
      """)
      
      assert html =~ "A"
      assert html =~ "B"
      assert html =~ "C"
    end

    test "renders with dividers" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons divider>
          <a href="#">Link 1</a>
          <a href="#">Link 2</a>
          <a href="#">Link 3</a>
        </.action_buttons>
      """)
      
      assert html =~ "Link 1"
      assert html =~ "Link 2"
      assert html =~ "Link 3"
      # Should have divider elements
      assert html =~ "border-l" || html =~ "divide-x"
    end

    test "renders with extra slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons align="between">
          <button>Left Button</button>
          <:extra>
            <button>Right Button</button>
          </:extra>
        </.action_buttons>
      """)
      
      assert html =~ "Left Button"
      assert html =~ "Right Button"
      assert html =~ "justify-between"
    end

    test "renders mixed button types" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons>
          <.button>Phoenix Button</.button>
          <button>HTML Button</button>
          <a href="#">Link</a>
        </.action_buttons>
      """)
      
      assert html =~ "Phoenix Button"
      assert html =~ "HTML Button"
      assert html =~ "Link"
    end

    test "applies custom classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons class="custom-actions">
          <button>Action</button>
        </.action_buttons>
      """)
      
      assert html =~ "custom-actions"
    end

    test "handles rest attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons id="actions-1" data-testid="action-group">
          <button>Action</button>
        </.action_buttons>
      """)
      
      assert html =~ ~s(id="actions-1")
      assert html =~ ~s(data-testid="action-group")
    end

    test "renders multiple action buttons" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons>
          <button>Action 1</button>
          <button>Action 2</button>
          <button>Action 3</button>
          <button>Action 4</button>
        </.action_buttons>
      """)
      
      # All actions should be rendered
      # The max_visible feature with dropdown is planned for future implementation
      assert html =~ "Action 1"
      assert html =~ "Action 2"
      assert html =~ "Action 3"
      assert html =~ "Action 4"
    end

    test "conditional rendering with :if" do
      assigns = %{show_edit: true, show_delete: false}
      
      html = rendered_to_string(~H"""
        <.action_buttons>
          <button :if={@show_edit}>Edit</button>
          <button :if={@show_delete}>Delete</button>
          <button>View</button>
        </.action_buttons>
      """)
      
      assert html =~ "Edit"
      refute html =~ "Delete"
      assert html =~ "View"
    end

    test "renders empty gracefully" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons />
      """)
      
      # Should render container without errors
      assert html =~ "<div"
    end
  end

  describe "styling" do
    test "applies correct flex properties" do
      assigns = %{}
      
      # Horizontal layout
      html = rendered_to_string(~H"""
        <.action_buttons direction="horizontal">
          <button>Button</button>
        </.action_buttons>
      """)
      assert html =~ "flex-row" || refute(html =~ "flex-col")
      
      # Vertical layout
      html = rendered_to_string(~H"""
        <.action_buttons direction="vertical">
          <button>Button</button>
        </.action_buttons>
      """)
      assert html =~ "flex-col"
    end

    test "applies correct spacing classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons spacing="large">
          <button>A</button>
          <button>B</button>
        </.action_buttons>
      """)
      
      assert html =~ "gap-4" || html =~ "space-x-4" || html =~ "space-y-4"
    end
  end

  describe "accessibility" do
    test "maintains semantic HTML structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons>
          <button>Action 1</button>
          <a href="/link">Link 1</a>
        </.action_buttons>
      """)
      
      # Should preserve button and link elements
      assert html =~ "<button"
      assert html =~ "<a"
      assert html =~ ~s(href="/link")
    end

    test "supports ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.action_buttons aria-label="Table actions">
          <button aria-label="Edit item">Edit</button>
          <button aria-label="Delete item">Delete</button>
        </.action_buttons>
      """)
      
      assert html =~ ~s(aria-label="Table actions")
      assert html =~ ~s(aria-label="Edit item")
      assert html =~ ~s(aria-label="Delete item")
    end
  end
end