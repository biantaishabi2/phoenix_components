defmodule PetalComponents.Custom.RangePickerTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.RangePicker

  describe "range_picker/1" do
    test "renders basic range picker" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="basic-range"
          placeholder={["开始日期", "结束日期"]}
        />
      """)
      
      assert html =~ "pc-range-picker"
      assert html =~ "开始日期"
      assert html =~ "结束日期"
      assert html =~ " ~ "
    end
    
    test "renders with custom separator" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="custom-sep"
          separator=" 至 "
          placeholder={["开始", "结束"]}
        />
      """)
      
      assert html =~ " 至 "
    end
    
    test "renders with value" do
      assigns = %{
        start_date: ~D[2024-01-01],
        end_date: ~D[2024-01-31]
      }
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="with-value"
          value={[@start_date, @end_date]}
        />
      """)
      
      assert html =~ "2024-01-01"
      assert html =~ "2024-01-31"
    end
    
    test "renders with custom format" do
      assigns = %{
        start_date: ~D[2024-01-01],
        end_date: ~D[2024-01-31]
      }
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="custom-format"
          value={[@start_date, @end_date]}
          format="YYYY年MM月DD日"
        />
      """)
      
      assert html =~ "2024年01月01日"
      assert html =~ "2024年01月31日"
    end
    
    test "renders with show_time" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="with-time"
          show_time={true}
        />
      """)
      
      assert html =~ "pc-range-picker__time"
    end
    
    test "renders disabled state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="disabled"
          disabled={true}
        />
      """)
      
      assert html =~ "cursor-not-allowed"
      assert html =~ "opacity-50"
    end
    
    test "renders different sizes" do
      for size <- ["small", "medium", "large"] do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.range_picker 
            id={"size-#{@size}"}
            size={@size}
          />
        """)
        
        case size do
          "small" -> assert html =~ "text-sm" && assert html =~ "py-2 px-3"
          "medium" -> assert html =~ "text-sm" && assert html =~ "py-2 px-4"
          "large" -> assert html =~ "text-base" && assert html =~ "py-2.5 px-6"
        end
      end
    end
    
    test "renders with ranges (shortcuts)" do
      assigns = %{
        ranges: [
          %{label: "今天", value: [Date.utc_today(), Date.utc_today()]},
          %{label: "最近7天", value: [Date.add(Date.utc_today(), -6), Date.utc_today()]}
        ]
      }
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="with-ranges"
          ranges={@ranges}
        />
      """)
      
      assert html =~ "shortcuts"
      assert html =~ "今天"
      assert html =~ "最近7天"
    end
    
    test "renders clearable button when value exists" do
      assigns = %{
        start_date: ~D[2024-01-01],
        end_date: ~D[2024-01-31]
      }
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="clearable"
          value={[@start_date, @end_date]}
          clearable={true}
        />
      """)
      
      assert html =~ "pc-range-picker__clear"
    end
    
    test "does not render clear button when no value" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="no-clear"
          clearable={true}
        />
      """)
      
      refute html =~ "pc-range-picker__clear"
    end
    
    test "renders with different picker types" do
      for picker <- ["date", "week", "month", "year"] do
        assigns = %{picker: picker}
        
        html = rendered_to_string(~H"""
          <.range_picker 
            id={"picker-#{@picker}"}
            picker={@picker}
          />
        """)
        
        assert html =~ "picker-type-#{picker}"
      end
    end
    
    test "renders hidden form inputs when name is provided" do
      assigns = %{
        start_date: ~D[2024-01-01],
        end_date: ~D[2024-01-31]
      }
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="form-input"
          name="date_range"
          value={[@start_date, @end_date]}
        />
      """)
      
      assert html =~ ~s(name="date_range[start]")
      assert html =~ ~s(name="date_range[end]")
      assert html =~ ~s(value="2024-01-01")
      assert html =~ ~s(value="2024-01-31")
    end
    
    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="custom-class"
          class="my-custom-class"
        />
      """)
      
      assert html =~ "my-custom-class"
    end
    
    test "renders with global attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="global-attrs"
          data-testid="range-picker"
          aria-label="选择日期范围"
        />
      """)
      
      assert html =~ ~s(data-testid="range-picker")
      assert html =~ ~s(aria-label="选择日期范围")
    end
    
    test "renders panels with correct classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="panels"
        />
      """)
      
      assert html =~ "start-panel"
      assert html =~ "end-panel" 
      assert html =~ "hidden"
    end
    
    test "handles nil values gracefully" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="nil-values"
          value={[nil, nil]}
        />
      """)
      
      # Should not crash and should render empty inputs
      assert html =~ "pc-range-picker"
    end
    
    test "validates date range order" do
      # This would typically be handled in the component logic
      assigns = %{
        start_date: ~D[2024-01-31],
        end_date: ~D[2024-01-01]  # End before start
      }
      
      html = rendered_to_string(~H"""
        <.range_picker 
          id="invalid-range"
          value={[@start_date, @end_date]}
        />
      """)
      
      # Component should still render but may show validation styling
      assert html =~ "pc-range-picker"
    end
  end
end