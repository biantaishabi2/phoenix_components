# Phoenix LiveView 测试指南

## 概述

本指南总结了在 Phoenix LiveView 项目中编写测试的最佳实践，特别是组件测试和 LiveView 交互测试。这些经验来自于对 Pento 项目的分析和 Table 组件测试的调试过程。

## 一、常见问题与解决方案

### 1.1 为什么 `live_isolated` 不工作？

**问题**：
```elixir
{:ok, view, _html} = live_isolated(conn, MyComponent)
# 报错：function live_isolated/2 is undefined or private
```

**原因**：
- `live_isolated` 在新版本的 Phoenix LiveView 中已被移除
- 现代 Phoenix 项目推荐使用 `live()` 或 `render_component()`

**解决方案**：
- 使用 `live()` 测试完整的 LiveView
- 使用 `render_component()` 测试独立组件
- 创建专门的测试 LiveView 来承载被测试的组件

### 1.2 组件测试 vs LiveView 测试

**什么时候用组件测试**：
- 测试纯展示组件
- 测试组件的渲染逻辑
- 不需要测试事件处理

**什么时候用 LiveView 测试**：
- 测试用户交互
- 测试事件处理
- 测试状态变化
- 测试组件间通信

## 二、测试设置

### 2.1 基础设置

```elixir
# 对于组件测试
defmodule MyAppWeb.ComponentTest do
  use MyAppWeb.ComponentCase, async: true
  import Phoenix.LiveViewTest
  
  alias MyAppWeb.Components.MyComponent
end

# 对于 LiveView 测试
defmodule MyAppWeb.MyLiveTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest
end
```

### 2.2 ComponentCase 设置

如果项目中没有 ComponentCase，创建一个：

```elixir
defmodule MyAppWeb.ComponentCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.LiveViewTest
      import Phoenix.Component
      
      # 辅助函数：渲染组件并返回 HTML 字符串
      def rendered_to_string(assigns) do
        assigns
        |> rendered_to_iodata()
        |> IO.iodata_to_binary()
      end
    end
  end
end
```

## 三、测试模式

### 3.1 纯组件测试

适用于无状态、无事件处理的组件：

```elixir
test "renders basic component" do
  assigns = %{title: "Hello"}
  
  html = rendered_to_string(~H"""
    <MyComponent.card title={@title}>
      Content
    </MyComponent.card>
  """)
  
  assert html =~ "Hello"
  assert html =~ "Content"
end
```

### 3.2 带事件的组件测试

对于需要测试事件的组件，创建一个测试 LiveView：

```elixir
defmodule TestLive do
  use Phoenix.LiveView
  alias MyAppWeb.Components.Table

  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(
       items: [%{id: 1, name: "Item 1"}],
       selected: []
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <Table.table 
        id="test-table"
        rows={@items}
        selectable
        row_id={&(&1.id)}>
        <:col :let={item} label="Name">
          <%= item.name %>
        </:col>
      </Table.table>
      
      <p>Selected: <%= length(@selected) %></p>
    </div>
    """
  end

  def handle_event("select_row", %{"id" => id}, socket) do
    # 处理选择逻辑
    {:noreply, socket}
  end
end

# 测试
test "selection works", %{conn: conn} do
  {:ok, view, html} = live(conn, "/test")
  
  # 点击选择框
  view
  |> element("[phx-value-id='1'] input[type='checkbox']")
  |> render_click()
  
  assert render(view) =~ "Selected: 1"
end
```

### 3.3 使用 render_component 测试

对于简单组件，可以使用 `render_component`：

```elixir
test "renders component with render_component" do
  html = render_component(&MyComponent.tag/1, %{
    color: "success",
    inner_block: [%{inner_block: fn _, _ -> "Success" end}]
  })
  
  assert html =~ "Success"
  assert html =~ "success"
end
```

## 四、交互测试模式

### 4.1 点击事件

```elixir
# 基础点击
view
|> element("button[phx-click='save']")
|> render_click()

# 带参数的点击
view
|> element("[phx-click='delete'][phx-value-id='123']")
|> render_click()

# 使用 CSS 选择器
view
|> element("#my-button")
|> render_click()
```

### 4.2 表单提交

```elixir
# 表单变化
view
|> form("#user-form", user: %{name: "John"})
|> render_change()

# 表单提交
view
|> form("#user-form", user: %{name: "John", email: "john@example.com"})
|> render_submit()
```

### 4.3 JavaScript 钩子

```elixir
# 触发 JavaScript 钩子
view
|> render_hook("chart-loaded", %{"width" => 600, "height" => 400})

# 键盘事件
view
|> element("#search-input")
|> render_keydown(%{"key" => "Enter", "value" => "search term"})
```

### 4.4 实时推送事件

```elixir
# 发送消息给 LiveView 进程
send(view.pid, {:update_data, new_data})

# 等待异步更新
:timer.sleep(100)

# 验证更新
assert render(view) =~ "Updated content"
```

## 五、断言模式

### 5.1 内容断言

```elixir
# 基础内容检查
assert html =~ "Expected text"
refute html =~ "Should not exist"

# 使用 has_element?
assert has_element?(view, "#my-element")
assert has_element?(view, "[data-role='admin']")
refute has_element?(view, ".error-message")

# 检查特定元素的内容
assert view |> element("#title") |> render() =~ "Page Title"
```

### 5.2 属性断言

```elixir
# 检查属性存在
assert html =~ ~s(disabled)
assert html =~ ~s(data-id="123")

# 使用正则表达式
assert html =~ ~r/class="[^"]*active[^"]*"/
```

### 5.3 计数断言

