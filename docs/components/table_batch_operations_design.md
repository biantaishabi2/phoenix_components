# 表格批量操作功能设计文档

## 概述

批量操作功能允许用户选择多个表格行并对其执行批量操作，如删除、导出、状态更改等。本文档定义了批量操作功能的设计规范和实现方案。

## 功能需求

### 核心功能
1. **行选择**：支持单选、多选、全选/取消全选
2. **选择状态管理**：维护选中行的状态，支持跨页选择
3. **批量操作按钮**：根据选择状态动态显示/隐藏批量操作
4. **批量操作执行**：支持常见的批量操作类型
5. **操作反馈**：提供操作进度和结果反馈

### 支持的批量操作类型
- **批量删除**：删除选中的多个项目
- **批量导出**：导出选中项目的数据
- **批量状态更改**：更改选中项目的状态（如启用/禁用）
- **批量编辑**：对选中项目进行批量编辑
- **批量移动**：将选中项目移动到其他分类或位置

## 设计原则

1. **渐进式增强**：在现有表格组件基础上增加批量操作功能
2. **状态可见性**：清晰显示选择状态和可用操作
3. **操作安全性**：危险操作需要确认，提供撤销机制
4. **性能优化**：大量数据时使用虚拟化和分页选择
5. **可访问性**：支持键盘导航和屏幕阅读器

## 技术架构

### 组件层次
```
BatchOperations (新增)
├── SelectionManager (选择状态管理)
├── BatchActionBar (批量操作栏)
└── OperationFeedback (操作反馈)

Table (现有)
├── SelectableRows (增强选择功能)
└── ActionButtons (现有，集成批量操作)
```

### 状态管理
```elixir
# LiveView 状态结构
%{
  # 选择状态
  selected_ids: MapSet.new(),           # 当前选中的ID集合
  selection_mode: :none | :some | :all, # 选择模式
  total_count: 0,                       # 总记录数
  
  # 批量操作状态
  batch_operation: nil | %{
    type: atom(),                       # 操作类型
    status: :pending | :processing | :completed | :error,
    progress: 0..100,                   # 进度百分比
    message: string()                   # 状态消息
  }
}
```

## API 设计

### Table 组件增强

```elixir
attr :batch_operations, :list, default: [], doc: "支持的批量操作列表"
attr :batch_operation_target, :string, default: nil, doc: "批量操作的目标组件"
attr :max_selection, :integer, default: nil, doc: "最大选择数量限制"
attr :selection_across_pages, :boolean, default: false, doc: "是否支持跨页选择"

# 批量操作配置示例
batch_operations: [
  %{key: "delete", label: "批量删除", icon: "hero-trash", color: "danger", confirm: true},
  %{key: "export", label: "批量导出", icon: "hero-arrow-down-tray", color: "primary"},
  %{key: "archive", label: "批量归档", icon: "hero-archive-box", color: "warning"}
]
```

### 新增组件：BatchActionBar

```elixir
defmodule ShopUxPhoenixWeb.Components.BatchActionBar do
  attr :selected_count, :integer, required: true
  attr :total_count, :integer, default: 0
  attr :operations, :list, default: []
  attr :operation_status, :map, default: nil
  attr :max_selection, :integer, default: nil
  
  slot :extra, doc: "额外的操作按钮"
end
```

## 用户交互流程

### 选择流程
1. **单行选择**：点击行复选框选择/取消选择单行
2. **全选操作**：点击表头复选框全选/取消全选当前页
3. **跨页全选**：提供"选择所有X项"选项
4. **选择限制**：达到最大选择数量时禁用其他选项

### 批量操作流程
1. **操作触发**：选择项目后，批量操作按钮变为可用
2. **操作确认**：危险操作显示确认对话框
3. **操作执行**：显示进度条和状态信息
4. **结果反馈**：显示操作结果和错误信息
5. **状态重置**：操作完成后清除选择状态

## 实现细节

### 选择状态管理

```elixir
# 选择管理模块
defmodule ShopUxPhoenixWeb.Components.Table.SelectionManager do
  def toggle_selection(selected_ids, id) do
    if MapSet.member?(selected_ids, id) do
      MapSet.delete(selected_ids, id)
    else
      MapSet.put(selected_ids, id)
    end
  end
  
  def select_all_current_page(rows, row_id_fun) do
    rows
    |> Enum.map(row_id_fun)
    |> MapSet.new()
  end
  
  def get_selection_mode(selected_ids, current_page_ids, total_count) do
    selected_count = MapSet.size(selected_ids)
    current_page_count = length(current_page_ids)
    
    cond do
      selected_count == 0 -> :none
      selected_count == total_count -> :all
      selected_count == current_page_count && 
        MapSet.subset?(MapSet.new(current_page_ids), selected_ids) -> :page
      true -> :some
    end
  end
end
```

