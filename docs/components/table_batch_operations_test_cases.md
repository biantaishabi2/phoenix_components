# 表格批量操作功能测试用例文档

## 测试概览

本文档定义了表格批量操作功能的完整测试用例，包括功能测试、集成测试、性能测试和可访问性测试。

## 测试环境

### 测试数据准备
```elixir
# 测试用的产品数据
@test_products [
  %{id: 1, name: "iPhone 15", category: "手机", price: 5999, status: "active"},
  %{id: 2, name: "iPad Pro", category: "平板", price: 8999, status: "active"}, 
  %{id: 3, name: "MacBook", category: "电脑", price: 12999, status: "inactive"},
  %{id: 4, name: "Apple Watch", category: "手表", price: 2999, status: "active"},
  %{id: 5, name: "AirPods", category: "音频", price: 1299, status: "inactive"}
]

# 大量数据测试（性能测试用）
@large_dataset 1..1000 |> Enum.map(fn i -> 
  %{id: i, name: "Product #{i}", category: "Category #{rem(i, 10)}", 
    price: 100 + i, status: if(rem(i, 2) == 0, do: "active", else: "inactive")}
end)
```

## 单元测试

### 1. 选择状态管理测试

#### 1.1 单行选择测试
```elixir
describe "single row selection" do
  test "selects a single row" do
    assigns = %{products: @test_products, selected_ids: MapSet.new()}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击第一行的选择框
    view
    |> element("[data-testid='row-checkbox-1']")
    |> render_click()
    
    # 验证选择状态
    assert view |> has_element?("[data-testid='row-checkbox-1'][checked]")
    assert view |> element("#selection-info") |> render() =~ "已选择 1 项"
  end
  
  test "deselects a selected row" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击已选择的行取消选择
    view
    |> element("[data-testid='row-checkbox-1']")
    |> render_click()
    
    # 验证取消选择状态
    refute view |> has_element?("[data-testid='row-checkbox-1'][checked]")
    assert view |> element("#selection-info") |> render() =~ "已选择 0 项"
  end
  
  test "supports multiple row selection" do
    assigns = %{products: @test_products, selected_ids: MapSet.new()}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 选择多行
    view |> element("[data-testid='row-checkbox-1']") |> render_click()
    view |> element("[data-testid='row-checkbox-2']") |> render_click()
    view |> element("[data-testid='row-checkbox-3']") |> render_click()
    
    # 验证多选状态
    assert view |> has_element?("[data-testid='row-checkbox-1'][checked]")
    assert view |> has_element?("[data-testid='row-checkbox-2'][checked]")  
    assert view |> has_element?("[data-testid='row-checkbox-3'][checked]")
    assert view |> element("#selection-info") |> render() =~ "已选择 3 项"
  end
end
```

#### 1.2 全选功能测试
```elixir
describe "select all functionality" do
  test "selects all rows on current page" do
    assigns = %{products: @test_products, selected_ids: MapSet.new()}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击全选复选框
    view
    |> element("[data-testid='select-all-checkbox']")
    |> render_click()
    
    # 验证所有行都被选中
    for i <- 1..5 do
      assert view |> has_element?("[data-testid='row-checkbox-#{i}'][checked]")
    end
    assert view |> element("#selection-info") |> render() =~ "已选择 5 项"
  end
  
  test "deselects all rows when all are selected" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2, 3, 4, 5])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击全选复选框取消全选
    view
    |> element("[data-testid='select-all-checkbox']")
    |> render_click()
    
    # 验证所有行都被取消选择
    for i <- 1..5 do
      refute view |> has_element?("[data-testid='row-checkbox-#{i}'][checked]")
    end
    assert view |> element("#selection-info") |> render() =~ "已选择 0 项"
  end
  
  test "shows indeterminate state when some rows are selected" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 3])}
    
    {:ok, view, html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证全选复选框处于中间状态
    assert html =~ ~r/select-all-checkbox.*indeterminate/
    assert view |> element("#selection-info") |> render() =~ "已选择 2 项"
  end
end
```

### 2. 批量操作按钮状态测试

