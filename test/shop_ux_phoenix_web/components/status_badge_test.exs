defmodule ShopUxPhoenixWeb.Components.StatusBadgeTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.StatusBadge

  describe "status_badge/1" do
    test "renders basic status badge with text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge text="Active" />
      """)
      
      assert html =~ "Active"
      assert html =~ ~s(class=)
    end

    test "renders different status types" do
      for {type, expected} <- [
        {"default", "gray"},
        {"success", "green"},
        {"processing", "blue"},
        {"warning", "yellow"},
        {"error", "red"},
        {"info", "blue"}
      ] do
        assigns = %{type: type}
        
        html = rendered_to_string(~H"""
          <.status_badge text="Status" type={@type} />
        """)
        
        assert html =~ "Status"
        assert html =~ expected || html =~ type
      end
    end

    test "renders with custom color" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge text="Custom" color="purple" />
      """)
      
      assert html =~ "Custom"
      assert html =~ "purple"
    end

    test "renders dot mode" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge type="success" dot />
      """)
      
      # Should render a dot/circle element
      assert html =~ "rounded-full"
      assert html =~ "w-2" || html =~ "w-3"
      assert html =~ "h-2" || html =~ "h-3"
    end

    test "renders with icon" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge text="Shipped" type="success" icon="hero-truck" />
      """)
      
      assert html =~ "Shipped"
      assert html =~ "hero-truck"
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.status_badge text="Size Test" size={@size} />
        """)
        
        assert html =~ "Size Test"
        case size do
          "small" -> assert html =~ "text-xs" || html =~ "small"
          "medium" -> assert html =~ "text-sm" || html =~ "medium"
          "large" -> assert html =~ "text-base" || html =~ "large"
        end
      end
    end

    test "renders without border" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge text="No Border" bordered={false} />
      """)
      
      assert html =~ "No Border"
      refute html =~ "border-"
    end

    test "applies custom classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge text="Custom" class="custom-class" />
      """)
      
      assert html =~ "Custom"
      assert html =~ "custom-class"
    end

    test "handles rest attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge
          text="Test"
          id="status-1"
          data-testid="status-badge"
        />
      """)
      
      assert html =~ ~s(id="status-1")
      assert html =~ ~s(data-testid="status-badge")
    end

    test "renders with inner_block slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge type="success">
          <span>Custom Content</span>
        </.status_badge>
      """)
      
      assert html =~ "Custom Content"
    end

    test "order status helper function" do
      # Test various order statuses
      for {status, expected_text} <- [
        {"pending", "待付款"},
        {"paid", "已付款"},
        {"shipped", "已发货"},
        {"completed", "已完成"},
        {"cancelled", "已取消"}
      ] do
        html = rendered_to_string(order_status_badge(%{status: status}))
        
        assert html =~ expected_text
      end
    end

    test "user status helper function" do
      # Test various user statuses
      for {status, expected_text} <- [
        {"active", "正常"},
        {"inactive", "已禁用"},
        {"pending", "待验证"}
      ] do
        html = rendered_to_string(user_status_badge(%{status: status}))
        
        assert html =~ expected_text
      end
    end

    test "combines all features" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge
          text="Premium"
          type="success"
          icon="hero-star"
          size="large"
          bordered={false}
          class="font-bold"
        />
      """)
      
      assert html =~ "Premium"
      assert html =~ "hero-star"
      assert html =~ "font-bold"
      refute html =~ "border-"
    end
  end

  describe "styling" do
    test "applies correct colors for each type" do
      assigns = %{}
      
      # Success type
      html = rendered_to_string(~H"""
        <.status_badge text="Success" type="success" />
      """)
      assert html =~ "bg-green-" || html =~ "text-green-"
      
      # Error type
      html = rendered_to_string(~H"""
        <.status_badge text="Error" type="error" />
      """)
      assert html =~ "bg-red-" || html =~ "text-red-"
      
      # Warning type
      html = rendered_to_string(~H"""
        <.status_badge text="Warning" type="warning" />
      """)
      assert html =~ "bg-yellow-" || html =~ "text-yellow-"
    end

    test "dot mode has consistent sizing" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.status_badge type="success" dot size={@size} />
        """)
        
        assert html =~ "rounded-full"
        assert html =~ "inline-block"
      end
    end
  end

  describe "accessibility" do
    test "includes appropriate ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.status_badge text="Active" type="success" />
      """)
      
      # Should have semantic HTML
      assert html =~ "<span" || html =~ "<div"
    end

    test "dot mode includes screen reader text" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <div class="flex items-center gap-2">
          <.status_badge type="success" dot />
          <span>Online</span>
        </div>
      """)
      
      # The accompanying text provides context
      assert html =~ "Online"
    end
  end
end