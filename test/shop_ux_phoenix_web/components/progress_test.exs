defmodule PetalComponents.Custom.ProgressTest do
  use ShopUxPhoenixWeb.ComponentCase
  import PetalComponents.Custom.Progress

  describe "progress/1" do
    test "renders basic line progress" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={30} />
      """)
      
      assert html =~ ~s(role="progressbar")
      assert html =~ ~s(aria-valuenow="30")
      assert html =~ ~s(aria-valuemin="0")
      assert html =~ ~s(aria-valuemax="100")
      assert html =~ "30%"
      assert html =~ ~s(style="width: 30%")
    end

    test "renders progress with different statuses" do
      for status <- ~w(normal active success exception) do
        assigns = %{status: status}
        
        html = rendered_to_string(~H"""
          <.progress percent={50} status={@status} />
        """)
        
        case status do
          "normal" -> assert html =~ "bg-primary"
          "active" -> assert html =~ "bg-primary" && html =~ "progress-active"
          "success" -> assert html =~ "bg-success"
          "exception" -> assert html =~ "bg-danger"
        end
      end
    end

    test "renders progress without info" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={75} show_info={false} />
      """)
      
      refute html =~ "pc-progress__info"
      assert html =~ ~s(style="width: 75%")
    end

    test "renders progress with custom colors" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={60} stroke_color="#87d068" trail_color="#ffe58f" />
      """)
      
      assert html =~ ~s(style="background-color: #87d068; width: 60%")
      assert html =~ ~s(style="background-color: #ffe58f")
    end

    test "renders different sizes" do
      for size <- ~w(small medium large) do
        assigns = %{size: size}
        
        html = rendered_to_string(~H"""
          <.progress percent={50} size={@size} />
        """)
        
        case size do
          "small" -> assert html =~ "h-1"
          "medium" -> assert html =~ "h-2"
          "large" -> assert html =~ "h-3"
        end
      end
    end

    test "renders with custom format function" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={90} format_fn={fn percent -> "#{percent} Days" end} />
      """)
      
      assert html =~ "90 Days"
      refute html =~ ">90%<"
    end

    test "renders with format slot" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={80}>
          <:format :let={percent}>
            <span class="custom-format">Custom: <%= percent %></span>
          </:format>
        </.progress>
      """)
      
      assert html =~ "custom-format"
      assert html =~ "Custom: 80"
      refute html =~ ">80%<"
    end

    test "renders circle progress" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress type="circle" percent={75} />
      """)
      
      assert html =~ "<svg"
      assert html =~ "<circle"
      assert html =~ "75%"
      assert html =~ ~s(stroke-dasharray)
      assert html =~ ~s(stroke-dashoffset)
    end

    test "renders circle with different sizes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress type="circle" percent={50} width={80} />
      """)
      
      assert html =~ ~s(width="80")
      assert html =~ ~s(height="80")
      assert html =~ ~s(viewBox="0 0 80 80")
    end

    test "renders circle with gap" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress type="circle" percent={75} gap_degree={90} gap_position="bottom" />
      """)
      
      assert html =~ "rotate(135"
      assert html =~ "75%"
    end

    test "handles edge cases for percent" do
      assigns = %{}
      
      # Negative percent
      html = rendered_to_string(~H"""
        <.progress percent={-10} />
      """)
      assert html =~ ~s(style="width: 0%")
      assert html =~ "0%"
      
      # Percent over 100
      html = rendered_to_string(~H"""
        <.progress percent={150} />
      """)
      assert html =~ ~s(style="width: 100%")
      assert html =~ "100%"
    end

    test "renders with custom stroke width" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={50} stroke_width={12} />
      """)
      
      assert html =~ "h-3" # Adjusts height based on stroke width
    end

    test "renders with custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={50} class="my-progress" />
      """)
      
      assert html =~ "my-progress"
    end

    test "renders success icon when 100% and success status" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={100} status="success" />
      """)
      
      assert html =~ "hero-check-circle-mini"
    end

    test "renders exception icon when exception status" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={70} status="exception" />
      """)
      
      assert html =~ "hero-x-circle-mini"
    end

    test "renders line progress with gradient color" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={80} stroke_color="linear-gradient(to right, #108ee9, #87d068)" />
      """)
      
      assert html =~ "linear-gradient"
    end

    test "renders circle progress with status colors" do
      assigns = %{}
      
      # Success status
      html = rendered_to_string(~H"""
        <.progress type="circle" percent={100} status="success" />
      """)
      assert html =~ ~s(stroke="#10b981") # success color
      
      # Exception status
      html = rendered_to_string(~H"""
        <.progress type="circle" percent={50} status="exception" />
      """)
      assert html =~ ~s(stroke="#ef4444") # danger color
    end
  end

  describe "accessibility" do
    test "includes proper ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress percent={60} />
      """)
      
      assert html =~ ~s(role="progressbar")
      assert html =~ ~s(aria-valuenow="60")
      assert html =~ ~s(aria-valuemin="0")
      assert html =~ ~s(aria-valuemax="100")
      assert html =~ ~s(aria-label="进度条")
    end

    test "includes aria-label for circle progress" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
        <.progress type="circle" percent={75} />
      """)
      
      assert html =~ ~s(role="progressbar")
      assert html =~ ~s(aria-valuenow="75")
      assert html =~ ~s(aria-label="环形进度条")
    end
  end
end