#### 2.1 按钮显示/隐藏测试
```elixir
describe "batch operation buttons" do
  test "hides batch operation buttons when no items selected" do
    assigns = %{products: @test_products, selected_ids: MapSet.new()}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证批量操作按钮不可见或被禁用
    refute view |> has_element?("[data-testid='batch-delete-btn']:not([disabled])")
    refute view |> has_element?("[data-testid='batch-export-btn']:not([disabled])")
  end
  
  test "shows batch operation buttons when items are selected" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证批量操作按钮可见且可用
    assert view |> has_element?("[data-testid='batch-delete-btn']:not([disabled])")
    assert view |> has_element?("[data-testid='batch-export-btn']:not([disabled])")
  end
  
  test "updates button text with selection count" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2, 3])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证按钮文本包含选择数量
    assert view |> element("[data-testid='batch-delete-btn']") |> render() =~ "批量删除 (3)"
    assert view |> element("[data-testid='batch-export-btn']") |> render() =~ "批量导出 (3)"
  end
end
```

### 3. 选择限制测试

#### 3.1 最大选择数量限制测试
```elixir
describe "selection limits" do
  test "enforces maximum selection limit" do
    assigns = %{
      products: @test_products, 
      selected_ids: MapSet.new(), 
      max_selection: 3
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 选择到最大数量
    view |> element("[data-testid='row-checkbox-1']") |> render_click()
    view |> element("[data-testid='row-checkbox-2']") |> render_click()
    view |> element("[data-testid='row-checkbox-3']") |> render_click()
    
    # 验证达到最大选择数量
    assert view |> element("#selection-info") |> render() =~ "已选择 3 项"
    
    # 尝试选择第四个项目应该被阻止或显示警告
    view |> element("[data-testid='row-checkbox-4']") |> render_click()
    
    # 验证选择数量没有超过限制
    assert view |> element("#selection-info") |> render() =~ "已选择 3 项"
    assert view |> has_element?("[data-testid='selection-limit-warning']")
  end
  
  test "disables checkboxes when limit is reached" do
    assigns = %{
      products: @test_products,
      selected_ids: MapSet.new([1, 2]),
      max_selection: 2
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证未选择的复选框被禁用
    assert view |> has_element?("[data-testid='row-checkbox-3'][disabled]")
    assert view |> has_element?("[data-testid='row-checkbox-4'][disabled]")
    assert view |> has_element?("[data-testid='row-checkbox-5'][disabled]")
    
    # 验证已选择的复选框仍可用（用于取消选择）
    refute view |> has_element?("[data-testid='row-checkbox-1'][disabled]")
    refute view |> has_element?("[data-testid='row-checkbox-2'][disabled]")
  end
end
```

## 集成测试

### 4. 批量操作执行测试

#### 4.1 批量删除测试
```elixir
describe "batch delete operation" do
  test "successfully deletes selected items" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 3, 5])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击批量删除按钮
    view
    |> element("[data-testid='batch-delete-btn']")
    |> render_click()
    
    # 验证确认对话框出现
    assert view |> has_element?("[data-testid='delete-confirmation']")
    assert view |> element("[data-testid='delete-confirmation']") |> render() =~ "确定要删除 3 个项目吗？"
    
    # 确认删除
    view
    |> element("[data-testid='confirm-delete-btn']")
    |> render_click()
    
    # 验证删除成功
    assert view |> has_element?("[data-testid='success-message']")
    assert view |> element("#selection-info") |> render() =~ "已选择 0 项"
    
    # 验证数据已从表格中移除
    refute view |> has_element?("[data-testid='row-1']")
    refute view |> has_element?("[data-testid='row-3']")
    refute view |> has_element?("[data-testid='row-5']")
  end
  
  test "cancels batch delete operation" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击批量删除按钮
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    
    # 取消删除
    view |> element("[data-testid='cancel-delete-btn']") |> render_click()
    
    # 验证取消后状态不变
    assert view |> element("#selection-info") |> render() =~ "已选择 2 项"
    assert view |> has_element?("[data-testid='row-1']")
    assert view |> has_element?("[data-testid='row-2']")
  end
  
  test "handles batch delete errors gracefully" do
    # 模拟删除失败的情况
    assigns = %{
      products: @test_products, 
      selected_ids: MapSet.new([1]), 
      delete_should_fail: true
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 验证错误处理
    assert view |> has_element?("[data-testid='error-message']")
    assert view |> element("[data-testid='error-message']") |> render() =~ "删除失败"
    
    # 验证选择状态保持不变
    assert view |> element("#selection-info") |> render() =~ "已选择 1 项"
  end
end
```

