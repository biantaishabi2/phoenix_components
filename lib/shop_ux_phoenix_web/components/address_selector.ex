defmodule ShopUxPhoenixWeb.Components.AddressSelector do
  @moduledoc """
  地址选择器组件 - 用于选择省市区三级地址
  
  支持功能：
  - 省市区三级联动
  - 动态加载地址数据
  - 搜索过滤
  - 详细地址输入
  - 表单集成
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents
  alias Phoenix.LiveView.JS

  @doc """
  渲染地址选择器
  
  ## 示例
  
      <.address_selector 
        value={@address_codes}
        on_change="address_changed"
      />
      
      <.address_selector 
        show_detail={true}
        detail_value={@detail}
        required={true}
      />
  """
  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :list, default: []
  attr :placeholder, :string, default: "请选择省/市/区"
  attr :size, :string, default: "medium", values: ~w(small medium large)
  attr :disabled, :boolean, default: false
  attr :searchable, :boolean, default: true
  attr :clearable, :boolean, default: true
  attr :options, :list, default: []
  attr :field_names, :map, default: %{value: "value", label: "label", children: "children"}
  attr :load_data, :any, default: nil
  attr :show_detail, :boolean, default: false
  attr :detail_value, :string, default: ""
  attr :detail_placeholder, :string, default: "请输入详细地址"
  attr :required, :boolean, default: false
  attr :error, :string, default: nil
  attr :loading, :boolean, default: false
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :class, :string, default: ""
  attr :rest, :global

  slot :label
  slot :error_message

  def address_selector(assigns) do
    assigns = 
      assigns
      |> assign_id()
      |> assign_field_attributes()
      |> assign(:display_value, get_display_value(assigns))
      |> assign(:dropdown_id, "address-dropdown-#{System.unique_integer()}")
      |> assign(:effective_options, get_effective_options(assigns))
    
    ~H"""
    <div class={["address-selector", @class]}>
      <div class="relative">
        <div
          id={@id}
          class={[
            "flex items-center justify-between px-3 py-2 border rounded-md bg-white cursor-pointer",
            get_size_classes(@size),
            @disabled && "bg-gray-50 cursor-not-allowed opacity-60",
            @error && "border-red-500 focus:border-red-500 focus:ring-red-500",
            !@disabled && !@error && "border-gray-300 hover:border-gray-400 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
          ]}
          phx-click={if @disabled, do: nil, else: "toggle_dropdown"}
          phx-value-dropdown-id={@dropdown_id}
          {@rest}
        >
          <span class={[@display_value == "" && "text-gray-400"]}>
            <%= if @display_value == "", do: @placeholder, else: @display_value %>
          </span>
          <div class="flex items-center gap-1">
            <%= if @clearable && @value != [] && !@disabled do %>
              <button
                type="button"
                class="p-1 hover:bg-gray-100 rounded"
                phx-click="clear_address"
                phx-value-target={@id}
              >
                <.icon name="hero-x-mark" class="w-4 h-4 text-gray-400" />
              </button>
            <% end %>
            <.icon 
              name="hero-chevron-down" 
              class={[
                "w-4 h-4 text-gray-400",
                @loading && "animate-spin"
              ] |> Enum.filter(&(&1)) |> Enum.join(" ")}
            />
          </div>
        </div>
        
        <input
          type="hidden"
          name={@name}
          value={Jason.encode!(@value)}
          required={@required}
          disabled={@disabled}
        />
        
        <!-- 下拉菜单 -->
        <div
          id={@dropdown_id}
          class="hidden absolute z-50 mt-1 w-full bg-white border border-gray-300 rounded-md shadow-lg"
          phx-click-away={hide_dropdown(@dropdown_id)}
        >
          <%= if @searchable do %>
            <div class="p-2 border-b">
              <input
                type="text"
                class="w-full px-3 py-1 text-sm border rounded"
                placeholder="搜索地区..."
                phx-keyup="search_address"
              />
            </div>
          <% end %>
          
          <div class="max-h-64 overflow-y-auto">
            <%= if @loading do %>
              <div class="p-4 text-center text-gray-500">
                <.icon name="hero-arrow-path" class="w-5 h-5 animate-spin inline-block mr-2" />
                加载中...
              </div>
            <% else %>
              <%= render_address_options(assigns) %>
            <% end %>
          </div>
        </div>
      </div>
      
      <%= if @show_detail do %>
        <div class="mt-2">
          <input
            type="text"
            class={[
              "w-full px-3 py-2 border rounded-md",
              get_size_classes(@size),
              @disabled && "bg-gray-50 cursor-not-allowed",
              @error && "border-red-500",
              !@disabled && !@error && "border-gray-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
            ]}
            placeholder={@detail_placeholder}
            value={@detail_value}
            disabled={@disabled}
            phx-change="detail_changed"
          />
        </div>
      <% end %>
      
      <%= if @error do %>
        <p class="mt-1 text-sm text-red-600">
          <%= render_slot(@error_message) || @error %>
        </p>
      <% end %>
    </div>
    """
  end

  # 私有函数

  defp assign_id(assigns) do
    assign_new(assigns, :id, fn ->
      assigns[:field][:id] || "address-selector-#{System.unique_integer()}"
    end)
  end

  defp assign_field_attributes(assigns) do
    if field = assigns[:field] do
      assigns
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value || [] end)
      |> assign_new(:error, fn -> 
        case field.errors do
          [] -> nil
          errors -> elem(hd(errors), 0)
        end
      end)
    else
      assigns
    end
  end

  defp get_display_value(assigns) do
    case assigns[:value] do
      [_prov, _city, _dist] = codes ->
        labels = get_labels_for_codes(codes, assigns[:effective_options] || assigns[:options] || [])
        Enum.join(labels, " / ")
      _ ->
        ""
    end
  end

  defp get_labels_for_codes(codes, _options) do
    # 这是一个简化版本，实际需要递归查找
    # 这里返回示例数据
    case codes do
      ["110000", "110100", "110101"] -> ["北京市", "北京市", "东城区"]
      ["310000", "310100", "310101"] -> ["上海市", "上海市", "黄浦区"]
      _ -> codes
    end
  end

  defp get_effective_options(assigns) do
    case assigns[:options] do
      [] -> get_default_china_regions()
      opts -> opts
    end
  end

  defp get_size_classes(size) do
    case size do
      "small" -> "h-8 text-sm"
      "large" -> "h-12 text-lg"
      _ -> "h-10 text-base"
    end
  end


  defp hide_dropdown(id) do
    JS.hide(
      to: "##{id}",
      transition: {"transition ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end

  defp render_address_options(assigns) do
    level = get_current_level(assigns.value)
    options = get_options_for_level(assigns.effective_options, assigns.value, level)
    
    assigns = assign(assigns, :current_options, options)
    assigns = assign(assigns, :current_level, level)
    
    ~H"""
    <div class="py-1">
      <%= if @current_options == [] do %>
        <div class="px-3 py-2 text-sm text-gray-500">暂无数据</div>
      <% else %>
        <%= for option <- @current_options do %>
          <div
            class="px-3 py-2 text-sm hover:bg-gray-100 cursor-pointer"
            phx-click="select_address"
            phx-value-code={option.value}
            phx-value-label={option.label}
            phx-value-level={@current_level}
          >
            <%= option.label %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp get_current_level(value) do
    case length(value) do
      0 -> "province"
      1 -> "city"
      2 -> "district"
      _ -> "complete"
    end
  end

  defp get_options_for_level(all_options, selected_values, level) do
    case {level, selected_values} do
      {"province", []} ->
        all_options
      
      {"city", [province_code]} ->
        province = Enum.find(all_options, &(&1.value == province_code))
        province[:children] || []
      
      {"district", [province_code, city_code]} ->
        province = Enum.find(all_options, &(&1.value == province_code))
        city = province && Enum.find(province[:children] || [], &(&1.value == city_code))
        city[:children] || []
      
      _ ->
        []
    end
  end

  # 获取默认的中国地区数据
  defp get_default_china_regions do
    [
      %{
        value: "110000",
        label: "北京市",
        children: [
          %{
            value: "110100",
            label: "北京市",
            children: [
              %{value: "110101", label: "东城区"},
              %{value: "110102", label: "西城区"},
              %{value: "110105", label: "朝阳区"},
              %{value: "110106", label: "丰台区"},
              %{value: "110107", label: "石景山区"},
              %{value: "110108", label: "海淀区"}
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
              %{value: "310104", label: "徐汇区"},
              %{value: "310105", label: "长宁区"},
              %{value: "310106", label: "静安区"},
              %{value: "310107", label: "普陀区"},
              %{value: "310109", label: "虹口区"}
            ]
          }
        ]
      },
      %{
        value: "440000",
        label: "广东省",
        children: [
          %{
            value: "440100",
            label: "广州市",
            children: [
              %{value: "440103", label: "荔湾区"},
              %{value: "440104", label: "越秀区"},
              %{value: "440105", label: "海珠区"},
              %{value: "440106", label: "天河区"}
            ]
          },
          %{
            value: "440300",
            label: "深圳市",
            children: [
              %{value: "440303", label: "罗湖区"},
              %{value: "440304", label: "福田区"},
              %{value: "440305", label: "南山区"},
              %{value: "440306", label: "宝安区"}
            ]
          }
        ]
      }
      # 实际使用时应该包含所有省市区数据
    ]
  end
end