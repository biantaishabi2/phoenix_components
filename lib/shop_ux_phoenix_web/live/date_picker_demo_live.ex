defmodule ShopUxPhoenixWeb.DatePickerDemoLive do
  use ShopUxPhoenixWeb, :live_view
  import PetalComponents.Custom.DatePicker

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       selected_date: nil,
       show_panel: false,
       shortcuts: [
         %{label: "今天", value: Date.utc_today()},
         %{label: "昨天", value: Date.add(Date.utc_today(), -1)},
         %{label: "一周前", value: Date.add(Date.utc_today(), -7)}
       ]
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p id="date-info">
        选中日期: <%= if @selected_date, do: Date.to_string(@selected_date), else: "无" %>
      </p>
      <p id="panel-state">
        面板状态: <%= if @show_panel, do: "打开", else: "关闭" %>
      </p>
      
      <.date_picker 
        id="test-date-picker"
        value={@selected_date}
        shortcuts={@shortcuts}
        on_change={JS.push("select_date")}
        on_clear={JS.push("clear_date")}
        placeholder="选择日期"
      />
    </div>
    """
  end

  def handle_event("select_date", params, socket) do
    date = case params do
      %{"date" => date_string} ->
        case Date.from_iso8601(date_string) do
          {:ok, date} -> date
          {:error, _} -> nil
        end
      %{"value" => %Date{} = date} ->
        date
      _ ->
        nil
    end
    
    {:noreply, assign(socket, selected_date: date)}
  end

  def handle_event("clear_date", _params, socket) do
    {:noreply, assign(socket, selected_date: nil)}
  end

  def handle_event("toggle_panel", _params, socket) do
    {:noreply, update(socket, :show_panel, &(!&1))}
  end
end