#### 4.2 批量导出测试
```elixir
describe "batch export operation" do
  test "exports selected items successfully" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([2, 4])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击批量导出按钮
    view
    |> element("[data-testid='batch-export-btn']")
    |> render_click()
    
    # 验证导出选项对话框
    assert view |> has_element?("[data-testid='export-options']")
    
    # 选择导出格式并确认
    view |> element("[data-testid='export-format-csv']") |> render_click()
    view |> element("[data-testid='confirm-export-btn']") |> render_click()
    
    # 验证导出成功
    assert view |> has_element?("[data-testid='export-success']")
    assert view |> element("[data-testid='export-success']") |> render() =~ "导出完成"
    
    # 验证下载链接
    assert view |> has_element?("[data-testid='download-link']")
  end
  
  test "supports different export formats" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2, 3])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    view |> element("[data-testid='batch-export-btn']") |> render_click()
    
    # 验证支持的导出格式
    assert view |> has_element?("[data-testid='export-format-csv']")
    assert view |> has_element?("[data-testid='export-format-excel']")
    assert view |> has_element?("[data-testid='export-format-pdf']")
  end
end
```

#### 4.3 批量状态更改测试
```elixir
describe "batch status change operation" do
  test "changes status of selected items" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([3, 5])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 点击批量状态更改按钮
    view |> element("[data-testid='batch-status-btn']") |> render_click()
    
    # 选择新状态
    view |> element("[data-testid='status-active']") |> render_click()
    view |> element("[data-testid='confirm-status-btn']") |> render_click()
    
    # 验证状态更改成功
    assert view |> has_element?("[data-testid='success-message']")
    
    # 验证表格中的状态已更新
    assert view |> element("[data-testid='row-3-status']") |> render() =~ "活跃"
    assert view |> element("[data-testid='row-5-status']") |> render() =~ "活跃"
  end
end
```

### 5. 跨页选择测试

#### 5.1 分页环境下的选择测试
```elixir
describe "selection across pages" do
  test "maintains selection when navigating between pages" do
    assigns = %{
      products: @large_dataset,
      pagination: %{current: 1, page_size: 10, total: 1000},
      selected_ids: MapSet.new(),
      selection_across_pages: true
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 第一页选择几个项目
    view |> element("[data-testid='row-checkbox-1']") |> render_click()
    view |> element("[data-testid='row-checkbox-3']") |> render_click()
    
    # 切换到第二页
    view |> element("[data-testid='page-2-btn']") |> render_click()
    
    # 第二页也选择几个项目
    view |> element("[data-testid='row-checkbox-11']") |> render_click()
    view |> element("[data-testid='row-checkbox-13']") |> render_click()
    
    # 验证总选择数量
    assert view |> element("#selection-info") |> render() =~ "已选择 4 项"
    
    # 回到第一页，验证选择状态保持
    view |> element("[data-testid='page-1-btn']") |> render_click()
    assert view |> has_element?("[data-testid='row-checkbox-1'][checked]")
    assert view |> has_element?("[data-testid='row-checkbox-3'][checked]")
  end
  
  test "provides select all items across all pages option" do
    assigns = %{
      products: @large_dataset,
      pagination: %{current: 1, page_size: 10, total: 1000},
      selected_ids: MapSet.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
      selection_across_pages: true
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证"选择全部1000项"选项出现
    assert view |> has_element?("[data-testid='select-all-pages']")
    assert view |> element("[data-testid='select-all-pages']") |> render() =~ "选择全部 1000 项"
    
    # 点击选择全部
    view |> element("[data-testid='select-all-pages']") |> render_click()
    
    # 验证全选状态
    assert view |> element("#selection-info") |> render() =~ "已选择 1000 项"
  end
end
```

### 6. 操作进度和反馈测试

