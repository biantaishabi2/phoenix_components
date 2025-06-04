defmodule ShopUxPhoenixWeb.Components.AddressSelectorTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.AddressSelector

  @sample_locations [
    %{
      value: "110000",
      label: "北京市",
      children: [
        %{
          value: "110100",
          label: "北京市",
          children: [
            %{value: "110101", label: "东城区"},
            %{value: "110102", label: "西城区"}
          ]
        }
      ]
    },
    %{
      value: "310000",
      label: "上海市",
      children: [
        %{
          value: "310100",
          label: "上海市",
          children: [
            %{value: "310101", label: "黄浦区"},
            %{value: "310104", label: "徐汇区"}
          ]
        }
      ]
    }
  ]

  describe "address_selector/1" do
    test "renders basic address selector" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector />
      """)
      
      assert html =~ "请选择省/市/区"
      assert html =~ ~s(phx-click)
    end

    test "renders with custom placeholder" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector placeholder="选择地址" />
      """)
      
      assert html =~ "选择地址"
    end

    test "renders with selected value" do
      assigns = %{
        value: ["110000", "110100", "110101"],
        sample_locations: @sample_locations
      }
      
      html = rendered_to_string(~H"""
        <.address_selector value={@value} options={@sample_locations} />
      """)
      
      # Should show selected labels
      assert html =~ "北京市"
      assert html =~ "东城区"
    end

    test "renders disabled state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector disabled={true} />
      """)
      
      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed"
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.address_selector size={@size} />
        """)
        
        case size do
          "small" -> assert html =~ "h-8" || html =~ "text-sm"
          "medium" -> assert html =~ "h-10" || html =~ "text-base"
          "large" -> assert html =~ "h-12" || html =~ "text-lg"
        end
      end
    end

    test "renders with detail address input" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector show_detail={true} />
      """)
      
      assert html =~ "请输入详细地址"
      assert html =~ ~s(type="text")
    end

    test "renders with custom detail placeholder" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector 
          show_detail={true} 
          detail_placeholder="街道、门牌号"
        />
      """)
      
      assert html =~ "街道、门牌号"
    end

    test "renders with error state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector error="请选择地址" />
      """)
      
      assert html =~ "请选择地址"
      assert html =~ "text-red-600"
      assert html =~ "border-red-500"
    end

    test "renders with required indicator" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector required={true} />
      """)
      
      assert html =~ ~s(required)
    end

    test "renders with clear button when has value" do
      assigns = %{
        value: ["110000", "110100", "110101"]
      }
      
      html = rendered_to_string(~H"""
        <.address_selector value={@value} clearable={true} />
      """)
      
      assert html =~ "hero-x-mark" || html =~ "清除"
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector class="custom-selector" />
      """)
      
      assert html =~ "custom-selector"
    end

    test "renders with name attribute for forms" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector name="user[address]" />
      """)
      
      assert html =~ ~s(name="user[address]")
    end

    test "renders with search input when searchable" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector searchable={true} />
      """)
      
      # The search input would appear in the dropdown
      assert html =~ "address-selector"
    end

    test "handles empty options gracefully" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector options={[]} />
      """)
      
      assert html =~ "address-selector"
      refute html =~ "Elixir.Inspect.Error"
    end

    test "renders with field for Phoenix forms" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector name="user[address]" id="user_address" />
      """)
      
      assert html =~ ~s(name="user[address]")
      assert html =~ ~s(id="user_address")
    end

    test "renders loading state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector loading={true} />
      """)
      
      assert html =~ "animate-spin" || html =~ "加载中"
    end
  end

  describe "styling" do
    test "applies correct border styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector />
      """)
      
      assert html =~ "border"
      assert html =~ "rounded"
    end

    test "applies hover and focus styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector />
      """)
      
      assert html =~ "hover:border" || html =~ "focus:border"
    end
  end

  describe "dropdown behavior" do
    test "renders dropdown trigger" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector />
      """)
      
      assert html =~ "hero-chevron-down" || html =~ "cursor-pointer"
    end

    test "shows selected path" do
      assigns = %{
        value: ["110000", "110100", "110101"],
        labels: ["北京市", "北京市", "东城区"],
        sample_locations: @sample_locations
      }
      
      html = rendered_to_string(~H"""
        <.address_selector 
          value={@value} 
          options={@sample_locations}
        />
      """)
      
      # Should show the selected path
      assert html =~ "北京市" || html =~ "东城区"
    end
  end

  describe "integration" do
    test "works with Phoenix.HTML.Form" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.address_selector 
          name="location[address]" 
          value={["110000", "110100", "110101"]}
          error="can't be blank"
        />
      """)
      
      assert html =~ ~s(name="location[address]")
      assert html =~ "can&#39;t be blank"
    end
  end
end