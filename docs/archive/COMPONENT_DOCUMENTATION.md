# 组件文档 - Vue到Phoenix迁移指南

> **归档说明**: 本文档记录了项目从 Vue/Ant Design Vue 到 Phoenix LiveView 的迁移过程和组件使用统计。
> 
> - 归档日期：2025-06-04
> - 原位置：/COMPONENT_DOCUMENTATION.md
> - 归档原因：文档内容已分散到更专门的文档中，保留作为历史参考

## 一、基础组件使用情况

### 1.1 Ant Design Vue基础组件清单

#### 表单组件 (使用频率最高)
| 组件名称 | 使用次数 | 主要用途 | 示例页面 |
|---------|---------|---------|---------|
| `a-form-item` | 197次 | 表单项容器 | 所有表单页面 |
| `a-button` | 180次 | 按钮操作 | 全局使用 |
| `a-input` | 50次 | 文本输入 | 商品编辑、供应商创建 |
| `a-select` | 35次 | 下拉选择 | 分类选择、状态筛选 |
| `a-select-option` | 72次 | 下拉选项 | 配合select使用 |
| `a-input-number` | 29次 | 数字输入 | 价格、库存设置 |
| `a-checkbox` | 26次 | 复选框 | 批量选择、功能开关 |
| `a-textarea` | 12次 | 多行文本 | 描述信息、备注 |
| `a-radio-group` | 9次 | 单选组 | 状态选择、类型选择 |
| `a-input-search` | 10次 | 搜索框 | 列表页搜索 |
| `a-cascader` | 11次 | 级联选择 | 地区选择、分类选择 |
| `a-date-picker` | 8次 | 日期选择 | 时间筛选 |
| `a-range-picker` | 6次 | 日期范围 | 订单查询、数据统计 |
| `a-time-picker` | 3次 | 时间选择 | 活动时间设置 |
| `a-switch` | 4次 | 开关 | 状态切换 |

#### 数据展示组件
| 组件名称 | 使用次数 | 主要用途 | 示例页面 |
|---------|---------|---------|---------|
| `a-table` | 37次 | 数据表格 | 商品列表、订单列表 |
| `a-descriptions` | 13次 | 描述列表 | 详情页展示 |
| `a-descriptions-item` | 57次 | 描述项 | 配合descriptions使用 |
| `a-list` | 10次 | 列表容器 | 活动列表、公告列表 |
| `a-list-item` | 10次 | 列表项 | 配合list使用 |
| `a-tag` | 9次 | 标签 | 状态标识、分类标签 |
| `a-statistic` | 5次 | 统计数值 | 数据概览 |
| `a-image` | 7次 | 图片展示 | 商品图片 |
| `a-avatar` | 3次 | 头像 | 用户信息 |
| `a-badge` | 4次 | 徽标 | 消息提醒、状态点 |

#### 布局组件
| 组件名称 | 使用次数 | 主要用途 | 示例页面 |
|---------|---------|---------|---------|
| `a-row` | 36次 | 栅格行 | 表单布局、卡片布局 |
| `a-col` | 67次 | 栅格列 | 响应式布局 |
| `a-layout` | 11次 | 布局容器 | 整体框架 |
| `a-card` | 55次 | 卡片容器 | 信息分组展示 |
| `a-space` | 32次 | 间距容器 | 按钮组、标签组 |
| `a-divider` | 15次 | 分割线 | 内容分隔 |
| `a-collapse` | 2次 | 折叠面板 | 详情收纳 |
| `a-tabs` | 6次 | 标签页 | 内容切换 |

#### 反馈组件
| 组件名称 | 使用次数 | 主要用途 | 示例页面 |
|---------|---------|---------|---------|
| `a-modal` | 23次 | 模态框 | 确认操作、表单弹窗 |
| `a-popconfirm` | 8次 | 气泡确认 | 删除确认 |
| `a-tooltip` | 5次 | 文字提示 | 帮助信息 |
| `a-alert` | 3次 | 警告提示 | 页面提示 |
| `a-spin` | 2次 | 加载中 | 数据加载 |
| `a-progress` | 2次 | 进度条 | 上传进度 |

