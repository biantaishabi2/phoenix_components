defmodule ShopUxPhoenixWeb.Components.ActionButtons do
  @moduledoc """
  操作按钮组组件 - 用于组织和展示一组相关的操作按钮
  
  ## 特性
  - 支持多种布局方式（水平、垂直、紧凑）
  - 自动处理按钮间距
  - 支持按钮分组
  - 响应式设计
  - 支持条件渲染
  - 支持下拉菜单收纳
  
  ## 依赖
  - Phoenix.Component
  - 可选：Dropdown 组件（用于 max_visible 功能）
  """
  use Phoenix.Component
  import ShopUxPhoenixWeb.CoreComponents
  alias Phoenix.LiveView.JS

  @doc """
  渲染操作按钮组
  
  ## 示例
  
      <.action_buttons>
        <.button>编辑</.button>
        <.button>删除</.button>
      </.action_buttons>
      
      <.action_buttons spacing="small" align="right">
        <.button>取消</.button>
        <.button type="submit">保存</.button>
      </.action_buttons>
  """
  attr :size, :string, default: "medium",
    values: ~w(small medium large),
    doc: "按钮尺寸"
  attr :spacing, :string, default: "medium",
    values: ~w(small medium large none),
    doc: "按钮间距"
  attr :align, :string, default: "left",
    values: ~w(left center right between),
    doc: "对齐方式"
  attr :direction, :string, default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "布局方向"
  attr :compact, :boolean, default: false, doc: "是否紧凑模式"
  # attr :max_visible, :integer, default: nil, doc: "最多显示的按钮数" # Complex feature - TODO: implement later
  attr :divider, :boolean, default: false, doc: "是否显示分隔符"
  attr :class, :string, default: "", doc: "自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"
  
  slot :inner_block, required: false, doc: "按钮内容"
  slot :extra, doc: "额外内容"

  def action_buttons(assigns) do
    ~H"""
    <div
      class={[
        "flex items-center",
        get_direction_classes(@direction),
        get_spacing_classes(@spacing, @direction, @divider),
        get_align_classes(@align),
        @compact && "flex-wrap",
        @class
      ]}
      {@rest}
    >
      <%= render_children(@inner_block, @divider, @direction) %>
      
      <%= if @extra != [] and @align == "between" do %>
        <div class="flex items-center gap-2">
          <%= render_slot(@extra) %>
        </div>
      <% else %>
        <%= render_slot(@extra) %>
      <% end %>
    </div>
    """
  end

  # 私有函数

  defp get_direction_classes(direction) do
    case direction do
      "horizontal" -> "flex-row"
      "vertical" -> "flex-col"
      _ -> "flex-row"
    end
  end

  defp get_spacing_classes(spacing, direction, divider) do
    if divider do
      case direction do
        "horizontal" -> "divide-x divide-gray-300"
        "vertical" -> "divide-y divide-gray-300"
        _ -> "divide-x divide-gray-300"
      end
    else
      base = case spacing do
        "small" -> "gap-1"
        "medium" -> "gap-2"
        "large" -> "gap-4"
        "none" -> "gap-0"
        _ -> "gap-2"
      end
      
      # 对于水平布局，可以使用 space-x 替代 gap
      case {spacing, direction} do
        {"small", "horizontal"} -> "space-x-1"
        {"medium", "horizontal"} -> "space-x-2"
        {"large", "horizontal"} -> "space-x-4"
        {"none", "horizontal"} -> "space-x-0"
        {"small", "vertical"} -> "space-y-1"
        {"medium", "vertical"} -> "space-y-2"
        {"large", "vertical"} -> "space-y-4"
        {"none", "vertical"} -> "space-y-0"
        _ -> base
      end
    end
  end

  defp get_align_classes(align) do
    case align do
      "left" -> "justify-start"
      "center" -> "justify-center"
      "right" -> "justify-end"
      "between" -> "justify-between"
      _ -> "justify-start"
    end
  end

  defp render_children(inner_block, divider, direction) do
    assigns = %{
      inner_block: inner_block,
      divider: divider,
      direction: direction
    }
    
    ~H"""
    <%= if @divider do %>
      <%= render_children_with_divider(assigns) %>
    <% else %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end
  
  defp render_children_with_divider(%{inner_block: inner_block} = assigns) do
    children = inner_block || []
    
    assigns = Map.put(assigns, :children, children)
    
    ~H"""
    <%= for {child, index} <- Enum.with_index(@children) do %>
      <%= if index > 0 do %>
        <div class={[
          assigns.direction == "horizontal" && "border-l border-gray-300 h-4 mx-1",
          assigns.direction == "vertical" && "border-t border-gray-300 w-full my-1"
        ]} />
      <% end %>
      <div class={assigns.direction == "horizontal" && "px-2"}>
        <%= render_slot([child]) %>
      </div>
    <% end %>
    """
  end

  # TODO: Implement max_visible with dropdown feature later
  # This requires proper slot counting and JS interactions

  @doc """
  CRUD 操作按钮组模板
  """
  attr :id, :any, required: true, doc: "记录 ID"
  attr :view_path, :string, required: true, doc: "查看路径"
  attr :edit_path, :string, default: nil, doc: "编辑路径"
  attr :can_edit, :boolean, default: true, doc: "是否可编辑"
  attr :can_delete, :boolean, default: true, doc: "是否可删除"
  attr :size, :string, default: "small", doc: "按钮尺寸"
  attr :spacing, :string, default: "small", doc: "按钮间距"

  def crud_actions(assigns) do
    ~H"""
    <.action_buttons size={@size} spacing={@spacing}>
      <.link navigate={@view_path} class="text-blue-600 hover:text-blue-700">
        查看
      </.link>
      <.link :if={@can_edit && @edit_path} navigate={@edit_path} class="text-blue-600 hover:text-blue-700">
        编辑
      </.link>
      <.link 
        :if={@can_delete}
        phx-click="delete" 
        phx-value-id={@id}
        data-confirm="确定要删除吗？"
        class="text-red-600 hover:text-red-700"
      >
        删除
      </.link>
    </.action_buttons>
    """
  end

  @doc """
  表单操作按钮组模板
  """
  attr :form_id, :string, default: nil, doc: "表单 ID"
  attr :can_save_draft, :boolean, default: false, doc: "是否显示保存草稿"
  attr :cancel_path, :string, default: nil, doc: "取消后跳转路径"
  attr :cancel_action, JS, default: nil, doc: "取消操作"
  attr :align, :string, default: "right", doc: "对齐方式"

  def form_actions(assigns) do
    ~H"""
    <.action_buttons align={@align}>
      <.button 
        type="button" 
        phx-click={@cancel_action || JS.navigate(@cancel_path || "/")}
      >
        取消
      </.button>
      
      <.button 
        :if={@can_save_draft}
        type="button" 
        phx-click="save_draft"
      >
        保存草稿
      </.button>
      
      <.button 
        type="submit" 
        form={@form_id}
        phx-disable-with="保存中..."
      >
        保存
      </.button>
    </.action_buttons>
    """
  end

  @doc """
  批量操作按钮组模板
  """
  attr :selected_count, :integer, default: 0, doc: "选中数量"
  attr :can_delete, :boolean, default: true, doc: "是否可删除"
  attr :can_export, :boolean, default: true, doc: "是否可导出"
  attr :create_path, :string, default: nil, doc: "新建路径"
  attr :create_label, :string, default: "新建", doc: "新建按钮文本"

  def batch_actions(assigns) do
    ~H"""
    <.action_buttons align="between">
      <div class="flex items-center gap-2">
        <.button 
          :if={@can_delete}
          phx-click="batch_delete"
          disabled={@selected_count == 0}
        >
          批量删除<%= if @selected_count > 0, do: " (#{@selected_count})" %>
        </.button>
        
        <.button 
          :if={@can_export}
          phx-click="batch_export"
          disabled={@selected_count == 0}
        >
          批量导出<%= if @selected_count > 0, do: " (#{@selected_count})" %>
        </.button>
      </div>
      
      <:extra>
        <.link :if={@create_path} navigate={@create_path}>
          <.button>
            <.icon name="hero-plus" class="w-4 h-4 mr-1" />
            <%= @create_label %>
          </.button>
        </.link>
      </:extra>
    </.action_buttons>
    """
  end
end