defmodule PetalComponents.Custom.StatisticTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Statistic

  describe "statistic/1" do
    test "renders basic statistic" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="basic-stat"
          title="用户总数"
          value={112893}
        />
      """)
      
      assert html =~ "pc-statistic"
      assert html =~ "用户总数"
      assert html =~ "112,893"
    end
    
    test "renders with title" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="title-stat"
          title="月收入"
          value={5680}
        />
      """)
      
      assert html =~ "pc-statistic__title"
      assert html =~ "月收入"
    end
    
    test "renders string value" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="string-stat"
          title="状态"
          value="活跃"
        />
      """)
      
      assert html =~ "活跃"
    end
    
    test "renders with precision" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="precision-stat"
          title="增长率"
          value={7.2845}
          precision={2}
        />
      """)
      
      assert html =~ "7.28"
    end
    
    test "renders with prefix and suffix" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="prefix-suffix"
          title="月收入"
          value={568.08}
          precision={2}
          prefix_text="¥"
          suffix_text="万"
        />
      """)
      
      assert html =~ "¥"
      assert html =~ "万"
      assert html =~ "568.08"
    end
    
    test "renders different colors" do
      for color <- ["default", "primary", "success", "warning", "danger", "info"] do
        assigns = %{current_color: color}
        
        html = rendered_to_string(~H"""
          <.statistic 
            id={"color-#{@current_color}"}
            title="测试"
            value={100}
            color={@current_color}
          />
        """)
        
        assert html =~ "pc-statistic--#{color}"
      end
    end

    test "renders with primary color specifically" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="primary-stat"
          title="主要统计"
          value={1000}
          color="primary"
        />
      """)
      
      assert html =~ "pc-statistic--primary"
      assert html =~ "text-primary"
      assert html =~ "主要统计"
      assert html =~ "1,000"
    end

    test "renders with different sizes" do
      assigns = %{}
      
      # Small size
      html = rendered_to_string(~H"""
        <.statistic 
          id="small-stat"
          title="小统计"
          value={100}
          size="small"
        />
      """)
      assert html =~ "小统计"
      assert html =~ "text-xs" # title size
      assert html =~ "text-xl" # value size
      
      # Medium size (default)
      html = rendered_to_string(~H"""
        <.statistic 
          id="medium-stat"
          title="中统计"
          value={200}
          size="medium"
        />
      """)
      assert html =~ "中统计"
      assert html =~ "text-sm" # title size
      assert html =~ "text-2xl" # value size
      
      # Large size
      html = rendered_to_string(~H"""
        <.statistic 
          id="large-stat"
          title="大统计"
          value={300}
          size="large"
        />
      """)
      assert html =~ "大统计"
      assert html =~ "text-base" # title size
      assert html =~ "text-3xl" # value size
    end

    test "renders with default size when not specified" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="default-size"
          title="默认尺寸"
          value={500}
        />
      """)
      
      assert html =~ "默认尺寸"
      # Should use medium size classes
      assert html =~ "text-sm" # title size
      assert html =~ "text-2xl" # value size
    end

    test "renders with size affecting prefix and suffix" do
      assigns = %{}
      
      # Test small size with prefix/suffix
      html = rendered_to_string(~H"""
        <.statistic 
          id="small-prefix-suffix"
          title="小号"
          value={100}
          size="small"
          prefix_text="¥"
          suffix_text="万"
        />
      """)
      
      assert html =~ "text-sm" # prefix/suffix size for small
      
      # Test large size with prefix/suffix
      html = rendered_to_string(~H"""
        <.statistic 
          id="large-prefix-suffix"
          title="大号"
          value={100}
          size="large"
          prefix_text="$"
          suffix_text="K"
        />
      """)
      
      assert html =~ "text-lg" # prefix/suffix size for large
    end
    
    test "renders with custom value style" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="custom-style"
          title="自定义样式"
          value={123}
          value_style="font-bold text-2xl text-red-500"
        />
      """)
      
      assert html =~ "font-bold text-2xl text-red-500"
    end
    
    test "renders loading state" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="loading-stat"
          title="加载中"
          value={0}
          loading={true}
        />
      """)
      
      assert html =~ "animate-pulse"
      assert html =~ "bg-gray-200 dark:bg-gray-700"
    end
    
    test "renders with trend indicator" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="trend-up"
          title="增长"
          value={100}
          trend="up"
        />
      """)
      
      assert html =~ "trend-up"
      assert html =~ "svg"
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="trend-down"
          title="下降"
          value={50}
          trend="down"
        />
      """)
      
      assert html =~ "trend-down"
      assert html =~ "svg"
    end
    
    test "renders with trend colors" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="trend-color"
          title="趋势"
          value={100}
          trend="up"
          trend_color={true}
        />
      """)
      
      assert html =~ "text-green-500"
    end
    
    test "renders without trend colors" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="no-trend-color"
          title="趋势"
          value={100}
          trend="up"
          trend_color={false}
        />
      """)
      
      refute html =~ "text-green-500"
    end
    
    test "renders with group separator" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="group-separator"
          title="大数字"
          value={1234567}
          group_separator=","
        />
      """)
      
      assert html =~ "1,234,567"
    end
    
    test "renders with custom decimal separator" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="decimal-separator"
          title="小数"
          value={123.45}
          precision={2}
          decimal_separator="."
        />
      """)
      
      assert html =~ "123.45"
    end
    
    test "renders with animation attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="animated"
          title="动画"
          value={100}
          animation={true}
          animation_duration={3000}
          animation_delay={500}
        />
      """)
      
      assert html =~ "data-duration=\"3000\""
      assert html =~ "data-delay=\"500\""
      assert html =~ "transition-all duration-150"
    end
    
    test "renders without animation" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="no-animation"
          title="无动画"
          value={100}
          animation={false}
        />
      """)
      
      assert html =~ "pc-statistic"
      refute html =~ "data-duration"
    end
    
    test "renders with prefix slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic id="prefix-slot" title="评分" value={4.5}>
          <:prefix>
            <svg class="w-4 h-4 text-yellow-400">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </:prefix>
        </.statistic>
      """)
      
      assert html =~ "w-4 h-4 text-yellow-400"
    end
    
    test "renders with suffix slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic id="suffix-slot" title="评分" value={4.5}>
          <:suffix>
            <span class="text-gray-500 text-sm">/ 5.0</span>
          </:suffix>
        </.statistic>
      """)
      
      assert html =~ "text-gray-500 text-sm"
      assert html =~ "/ 5.0"
    end
    
    test "renders with both prefix and suffix slots" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic id="both-slots" title="温度" value={25}>
          <:prefix>
            <svg class="w-4 h-4"><!-- thermometer icon --></svg>
          </:prefix>
          <:suffix>
            <span class="text-sm">°C</span>
          </:suffix>
        </.statistic>
      """)
      
      assert html =~ "w-4 h-4"
      assert html =~ "°C"
    end
    
    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="custom-class"
          title="自定义"
          value={100}
          class="my-custom-class"
        />
      """)
      
      assert html =~ "my-custom-class"
    end
    
    test "renders with global attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="global-attrs"
          title="属性"
          value={100}
          data-testid="statistic"
          aria-label="统计数值"
        />
      """)
      
      assert html =~ ~s(data-testid="statistic")
      assert html =~ ~s(aria-label="统计数值")
    end
    
    test "handles zero value" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="zero-value"
          title="零值"
          value={0}
        />
      """)
      
      assert html =~ "0"
    end
    
    test "handles negative value" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="negative-value"
          title="负值"
          value={-123}
        />
      """)
      
      assert html =~ "-123"
    end
    
    test "handles large numbers" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="large-number"
          title="大数字"
          value={999999999}
          group_separator=","
        />
      """)
      
      assert html =~ "999,999,999"
    end
    
    test "handles float precision correctly" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="float-precision"
          title="精度测试"
          value={123.456789}
          precision={3}
        />
      """)
      
      assert html =~ "123.457"
    end
    
    test "renders value container structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="structure-test"
          title="结构测试"
          value={100}
        />
      """)
      
      assert html =~ "pc-statistic__value"
      assert html =~ "pc-statistic__number"
    end
    
    test "renders without title" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.statistic 
          id="no-title"
          value={100}
        />
      """)
      
      assert html =~ "100"
      refute html =~ "pc-statistic__title text-sm"
    end
  end
end