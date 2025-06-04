defmodule ShopUxPhoenixWeb.Components.SearchableSelect do
  @moduledoc """
  SearchableSelect component with search functionality and multiple selection support.
  
  Based on Ant Design's Select component with enhanced search capabilities.
  """
  
  use Phoenix.Component

  @doc """
  Renders a searchable select component.

  ## Examples

      <.searchable_select
        id="category-select"
        name="category"
        options={@category_options}
        value={@form.category}
        placeholder="Select category"
        on_change="category_changed"
      />

      <.searchable_select
        id="multi-select"
        name="tags"
        options={@tag_options}
        value={@form.tags}
        multiple={true}
        placeholder="Select tags"
        on_change="tags_changed"
      />
  """
  attr :id, :string, required: true, doc: "Unique identifier for the component"
  attr :name, :string, required: true, doc: "Form field name"
  attr :options, :list, default: [], doc: "List of options"
  attr :value, :any, default: nil, doc: "Current selected value(s)"
  attr :placeholder, :string, default: "Please select", doc: "Placeholder text"
  attr :multiple, :boolean, default: false, doc: "Enable multiple selection"
  attr :searchable, :boolean, default: true, doc: "Enable search functionality"
  attr :remote_search, :boolean, default: false, doc: "Enable remote search"
  attr :allow_clear, :boolean, default: true, doc: "Show clear button"
  attr :disabled, :boolean, default: false, doc: "Disable the component"
  attr :loading, :boolean, default: false, doc: "Show loading state"
  attr :max_tag_count, :integer, default: nil, doc: "Maximum number of tags to display"
  attr :filter_option, :string, default: "default", doc: "Filter option: 'default', 'custom', 'none'"
  attr :size, :string, default: "md", doc: "Size: 'sm', 'md', 'lg'"
  attr :required, :boolean, default: false, doc: "Required field"
  attr :errors, :list, default: [], doc: "List of validation errors"
  attr :on_change, :string, default: nil, doc: "Change event handler"
  attr :on_search, :string, default: nil, doc: "Search event handler"
  attr :on_focus, :string, default: nil, doc: "Focus event handler"
  attr :on_blur, :string, default: nil, doc: "Blur event handler"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :rest, :global, doc: "Additional HTML attributes"

  slot :option, doc: "Custom option rendering" do
    attr :option, :map, doc: "Option data"
  end

  def searchable_select(assigns) do
    assigns = assign_defaults(assigns)

    ~H"""
    <div 
      class={[
        "searchable-select-container relative",
        "size-#{@size}",
        size_classes(@size),
        @disabled && "cursor-not-allowed opacity-50",
        @class
      ]}
      data-searchable-select
      data-multiple={@multiple}
      data-remote-search={@remote_search}
      {@rest}
    >
      <!-- Hidden input for form submission -->
      <input
        type="hidden"
        id={"#{@id}-hidden"}
        name={if @multiple, do: "#{@name}[]", else: @name}
        value={encode_value(@value, @multiple)}
        disabled={@disabled}
        required={@required}
      />
      
      <!-- Main select container -->
      <div
        id={@id}
        class={[
          "select-container relative w-full min-h-8 px-3 py-2 border rounded-lg",
          "focus-within:ring-2 focus-within:ring-blue-500 focus-within:border-blue-500",
          "transition-colors duration-200",
          border_classes(@errors),
          @disabled && "bg-gray-50 cursor-not-allowed"
        ]}
        phx-click={!@disabled && "toggle_dropdown"}
        phx-target={@on_change && "##{@id}"}
        data-testid="select-container"
      >
        <!-- Selection display area -->
        <div class="flex items-center flex-wrap gap-1 min-h-6">
          <%= if @multiple do %>
            <%= render_multiple_selection(assigns) %>
          <% else %>
            <%= render_single_selection(assigns) %>
          <% end %>
          
          <!-- Search input -->
          <%= if @searchable && !@disabled do %>
            <input
              type="text"
              class="search-input flex-1 min-w-12 border-0 outline-0 bg-transparent text-sm placeholder-gray-400"
              placeholder={if is_empty_selection(@value, @multiple), do: @placeholder, else: ""}
              phx-keyup={if @remote_search || @on_search, do: (@on_search || "search"), else: nil}
              phx-target={(@remote_search || @on_search) && "##{@id}"}
              phx-debounce="300"
              data-testid="search-input"
            />
          <% end %>
        </div>

        <!-- Action buttons -->
        <div class="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1">
          <!-- Loading spinner -->
          <%= if @loading do %>
            <div class="animate-spin h-4 w-4 border-2 border-blue-500 border-t-transparent rounded-full" data-testid="loading-spinner"></div>
          <% end %>
          
          <!-- Clear button -->
          <%= if @allow_clear && !is_empty_selection(@value, @multiple) && !@disabled do %>
            <button
              type="button"
              class="clear-button p-1 hover:bg-gray-100 rounded text-gray-400 hover:text-gray-600"
              phx-click="clear_selection"
              phx-target={@on_change && "##{@id}"}
              data-testid="clear-button"
            >
              ×
            </button>
          <% end %>
          
          <!-- Dropdown arrow -->
          <div class="text-gray-400">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Dropdown menu -->
      <div
        class="dropdown-menu absolute z-50 w-full mt-1 max-h-60 overflow-auto bg-white border border-gray-200 rounded-lg shadow-lg hidden"
        data-testid="dropdown-menu"
      >
        <%= if Enum.empty?(@options) do %>
          <div class="px-3 py-2 text-gray-500 text-sm">No options available</div>
        <% else %>
          <!-- Native select for accessibility -->
          <select class="hidden">
            <%= render_native_options(assigns) %>
          </select>
          <%= render_options(assigns) %>
        <% end %>
      </div>

      <!-- Validation errors -->
      <%= if @errors != [] do %>
        <div class="mt-1 text-sm text-red-600" data-testid="error-message">
          <%= Enum.join(@errors, ", ") %>
        </div>
      <% end %>
    </div>
    """
  end

  # Private helper functions

  defp assign_defaults(assigns) do
    assigns
    |> assign_new(:options, fn -> [] end)
    |> assign_new(:value, fn -> nil end)
    |> assign_new(:placeholder, fn -> "Please select" end)
    |> assign_new(:multiple, fn -> false end)
    |> assign_new(:searchable, fn -> true end)
    |> assign_new(:remote_search, fn -> false end)
    |> assign_new(:allow_clear, fn -> true end)
    |> assign_new(:disabled, fn -> false end)
    |> assign_new(:loading, fn -> false end)
    |> assign_new(:max_tag_count, fn -> nil end)
    |> assign_new(:filter_option, fn -> "default" end)
    |> assign_new(:size, fn -> "md" end)
    |> assign_new(:required, fn -> false end)
    |> assign_new(:errors, fn -> [] end)
    |> assign_new(:class, fn -> "" end)
  end

  defp render_single_selection(assigns) do
    ~H"""
    <%= if @value do %>
      <div class="flex items-center gap-2">
        <%= case find_option(@options, @value) do %>
          <% nil -> %>
            <span class="text-gray-900"><%= @value %></span>
          <% option -> %>
            <%= if @option != [] do %>
              <%= render_slot(@option, option) %>
            <% else %>
              <%= if Map.has_key?(option, :avatar) do %>
                <img src={option.avatar} class="w-5 h-5 rounded-full option-avatar" />
              <% end %>
              <span class="text-gray-900"><%= option.label %></span>
            <% end %>
        <% end %>
      </div>
    <% end %>
    """
  end

  defp render_multiple_selection(assigns) do
    ~H"""
    <%= if @value && length(@value) > 0 do %>
      <%= for {selected_value, index} <- Enum.with_index(@value) do %>
        <%= if is_nil(@max_tag_count) || index < @max_tag_count do %>
          <%= case find_option(@options, selected_value) do %>
            <% nil -> %>
              <span class="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded">
                <%= selected_value %>
                <button
                  type="button"
                  class="text-blue-600 hover:text-blue-800"
                  phx-click="remove_tag"
                  phx-value-index={index}
                  phx-target={@on_change && "##{@id}"}
                >
                  ×
                </button>
              </span>
            <% option -> %>
              <span class="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded">
                <%= option.label %>
                <button
                  type="button"
                  class="text-blue-600 hover:text-blue-800"
                  phx-click="remove_tag"
                  phx-value-index={index}
                  phx-target={@on_change && "##{@id}"}
                >
                  ×
                </button>
              </span>
          <% end %>
        <% end %>
      <% end %>
      
      <%= if @max_tag_count && length(@value) > @max_tag_count do %>
        <span class="inline-flex items-center px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded">
          +<%= length(@value) - @max_tag_count %>
        </span>
      <% end %>
    <% end %>
    """
  end

  defp render_native_options(assigns) do
    ~H"""
    <%= for option <- normalize_options(@options) do %>
      <%= if Map.has_key?(option, :options) do %>
        <optgroup label={option.label}>
          <%= for sub_option <- option.options do %>
            <option value={sub_option.value}><%= sub_option.label %></option>
          <% end %>
        </optgroup>
      <% else %>
        <option value={option.value}><%= option.label %></option>
      <% end %>
    <% end %>
    """
  end

  defp render_options(assigns) do
    ~H"""
    <%= for option <- normalize_options(@options) do %>
      <%= if Map.has_key?(option, :options) do %>
        <!-- Option group -->
        <div class="option-group">
          <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wider bg-gray-50">
            <%= option.label %>
          </div>
          <%= for sub_option <- option.options do %>
            <%= render_option(sub_option, assigns) %>
          <% end %>
        </div>
      <% else %>
        <%= render_option(option, assigns) %>
      <% end %>
    <% end %>
    """
  end

  defp render_option(option, assigns) do
    assigns = assign(assigns, :option_data, option)
    
    ~H"""
    <div
      class={[
        "option px-3 py-2 cursor-pointer hover:bg-blue-50 flex items-center justify-between",
        is_selected(@option_data.value, @value, @multiple) && "bg-blue-100 text-blue-700"
      ]}
      phx-click="select_option"
      phx-value-option={@option_data.value}
      phx-target={@on_change && "##{@id}"}
      data-testid="option"
    >
      <div class="flex items-center gap-2 flex-1">
        <%= if @option != [] do %>
          <%= render_slot(@option, @option_data) %>
        <% else %>
          <%= if Map.has_key?(@option_data, :avatar) do %>
            <img src={@option_data.avatar} class="w-6 h-6 rounded-full option-avatar" />
          <% end %>
          <div class="flex-1">
            <div class="font-medium"><%= @option_data.label %></div>
            <%= if Map.has_key?(@option_data, :description) do %>
              <div class="text-sm text-gray-500"><%= @option_data.description %></div>
            <% end %>
            <%= if Map.has_key?(@option_data, :email) do %>
              <div class="text-sm text-gray-500"><%= @option_data.email %></div>
            <% end %>
          </div>
        <% end %>
      </div>
      
      <%= if is_selected(@option_data.value, @value, @multiple) do %>
        <svg class="w-4 h-4 text-blue-600" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
        </svg>
      <% end %>
    </div>
    """
  end

  defp size_classes("sm"), do: "text-sm"
  defp size_classes("md"), do: "text-base"
  defp size_classes("lg"), do: "text-lg"
  defp size_classes(_), do: "text-base"

  defp border_classes([]), do: "border-gray-300"
  defp border_classes(_errors), do: "border-red-500"

  defp encode_value(nil, _multiple), do: ""
  defp encode_value([], _multiple), do: ""
  defp encode_value(value, false), do: to_string(value)
  defp encode_value(values, true) when is_list(values), do: Enum.join(values, ",")
  defp encode_value(value, true), do: to_string(value)

  defp is_empty_selection(nil, _multiple), do: true
  defp is_empty_selection([], _multiple), do: true
  defp is_empty_selection("", _multiple), do: true
  defp is_empty_selection(_value, _multiple), do: false

  defp normalize_options(options) when is_list(options) do
    Enum.map(options, &normalize_option/1)
  end

  defp normalize_option(option) when is_map(option) do
    # Option is already a map, ensure it has required keys
    option
    |> Map.put_new(:value, Map.get(option, :value, ""))
    |> Map.put_new(:label, Map.get(option, :label, Map.get(option, :value, "")))
  end

  defp normalize_option(option) when is_binary(option) do
    %{value: option, label: option}
  end

  defp normalize_option(option) do
    %{value: to_string(option), label: to_string(option)}
  end

  defp find_option(options, value) do
    Enum.find_value(options, fn option ->
      normalized = normalize_option(option)
      
      cond do
        Map.has_key?(normalized, :options) ->
          # This is a group, search in sub-options
          find_option(normalized.options, value)
        
        to_string(normalized.value) == to_string(value) ->
          normalized
          
        true ->
          nil
      end
    end)
  end

  defp is_selected(_option_value, nil, _multiple), do: false
  defp is_selected(_option_value, [], _multiple), do: false
  defp is_selected(option_value, value, false) do
    to_string(option_value) == to_string(value)
  end
  defp is_selected(option_value, values, true) when is_list(values) do
    Enum.any?(values, fn v -> to_string(option_value) == to_string(v) end)
  end
  defp is_selected(option_value, value, true) do
    to_string(option_value) == to_string(value)
  end
end