#### 导航组件
| 组件名称 | 使用次数 | 主要用途 | 示例页面 |
|---------|---------|---------|---------|
| `a-menu` | 8次 | 菜单 | 侧边栏导航 |
| `a-menu-item` | 15次 | 菜单项 | 导航选项 |
| `a-sub-menu` | 4次 | 子菜单 | 多级导航 |
| `a-breadcrumb` | 5次 | 面包屑 | 页面导航 |
| `a-pagination` | 4次 | 分页 | 列表分页 |
| `a-steps` | 3次 | 步骤条 | 流程展示 |
| `a-dropdown` | 6次 | 下拉菜单 | 操作菜单 |

#### 其他组件
| 组件名称 | 使用次数 | 主要用途 | 示例页面 |
|---------|---------|---------|---------|
| `a-upload` | 12次 | 文件上传 | 图片上传、文件导入 |
| `a-tree-select` | 4次 | 树选择 | 组织架构选择 |
| `a-auto-complete` | 2次 | 自动完成 | 搜索建议 |
| `a-config-provider` | 1次 | 全局配置 | App.vue |

## 二、公共组件清单

### 2.1 自定义公共组件

| 组件名称 | 功能描述 | 使用的基础组件 | 复杂度 |
|---------|---------|---------------|--------|
| **CustomTable.vue** | 自定义样式表格 | a-table | ⭐⭐ |
| **SearchForm.vue** | 动态搜索表单 | a-form, a-input, a-select等 | ⭐⭐⭐⭐ |
| **ActivityTable.vue** | 活动专用表格 | a-table, a-space, a-button | ⭐⭐⭐ |
| **AppLayout.vue** | 应用布局框架 | a-layout, a-breadcrumb | ⭐⭐⭐ |
| **AppSidebar.vue** | 侧边栏导航 | a-layout-sider, a-menu | ⭐⭐⭐ |
| **AppHeader.vue** | 顶部导航栏 | 自定义 | ⭐⭐ |
| **DataCard.vue** | 数据统计卡片 | 纯自定义 | ⭐ |
| **CustomCard.vue** | 悬浮效果卡片 | a-card | ⭐ |
| **ContentSectionHeader.vue** | 内容区标题 | 自定义 | ⭐ |
| **TitleWithButtons.vue** | 标题按钮组合 | a-button | ⭐ |
| **LabeledSelect.vue** | 标签选择器 | a-select | ⭐ |
| **LabeledValueWithAction.vue** | 标签值操作组合 | 自定义 | ⭐ |
| **QuickActionButton.vue** | 快捷操作按钮 | a-button | ⭐ |
| **SystemSelection.vue** | 系统选择器 | 自定义 | ⭐⭐ |
| **MainContent.vue** | 主内容容器 | 自定义 | ⭐ |
| **Sidebar.vue** | 通用侧边栏 | 自定义 | ⭐⭐ |
| **APieChart.vue** | 饼图组件 | SVG自定义 | ⭐⭐ |
| **Mermaid.vue** | 流程图组件 | mermaid库 | ⭐⭐ |

## 三、Petal Components对比分析

### 3.1 Petal Components现有组件

#### ✅ 已有对应组件
| Ant Design Vue | Petal Components | 功能差异 |
|---------------|-----------------|----------|
| a-button | Button | 基本一致 |
| a-card | Card | 基本一致 |
| a-modal | Modal | 支持LiveView |
| a-alert | Alert | 基本一致 |
| a-badge | Badge | 基本一致 |
| a-avatar | Avatar | 基本一致 |
| a-tabs | Tabs | 基本一致 |
| a-dropdown | Dropdown | ✅ 有（支持Alpine JS和LiveView JS） |
| a-pagination | Pagination | 基本一致 |
| a-progress | Progress | 基本一致 |
| a-form | Form Components | 组件化程度不同 |
| a-input | Input (in Forms) | 基本一致 |
| a-tooltip | Tooltip (部分) | 功能简化 |

