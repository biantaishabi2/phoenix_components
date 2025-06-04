defmodule ShopUxPhoenixWeb.Components.BreadcrumbTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.Breadcrumb

  describe "breadcrumb/1" do
    test "renders basic breadcrumb" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      
      assert html =~ ~s(aria-label="Breadcrumb")
      assert html =~ "首页"
      assert html =~ "产品"
    end

    test "renders with clickable links" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/"},
          %{title: "用户", path: "/users"},
          %{title: "详情", path: nil}
        ]} />
      """)
      
      assert html =~ ~s(href="/")
      assert html =~ ~s(href="/users")
      refute html =~ ~s(href="nil")
    end

    test "renders with icons" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/", icon: "hero-home"},
          %{title: "用户", path: "/users", icon: "hero-users"}
        ]} />
      """)
      
      assert html =~ "hero-home"
      assert html =~ "hero-users"
    end

    test "renders different separators" do
      assigns = %{}
      
      # Default chevron separator
      html_chevron = rendered_to_string(~H"""
        <.breadcrumb separator="chevron" items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      
      assert html_chevron =~ "hero-chevron-right"
      
      # Slash separator
      html_slash = rendered_to_string(~H"""
        <.breadcrumb separator="slash" items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      
      assert html_slash =~ "/"
      refute html_slash =~ "hero-chevron-right"
      
      # Custom separator
      html_custom = rendered_to_string(~H"""
        <.breadcrumb separator=">" items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      
      assert html_custom =~ ">"
    end

    test "renders different sizes" do
      assigns = %{}
      
      # Test small size
      html_small = rendered_to_string(~H"""
        <.breadcrumb size="small" items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      assert html_small =~ "text-xs"
      
      # Test medium size
      html_medium = rendered_to_string(~H"""
        <.breadcrumb size="medium" items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      assert html_medium =~ "text-sm"
      
      # Test large size
      html_large = rendered_to_string(~H"""
        <.breadcrumb size="large" items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      assert html_large =~ "text-base"
    end

    test "handles max_items limitation" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb max_items={3} items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: "/products"},
          %{title: "分类", path: "/categories"},
          %{title: "子分类", path: "/subcategories"},
          %{title: "详情", path: nil}
        ]} />
      """)
      
      assert html =~ "首页"
      assert html =~ "详情"
      assert html =~ "..."  # ellipsis
    end

    test "shows home link when enabled" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb 
          show_home={true}
          home_title="主页"
          home_path="/dashboard"
          items={[
            %{title: "产品", path: nil}
          ]} 
        />
      """)
      
      assert html =~ "主页"
      assert html =~ ~s(href="/dashboard")
    end

    test "hides home link when disabled" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb 
          show_home={false}
          items={[
            %{title: "产品", path: nil}
          ]} 
        />
      """)
      
      refute html =~ "首页"
    end

    test "renders empty breadcrumb" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[]} />
      """)
      
      assert html =~ ~s(aria-label="Breadcrumb")
      # Should only show home when show_home is true
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb class="custom-breadcrumb" items={[
          %{title: "首页", path: "/"}
        ]} />
      """)
      
      assert html =~ "custom-breadcrumb"
    end

    test "renders responsive breadcrumb" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb responsive={true} items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: "/products"},
          %{title: "详情", path: nil}
        ]} />
      """)
      
      assert html =~ "hidden"  # Should have responsive hiding classes
    end

    test "handles single item" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb show_home={false} items={[
          %{title: "当前页", path: nil}
        ]} />
      """)
      
      assert html =~ "当前页"
      refute html =~ "hero-chevron-right"  # No separator for single item
    end

    test "renders with overlay tooltips" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/", overlay: "返回首页"},
          %{title: "产品", path: nil, overlay: "当前产品页面"}
        ]} />
      """)
      
      assert html =~ ~s(title="返回首页")
      assert html =~ ~s(title="当前产品页面")
    end

    test "validates required items attribute" do
      assigns = %{}
      
      # Should not raise error with empty items
      html = rendered_to_string(~H"""
        <.breadcrumb items={[]} />
      """)
      
      assert html =~ ~s(aria-label="Breadcrumb")
    end
  end

  describe "accessibility" do
    test "includes proper ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      
      assert html =~ ~s(aria-label="Breadcrumb")
      assert html =~ ~s(role="navigation") || html =~ ~s(<nav)
    end

    test "includes aria-current for last item" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/"},
          %{title: "当前页", path: nil}
        ]} />
      """)
      
      assert html =~ ~s(aria-current="page")
    end
  end

  describe "edge cases" do
    test "handles nil path correctly" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页", path: "/"},
          %{title: "当前页", path: nil}
        ]} />
      """)
      
      assert html =~ "当前页"
      refute html =~ ~s(href="")
    end

    test "handles empty title" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "", path: "/"},
          %{title: "产品", path: nil}
        ]} />
      """)
      
      assert html =~ "产品"
    end

    test "handles special characters in titles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={[
          %{title: "首页 & 导航", path: "/"},
          %{title: "产品 <测试>", path: nil}
        ]} />
      """)
      
      assert html =~ "首页 &amp; 导航"
      assert html =~ "产品 &lt;测试&gt;"
    end
  end
end