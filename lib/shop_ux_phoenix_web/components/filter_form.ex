defmodule ShopUxPhoenixWeb.Components.FilterForm do
  @moduledoc """
  筛选表单组件，提供灵活的数据筛选功能
  
  支持多种表单控件类型，采用内联布局，提供响应式设计。
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents

  @doc """
  渲染筛选表单
  
  ## 示例
      <.filter_form
        id="order-filter"
        fields={[
          %{name: "search", type: "search", placeholder: "搜索订单"},
          %{name: "status", label: "状态", type: "select", options: @status_options}
        ]}
        on_search="search"
        on_reset="reset"
      />
  """
  attr :id, :string, required: true, doc: "表单唯一标识符"
  attr :fields, :list, default: [], doc: "表单字段配置"
  attr :values, :map, default: %{}, doc: "表单字段值"
  attr :on_search, :string, default: nil, doc: "搜索事件处理函数"
  attr :on_reset, :string, default: nil, doc: "重置事件处理函数"
  attr :layout, :string, default: "inline", doc: "表单布局方式"
  attr :responsive, :map, default: nil, doc: "响应式布局配置"
  attr :collapsible, :boolean, default: false, doc: "是否可折叠"
  attr :collapsed, :boolean, default: false, doc: "是否折叠状态"
  attr :on_toggle, :string, default: nil, doc: "折叠切换事件"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :field_class, :string, default: "", doc: "字段容器 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :actions, doc: "自定义操作按钮"
  
  def filter_form(assigns) do
    ~H"""
    <div class={["filter-form-container mb-4", @class]} data-filter-form {@rest}>
      <.form
        for={%{}}
        as={:filters}
        id={@id}
        phx-change={if @on_search == nil, do: nil, else: "#{@on_search}_change"}
        phx-submit={@on_search}
        class={[
          "filter-form",
          @layout == "inline" && "flex flex-wrap items-start gap-4",
          @layout == "vertical" && "space-y-4",
          @collapsible && "filter-form--collapsible"
        ]}
      >
        <div
          class={[
            "filter-form__content flex flex-wrap items-start gap-4 w-full",
            @collapsed && "hidden"
          ]}
          data-collapsed={to_string(@collapsed)}
        >
          <div class={[
            "filter-form__fields flex-1 flex flex-wrap gap-4",
            @responsive && "grid",
            get_responsive_classes(@responsive)
          ]}>
            <%= for field <- @fields do %>
              <div class={["filter-form__field", @field_class]}>
                <.render_field field={field} values={@values} />
              </div>
            <% end %>
          </div>
          
          <div class="filter-form__actions flex gap-2">
            <%= if @actions != [] do %>
              <%= render_slot(@actions) %>
            <% else %>
              <.button
                :if={@on_search}
                type="submit"
                phx-disable-with="搜索中..."
              >
                <.icon name="hero-magnifying-glass" class="w-4 h-4 mr-1" />
                搜索
              </.button>
              
              <.button
                :if={@on_reset}
                type="button"
                phx-click={@on_reset}
              >
                重置
              </.button>
            <% end %>
          </div>
        </div>
        
        <div :if={@collapsible} class="filter-form__toggle mt-2">
          <.button
            type="button"
            phx-click={@on_toggle}
          >
            <.icon 
              name={if @collapsed, do: "hero-chevron-down", else: "hero-chevron-up"}
              class="w-4 h-4 mr-1"
            />
            <%= if @collapsed, do: "展开筛选", else: "收起筛选" %>
          </.button>
        </div>
      </.form>
    </div>
    """
  end
  
  # 渲染单个字段
  defp render_field(assigns) do
    field = assigns.field
    value = get_field_value(assigns.values, field.name)
    
    assigns =
      assigns
      |> assign(:field, field)
      |> assign(:value, value)
    
    case field.type do
      "input" -> render_input_field(assigns)
      "search" -> render_search_field(assigns)
      "select" -> render_select_field(assigns)
      "date" -> render_date_field(assigns)
      "date_range" -> render_date_range_field(assigns)
      "number" -> render_number_field(assigns)
      "number_range" -> render_number_range_field(assigns)
      "checkbox" -> render_checkbox_field(assigns)
      "tree_select" -> render_tree_select_field(assigns)
      _ -> render_input_field(assigns)
    end
  end
  
  # 文本输入字段
  defp render_input_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <.input
        type="text"
        id={@field.name}
        name={@field.name}
        value={@value}
        placeholder={@field[:placeholder]}
        style={if @field[:width], do: "width: #{@field.width}"}
        required={@field[:required] || false}
        {@field[:props] || %{}}
      />
    </div>
    """
  end
  
  # 搜索输入字段
  defp render_search_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <div class="relative">
        <.input
          type="search"
          id={@field.name}
          name={@field.name}
          value={@value}
          placeholder={@field[:placeholder]}
          style={if @field[:width], do: "width: #{@field.width}"}
          class="pr-10"
          {@field[:props] || %{}}
        />
        <.icon
          name="hero-magnifying-glass"
          class="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
        />
      </div>
    </div>
    """
  end
  
  # 选择框字段
  defp render_select_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <select
        id={@field.name}
        name={@field.name}
        style={if @field[:width], do: "width: #{@field.width}"}
        class={[
          "mt-2 block rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "border-zinc-300 focus:border-zinc-400"
        ]}
        multiple={@field[:props][:mode] == "multiple" || @field[:props][:multiple]}
        {@field[:props] || %{}}
      >
        <option value="">
          <%= @field[:placeholder] || "请选择" %>
        </option>
        <%= for option <- (@field[:options] || []) do %>
          <option value={option.value} selected={selected_option?(@value, option.value)}>
            <%= option.label %>
          </option>
        <% end %>
      </select>
    </div>
    """
  end
  
  # 日期选择字段
  defp render_date_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <.input
        type="date"
        id={@field.name}
        name={@field.name}
        value={@value}
        placeholder={@field[:placeholder]}
        style={if @field[:width], do: "width: #{@field.width}"}
        data-date-picker
        {@field[:props] || %{}}
      />
    </div>
    """
  end
  
  # 日期范围字段
  defp render_date_range_field(assigns) do
    placeholders = assigns.field[:placeholder] || ["开始日期", "结束日期"]
    [start_placeholder, end_placeholder] = 
      if is_list(placeholders), do: placeholders, else: [placeholders, placeholders]
    
    assigns = 
      assigns
      |> assign(:start_placeholder, start_placeholder)
      |> assign(:end_placeholder, end_placeholder)
    
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <div class="flex items-center gap-2" data-date-range-picker>
        <.input
          type="date"
          id={"#{@field.name}_start"}
          name={"#{@field.name}[start]"}
          value={get_range_value(@value, :start)}
          placeholder={@start_placeholder}
          class="flex-1"
        />
        <span class="text-gray-500">~</span>
        <.input
          type="date"
          id={"#{@field.name}_end"}
          name={"#{@field.name}[end]"}
          value={get_range_value(@value, :end)}
          placeholder={@end_placeholder}
          class="flex-1"
        />
      </div>
    </div>
    """
  end
  
  # 数字输入字段
  defp render_number_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <.input
        type="number"
        id={@field.name}
        name={@field.name}
        value={@value}
        placeholder={@field[:placeholder]}
        style={if @field[:width], do: "width: #{@field.width}"}
        {@field[:props] || %{}}
      />
    </div>
    """
  end
  
  # 数字范围字段
  defp render_number_range_field(assigns) do
    placeholders = assigns.field[:placeholder] || ["最小值", "最大值"]
    [min_placeholder, max_placeholder] = 
      if is_list(placeholders), do: placeholders, else: [placeholders, placeholders]
    
    assigns = 
      assigns
      |> assign(:min_placeholder, min_placeholder)
      |> assign(:max_placeholder, max_placeholder)
    
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <div class="flex items-center gap-2">
        <.input
          type="number"
          id={"#{@field.name}_min"}
          name={"#{@field.name}[min]"}
          value={get_range_value(@value, :min)}
          placeholder={@min_placeholder}
          class="flex-1"
          {@field[:props][:min_props] || %{}}
        />
        <span class="text-gray-500">-</span>
        <.input
          type="number"
          id={"#{@field.name}_max"}
          name={"#{@field.name}[max]"}
          value={get_range_value(@value, :max)}
          placeholder={@max_placeholder}
          class="flex-1"
          {@field[:props][:max_props] || %{}}
        />
      </div>
    </div>
    """
  end
  
  # 复选框字段
  defp render_checkbox_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <label class="flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          id={@field.name}
          name={@field.name}
          value="true"
          checked={@value == true || @value == "true"}
          class="rounded border-gray-300 text-zinc-900 focus:ring-0"
          {@field[:props] || %{}}
        />
        <span class="text-sm">
          <%= @field[:label] || @field[:placeholder] %>
        </span>
      </label>
    </div>
    """
  end
  
  # 树形选择字段
  defp render_tree_select_field(assigns) do
    ~H"""
    <div class="field-wrapper">
      <.label :if={@field[:label]} for={"#{@field.name}"}>
        <%= @field.label %>
      </.label>
      <div
        class="tree-select"
        data-tree-select
        style={if @field[:width], do: "width: #{@field.width}"}
      >
        <select
          id={@field.name}
          name={@field.name}
          class={[
            "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
            "border-zinc-300 focus:border-zinc-400"
          ]}
          multiple={@field[:props][:multiple]}
        >
          <option value="">
            <%= @field[:placeholder] || "请选择" %>
          </option>
          <%= for option <- flatten_tree_options(@field[:options] || []) do %>
            <option 
              value={option.value}
              selected={selected_option?(@value, option.value)}
              style={"padding-left: #{option.level * 20}px"}
            >
              <%= option.label %>
            </option>
          <% end %>
        </select>
      </div>
    </div>
    """
  end
  
  # Helper functions
  
  defp get_field_value(values, name) when is_map(values) do
    Map.get(values, name) || Map.get(values, to_string(name))
  end
  defp get_field_value(_, _), do: nil
  
  defp get_range_value(value, key) when is_map(value) do
    Map.get(value, key) || Map.get(value, to_string(key))
  end
  defp get_range_value(_, _), do: nil
  
  defp selected_option?(current_value, option_value) when is_list(current_value) do
    Enum.member?(current_value, option_value)
  end
  defp selected_option?(current_value, option_value) do
    to_string(current_value) == to_string(option_value)
  end
  
  defp flatten_tree_options(options, level \\ 0) do
    Enum.flat_map(options, fn option ->
      current = Map.put(option, :level, level)
      children = Map.get(option, :children, [])
      
      if Enum.empty?(children) do
        [current]
      else
        [current | flatten_tree_options(children, level + 1)]
      end
    end)
  end
  
  defp get_responsive_classes(nil), do: ""
  defp get_responsive_classes(responsive) do
    [
      responsive[:sm] && "sm:grid-cols-#{responsive.sm}",
      responsive[:md] && "md:grid-cols-#{responsive.md}",
      responsive[:lg] && "lg:grid-cols-#{responsive.lg}",
      responsive[:xl] && "xl:grid-cols-#{responsive.xl}"
    ]
    |> Enum.filter(& &1)
    |> Enum.join(" ")
  end
end