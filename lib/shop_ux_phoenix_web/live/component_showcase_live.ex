defmodule ShopUxPhoenixWeb.ComponentShowcaseLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    component = params["component"] || "table"
    
    components = get_component_list()
    current_component = Enum.find(components, &(&1.id == component)) || hd(components)
    
    {:ok,
     socket
     |> assign(:components, components)
     |> assign(:current_component, current_component)
     |> assign(:page_title, "组件展示 - #{current_component.name}")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    component = params["component"] || "table"
    components = socket.assigns.components
    current_component = Enum.find(components, &(&1.id == component)) || hd(components)
    
    {:noreply,
     socket
     |> assign(:current_component, current_component)
     |> assign(:page_title, "组件展示 - #{current_component.name}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-100">
      <!-- 侧边栏 -->
      <div class="w-64 bg-white shadow-lg overflow-y-auto">
        <div class="p-4 border-b">
          <h2 class="text-xl font-bold text-gray-800">组件库展示</h2>
          <p class="text-sm text-gray-600 mt-1">Shop UX Phoenix</p>
        </div>
        
        <nav class="p-4">
          <.component_category 
            title="表单组件" 
            components={filter_by_category(@components, :form)}
            current_component={@current_component}
          />
          
          <.component_category 
            title="数据展示" 
            components={filter_by_category(@components, :data)}
            current_component={@current_component}
          />
          
          <.component_category 
            title="布局组件" 
            components={filter_by_category(@components, :layout)}
            current_component={@current_component}
          />
          
          <.component_category 
            title="反馈组件" 
            components={filter_by_category(@components, :feedback)}
            current_component={@current_component}
          />
          
          <.component_category 
            title="其他组件" 
            components={filter_by_category(@components, :other)}
            current_component={@current_component}
          />
        </nav>
      </div>

      <!-- 主内容区 -->
      <div class="flex-1 overflow-hidden">
        <!-- 顶部标题栏 -->
        <div class="bg-white shadow-sm px-8 py-4 border-b">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl font-bold text-gray-800"><%= @current_component.name %></h1>
              <p class="text-gray-600 mt-1"><%= @current_component.description %></p>
            </div>
            <div class="flex gap-2">
              <.link
                navigate={"/demo/#{@current_component.id}"}
                target="_blank"
                class="px-4 py-2 text-sm bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
              >
                <.icon name="hero-arrow-top-right-on-square" class="w-4 h-4 inline mr-1" />
                独立页面
              </.link>
              <.link
                navigate={@current_component.doc_path}
                class="px-4 py-2 text-sm bg-blue-600 text-white hover:bg-blue-700 rounded-md transition-colors"
                :if={@current_component.doc_path}
              >
                <.icon name="hero-document-text" class="w-4 h-4 inline mr-1" />
                查看文档
              </.link>
            </div>
          </div>
        </div>

        <!-- Demo 内容区 -->
        <div class="h-full overflow-y-auto p-8">
          <div class="max-w-7xl mx-auto">
            <%= live_render(@socket, @current_component.module, id: "component-demo-#{@current_component.id}") %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # 组件分类渲染
  defp component_category(assigns) do
    ~H"""
    <div class="mb-6">
      <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
        <%= @title %>
      </h3>
      <ul class="space-y-1">
        <li :for={component <- @components}>
          <.link
            patch={~p"/components/showcase?component=#{component.id}"}
            class={[
              "block px-3 py-2 rounded-md text-sm font-medium transition-colors",
              if(@current_component.id == component.id,
                do: "bg-blue-100 text-blue-700",
                else: "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
              )
            ]}
          >
            <%= component.name %>
          </.link>
        </li>
      </ul>
    </div>
    """
  end

  # 获取组件列表
  defp get_component_list do
    [
      # 表单组件
      %{
        id: "form_builder",
        name: "表单构建器",
        description: "动态表单构建器，支持条件逻辑和字段联动",
        category: :form,
        module: ShopUxPhoenixWeb.FormBuilderDemoLive,
        doc_path: "/docs/components/form_builder_doc.md"
      },
      %{
        id: "select",
        name: "选择框",
        description: "增强的下拉选择框组件",
        category: :form,
        module: ShopUxPhoenixWeb.SelectDemoLive,
        doc_path: "/docs/components/select_doc.md"
      },
      %{
        id: "searchable_select",
        name: "搜索选择框",
        description: "支持搜索过滤的选择框",
        category: :form,
        module: ShopUxPhoenixWeb.SearchableSelectDemoLive,
        doc_path: "/docs/components/searchable_select_doc.md"
      },
      %{
        id: "tree_select",
        name: "树形选择器",
        description: "层级数据选择组件",
        category: :form,
        module: ShopUxPhoenixWeb.TreeSelectDemoLive,
        doc_path: "/docs/components/tree_select_doc.md"
      },
      %{
        id: "cascader",
        name: "级联选择器",
        description: "多级联动选择组件",
        category: :form,
        module: ShopUxPhoenixWeb.CascaderDemoLive,
        doc_path: "/docs/components/cascader_doc.md"
      },
      %{
        id: "date_picker",
        name: "日期选择器",
        description: "日期选择组件",
        category: :form,
        module: ShopUxPhoenixWeb.DatePickerDemoLive,
        doc_path: "/docs/components/date_picker_doc.md"
      },
      %{
        id: "range_picker",
        name: "日期范围选择",
        description: "日期范围选择组件",
        category: :form,
        module: ShopUxPhoenixWeb.RangePickerDemoLive,
        doc_path: "/docs/components/range_picker_doc.md"
      },
      %{
        id: "input_number",
        name: "数字输入框",
        description: "数字输入组件，支持步进器",
        category: :form,
        module: ShopUxPhoenixWeb.InputNumberDemoLive,
        doc_path: "/docs/components/input_number_doc.md"
      },
      %{
        id: "switch",
        name: "开关",
        description: "开关切换组件",
        category: :form,
        module: ShopUxPhoenixWeb.SwitchDemoLive,
        doc_path: "/docs/components/switch_doc.md"
      },
      %{
        id: "address_selector",
        name: "地址选择器",
        description: "省市区三级地址选择",
        category: :form,
        module: ShopUxPhoenixWeb.AddressSelectorDemoLive,
        doc_path: "/docs/components/address_selector_doc.md"
      },
      %{
        id: "media_upload",
        name: "媒体上传",
        description: "图片和视频上传组件",
        category: :form,
        module: ShopUxPhoenixWeb.MediaUploadDemoLive,
        doc_path: "/docs/components/media_upload_doc.md"
      },
      
      # 数据展示组件
      %{
        id: "table",
        name: "数据表格",
        description: "功能强大的数据表格，支持排序、筛选、固定列等",
        category: :data,
        module: ShopUxPhoenixWeb.TableDemoLive,
        doc_path: "/docs/components/table_doc.md"
      },
      %{
        id: "card",
        name: "卡片",
        description: "通用卡片容器组件",
        category: :data,
        module: ShopUxPhoenixWeb.CardDemoLive,
        doc_path: "/docs/components/card_doc.md"
      },
      %{
        id: "statistic",
        name: "统计数值",
        description: "数据统计展示组件",
        category: :data,
        module: ShopUxPhoenixWeb.StatisticDemoLive,
        doc_path: "/docs/components/statistic_doc.md"
      },
      %{
        id: "timeline",
        name: "时间轴",
        description: "时间轴展示组件",
        category: :data,
        module: ShopUxPhoenixWeb.TimelineDemoLive,
        doc_path: "/docs/components/timeline_doc.md"
      },
      %{
        id: "progress",
        name: "进度条",
        description: "进度展示组件",
        category: :data,
        module: ShopUxPhoenixWeb.ProgressDemoLive,
        doc_path: "/docs/components/progress_doc.md"
      },
      
      # 布局组件
      %{
        id: "app_layout",
        name: "应用布局",
        description: "应用整体布局框架",
        category: :layout,
        module: ShopUxPhoenixWeb.AppLayoutDemoLive,
        doc_path: "/docs/business_components/app_layout_doc.md"
      },
      %{
        id: "tabs",
        name: "标签页",
        description: "标签页切换组件",
        category: :layout,
        module: ShopUxPhoenixWeb.TabsDemoLive,
        doc_path: "/docs/components/tabs_doc.md"
      },
      %{
        id: "steps",
        name: "步骤条",
        description: "步骤进度展示组件",
        category: :layout,
        module: ShopUxPhoenixWeb.StepsDemoLive,
        doc_path: "/docs/components/steps_doc.md"
      },
      %{
        id: "breadcrumb",
        name: "面包屑",
        description: "页面导航路径组件",
        category: :layout,
        module: ShopUxPhoenixWeb.BreadcrumbDemoLive,
        doc_path: "/docs/components/breadcrumb_doc.md"
      },
      %{
        id: "filter_form",
        name: "筛选表单",
        description: "列表页筛选表单布局",
        category: :layout,
        module: ShopUxPhoenixWeb.FilterFormDemoLive,
        doc_path: "/docs/components/filter_form_doc.md"
      },
      
      # 反馈组件
      %{
        id: "action_buttons",
        name: "操作按钮组",
        description: "批量操作按钮组件",
        category: :feedback,
        module: ShopUxPhoenixWeb.ActionButtonsDemoLive,
        doc_path: "/docs/components/action_buttons_doc.md"
      },
      %{
        id: "dropdown",
        name: "下拉菜单",
        description: "下拉菜单组件",
        category: :feedback,
        module: ShopUxPhoenixWeb.DropdownDemoLive,
        doc_path: "/docs/components/dropdown_doc.md"
      },
      %{
        id: "tooltip",
        name: "文字提示",
        description: "鼠标悬停提示组件",
        category: :feedback,
        module: ShopUxPhoenixWeb.TooltipDemoLive,
        doc_path: "/docs/components/tooltip_doc.md"
      },
      %{
        id: "status_badge",
        name: "状态徽章",
        description: "状态标识组件",
        category: :feedback,
        module: ShopUxPhoenixWeb.StatusBadgeDemoLive,
        doc_path: "/docs/components/status_badge_doc.md"
      }
    ]
  end

  # 按分类过滤组件
  defp filter_by_category(components, category) do
    Enum.filter(components, &(&1.category == category))
  end
end