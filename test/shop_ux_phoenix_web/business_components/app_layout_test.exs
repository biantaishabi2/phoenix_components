defmodule ShopUxPhoenixWeb.BusinessComponents.AppLayoutTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.BusinessComponents.AppLayout

  describe "app_layout/1" do
    test "renders basic app layout structure" do
      assigns = %{
        page_title: "测试页面",
        current_user: %{name: "张三", company: "测试公司"},
        breadcrumbs: [
          %{title: "首页", path: "/"},
          %{title: "测试页面", path: nil}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.app_layout 
          page_title={@page_title}
          current_user={@current_user}
          breadcrumbs={@breadcrumbs}
        >
          <div class="test-content">测试内容</div>
        </.app_layout>
      """)
      
      assert html =~ "app-layout"
      assert html =~ "app-sidebar"
      assert html =~ "app-header"
      assert html =~ "测试内容"
    end

    test "renders with collapsed sidebar" do
      assigns = %{collapsed: true}
      
      html = rendered_to_string(~H"""
        <.app_layout collapsed={@collapsed}>
          <div>内容</div>
        </.app_layout>
      """)
      
      assert html =~ "sidebar-collapsed"
    end

    test "renders breadcrumbs correctly" do
      assigns = %{
        breadcrumbs: [
          %{title: "首页", path: "/"},
          %{title: "商品管理", path: "/products"},
          %{title: "商品详情", path: nil}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.app_layout breadcrumbs={@breadcrumbs}>
          <div>内容</div>
        </.app_layout>
      """)
      
      assert html =~ "首页"
      assert html =~ "商品管理"
      assert html =~ "商品详情"
      assert html =~ "breadcrumb"
    end

    test "passes user info to header" do
      assigns = %{
        current_user: %{
          name: "李四",
          company: "示例公司",
          avatar_url: "/images/avatar.jpg"
        }
      }
      
      html = rendered_to_string(~H"""
        <.app_layout current_user={@current_user}>
          <div>内容</div>
        </.app_layout>
      """)
      
      assert html =~ "李四"
      assert html =~ "示例公司"
    end
  end

  describe "app_sidebar/1" do
    test "renders sidebar with menu items" do
      assigns = %{
        menu_items: [
          %{
            key: "dashboard",
            title: "仪表盘",
            icon: "hero-home",
            path: "/dashboard"
          },
          %{
            key: "products",
            title: "商品管理",
            icon: "hero-shopping-bag",
            children: [
              %{key: "product-list", title: "商品列表", path: "/products"},
              %{key: "product-create", title: "新建商品", path: "/products/new"}
            ]
          }
        ],
        current_path: "/dashboard"
      }
      
      html = rendered_to_string(~H"""
        <.app_sidebar 
          menu_items={@menu_items}
          current_path={@current_path}
        />
      """)
      
      assert html =~ "仪表盘"
      assert html =~ "商品管理"
      assert html =~ "商品列表"
      assert html =~ "新建商品"
    end

    test "highlights current menu item" do
      assigns = %{
        menu_items: [
          %{key: "dashboard", title: "仪表盘", path: "/dashboard"},
          %{key: "products", title: "商品管理", path: "/products"}
        ],
        current_path: "/products"
      }
      
      html = rendered_to_string(~H"""
        <.app_sidebar 
          menu_items={@menu_items}
          current_path={@current_path}
        />
      """)
      
      assert html =~ "menu-item-active"
    end

    test "renders collapsed sidebar" do
      assigns = %{collapsed: true}
      
      html = rendered_to_string(~H"""
        <.app_sidebar collapsed={@collapsed} />
      """)
      
      assert html =~ "w-20" # 折叠宽度
      refute html =~ "w-64" # 正常宽度
    end
  end

  describe "app_header/1" do
    test "renders header with user info" do
      assigns = %{
        title: "客户服务系统",
        current_user: %{name: "王五", company: "测试公司"}
      }
      
      html = rendered_to_string(~H"""
        <.app_header 
          title={@title}
          current_user={@current_user}
        />
      """)
      
      assert html =~ "客户服务系统"
      assert html =~ "王五"
      assert html =~ "测试公司"
    end

    test "renders notification badge" do
      assigns = %{notifications_count: 5}
      
      html = rendered_to_string(~H"""
        <.app_header notifications_count={@notifications_count} />
      """)
      
      assert html =~ "5"
      assert html =~ "hero-bell"
    end

    test "renders logout button" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.app_header />
      """)
      
      assert html =~ "hero-arrow-right-on-rectangle"
      assert html =~ "phx-click=\"logout\""
    end
  end

  describe "breadcrumb/1" do
    test "renders single breadcrumb" do
      assigns = %{
        items: [%{title: "首页", path: "/"}]
      }
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={@items} />
      """)
      
      assert html =~ "首页"
      assert html =~ "href=\"/\""
    end

    test "renders multiple breadcrumbs with separator" do
      assigns = %{
        items: [
          %{title: "首页", path: "/"},
          %{title: "商品管理", path: "/products"},
          %{title: "商品详情", path: nil}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={@items} />
      """)
      
      assert html =~ "首页"
      assert html =~ "商品管理"
      assert html =~ "商品详情"
      assert html =~ "hero-chevron-right" # 分隔符
    end

    test "last item is not clickable" do
      assigns = %{
        items: [
          %{title: "首页", path: "/"},
          %{title: "当前页", path: nil}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.breadcrumb items={@items} />
      """)
      
      assert html =~ "<a"
      assert html =~ "当前页"
      refute html =~ "href=\"当前页\""
    end
  end

  describe "main_content/1" do
    test "renders content wrapper" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.main_content>
          <div class="test">测试内容</div>
        </.main_content>
      """)
      
      assert html =~ "main-content"
      assert html =~ "测试内容"
      assert html =~ "bg-white"
      assert html =~ "rounded-lg"
      assert html =~ "shadow"
    end

    test "accepts custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.main_content class="custom-class">
          <div>内容</div>
        </.main_content>
      """)
      
      assert html =~ "custom-class"
    end
  end
end