#### 6.1 操作进度测试
```elixir
describe "operation progress" do
  test "shows progress during batch operations" do
    assigns = %{
      products: @large_dataset[1..100],
      selected_ids: MapSet.new(1..50),
      simulate_slow_operation: true
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 开始批量删除
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 验证进度条出现
    assert view |> has_element?("[data-testid='operation-progress']")
    assert view |> has_element?("[data-testid='progress-bar']")
    
    # 验证进度消息
    assert view |> element("[data-testid='progress-message']") |> render() =~ "正在删除"
    
    # 等待操作完成
    :timer.sleep(100)
    
    # 验证完成状态
    assert view |> has_element?("[data-testid='operation-complete']")
    assert view |> element("[data-testid='operation-complete']") |> render() =~ "删除完成"
  end
  
  test "allows canceling ongoing operations" do
    assigns = %{
      products: @large_dataset[1..100],
      selected_ids: MapSet.new(1..50),
      simulate_slow_operation: true
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 开始批量操作
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 验证取消按钮可用
    assert view |> has_element?("[data-testid='cancel-operation-btn']")
    
    # 取消操作
    view |> element("[data-testid='cancel-operation-btn']") |> render_click()
    
    # 验证操作被取消
    assert view |> has_element?("[data-testid='operation-cancelled']")
    refute view |> has_element?("[data-testid='operation-progress']")
  end
end
```

## 性能测试

### 7. 大数据量测试

#### 7.1 大量数据选择性能测试
```elixir
describe "large dataset performance" do
  test "handles selection of 1000+ items efficiently" do
    large_products = Enum.map(1..1000, fn i ->
      %{id: i, name: "Product #{i}", category: "Category", price: 100, status: "active"}
    end)
    
    assigns = %{products: large_products, selected_ids: MapSet.new()}
    
    start_time = System.monotonic_time(:millisecond)
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 全选操作
    view |> element("[data-testid='select-all-checkbox']") |> render_click()
    
    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time
    
    # 验证操作在合理时间内完成（< 500ms）
    assert duration < 500
    assert view |> element("#selection-info") |> render() =~ "已选择 1000 项"
  end
  
  test "efficiently processes batch operations on large datasets" do
    large_products = Enum.map(1..500, fn i ->
      %{id: i, name: "Product #{i}", category: "Category", price: 100, status: "active"}
    end)
    
    assigns = %{
      products: large_products,
      selected_ids: MapSet.new(1..500)
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    start_time = System.monotonic_time(:millisecond)
    
    # 执行批量删除
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 等待操作完成
    assert_receive {:batch_operation_complete, _}, 5000
    
    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time
    
    # 验证大量数据操作在合理时间内完成（< 3s）
    assert duration < 3000
  end
end
```

## 可访问性测试

### 8. 键盘导航测试

#### 8.1 键盘操作测试
```elixir
describe "keyboard accessibility" do
  test "supports keyboard navigation for selection" do
    assigns = %{products: @test_products, selected_ids: MapSet.new()}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 模拟键盘事件 - Space键选择当前行
    view
    |> element("[data-testid='table-body']")
    |> render_hook("keydown", %{"key" => " ", "target_row" => "1"})
    
    # 验证行被选中
    assert view |> has_element?("[data-testid='row-checkbox-1'][checked]")
    
    # Ctrl+A 全选
    view
    |> element("[data-testid='table-body']") 
    |> render_hook("keydown", %{"key" => "a", "ctrlKey" => true})
    
    # 验证全选
    assert view |> element("#selection-info") |> render() =~ "已选择 5 项"
  end
  
  test "supports keyboard shortcuts for batch operations" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # Delete键触发批量删除
    view
    |> element("[data-testid='table-body']")
    |> render_hook("keydown", %{"key" => "Delete"})
    
    # 验证删除确认对话框出现
    assert view |> has_element?("[data-testid='delete-confirmation']")
  end
end
```

### 9. 屏幕阅读器支持测试

#### 9.1 ARIA 属性测试
```elixir
describe "screen reader support" do
  test "provides proper ARIA attributes for selection state" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 3])}
    
    {:ok, view, html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 验证表格具有正确的ARIA属性
    assert html =~ ~r/role="grid"/
    assert html =~ ~r/aria-multiselectable="true"/
    
    # 验证选中行的ARIA属性
    assert html =~ ~r/data-testid="row-1".*aria-selected="true"/
    assert html =~ ~r/data-testid="row-3".*aria-selected="true"/
    assert html =~ ~r/data-testid="row-2".*aria-selected="false"/
    
    # 验证批量操作按钮的ARIA标签
    assert html =~ ~r/aria-label="批量删除 2 个选中项目"/
  end
  
  test "announces selection changes to screen readers" do
    assigns = %{products: @test_products, selected_ids: MapSet.new()}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 选择一行
    view |> element("[data-testid='row-checkbox-1']") |> render_click()
    
    # 验证状态公告区域
    assert view |> has_element?("[aria-live='polite']")
    assert view |> element("[aria-live='polite']") |> render() =~ "已选择 1 项"
  end
end
```

