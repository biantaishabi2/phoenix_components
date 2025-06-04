defmodule ShopUxPhoenixWeb.Components.CardTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.Card

  describe "card/1" do
    test "renders basic card with content" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card>
          <p>Card content</p>
        </.card>
      """)
      
      assert html =~ "Card content"
      assert html =~ ~s(class=)
    end

    test "renders card with title" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card title="Card Title">
          <p>Content</p>
        </.card>
      """)
      
      assert html =~ "Card Title"
      assert html =~ "Content"
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.card size={@size} title="Test">
            <p>Content</p>
          </.card>
        """)
        
        case size do
          "small" -> assert html =~ "p-4" || html =~ "small"
          "medium" -> assert html =~ "p-6" || html =~ "medium"
          "large" -> assert html =~ "p-8" || html =~ "large"
        end
      end
    end

    test "renders without border when bordered is false" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card bordered={false}>
          <p>No border</p>
        </.card>
      """)
      
      assert html =~ "No border"
      refute html =~ "border-gray-200"
    end

    test "renders with hoverable effect" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card hoverable>
          <p>Hoverable card</p>
        </.card>
      """)
      
      assert html =~ "Hoverable card"
      assert html =~ "hover:shadow" || html =~ "transition"
    end

    test "renders loading state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card loading title="Loading...">
          <p>Content</p>
        </.card>
      """)
      
      # Should show skeleton or loading indicator
      assert html =~ "animate-pulse"
      # Should have skeleton blocks
      assert html =~ "bg-gray-200"
      assert html =~ "rounded"
    end

    test "renders with extra slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card title="Title">
          <:extra>
            <a href="/more">More</a>
          </:extra>
          <p>Content</p>
        </.card>
      """)
      
      assert html =~ "Title"
      assert html =~ "More"
      assert html =~ "Content"
    end

    test "renders with actions slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card>
          <p>Content</p>
          <:actions>
            <button>Save</button>
            <button>Cancel</button>
          </:actions>
        </.card>
      """)
      
      assert html =~ "Content"
      assert html =~ "Save"
      assert html =~ "Cancel"
    end

    test "renders with cover slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card>
          <:cover>
            <img src="/image.jpg" alt="Cover" />
          </:cover>
          <p>Content below cover</p>
        </.card>
      """)
      
      assert html =~ ~s(src="/image.jpg")
      assert html =~ "Content below cover"
    end

    test "renders with custom header slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card>
          <:header>
            <h3>Custom Header</h3>
          </:header>
          <p>Content</p>
        </.card>
      """)
      
      assert html =~ "Custom Header"
      assert html =~ "Content"
    end

    test "applies custom classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card 
          class="custom-card"
          header_class="custom-header"
          body_style="custom-body"
        >
          <p>Content</p>
        </.card>
      """)
      
      assert html =~ "custom-card"
      assert html =~ "custom-body"
    end

    test "renders nested cards" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card title="Parent Card">
          <p>Parent content</p>
          <.card title="Child Card" size="small">
            <p>Child content</p>
          </.card>
        </.card>
      """)
      
      assert html =~ "Parent Card"
      assert html =~ "Child Card"
      assert html =~ "Parent content"
      assert html =~ "Child content"
    end

    test "renders with all slots combined" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card title="Complete Card">
          <:extra>
            <span>Extra</span>
          </:extra>
          <:cover>
            <div>Cover Image</div>
          </:cover>
          <p>Main content</p>
          <:actions>
            <button>Action</button>
          </:actions>
        </.card>
      """)
      
      assert html =~ "Complete Card"
      assert html =~ "Extra"
      assert html =~ "Cover Image"
      assert html =~ "Main content"
      assert html =~ "Action"
    end

    test "handles rest attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card id="test-card" data-testid="card">
          <p>Content</p>
        </.card>
      """)
      
      assert html =~ ~s(id="test-card")
      assert html =~ ~s(data-testid="card")
    end

    test "renders empty card gracefully" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card />
      """)
      
      # Should render an empty card without errors
      assert html =~ "<div"
    end
  end

  describe "card styling" do
    test "applies correct padding for different sizes" do
      assigns = %{}
      
      # Small size
      html = rendered_to_string(~H"""
        <.card size="small" title="Small">
          <p>Content</p>
        </.card>
      """)
      assert html =~ "p-4" || html =~ "px-4" || html =~ "py-4"
      
      # Medium size
      html = rendered_to_string(~H"""
        <.card size="medium" title="Medium">
          <p>Content</p>
        </.card>
      """)
      assert html =~ "p-6" || html =~ "px-6" || html =~ "py-6"
      
      # Large size
      html = rendered_to_string(~H"""
        <.card size="large" title="Large">
          <p>Content</p>
        </.card>
      """)
      assert html =~ "p-8" || html =~ "px-8" || html =~ "py-8"
    end

    test "applies hover effects when hoverable" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card hoverable>
          <p>Hover me</p>
        </.card>
      """)
      
      assert html =~ "hover:shadow-lg" || 
             html =~ "hover:shadow-md" || 
             html =~ "transition-shadow"
    end

    test "removes border when bordered is false" do
      assigns = %{}
      
      html_with_border = rendered_to_string(~H"""
        <.card bordered={true}>
          <p>With border</p>
        </.card>
      """)
      
      html_without_border = rendered_to_string(~H"""
        <.card bordered={false}>
          <p>Without border</p>
        </.card>
      """)
      
      assert html_with_border =~ "border"
      refute html_without_border =~ "border-gray"
    end
  end

  describe "accessibility" do
    test "uses semantic HTML structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card title="Accessible Card">
          <p>Content</p>
        </.card>
      """)
      
      assert html =~ "<div"
      # Title should be in a header element
      assert html =~ "<h" || html =~ "header"
    end

    test "maintains proper heading hierarchy" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.card title="Card Title">
          <p>Content</p>
        </.card>
      """)
      
      # Should use appropriate heading level
      assert html =~ "<h3" || html =~ "<h4" || html =~ ~s(role="heading")
    end
  end
end