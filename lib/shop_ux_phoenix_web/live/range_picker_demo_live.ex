defmodule ShopUxPhoenixWeb.RangePickerDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.RangePicker

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       basic_range: nil,
       preset_range: nil,
       time_range: nil,
       ranges: [
         %{label: "今天", value: [Date.utc_today(), Date.utc_today()]},
         %{label: "最近7天", value: [Date.add(Date.utc_today(), -6), Date.utc_today()]},
         %{label: "最近30天", value: [Date.add(Date.utc_today(), -29), Date.utc_today()]},
         %{label: "本月", value: [Date.beginning_of_month(Date.utc_today()), Date.end_of_month(Date.utc_today())]}
       ]
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p id="basic-range-info">
        基础范围: <%= format_range_display(@basic_range) %>
      </p>
      <p id="preset-range-info">
        预设范围: <%= format_range_display(@preset_range) %>
      </p>
      <p id="time-range-info">
        时间范围: <%= format_range_display(@time_range) %>
      </p>
      
      <h3>基础范围选择器</h3>
      <.range_picker 
        id="basic-range"
        value={@basic_range}
        on_change={JS.push("select_basic_range")}
        on_clear={JS.push("clear_basic_range")}
        clearable
        placeholder={["开始日期", "结束日期"]}
      />
      
      <h3>预设范围选择器</h3>
      <.range_picker 
        id="preset-range"
        value={@preset_range}
        ranges={@ranges}
        on_change={JS.push("select_preset_range")}
        on_clear={JS.push("clear_preset_range")}
        clearable
        placeholder={["开始日期", "结束日期"]}
      />
      
      <h3>时间范围选择器</h3>
      <.range_picker 
        id="time-range"
        value={@time_range}
        show_time={true}
        format="YYYY-MM-DD HH:mm:ss"
        on_change={JS.push("select_time_range")}
        on_clear={JS.push("clear_time_range")}
        clearable
        placeholder={["开始时间", "结束时间"]}
      />
    </div>
    """
  end

  def handle_event("select_basic_range", %{"date" => date, "position" => position}, socket) do
    current_range = socket.assigns.basic_range || [nil, nil]
    new_range = case position do
      "start" -> [parse_date(date), Enum.at(current_range, 1)]
      "end" -> [Enum.at(current_range, 0), parse_date(date)]
      _ -> current_range
    end
    {:noreply, assign(socket, basic_range: new_range)}
  end

  def handle_event("select_preset_range", %{"start" => start_date, "end" => end_date}, socket) do
    new_range = [parse_date(start_date), parse_date(end_date)]
    {:noreply, assign(socket, preset_range: new_range)}
  end

  def handle_event("select_preset_range", %{"date" => date, "position" => position}, socket) do
    current_range = socket.assigns.preset_range || [nil, nil]
    new_range = case position do
      "start" -> [parse_date(date), Enum.at(current_range, 1)]
      "end" -> [Enum.at(current_range, 0), parse_date(date)]
      _ -> current_range
    end
    {:noreply, assign(socket, preset_range: new_range)}
  end

  def handle_event("select_time_range", %{"date" => date, "position" => position}, socket) do
    current_range = socket.assigns.time_range || [nil, nil]
    new_range = case position do
      "start" -> [parse_date(date), Enum.at(current_range, 1)]
      "end" -> [Enum.at(current_range, 0), parse_date(date)]
      _ -> current_range
    end
    {:noreply, assign(socket, time_range: new_range)}
  end

  def handle_event("clear_basic_range", _params, socket) do
    {:noreply, assign(socket, basic_range: nil)}
  end

  def handle_event("clear_preset_range", _params, socket) do
    {:noreply, assign(socket, preset_range: nil)}
  end

  def handle_event("clear_time_range", _params, socket) do
    {:noreply, assign(socket, time_range: nil)}
  end

  defp format_range_display(nil), do: "无"
  defp format_range_display([nil, nil]), do: "无"
  defp format_range_display([start_date, end_date]) do
    start_str = if start_date, do: Date.to_string(start_date), else: "无"
    end_str = if end_date, do: Date.to_string(end_date), else: "无"
    "#{start_str} ~ #{end_str}"
  end
  defp format_range_display(_), do: "无"

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      _ -> nil
    end
  end
  defp parse_date(_), do: nil
end