### 批量操作处理

```elixir
# LiveView 中的批量操作处理
def handle_event("batch_operation", %{"operation" => operation, "ids" => ids}, socket) do
  socket = assign(socket, batch_operation: %{
    type: operation,
    status: :processing,
    progress: 0,
    message: "正在处理..."
  })
  
  # 异步处理批量操作
  Task.start(fn ->
    result = perform_batch_operation(operation, ids)
    send(self(), {:batch_operation_complete, result})
  end)
  
  {:noreply, socket}
end

def handle_info({:batch_operation_complete, result}, socket) do
  socket = case result do
    {:ok, count} ->
      socket
      |> assign(batch_operation: %{
        type: nil,
        status: :completed,
        progress: 100,
        message: "成功处理 #{count} 项"
      })
      |> assign(selected_ids: MapSet.new())
      |> refresh_data()
    
    {:error, reason} ->
      assign(socket, batch_operation: %{
        type: nil,
        status: :error,
        progress: 0,
        message: "操作失败：#{reason}"
      })
  end
  
  {:noreply, socket}
end
```

### 前端交互增强

```javascript
// 批量操作相关的 JavaScript Hook
const BatchOperations = {
  mounted() {
    // 监听键盘快捷键
    document.addEventListener('keydown', (e) => {
      if (e.ctrlKey || e.metaKey) {
        switch(e.key) {
          case 'a':
            e.preventDefault();
            this.pushEvent('select_all');
            break;
          case 'd':
            e.preventDefault();
            this.pushEvent('batch_delete');
            break;
        }
      }
    });
  }
};
```

## 测试策略

### 单元测试
- 选择状态管理逻辑
- 批量操作配置解析
- 权限检查逻辑

### 集成测试
- 表格选择交互
- 批量操作执行流程
- 错误处理和恢复

### 端到端测试
- 完整的用户操作流程
- 跨页选择功能
- 性能测试（大数据量）

## 性能考虑

### 大数据量优化
1. **分页选择**：只在当前页面维护选择状态
2. **虚拟化**：大量数据时使用虚拟滚动
3. **批量操作分批**：大量操作时分批处理
4. **操作队列**：支持操作排队和取消

### 内存优化
1. **选择状态压缩**：使用 MapSet 而不是 List
2. **及时清理**：操作完成后及时清理状态
3. **状态持久化**：必要时将状态持久化到数据库

## 可访问性

### 键盘导航
- `Space`：切换当前行选择状态
- `Ctrl+A`：全选/取消全选
- `Delete`：删除选中项目（如果支持）
- `Tab`：在批量操作按钮间导航

### 屏幕阅读器支持
- 选择状态的语音提示
- 批量操作按钮的描述
- 操作进度的实时播报

### ARIA 属性
```html
<tr role="row" aria-selected="true">
<button aria-label="批量删除 3 个选中项目">
<div role="status" aria-live="polite">正在删除 3 个项目...</div>
```

## 安全考虑

### 权限验证
- 操作权限检查
- 数据访问权限验证
- 批量操作限制

### 操作审计
- 记录批量操作日志
- 用户操作追踪
- 数据变更记录

## 兼容性

### 浏览器兼容性
- 现代浏览器支持（Chrome 90+, Firefox 88+, Safari 14+）
- 渐进式降级策略
- 移动端适配

### 现有组件兼容性
- 与现有 Table 组件向后兼容
- 与 ActionButtons 组件集成
- 与 LiveView 生命周期兼容

## 国际化

### 多语言支持
```elixir
# 批量操作相关的翻译键
%{
  "batch_operations.select_all" => "全选",
  "batch_operations.selected_count" => "已选择 %{count} 项",
  "batch_operations.delete_confirm" => "确定要删除 %{count} 个项目吗？",
  "batch_operations.operation_success" => "操作成功完成",
  "batch_operations.operation_failed" => "操作失败：%{reason}"
}
```

## 发布计划

### 第一阶段（MVP）
- 基础选择功能
- 批量删除操作
- 基础操作反馈

### 第二阶段
- 批量导出功能
- 跨页选择
- 操作进度追踪

### 第三阶段
- 批量编辑功能
- 自定义批量操作
- 高级性能优化

## 参考资料

- [Ant Design Table Selection](https://ant.design/components/table#rowSelection)
- [Material-UI DataGrid Selection](https://mui.com/x/react-data-grid/selection/)
- [Phoenix LiveView Patterns](https://hexdocs.pm/phoenix_live_view/)
- [Web Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)