#### ❌ 缺失的关键组件
| 组件类型 | Ant Design Vue组件 | 影响范围 | 解决方案 |
|---------|-------------------|----------|----------|
| **数据表格** | a-table | 高（37处使用） | 需自行实现或使用第三方 |
| **选择器** | a-select, a-select-option | 高（35+72处） | 需自定义实现（注意：不是Dropdown） |
| **日期选择** | a-date-picker, a-range-picker | 中（14处） | 需集成日期库 |
| **数字输入** | a-input-number | 中（29处） | Phoenix原生input支持type="number" ✅ |
| **级联选择** | a-cascader | 中（11处） | 需自定义实现 |
| **树选择** | a-tree-select | 低（4处） | 需自定义实现 |
| **描述列表** | a-descriptions | 中（13处） | 可用简单HTML表格实现 |
| **步骤条** | a-steps | 低（3处） | 需自定义实现 |
| **上传** | a-upload | 中（12处） | 需集成上传库 |
| **开关** | a-switch | 低（4处） | 可用checkbox替代 ✅ |
| **标签** | a-tag | 中（9处） | 需自定义实现 |
| **栅格系统** | a-row, a-col | 高（36+67处） | 使用Tailwind Grid ✅ |
| **列表** | a-list | 中（10处） | Phoenix原生list组件 ✅ |
| **统计数值** | a-statistic | 低（5处） | 需自定义实现 |
| **面包屑** | a-breadcrumb | 低（5处） | 可用简单链接实现 |

### 3.2 补充组件开发优先级

#### 🔴 高优先级（必须实现）
1. **Table组件** - 数据展示核心
2. **Select组件** - 表单交互核心（注意：不是Dropdown）
3. **DatePicker组件** - 时间选择必需

#### 🟡 中优先级（重要功能）
1. **Tag组件** - 状态展示
2. **Upload组件** - 文件上传
3. **Cascader组件** - 级联选择
4. **RangePicker组件** - 日期范围选择

#### 🟢 低优先级（可后期完善）
1. **Steps组件** - 步骤展示
2. **TreeSelect组件** - 树形选择
3. **Statistic组件** - 数据统计

## 四、公共组件重构方案

### 4.1 重构策略

#### 第一阶段：基础组件补充
```elixir
# 1. 创建基础组件库目录结构
lib/
  shop_ux_web/
    components/
      base/           # 基础组件
        table.ex      # 表格组件
        select.ex     # 选择器组件
        date_picker.ex # 日期选择器
        input_number.ex # 数字输入
        tag.ex        # 标签组件
      layout/         # 布局组件
        grid.ex       # 栅格系统
        app_layout.ex # 应用布局
        sidebar.ex    # 侧边栏
      business/       # 业务组件
        search_form.ex # 搜索表单
        data_card.ex   # 数据卡片
        custom_table.ex # 自定义表格
```

#### 第二阶段：公共组件迁移

##### 4.1.1 CustomTable组件重构
```elixir
defmodule ShopUxWeb.Components.Business.CustomTable do
  use Phoenix.Component
  import ShopUxWeb.Components.Base.Table

  def custom_table(assigns) do
    ~H"""
    <.table
      id={@id}
      rows={@rows}
      class="custom-table"
    >
      <:col :for={col <- @columns} label={col.label}>
        <%= render_cell(col, @row) %>
      </:col>
      <:action :if={@actions}>
        <.link class="text-primary hover:text-primary-dark">
          <%= @action.label %>
        </.link>
      </:action>
    </.table>

    <style>
      .custom-table {
        @apply rounded-lg overflow-hidden;
      }
      .custom-table thead {
        @apply bg-gray-50;
      }
      .custom-table tbody tr:hover {
        @apply bg-orange-50;
      }
      .text-primary {
        @apply text-[#FD8E25];
      }
    </style>
    """
  end
end
```

