defmodule PetalComponents.Custom.DatePickerTest do
  use ShopUxPhoenixWeb.ComponentCase, async: true
  
  alias PetalComponents.Custom.DatePicker
  alias Phoenix.LiveView.JS

  describe "date_picker/1" do
    test "renders basic date picker" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker id="test-date" />
      """)
      
      # 检查基本结构
      assert html =~ ~s(id="test-date")
      assert html =~ "请选择日期"  # 默认placeholder
      assert html =~ ~s(type="text")  # 输入框
      assert html =~ "pc-date-picker__icon"  # 日历图标
    end

    test "renders with custom placeholder" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="placeholder-date" 
          placeholder="选择生日" 
        />
      """)
      
      assert html =~ "选择生日"
    end

    test "renders with selected date" do
      assigns = %{
        date: ~D[2024-01-15]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="value-date" 
          value={@date}
        />
      """)
      
      assert html =~ "2024-01-15"
      assert html =~ ~s(value="2024-01-15")
    end

    test "renders with custom format" do
      assigns = %{
        date: ~D[2024-01-15]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="format-date" 
          value={@date}
          format="YYYY年MM月DD日"
        />
      """)
      
      assert html =~ "2024年01月15日"
    end

    test "renders disabled date picker" do
      assigns = %{
        date: ~D[2024-01-15]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="disabled-date" 
          value={@date}
          disabled
        />
      """)
      
      assert html =~ "disabled"
      assert html =~ "opacity-50"
      assert html =~ "cursor-not-allowed"
    end

    test "renders clearable date picker with value" do
      assigns = %{
        date: ~D[2024-01-15]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="clearable-date" 
          value={@date}
          clearable
          on_clear={JS.push("clear_date")}
        />
      """)
      
      # 应该显示清除按钮
      assert html =~ "pc-date-picker__clear"
      assert html =~ ~s(phx-click)
    end

    test "renders with show_time option" do
      assigns = %{
        datetime: ~U[2024-01-15 14:30:00Z]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="datetime-picker" 
          value={@datetime}
          show_time
          format="YYYY-MM-DD HH:mm:ss"
        />
      """)
      
      # 应该显示时间
      assert html =~ "14:30:00"
      assert html =~ "pc-date-picker__time"
    end

    test "renders with different sizes" do
      assigns = %{}
      
      # 小尺寸
      html = rendered_to_string(~H"""
        <DatePicker.date_picker id="small" size="small" />
      """)
      assert html =~ "text-sm"
      assert html =~ "py-2 px-3"
      
      # 中尺寸（默认）
      html = rendered_to_string(~H"""
        <DatePicker.date_picker id="medium" size="medium" />
      """)
      assert html =~ "text-sm"
      assert html =~ "py-2 px-4"
      
      # 大尺寸
      html = rendered_to_string(~H"""
        <DatePicker.date_picker id="large" size="large" />
      """)
      assert html =~ "text-base"
      assert html =~ "py-2.5 px-6"
    end

    test "renders different picker types" do
      assigns = %{}
      
      # 周选择器
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="week-picker" 
          picker="week"
          placeholder="选择周"
        />
      """)
      assert html =~ "选择周"
      assert html =~ "week-picker"
      
      # 月选择器
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="month-picker" 
          picker="month"
          placeholder="选择月份"
        />
      """)
      assert html =~ "选择月份"
      assert html =~ "month-picker"
      
      # 年选择器
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="year-picker" 
          picker="year"
          placeholder="选择年份"
        />
      """)
      assert html =~ "选择年份"
      assert html =~ "year-picker"
    end

    test "renders with shortcuts" do
      assigns = %{
        shortcuts: [
          %{label: "今天", value: Date.utc_today()},
          %{label: "昨天", value: Date.add(Date.utc_today(), -1)},
          %{label: "一周前", value: Date.add(Date.utc_today(), -7)}
        ]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="shortcuts-date" 
          shortcuts={@shortcuts}
        />
      """)
      
      # 应该显示快捷选项
      assert html =~ "今天"
      assert html =~ "昨天"
      assert html =~ "一周前"
      assert html =~ "pc-date-picker__shortcuts"
    end

    test "renders with min and max date" do
      assigns = %{
        min_date: ~D[2024-01-01],
        max_date: ~D[2024-12-31]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="limited-date" 
          min_date={@min_date}
          max_date={@max_date}
        />
      """)
      
      # 应该有限制属性
      assert html =~ "data-min-date=\"2024-01-01\""
      assert html =~ "data-max-date=\"2024-12-31\""
    end

    test "renders with show_today button" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="today-button-date" 
          show_today
        />
      """)
      
      # 应该有今天按钮
      assert html =~ "today-button"
      assert html =~ "今天"
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="custom-class-date" 
          class="custom-date-picker"
        />
      """)
      
      assert html =~ "custom-date-picker"
    end

    test "renders with form field name" do
      assigns = %{
        date: ~D[2024-01-15]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="form-date" 
          name="user[birth_date]"
          value={@date}
        />
      """)
      
      # 应该有隐藏的input用于表单提交
      assert html =~ ~s(name="user[birth_date]")
      assert html =~ ~s(type="hidden")
      assert html =~ ~s(value="2024-01-15")
    end

    test "renders calendar panel structure" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="calendar-panel-date" 
        />
      """)
      
      # 日历面板（初始隐藏）
      assert html =~ "calendar-panel"
      assert html =~ "hidden"
      
      # 面板应该包含
      assert html =~ "pc-date-picker__header"  # 年月导航
      assert html =~ "pc-date-picker__body"    # 日期网格
      assert html =~ "weekdays"         # 星期标题
    end

    test "renders with default_value when no value" do
      assigns = %{
        default_date: ~D[2024-01-01]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="default-value-date" 
          default_value={@default_date}
        />
      """)
      
      # 输入框应该是空的，但日历应该定位到默认日期
      assert html =~ "data-default-value=\"2024-01-01\""
    end
  end

  describe "date_picker/1 with event handlers" do
    test "renders with on_change handler" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="change-date" 
          on_change={JS.push("date_changed")}
        />
      """)
      
      assert html =~ "date_changed"
    end

    test "renders with on_clear handler for clearable" do
      assigns = %{
        date: ~D[2024-01-15]
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="clear-date" 
          value={@date}
          clearable
          on_clear={JS.push("clear_date")}
        />
      """)
      
      assert html =~ "clear_date"
    end
  end

  describe "date_picker/1 with disabled_date function" do
    test "marks dates as disabled based on function" do
      assigns = %{
        # 禁用周末
        disabled_date_fn: fn date -> 
          Date.day_of_week(date) in [6, 7]
        end
      }
      
      html = rendered_to_string(~H"""
        <DatePicker.date_picker 
          id="disabled-weekends" 
          disabled_date={@disabled_date_fn}
        />
      """)
      
      # 应该有禁用日期的数据属性
      assert html =~ "data-disabled-date"
    end
  end
end