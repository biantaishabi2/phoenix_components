defmodule ShopUxPhoenixWeb.Components.FormBuilder do
  @moduledoc """
  表单构建器组件 - 通过配置快速生成动态表单
  
  支持功能：
  - 配置驱动的表单生成
  - 多种字段类型和布局模式
  - 智能验证和字段联动
  - 响应式设计和主题定制
  - 复杂条件表达式（AND/OR/嵌套）
  - 动态字段加载和级联更新
  - 计算字段和异步验证
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents
  
  alias ShopUxPhoenixWeb.Components.FormBuilder.ConditionEvaluator
  alias ShopUxPhoenixWeb.Components.FormBuilder.DependencyManager

  @doc """
  渲染表单构建器
  
  ## 示例
  
      <.form_builder 
        id="user-form"
        config={%{
          fields: [
            %{type: "input", name: "name", label: "姓名", required: true},
            %{type: "email", name: "email", label: "邮箱"}
          ]
        }}
        on_submit="save_user"
      />
  """
  attr :id, :string, required: true
  attr :config, :map, default: %{}
  attr :initial_data, :map, default: %{}
  attr :changeset, :any, default: nil, doc: "Ecto.Changeset for automatic form generation"
  attr :field_overrides, :map, default: %{}, doc: "Override field configurations from changeset"
  attr :layout, :string, default: "vertical", values: ~w(vertical horizontal inline grid)
  attr :size, :string, default: "medium", values: ~w(small medium large)
  attr :disabled, :boolean, default: false
  attr :readonly, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :validate_on_change, :boolean, default: true
  attr :submit_text, :string, default: "提交"
  attr :reset_text, :string, default: "重置"
  attr :show_submit, :boolean, default: true
  attr :show_reset, :boolean, default: true
  attr :on_submit, :string, default: nil
  attr :on_change, :string, default: nil
  attr :on_reset, :string, default: nil
  attr :on_field_change, :string, default: nil, doc: "Callback for individual field changes"
  attr :auto_save, :boolean, default: false, doc: "Enable automatic saving of form state"
  attr :save_debounce, :integer, default: 500, doc: "Debounce delay for auto-save in milliseconds"
  attr :enable_smart_linkage, :boolean, default: true, doc: "Enable smart field linkage"
  attr :linkage_debounce, :integer, default: 300, doc: "Debounce delay for field linkage in milliseconds"
  attr :errors, :map, default: %{}, doc: "Field validation errors map"
  attr :class, :string, default: ""
  attr :rest, :global

  def form_builder(assigns) do
    assigns = 
      assigns
      |> process_changeset()
      |> then(fn updated_assigns -> assign(updated_assigns, :fields, get_fields(updated_assigns)) end)
      |> process_smart_linkage()
      |> assign(:groups, get_groups(assigns.config))
      |> assign(:layout_config, get_layout_config(assigns.config, assigns.layout))
      |> assign(:form_data, get_form_data(assigns))
      |> assign(:form_errors, get_errors(assigns))
    
    ~H"""
    <div 
      id={@id}
      class={[
        "form-builder",
        get_layout_classes(@layout),
        get_size_classes(@size),
        @loading && "animate-pulse opacity-60",
        @disabled && "pointer-events-none opacity-60",
        @readonly && "pointer-events-none",
        @class
      ]}
      {@rest}
    >
      <form 
        phx-submit={@on_submit}
        phx-change={@validate_on_change && (@on_field_change || @on_change)}
        class={[
          "form-builder-form",
          get_form_classes(@layout, @layout_config)
        ]}
        data-enable-smart-linkage={@enable_smart_linkage}
      >
        <%= if @groups != [] do %>
          <%= for group <- @groups do %>
            <div class="form-builder-group mb-6">
              <%= if group[:title] do %>
                <h3 class="text-lg font-medium text-gray-900 mb-4 border-b border-gray-200 pb-2">
                  <%= group[:title] %>
                </h3>
              <% end %>
              
              <div class={get_fields_container_classes(@layout, @layout_config)}>
                <%= for field_name <- group[:fields] || [] do %>
                  <%= if field = find_field(@fields, field_name) do %>
                    <%= render_field(assigns, field) %>
                  <% end %>
                <% end %>
              </div>
            </div>
          <% end %>
        <% else %>
          <div class={get_fields_container_classes(@layout, @layout_config)}>
            <%= for field <- @fields do %>
              <%= render_field(assigns, field) %>
            <% end %>
          </div>
        <% end %>
        
        <%= if @show_submit || @show_reset do %>
          <div class={[
            "form-builder-buttons flex gap-3 pt-6 border-t border-gray-200",
            @layout == "horizontal" && "ml-auto"
          ]}>
            <%= if @show_submit do %>
              <.button 
                type="submit"
                disabled={@disabled || @loading}
                class="px-6"
              >
                <%= if @loading do %>
                  <.icon name="hero-arrow-path" class="w-4 h-4 animate-spin mr-2" />
                <% end %>
                <%= @submit_text %>
              </.button>
            <% end %>
            
            <%= if @show_reset do %>
              <.button 
                type="button"
                phx-click={@on_reset}
                disabled={@disabled || @loading}
                class="px-6 bg-white border border-gray-300 text-gray-700 hover:bg-gray-50"
              >
                <%= @reset_text %>
              </.button>
            <% end %>
          </div>
        <% end %>
      </form>
    </div>
    """
  end

  # 渲染单个字段
  defp render_field(assigns, field) do
    assigns = 
      assigns
      |> assign(:field, field)
      |> assign(:field_value, get_field_display_value(field, assigns.form_data))
      |> assign(:field_error, get_field_error(assigns.form_errors, field[:name]))
      |> assign(:field_id, "#{assigns.id}_#{field[:name]}")
      |> assign(:show_field, should_show_field?(field, assigns.form_data))
    
    ~H"""
    <%= if @show_field do %>
      <div class={[
        "form-builder-field",
        get_field_wrapper_classes(@layout, @field, @layout_config),
        @field_error && "form-field-error"
      ]}>
        <%= render_field_by_type(assigns) %>
      </div>
    <% end %>
    """
  end

  # 根据字段类型渲染具体字段
  defp render_field_by_type(%{field: %{type: "input"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="text"
        value={@field_value}
        placeholder={@field[:placeholder]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly || @field[:readonly]}
        class={get_input_classes(@size)}
        phx-blur={@field[:async_validation] && "validate_field"}
        phx-value-field={@field[:name]}
        phx-debounce={@field[:async_validation][:debounce] || 500}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "textarea"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <textarea
        id={@field_id}
        name={@field[:name]}
        rows={@field[:rows] || 3}
        placeholder={@field[:placeholder]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={[
          "block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500",
          get_input_classes(@size)
        ]}
      ><%= @field_value %></textarea>
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "password"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="password"
        value={@field_value}
        placeholder={@field[:placeholder]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "number"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <input
        id={@field_id}
        name={@field[:name]}
        type="number"
        value={@field_value || ""}
        placeholder={@field[:placeholder]}
        min={@field[:min]}
        max={@field[:max]}
        step={@field[:step]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly || @field[:readonly] || @field[:computed] != nil}
        class={[
          "block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500",
          get_input_classes(@size)
        ]}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "email"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="email"
        value={@field_value}
        placeholder={@field[:placeholder]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "tel"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="tel"
        value={@field_value}
        placeholder={@field[:placeholder]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "url"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="url"
        value={@field_value}
        placeholder={@field[:placeholder]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "select"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <select
        id={@field_id}
        name={@field[:name]}
        required={@field[:required]}
        disabled={@disabled}
        class={[
          "block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500",
          get_input_classes(@size)
        ]}
      >
        <%= if @field[:placeholder] do %>
          <option value=""><%= @field[:placeholder] %></option>
        <% end %>
        <%= for option <- @field[:options] || [] do %>
          <option 
            value={option[:value]} 
            selected={to_string(@field_value) == to_string(option[:value])}
          >
            <%= option[:label] %>
          </option>
        <% end %>
      </select>
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "radio"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <div class="space-y-2">
        <%= for option <- @field[:options] || [] do %>
          <label class="flex items-center">
            <input
              type="radio"
              name={@field[:name]}
              value={option[:value]}
              checked={to_string(@field_value) == to_string(option[:value])}
              required={@field[:required]}
              disabled={@disabled}
              class="text-blue-600 border-gray-300 focus:ring-blue-500"
            />
            <span class="ml-2 text-sm text-gray-700"><%= option[:label] %></span>
          </label>
        <% end %>
      </div>
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "checkbox"}} = assigns) do
    # Handle boolean checkbox vs multi-option checkbox
    if assigns.field[:options] && length(assigns.field[:options]) > 0 do
      # Multi-option checkbox
      ~H"""
      <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
        <div class="space-y-2">
          <%= for option <- @field[:options] || [] do %>
            <label class="flex items-center">
              <input
                type="checkbox"
                name={"#{@field[:name]}[]"}
                value={option[:value]}
                checked={is_checked?(@field_value, option[:value])}
                disabled={@disabled}
                class="text-blue-600 border-gray-300 focus:ring-blue-500 rounded"
              />
              <span class="ml-2 text-sm text-gray-700"><%= option[:label] %></span>
            </label>
          <% end %>
        </div>
      </.field_wrapper>
      """
    else
      # Single boolean checkbox
      ~H"""
      <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
        <label class="flex items-center">
          <input
            type="checkbox"
            id={@field_id}
            name={@field[:name]}
            value="true"
            checked={@field_value == true || @field_value == "true"}
            disabled={@disabled}
            class="text-blue-600 border-gray-300 focus:ring-blue-500 rounded"
          />
          <span class="ml-2 text-sm text-gray-700">
            <%= @field[:label] %>
          </span>
        </label>
      </.field_wrapper>
      """
    end
  end

  defp render_field_by_type(%{field: %{type: "date"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="date"
        value={@field_value}
        min={@field[:min]}
        max={@field[:max]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "datetime-local"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="datetime-local"
        value={@field_value}
        min={@field[:min]}
        max={@field[:max]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "time"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <.input
        id={@field_id}
        name={@field[:name]}
        type="time"
        value={@field_value}
        min={@field[:min]}
        max={@field[:max]}
        required={@field[:required]}
        disabled={@disabled}
        readonly={@readonly}
        class={get_input_classes(@size)}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "range"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <input
        id={@field_id}
        name={@field[:name]}
        type="range"
        value={@field_value || @field[:min] || 0}
        min={@field[:min] || 0}
        max={@field[:max] || 100}
        step={@field[:step] || 1}
        disabled={@disabled}
        class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
      />
      <%= if @field[:show_value] do %>
        <div class="text-center text-sm text-gray-600 mt-1">
          <%= @field_value || @field[:min] || 0 %>
        </div>
      <% end %>
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "color"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <input
        id={@field_id}
        name={@field[:name]}
        type="color"
        value={@field_value || "#000000"}
        disabled={@disabled}
        class="h-10 w-20 border border-gray-300 rounded cursor-pointer"
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "file"}} = assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <input
        id={@field_id}
        name={@field[:name]}
        type="file"
        accept={@field[:accept]}
        multiple={@field[:multiple]}
        required={@field[:required]}
        disabled={@disabled}
        class={[
          "block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100",
          get_input_classes(@size)
        ]}
      />
    </.field_wrapper>
    """
  end

  defp render_field_by_type(%{field: %{type: "hidden"}} = assigns) do
    ~H"""
    <input
      id={@field_id}
      name={@field[:name]}
      type="hidden"
      value={@field_value}
    />
    """
  end

  defp render_field_by_type(%{field: %{type: "divider"}} = assigns) do
    ~H"""
    <div class="border-t border-gray-200 my-6">
      <%= if @field[:title] do %>
        <div class="relative">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-200"></div>
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-2 bg-white text-gray-500"><%= @field[:title] %></span>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_field_by_type(%{field: %{type: "text"}} = assigns) do
    ~H"""
    <div class="py-2">
      <%= if @field[:label] do %>
        <div class="text-sm font-medium text-gray-700 mb-1"><%= @field[:label] %></div>
      <% end %>
      <div class="text-sm text-gray-600"><%= @field[:content] %></div>
    </div>
    """
  end

  # 默认处理未知字段类型
  defp render_field_by_type(assigns) do
    ~H"""
    <.field_wrapper field={@field} field_id={@field_id} field_error={@field_error}>
      <div class="p-4 bg-yellow-50 border border-yellow-200 rounded-md">
        <p class="text-sm text-yellow-800">
          未知字段类型: <code><%= @field[:type] %></code>
        </p>
      </div>
    </.field_wrapper>
    """
  end

  # 字段包装器组件
  defp field_wrapper(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= if @field[:label] do %>
        <label 
          for={@field_id}
          class={[
            "block text-sm font-medium text-gray-700",
            @field[:required] && "after:content-['*'] after:ml-0.5 after:text-red-500"
          ]}
        >
          <%= @field[:label] %>
        </label>
      <% end %>
      
      <%= render_slot(@inner_block) %>
      
      <%= if @field[:description] do %>
        <p class="text-xs text-gray-500"><%= @field[:description] %></p>
      <% end %>
      
      <%= if @field_error do %>
        <%= if is_list(@field_error) do %>
          <%= for error <- @field_error do %>
            <p class="text-xs text-red-600"><%= error %></p>
          <% end %>
        <% else %>
          <p class="text-xs text-red-600"><%= @field_error %></p>
        <% end %>
      <% end %>
    </div>
    """
  end

  # 私有函数（已在 Changeset 部分定义）

  defp get_groups(%{groups: groups}) when is_list(groups), do: groups
  defp get_groups(_), do: []

  defp get_layout_config(%{layout_config: config}, _layout), do: config
  defp get_layout_config(_, layout) do
    case layout do
      "horizontal" -> %{label_col: %{span: 6}, wrapper_col: %{span: 18}}
      "grid" -> %{gutter: 16}
      _ -> %{}
    end
  end

  defp get_layout_classes(layout) do
    case layout do
      "vertical" -> "form-vertical"
      "horizontal" -> "form-horizontal"
      "inline" -> "form-inline"
      "grid" -> "form-grid"
      _ -> "form-vertical"
    end
  end

  defp get_size_classes(size) do
    case size do
      "small" -> "form-size-small text-sm"
      "large" -> "form-size-large text-lg"
      _ -> "form-size-medium text-base"
    end
  end

  defp get_form_classes(layout, layout_config) do
    case layout do
      "inline" -> "flex flex-wrap gap-4 items-end"
      "grid" -> "grid grid-cols-12 gap-#{layout_config[:gutter] || 16}"
      _ -> "space-y-6"
    end
  end

  defp get_fields_container_classes(layout, layout_config) do
    case layout do
      "grid" -> "grid grid-cols-12 gap-#{layout_config[:gutter] || 16}"
      "inline" -> "flex flex-wrap gap-4"
      _ -> "space-y-4"
    end
  end

  defp get_field_wrapper_classes(layout, field, _layout_config) do
    case layout do
      "grid" -> 
        span = get_in(field, [:grid, :span]) || 12
        "col-span-#{span}"
      "inline" -> "flex-shrink-0"
      _ -> ""
    end
  end

  defp get_input_classes(size) do
    case size do
      "small" -> "text-sm py-1"
      "large" -> "text-lg py-3"
      _ -> "text-base py-2"
    end
  end

  defp find_field(fields, name) do
    Enum.find(fields, fn field -> field[:name] == name end)
  end

  defp get_field_value(form_data, field_name) when is_binary(field_name) do
    Map.get(form_data, field_name) || Map.get(form_data, String.to_atom(field_name))
  end
  defp get_field_value(form_data, field_name) when is_atom(field_name) do
    Map.get(form_data, field_name) || Map.get(form_data, Atom.to_string(field_name))
  end
  defp get_field_value(_form_data, _field_name), do: nil
  
  # 获取字段值，优先使用计算值
  defp get_field_display_value(field, form_data) do
    if field[:computed] && field[:computed_value] do
      field[:computed_value]
    else
      get_field_value(form_data, field[:name])
    end
  end

  defp get_field_error(errors, field_name) when is_binary(field_name) do
    Map.get(errors, field_name) || Map.get(errors, String.to_atom(field_name))
  end
  defp get_field_error(errors, field_name) when is_atom(field_name) do
    Map.get(errors, field_name) || Map.get(errors, Atom.to_string(field_name))
  end
  defp get_field_error(_errors, _field_name), do: nil

  defp should_show_field?(field, form_data) do
    case field[:show_if] do
      nil -> true
      condition ->
        evaluate_condition(condition, form_data)
    end
  end

  # 简单的条件评估（实际使用中建议使用更安全的表达式解析器）
  defp evaluate_condition(condition, form_data) do
    ConditionEvaluator.evaluate(condition, form_data)
  end

  defp is_checked?(field_value, option_value) when is_list(field_value) do
    Enum.any?(field_value, fn v -> to_string(v) == to_string(option_value) end)
  end
  defp is_checked?(field_value, option_value) do
    to_string(field_value) == to_string(option_value)
  end

  # Smart linkage functions
  
  defp process_smart_linkage(%{enable_smart_linkage: false} = assigns), do: assigns
  defp process_smart_linkage(assigns) do
    fields = get_fields(assigns)
    form_data = get_form_data(assigns)
    
    # 构建依赖关系图
    case DependencyManager.build_dependency_graph(fields) do
      {:ok, dependency_graph} ->
        # 处理动态字段选项加载
        fields = Enum.map(fields, fn field ->
          if field[:load_options] do
            case DependencyManager.load_field_options(field, form_data) do
              {:ok, options} -> Map.put(field, :options, options)
              {:error, _} -> field
            end
          else
            field
          end
        end)
        
        # 处理计算字段
        fields = Enum.map(fields, fn field ->
          if field[:computed] do
            case DependencyManager.compute_field_value(field, form_data) do
              {:ok, value} -> 
                Map.put(field, :computed_value, value)
              {:error, _reason} -> 
                field
            end
          else
            field
          end
        end)
        
        assigns
        |> assign(:fields, fields)
        |> assign(:dependency_graph, dependency_graph)
      
      {:error, reason} ->
        # 如果有循环依赖，记录错误但继续渲染
        IO.warn("FormBuilder dependency error: #{reason}")
        assigns
    end
  end

  # Changeset integration functions

  defp process_changeset(%{changeset: nil} = assigns), do: assigns
  defp process_changeset(%{changeset: changeset} = assigns) do
    config = build_config_from_changeset(changeset, assigns.field_overrides)
    assign(assigns, :config, config)
  end

  defp build_config_from_changeset(changeset, overrides) do
    %{
      fields: build_fields_from_changeset(changeset, overrides)
    }
  end

  defp build_fields_from_changeset(changeset, overrides) do
    # Get schema module and its fields
    schema = changeset.data.__struct__
    fields = schema.__schema__(:fields)
    types = changeset.types
    
    # Debug output
    if Application.get_env(:shop_ux_phoenix, :debug_form_builder) do
      IO.puts "\n=== build_fields_from_changeset ==="
      IO.inspect schema, label: "Schema"
      IO.inspect fields, label: "Schema fields"
      IO.inspect types, label: "Types"
    end
    
    # Get fields that are in the changeset's params or cast fields
    cast_fields = get_cast_fields(changeset)
    changeset_fields = if cast_fields == [] do
      # If no cast fields, use all schema fields except timestamps and associations
      fields
      |> Enum.reject(&(&1 in [:id, :inserted_at, :updated_at]))
    else
      cast_fields
    end
    
    # Filter out fields that don't have types
    changeset_fields = changeset_fields
    |> Enum.filter(&Map.has_key?(types, &1))
    
    if Application.get_env(:shop_ux_phoenix, :debug_form_builder) do
      IO.inspect cast_fields, label: "Cast fields"
      IO.inspect changeset_fields, label: "Changeset fields after filtering"
    end
    
    # Build field configurations
    result = changeset_fields
    |> Enum.map(fn field_name ->
      field_config = %{
        name: to_string(field_name),
        type: infer_field_type(field_name, types[field_name]),
        label: humanize_field_name(field_name),
        required: field_required?(changeset, field_name)
      }
      
      if Application.get_env(:shop_ux_phoenix, :debug_form_builder) do
        IO.inspect field_config, label: "Field config for #{field_name}"
      end
      
      # Add validation-based configurations
      field_config
      |> add_length_validation(changeset, field_name)
      |> add_number_validation(changeset, field_name)
      |> add_format_validation(changeset, field_name)
      |> add_inclusion_validation(changeset, field_name)
      |> add_confirmation_field(changeset, field_name)
      |> add_description_from_validations(changeset, field_name)
      |> merge_field_override(overrides, field_name)
    end)
    |> add_confirmation_fields(changeset)
    |> Enum.reject(&is_nil/1)
    
    if Application.get_env(:shop_ux_phoenix, :debug_form_builder) do
      IO.inspect result, label: "Final fields list"
    end
    
    result
  end

  defp get_fields(%{config: %{fields: fields}}) when is_list(fields), do: fields
  defp get_fields(%{config: config}) when is_map(config), do: []
  defp get_fields(_), do: []

  defp get_form_data(%{changeset: changeset}) when not is_nil(changeset) do
    changeset.changes
  end
  defp get_form_data(%{initial_data: data}), do: data

  defp get_errors(%{changeset: changeset}) when not is_nil(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
  defp get_errors(%{errors: errors}) when is_map(errors), do: errors
  defp get_errors(_), do: %{}

  # Field type inference
  defp infer_field_type(field_name, :string) do
    cond do
      String.contains?(to_string(field_name), "password") -> "password"
      String.contains?(to_string(field_name), "email") -> "email"
      String.contains?(to_string(field_name), "url") -> "url"
      String.contains?(to_string(field_name), "phone") || String.contains?(to_string(field_name), "tel") -> "tel"
      String.contains?(to_string(field_name), "bio") || String.contains?(to_string(field_name), "description") -> "textarea"
      true -> "input"
    end
  end
  defp infer_field_type(_field_name, :integer), do: "number"
  defp infer_field_type(_field_name, :float), do: "number"
  defp infer_field_type(_field_name, :boolean), do: "checkbox"
  defp infer_field_type(_field_name, :date), do: "date"
  defp infer_field_type(_field_name, :time), do: "time"
  defp infer_field_type(_field_name, :naive_datetime), do: "datetime-local"
  defp infer_field_type(_field_name, :utc_datetime), do: "datetime-local"
  defp infer_field_type(_field_name, {:array, _}), do: "select"
  defp infer_field_type(_field_name, :map), do: "textarea"
  defp infer_field_type(_field_name, :json), do: "textarea"
  defp infer_field_type(field_name, _type) do
    if String.ends_with?(to_string(field_name), "_id"), do: "select", else: "input"
  end

  # Validation helpers
  defp field_required?(changeset, field_name) do
    changeset.required
    |> Enum.member?(field_name)
  end

  defp add_length_validation(field_config, changeset, field_name) do
    case get_validation_for(changeset, field_name, :length) do
      nil -> field_config
      opts ->
        field_config
        |> Map.put(:min_length, Keyword.get(opts, :min))
        |> Map.put(:max_length, Keyword.get(opts, :max))
    end
  end

  defp add_number_validation(field_config, changeset, field_name) do
    case get_validation_for(changeset, field_name, :number) do
      nil -> field_config
      opts ->
        min = Keyword.get(opts, :greater_than_or_equal_to) || Keyword.get(opts, :greater_than)
        max = Keyword.get(opts, :less_than_or_equal_to) || Keyword.get(opts, :less_than)
        
        field_config
        |> Map.put(:min, min)
        |> Map.put(:max, max)
        |> Map.put(:step, if(field_config.type == "number", do: get_number_step(Map.get(changeset.types, field_name))))
    end
  end

  defp add_format_validation(field_config, changeset, field_name) do
    case get_validation_for(changeset, field_name, :format) do
      nil -> field_config
      opts when is_struct(opts, Regex) ->
        # If opts is a Regex directly (pattern without options)
        Map.put(field_config, :pattern, inspect(opts))
      opts when is_list(opts) ->
        # If opts is a keyword list with pattern and possibly message
        pattern = Keyword.get(opts, :pattern) || opts
        Map.put(field_config, :pattern, inspect(pattern))
      opts ->
        # Handle other formats
        Map.put(field_config, :pattern, inspect(opts))
    end
  end

  defp add_inclusion_validation(field_config, changeset, field_name) do
    case get_validation_for(changeset, field_name, :inclusion) do
      nil -> field_config
      values when is_list(values) ->
        options = Enum.map(values, fn value ->
          %{value: value, label: to_string(value)}
        end)
        
        field_config
        |> Map.put(:type, "select")
        |> Map.put(:options, options)
      _ -> field_config
    end
  end

  defp add_confirmation_field(field_config, changeset, field_name) do
    if confirmation_field?(changeset, field_name) do
      Map.put(field_config, :needs_confirmation, true)
    else
      field_config
    end
  end

  defp add_confirmation_fields(fields, _changeset) do
    confirmation_fields = fields
    |> Enum.filter(&Map.get(&1, :needs_confirmation))
    |> Enum.map(fn field ->
      %{
        name: "#{field.name}_confirmation",
        type: field.type,
        label: "#{field.label} 确认",
        description: "请再次输入#{field.label}",
        required: field.required
      }
    end)
    
    fields ++ confirmation_fields
  end

  defp add_description_from_validations(field_config, _changeset, _field_name) do
    descriptions = []
    
    # Required
    descriptions = if field_config[:required] do
      ["此字段必填" | descriptions]
    else
      descriptions
    end
    
    # Length
    descriptions = case {field_config[:min_length], field_config[:max_length]} do
      {nil, nil} -> descriptions
      {min, nil} -> ["至少 #{min} 个字符" | descriptions]
      {nil, max} -> ["最多 #{max} 个字符" | descriptions]
      {min, max} -> ["长度应在 #{min} 到 #{max} 之间" | descriptions]
    end
    
    # Number range
    descriptions = case {field_config[:min], field_config[:max]} do
      {nil, nil} -> descriptions
      {min, nil} -> ["最小值为 #{min}" | descriptions]
      {nil, max} -> ["最大值为 #{max}" | descriptions]
      {min, max} -> ["数值应在 #{min} 到 #{max} 之间" | descriptions]
    end
    
    # Format
    descriptions = if field_config[:pattern] do
      case field_config.type do
        "email" -> ["请输入有效的邮箱地址" | descriptions]
        _ -> ["请输入正确的格式" | descriptions]
      end
    else
      descriptions
    end
    
    if descriptions != [] do
      Map.put(field_config, :description, Enum.join(Enum.reverse(descriptions), "，"))
    else
      field_config
    end
  end

  defp merge_field_override(field_config, overrides, field_name) do
    case Map.get(overrides, to_string(field_name)) do
      nil -> field_config
      override -> Map.merge(field_config, override)
    end
  end

  # Helper functions
  defp get_validation_for(changeset, field_name, validation_type) do
    changeset.validations
    |> Enum.find_value(fn
      {^field_name, {^validation_type, opts}} -> opts
      _ -> nil
    end)
  end

  defp confirmation_field?(changeset, field_name) do
    changeset.validations
    |> Enum.any?(fn
      {^field_name, {:confirmation, _}} -> true
      _ -> false
    end)
  end

  defp get_number_step(:float), do: "any"
  defp get_number_step(_), do: 1

  defp humanize_field_name(field_name) do
    field_name
    |> to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp get_cast_fields(changeset) do
    # Try multiple approaches to get cast fields
    cond do
      # If changeset has params with keys, use those
      Map.get(changeset, :params) && map_size(changeset.params) > 0 ->
        Map.keys(changeset.params) |> Enum.map(&String.to_atom/1)
      
      # If schema module defines cast_fields function (for testing)
      function_exported?(changeset.data.__struct__, :cast_fields, 0) ->
        apply(changeset.data.__struct__, :cast_fields, [])
      
      # Otherwise, use all non-system fields from schema
      true ->
        schema = changeset.data.__struct__
        schema.__schema__(:fields)
        |> Enum.reject(&(&1 in [:id, :inserted_at, :updated_at]))
    end
  end
end