```elixir
# 计算元素数量
checkbox_count = 
  html
  |> String.split(~s(type="checkbox"))
  |> length()
  |> Kernel.-(1)

assert checkbox_count == 5
```

## 六、测试组织最佳实践

### 6.1 测试辅助函数

```elixir
defmodule MyAppWeb.TestHelpers do
  import Phoenix.LiveViewTest

  def click_button(view, text) do
    view
    |> element("button", text)
    |> render_click()
  end

  def fill_form(view, form_id, data) do
    view
    |> form("##{form_id}", data)
    |> render_submit()
  end

  def select_row(view, row_id) do
    view
    |> element("[data-row-id='#{row_id}'] input[type='checkbox']")
    |> render_click()
  end
end
```

### 6.2 测试数据构建

```elixir
defmodule MyAppWeb.TestFixtures do
  def product_fixture(attrs \\ %{}) do
    %{
      id: System.unique_integer([:positive]),
      name: "Product #{System.unique_integer([:positive])}",
      price: 100,
      stock: 10
    }
    |> Map.merge(attrs)
  end

  def order_fixture(attrs \\ %{}) do
    %{
      id: System.unique_integer([:positive]),
      order_no: "ORD#{System.unique_integer([:positive])}",
      status: "pending",
      amount: 1000
    }
    |> Map.merge(attrs)
  end
end
```

### 6.3 分组测试

```elixir
describe "table component" do
  setup do
    products = Enum.map(1..5, &product_fixture(id: &1))
    %{products: products}
  end

  describe "rendering" do
    test "renders all products", %{products: products} do
      # 测试渲染
    end
  end

  describe "selection" do
    test "selects individual rows", %{conn: conn, products: products} do
      # 测试选择
    end

    test "selects all rows", %{conn: conn, products: products} do
      # 测试全选
    end
  end

  describe "pagination" do
    # 分页相关测试
  end
end
```

## 七、调试技巧

### 7.1 打印 HTML 输出

```elixir
test "debug rendering" do
  html = render(view)
  IO.puts("=== HTML OUTPUT ===")
  IO.puts(html)
  IO.puts("==================")
end
```

### 7.2 使用 open_browser

```elixir
test "visual debugging", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/my-page")
  
  # 在浏览器中打开当前状态
  open_browser(view)
  
  # 执行一些操作后再次查看
  view |> element("button") |> render_click()
  open_browser(view)
end
```

### 7.3 检查 LiveView 状态

```elixir
test "inspect socket assigns" do
  {:ok, view, _html} = live(conn, "/my-page")
  
  # 发送自定义消息来检查状态
  send(view.pid, :inspect_state)
  
  # 在 LiveView 中处理
  def handle_info(:inspect_state, socket) do
    IO.inspect(socket.assigns, label: "Socket assigns")
    {:noreply, socket}
  end
end
```

## 八、性能测试

### 8.1 测试大数据集

```elixir
test "handles large datasets efficiently" do
  items = Enum.map(1..1000, &item_fixture/1)
  
  {time, result} = :timer.tc(fn ->
    render_component(&Table.table/1, %{
      id: "large-table",
      rows: items,
      # ... 其他属性
    })
  end)
  
  # 时间应该在合理范围内（微秒）
  assert time < 1_000_000  # 1秒
end
```

### 8.2 测试快速交互

```elixir
test "handles rapid clicks" do
  {:ok, view, _html} = live(conn, "/my-page")
  
  # 快速点击 10 次
  for _ <- 1..10 do
    view
    |> element("#counter-button")
    |> render_click()
  end
  
  # 验证状态正确
  assert render(view) =~ "Count: 10"
end
```

## 九、常见错误和解决方案

### 9.1 "No route found for GET /test"

**解决**：为测试创建临时路由或使用 `live_isolated`（如果可用）

### 9.2 "undefined function render_component/2"

**解决**：确保导入了 `Phoenix.LiveViewTest`

### 9.3 "could not find element"

**解决**：
- 检查选择器语法
- 确保元素已渲染
- 使用 `IO.puts` 打印 HTML 调试

### 9.4 "function MyComponent.component/1 is undefined"

**解决**：
- 确保正确导入或别名组件模块
- 检查函数名拼写

## 十、迁移指南

### 10.1 从 live_isolated 迁移

旧代码：
```elixir
{:ok, view, _html} = live_isolated(conn, MyComponent, 
  session: %{"user_id" => user.id}
)
```

新代码：
```elixir
# 选项 1：创建测试 LiveView
defmodule TestLive do
  use Phoenix.LiveView
  
  def render(assigns) do
    ~H"""
    <MyComponent.component {@attrs} />
    """
  end
end

{:ok, view, _html} = live(conn, "/test")

# 选项 2：使用 render_component（仅适用于无状态组件）
html = render_component(&MyComponent.component/1, %{...})
```

### 10.2 测试事件处理

如果组件有事件处理，必须通过 LiveView 测试：

```elixir
# 不能这样做
render_component(&Table.table/1, %{on_click: ...})

# 应该这样做
defmodule TableTestLive do
  # ... LiveView 实现
  
  def handle_event("table_click", params, socket) do
    # 处理事件
  end
end
```

## 十一、总结

1. **优先使用 `render_component`** 测试简单组件
2. **创建测试 LiveView** 来测试复杂交互
3. **避免使用 `live_isolated`**（已弃用）
4. **编写辅助函数** 来简化测试
5. **分组组织测试** 提高可读性
6. **使用 `open_browser`** 进行可视化调试

记住：好的测试应该清晰、独立、可重复。遵循这些模式可以确保测试既全面又易于维护。