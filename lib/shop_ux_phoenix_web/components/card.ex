defmodule ShopUxPhoenixWeb.Components.Card do
  @moduledoc """
  卡片组件，用于组织和展示信息的通用容器
  
  ## 特性
  - 支持标题、额外内容、操作区域等多个插槽
  - 支持加载状态
  - 支持悬停效果
  - 支持自定义边框
  - 支持不同尺寸
  - 完全响应式设计
  
  ## 依赖
  - 无外部依赖，样式完全基于 Tailwind CSS
  """
  use Phoenix.Component

  @doc """
  渲染卡片组件
  
  ## 示例
      <.card title="卡片标题">
        <p>卡片内容</p>
      </.card>
      
      <.card title="带操作的卡片">
        <:extra>
          <.link navigate="/more">更多</.link>
        </:extra>
        <p>内容</p>
        <:actions>
          <.button>操作</.button>
        </:actions>
      </.card>
  """
  attr :title, :string, default: nil, doc: "卡片标题"
  attr :size, :string, values: ~w(small medium large), default: "medium", doc: "卡片尺寸"
  attr :bordered, :boolean, default: true, doc: "是否显示边框"
  attr :hoverable, :boolean, default: false, doc: "鼠标悬停时是否有阴影效果"
  attr :loading, :boolean, default: false, doc: "是否显示加载状态"
  attr :body_style, :string, default: "", doc: "内容区域的自定义样式类"
  attr :header_class, :string, default: "", doc: "标题区域的自定义样式类"
  attr :class, :string, default: "", doc: "卡片容器的自定义 CSS 类"
  attr :rest, :global, doc: "其他 HTML 属性"

  slot :inner_block, doc: "卡片主体内容"
  slot :header, doc: "自定义标题区域内容"
  slot :extra, doc: "标题栏右侧的额外内容"
  slot :actions, doc: "卡片底部的操作区域"
  slot :cover, doc: "卡片封面"

  def card(assigns) do
    ~H"""
    <div
      class={[
        "bg-white rounded-lg",
        get_border_classes(@bordered),
        get_shadow_classes(@hoverable),
        @class
      ]}
      {@rest}
    >
      <%= if @cover != [] do %>
        <div class="rounded-t-lg overflow-hidden">
          <%= render_slot(@cover) %>
        </div>
      <% end %>
      
      <%= if @loading do %>
        <div class={get_padding_classes(@size)}>
          <div class="animate-pulse">
            <%= if @title || @header != [] do %>
              <div class="h-6 bg-gray-200 rounded w-1/4 mb-4"></div>
            <% end %>
            <div class="space-y-3">
              <div class="h-4 bg-gray-200 rounded"></div>
              <div class="h-4 bg-gray-200 rounded w-5/6"></div>
              <div class="h-4 bg-gray-200 rounded w-4/6"></div>
            </div>
          </div>
        </div>
      <% else %>
        <%= if @title || @header != [] || @extra != [] do %>
          <div class={[
            "border-b border-gray-200",
            get_header_padding_classes(@size),
            @header_class
          ]}>
            <div class="flex items-center justify-between">
              <div>
                <%= if @header != [] do %>
                  <%= render_slot(@header) %>
                <% else %>
                  <h3 class={get_title_classes(@size)}>
                    <%= @title %>
                  </h3>
                <% end %>
              </div>
              <%= if @extra != [] do %>
                <div class="flex items-center">
                  <%= render_slot(@extra) %>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
        
        <div class={[
          get_padding_classes(@size),
          @body_style
        ]}>
          <%= render_slot(@inner_block) %>
        </div>
        
        <%= if @actions != [] do %>
          <div class={[
            "border-t border-gray-200",
            get_actions_padding_classes(@size),
            "flex items-center gap-2"
          ]}>
            <%= render_slot(@actions) %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  # Helper functions

  defp get_border_classes(true), do: "border border-gray-200"
  defp get_border_classes(false), do: ""

  defp get_shadow_classes(true), do: "shadow-sm hover:shadow-lg transition-shadow duration-300"
  defp get_shadow_classes(false), do: "shadow-sm"

  defp get_padding_classes("small"), do: "p-4"
  defp get_padding_classes("medium"), do: "p-6"
  defp get_padding_classes("large"), do: "p-8"
  defp get_padding_classes(_), do: "p-6"

  defp get_header_padding_classes("small"), do: "px-4 py-3"
  defp get_header_padding_classes("medium"), do: "px-6 py-4"
  defp get_header_padding_classes("large"), do: "px-8 py-5"
  defp get_header_padding_classes(_), do: "px-6 py-4"

  defp get_actions_padding_classes("small"), do: "px-4 py-3"
  defp get_actions_padding_classes("medium"), do: "px-6 py-4"
  defp get_actions_padding_classes("large"), do: "px-8 py-5"
  defp get_actions_padding_classes(_), do: "px-6 py-4"

  defp get_title_classes("small"), do: "text-base font-semibold text-gray-900"
  defp get_title_classes("medium"), do: "text-lg font-semibold text-gray-900"
  defp get_title_classes("large"), do: "text-xl font-semibold text-gray-900"
  defp get_title_classes(_), do: "text-lg font-semibold text-gray-900"
end