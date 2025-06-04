defmodule PetalComponents.Custom.Table do
  @moduledoc """
  表格组件 - 用于展示多条结构类似的数据
  
  ## 特性
  - 支持自定义列
  - 支持操作列
  - 支持行选择
  - 支持分页
  - 支持排序
  - 支持固定表头
  - 支持自定义空状态
  - 支持行点击事件
  - 支持列宽控制（固定宽度、百分比、最小/最大宽度）
  - 支持文本省略（ellipsis）
  - 支持固定列（左固定、右固定）
  
  ## 依赖
  - Phoenix.Component
  - Phoenix.LiveView.JS
  """
  use Phoenix.Component
  
  # 导入功能模块
  alias ShopUxPhoenixWeb.Components.Table.{
    FixedColumns,
    ColumnWidth,
    TextEllipsis,
    Styles,
    Pagination,
    Sorting,
    Filtering
  }

  @doc """
  渲染表格组件
  
  ## 示例
  
      <.table id="products-table" rows={@products}>
        <:col :let={product} label="名称">
          <%= product.name %>
        </:col>
        <:col :let={product} label="价格">
          <%= product.price %>
        </:col>
        <:action :let={product}>
          <.link navigate={"/products/\#{product.id}"}>查看</.link>
        </:action>
      </.table>
      
      <!-- 不同尺寸示例 -->
      <.table id="small-table" size="small" rows={@data}>
        <:col :let={item} label="标题"><%= item.title %></:col>
      </.table>
      
      <.table id="large-table" size="large" color="success" rows={@data}>
        <:col :let={item} label="标题"><%= item.title %></:col>
      </.table>
      
      <!-- 固定列示例 -->
      <.table id="fixed-table" rows={@products}>
        <:col :let={product} label="ID" fixed="left" width={80}>
          <%= product.id %>
        </:col>
        <:col :let={product} label="名称" fixed="left" width={150}>
          <%= product.name %>
        </:col>
        <:col :let={product} label="描述" ellipsis>
          <%= product.description %>
        </:col>
        <:col :let={product} label="价格" fixed="right" width={100}>
          <%= product.price %>
        </:col>
        <:action fixed="right" width={120}>
          <.button size="small">编辑</.button>
        </:action>
      </.table>
  """
  attr :id, :string, required: true, doc: "表格唯一标识"
  attr :rows, :list, default: [], doc: "数据源"
  attr :size, :string, values: ["small", "medium", "large"], default: "medium", doc: "表格尺寸"
  attr :row_click, :any, default: nil, doc: "行点击事件处理函数"
  attr :row_id, :any, default: nil, doc: "行数据的key函数"
  attr :pagination, :map, default: nil, doc: "分页配置"
  attr :color, :string, values: ["primary", "info", "success", "warning", "danger"], default: "primary", doc: "颜色主题"
  attr :class, :string, default: "", doc: "自定义CSS类"
  attr :sticky_header, :boolean, default: false, doc: "是否固定表头"
  attr :selectable, :boolean, default: false, doc: "是否可选择行"
  attr :sortable, :boolean, default: false, doc: "是否支持排序"
  attr :filters, :map, default: %{}, doc: "当前筛选状态 %{column_key => [values]}"
  
  slot :col, required: true, doc: "列定义" do
    attr :label, :string, required: true, doc: "列标题"
    attr :key, :string, doc: "排序字段名"
    attr :sortable, :boolean, doc: "该列是否可排序"
    attr :class, :string, doc: "列的自定义CSS类"
    attr :width, :any, doc: "列宽度，可以是数字（像素）或字符串（如 '20%'）"
    attr :ellipsis, :boolean, doc: "是否显示省略号"
    attr :min_width, :any, doc: "最小列宽"
    attr :max_width, :any, doc: "最大列宽"
    attr :fixed, :string, doc: "固定列位置，支持 'left' 或 'right'"
    attr :filterable, :boolean, doc: "是否可筛选"
    attr :filter_icon, :any, doc: "自定义筛选图标"
  end
  
  slot :action, doc: "操作列" do
    attr :width, :any, doc: "操作列宽度"
    attr :ellipsis, :boolean, doc: "操作列是否显示省略号"
    attr :min_width, :any, doc: "操作列最小宽度"
    attr :max_width, :any, doc: "操作列最大宽度"
    attr :fixed, :string, doc: "固定操作列位置，支持 'left' 或 'right'"
  end
  slot :empty, doc: "空数据时的展示"

  def table(assigns) do
    assigns = 
      assigns
      |> assign(:has_actions, assigns[:action] != [])
      |> assign(:row_id_fun, assigns[:row_id] || fn _ -> System.unique_integer() end)
      |> assign(:header_cell_padding, Styles.get_header_cell_padding(assigns.size))
      |> assign(:body_cell_padding, Styles.get_body_cell_padding(assigns.size))
      |> Filtering.process_filter_states()
      |> FixedColumns.process_fixed_columns()
    
    ~H"""
    <div class={[
      "pc-table",
      @class,
      @has_fixed_left && "pc-table--has-fix-left",
      @has_fixed_right && "pc-table--has-fix-right"
    ]}>
      <div class="pc-table__container overflow-x-auto">
        <table 
        id={@id}
        class={[
          "pc-table__table min-w-full divide-y divide-gray-200 dark:divide-gray-700",
          @sticky_header && "relative"
        ]}>
        <thead class={[
          "pc-table__header bg-gray-50 dark:bg-gray-800",
          @sticky_header && "sticky top-0 z-10"
        ]}>
          <tr>
            <%= if @selectable do %>
              <th scope="col" class={["relative w-12", @header_cell_padding]}>
                <input
                  type="checkbox"
                  data-select-all
                  phx-click="select_all"
                  class={["h-4 w-4 rounded border-gray-300 transition duration-150 ease-in-out", Styles.get_checkbox_classes(@color)]}
                />
              </th>
            <% end %>
            
            <%= if @has_fixed_columns do %>
              <!-- 左固定列 -->
              <%= for {col, position_info} <- @left_fixed_positions do %>
                <th scope="col" 
                    class={[
                      "text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                      @header_cell_padding,
                      col[:class],
                      FixedColumns.build_fixed_column_classes(col, position_info, :header)
                    ]}
                    style={FixedColumns.build_fixed_column_style(col, position_info)}>
                  <%= Sorting.render_column_header(col, assigns) %>
                </th>
              <% end %>
              
              <!-- 普通列 -->
              <%= for col <- @normal_cols do %>
                <th scope="col" 
                    class={[
                      "text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                      @header_cell_padding,
                      col[:class]
                    ]}
                    style={ColumnWidth.build_width_style(col)}>
                  <%= Sorting.render_column_header(col, assigns) %>
                </th>
              <% end %>
              
              <!-- 右固定列 -->
              <%= for {col, position_info} <- @right_fixed_positions do %>
                <th scope="col" 
                    class={[
                      "text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                      @header_cell_padding,
                      col[:class],
                      FixedColumns.build_fixed_column_classes(col, position_info, :header)
                    ]}
                    style={FixedColumns.build_fixed_column_style(col, position_info)}>
                  <%= Sorting.render_column_header(col, assigns) %>
                </th>
              <% end %>
            <% else %>
              <!-- 没有固定列时的原始渲染逻辑 -->
              <%= for col <- @col do %>
                <th scope="col" 
                    class={[
                      "text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                      @header_cell_padding,
                      col[:class]
                    ]}
                    style={ColumnWidth.build_width_style(col)}>
                  <%= Sorting.render_column_header(col, assigns) %>
                </th>
              <% end %>
            <% end %>
            
            <%= if @has_actions do %>
              <% action = List.first(@action) || %{} %>
              <%= if @has_fixed_columns && action[:fixed] do %>
                <th scope="col" 
                    class={[
                      "text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                      @header_cell_padding,
                      FixedColumns.build_fixed_column_classes(action, %{is_first: true, is_last: true}, :header)
                    ]}
                    style={FixedColumns.build_fixed_action_style(action)}>
                  操作
                </th>
              <% else %>
                <th scope="col" 
                    class={[
                      "text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                      @header_cell_padding
                    ]}
                    style={ColumnWidth.build_width_style(action)}>
                  操作
                </th>
              <% end %>
            <% end %>
          </tr>
        </thead>
        
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <%= if @rows == [] do %>
            <tr>
              <td colspan={length(@col) + (if @selectable, do: 1, else: 0) + (if @has_actions, do: 1, else: 0)} 
                  class={["pc-table__cell text-center", @body_cell_padding]}>
                <%= if @empty != [] do %>
                  <%= render_slot(@empty) %>
                <% else %>
                  <div class="pc-table__empty text-gray-500 dark:text-gray-400">暂无数据</div>
                <% end %>
              </td>
            </tr>
          <% else %>
            <%= for row <- @rows do %>
              <tr 
                data-row-id={@row_id_fun.(row)}
                class={[
                  "pc-table__row transition duration-150 ease-in-out hover:bg-gray-50 dark:hover:bg-gray-700",
                  @row_click && "cursor-pointer"
                ]}
                {if @row_click, do: [phx_click: @row_click.(row)], else: []}>
                
                <%= if @selectable do %>
                  <td class={["pc-table__cell w-12", @body_cell_padding]}>
                    <input
                      type="checkbox"
                      value={@row_id_fun.(row)}
                      phx-click="select_row"
                      phx-value-id={@row_id_fun.(row)}
                      class={["h-4 w-4 rounded border-gray-300 transition duration-150 ease-in-out", Styles.get_checkbox_classes(@color)]}
                    />
                  </td>
                <% end %>
                
                <%= if @has_fixed_columns do %>
                  <!-- 左固定列 -->
                  <%= for {col, position_info} <- @left_fixed_positions do %>
                    <% content = render_slot(col, row) %>
                    <td class={[
                         "pc-table__cell text-sm text-gray-900 dark:text-gray-100", 
                         @body_cell_padding, 
                         col[:class],
                         TextEllipsis.build_ellipsis_class(col),
                         FixedColumns.build_fixed_column_classes(col, position_info)
                       ]}
                       style={FixedColumns.build_fixed_column_style(col, position_info)}
                       title={TextEllipsis.get_cell_title(col, content)}>
                      <%= content %>
                    </td>
                  <% end %>
                  
                  <!-- 普通列 -->
                  <%= for col <- @normal_cols do %>
                    <% content = render_slot(col, row) %>
                    <td class={[
                         "pc-table__cell text-sm text-gray-900 dark:text-gray-100", 
                         @body_cell_padding, 
                         col[:class],
                         TextEllipsis.build_ellipsis_class(col)
                       ]}
                       style={ColumnWidth.build_width_style(col)}
                       title={TextEllipsis.get_cell_title(col, content)}>
                      <%= content %>
                    </td>
                  <% end %>
                  
                  <!-- 右固定列 -->
                  <%= for {col, position_info} <- @right_fixed_positions do %>
                    <% content = render_slot(col, row) %>
                    <td class={[
                         "pc-table__cell text-sm text-gray-900 dark:text-gray-100", 
                         @body_cell_padding, 
                         col[:class],
                         TextEllipsis.build_ellipsis_class(col),
                         FixedColumns.build_fixed_column_classes(col, position_info)
                       ]}
                       style={FixedColumns.build_fixed_column_style(col, position_info)}
                       title={TextEllipsis.get_cell_title(col, content)}>
                      <%= content %>
                    </td>
                  <% end %>
                <% else %>
                  <!-- 没有固定列时的原始渲染逻辑 -->
                  <%= for col <- @col do %>
                    <% content = render_slot(col, row) %>
                    <td class={[
                         "pc-table__cell text-sm text-gray-900 dark:text-gray-100", 
                         @body_cell_padding, 
                         col[:class],
                         TextEllipsis.build_ellipsis_class(col)
                       ]}
                       style={ColumnWidth.build_width_style(col)}
                       title={TextEllipsis.get_cell_title(col, content)}>
                      <%= content %>
                    </td>
                  <% end %>
                <% end %>
                
                <%= if @has_actions do %>
                  <% action_col = List.first(@action) || %{} %>
                  <%= if @has_fixed_columns && action_col[:fixed] do %>
                    <td class={[
                         "pc-table__cell text-sm font-medium", 
                         @body_cell_padding,
                         TextEllipsis.build_ellipsis_class(action_col),
                         FixedColumns.build_fixed_column_classes(action_col, %{is_first: true, is_last: true})
                       ]}
                       style={FixedColumns.build_fixed_action_style(action_col)}>
                      <div class="flex items-center gap-3">
                        <%= render_slot(@action, row) %>
                      </div>
                    </td>
                  <% else %>
                    <td class={[
                         "pc-table__cell text-sm font-medium", 
                         @body_cell_padding,
                         TextEllipsis.build_ellipsis_class(action_col)
                       ]}
                       style={ColumnWidth.build_width_style(action_col)}>
                      <div class="flex items-center gap-3">
                        <%= render_slot(@action, row) %>
                      </div>
                    </td>
                  <% end %>
                <% end %>
              </tr>
            <% end %>
          <% end %>
        </tbody>
      </table>
      </div>
      
      <%= if @pagination do %>
        <div class="pagination mt-4">
          <Pagination.render pagination={@pagination} color={@color} />
        </div>
      <% end %>
    </div>
    
    """
  end
end