## 错误处理测试

### 10. 边界条件和错误场景测试

#### 10.1 网络错误处理测试
```elixir
describe "error handling" do
  test "handles network failures during batch operations" do
    assigns = %{
      products: @test_products,
      selected_ids: MapSet.new([1, 2]),
      simulate_network_error: true
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 尝试批量删除（会失败）
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 验证错误处理
    assert view |> has_element?("[data-testid='network-error']")
    assert view |> element("[data-testid='network-error']") |> render() =~ "网络连接失败"
    
    # 验证重试按钮
    assert view |> has_element?("[data-testid='retry-btn']")
    
    # 验证选择状态保持
    assert view |> element("#selection-info") |> render() =~ "已选择 2 项"
  end
  
  test "handles partial operation failures" do
    assigns = %{
      products: @test_products,
      selected_ids: MapSet.new([1, 2, 3]),
      simulate_partial_failure: [2] # 第2项删除失败
    }
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 验证部分成功的结果
    assert view |> has_element?("[data-testid='partial-success']")
    assert view |> element("[data-testid='partial-success']") |> render() =~ "2 项删除成功，1 项失败"
    
    # 验证失败项目仍在选择中
    assert view |> has_element?("[data-testid='row-checkbox-2'][checked]")
    refute view |> has_element?("[data-testid='row-1']")
    refute view |> has_element?("[data-testid='row-3']")
  end
end
```

#### 10.2 数据状态不一致处理测试
```elixir
describe "data consistency" do
  test "handles items deleted by other users during selection" do
    assigns = %{products: @test_products, selected_ids: MapSet.new([1, 2, 3])}
    
    {:ok, view, _html} = live_isolated(conn, TestTableLive, session: %{assigns: assigns})
    
    # 模拟其他用户删除了第2项
    send(view.pid, {:external_deletion, 2})
    
    # 尝试批量操作
    view |> element("[data-testid='batch-delete-btn']") |> render_click()
    view |> element("[data-testid='confirm-delete-btn']") |> render_click()
    
    # 验证处理已删除项目的情况
    assert view |> has_element?("[data-testid='item-not-found-warning']")
    assert view |> element("[data-testid='item-not-found-warning']") |> render() =~ "1 项已被删除"
    
    # 验证其余项目正常处理
    assert view |> element("#selection-info") |> render() =~ "已选择 0 项"
  end
end
```

## 测试运行指令

### 运行所有批量操作测试
```bash
# 运行所有批量操作相关测试
mix test test/shop_ux_phoenix_web/components/table_batch_operations_test.exs

# 运行特定测试组
mix test test/shop_ux_phoenix_web/components/table_batch_operations_test.exs --grep "selection"
mix test test/shop_ux_phoenix_web/components/table_batch_operations_test.exs --grep "batch delete"

# 运行性能测试
mix test test/shop_ux_phoenix_web/components/table_batch_operations_test.exs --grep "performance"

# 运行可访问性测试
mix test test/shop_ux_phoenix_web/components/table_batch_operations_test.exs --grep "accessibility"
```

### 测试覆盖率要求

- **功能覆盖率**: >= 95%
- **分支覆盖率**: >= 90%
- **行覆盖率**: >= 95%

### 测试数据清理

每个测试后需要清理：
- 重置选择状态
- 清除模拟数据
- 重置操作状态
- 清理事件监听器

## 测试维护

### 定期检查项目
1. **性能基准更新**：随着数据量增长更新性能基准
2. **浏览器兼容性**：定期在不同浏览器中验证
3. **可访问性标准**：跟进最新的WCAG标准
4. **用户体验**：根据用户反馈调整测试用例

### 测试环境配置
```elixir
# test/support/table_test_helper.ex
defmodule ShopUxPhoenixWeb.TableTestHelper do
  def setup_test_data(context) do
    # 准备测试数据
  end
  
  def cleanup_test_data(context) do
    # 清理测试数据
  end
  
  def assert_accessibility(view) do
    # 可访问性断言
  end
  
  def measure_performance(operation) do
    # 性能测量
  end
end
```