##### 4.1.2 SearchForm组件重构
```elixir
defmodule ShopUxWeb.Components.Business.SearchForm do
  use Phoenix.Component
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <form phx-change="search" phx-submit="search" class="search-form">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <%= for field <- @fields do %>
          <div class="form-field">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              <%= field.label %>
            </label>
            <%= render_field(field, assigns) %>
          </div>
        <% end %>
      </div>
      
      <div class="mt-4 flex gap-2">
        <%= for button <- @buttons do %>
          <.button type={button.type} phx-click={button.action}>
            <%= button.label %>
          </.button>
        <% end %>
      </div>
    </form>
    """
  end
  
  defp render_field(%{type: "input"} = field, assigns) do
    ~H"""
    <.input
      name={field.name}
      value={@form[field.name]}
      placeholder={field.placeholder}
    />
    """
  end
  
  defp render_field(%{type: "select"} = field, assigns) do
    ~H"""
    <.select
      name={field.name}
      value={@form[field.name]}
      options={field.options}
      placeholder={field.placeholder}
    />
    """
  end
  
  defp render_field(%{type: "date"} = field, assigns) do
    ~H"""
    <.date_picker
      name={field.name}
      value={@form[field.name]}
      placeholder={field.placeholder}
    />
    """
  end
end
```

##### 4.1.3 DataCard组件重构
```elixir
defmodule ShopUxWeb.Components.Business.DataCard do
  use Phoenix.Component

  attr :title, :string, required: true
  attr :value, :any, required: true
  slot :icon

  def data_card(assigns) do
    ~H"""
    <div class="data-card bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600"><%= @title %></p>
          <p class="text-2xl font-semibold text-primary mt-1"><%= @value %></p>
        </div>
        <div :if={@icon} class="text-gray-400">
          <%= render_slot(@icon) %>
        </div>
      </div>
    </div>

    <style>
      .text-primary {
        color: #FD8E25;
      }
    </style>
    """
  end
end
```

### 4.2 样式系统设计

```css
/* app.css - 主题变量定义 */
:root {
  --primary-color: #FD8E25;
  --primary-hover: #E57E20;
  --border-radius: 8px;
  --spacing-unit: 8px;
}

/* 组件通用样式 */
.ant-compat {
  /* 保持与Ant Design相似的视觉风格 */
  --font-family: -apple-system, BlinkMacSystemFont, 'Microsoft YaHei', sans-serif;
  --box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --box-shadow-hover: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}
```

### 4.3 实施步骤

1. **第1周**：搭建Phoenix项目，集成Petal Components
2. **第2-3周**：开发缺失的基础组件（Table、Select、DatePicker）
3. **第4周**：迁移核心公共组件（SearchForm、CustomTable）
4. **第5-6周**：迁移第一个完整页面作为试点
5. **第7-8周**：根据试点反馈优化组件库
6. **第9周起**：批量迁移其他页面

### 4.4 注意事项

1. **保持接口一致性**：新组件的props应尽量与原Vue组件保持一致
2. **渐进式迁移**：可以先迁移独立性强的页面
3. **样式复用**：使用Tailwind CSS实现原有样式效果
4. **性能优化**：利用LiveView的特性优化实时更新
5. **测试覆盖**：为每个组件编写测试用例

## 五、总结

通过分析，该项目主要使用Ant Design Vue作为UI组件库，并开发了18个自定义公共组件。迁移到Phoenix时，可以使用Petal Components作为基础，但需要补充开发约15个缺失的基础组件。建议采用渐进式迁移策略，优先实现高频使用的组件，保持设计风格的一致性。