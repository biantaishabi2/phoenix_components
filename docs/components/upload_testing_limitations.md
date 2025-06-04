# Phoenix LiveView 文件上传测试限制说明

## 问题描述

在为 MediaUpload 组件编写测试时，我们发现 Phoenix LiveView 的测试框架在测试实际文件上传功能时存在一些限制。

## 具体限制

### 1. DOM 结构不匹配

Phoenix LiveView 的 `file_input/4` 测试函数期望找到标准的 HTML 文件输入元素：
```html
<input type="file" name="upload_name" />
```

但是 LiveView 的 `live_file_input/1` 组件实际上不生成传统的文件输入元素，而是使用 JavaScript 和 WebSocket 来处理文件上传。

### 2. 无法直接发送文件

虽然测试框架提供了 `file_input/4` 和 `render_upload/3` 函数，但它们依赖于特定的 DOM 结构，而这个结构在实际的 LiveView 组件中并不存在。

### 3. 测试框架的限制

当前的 Phoenix LiveView 测试框架主要通过模拟 DOM 交互来工作，但文件上传涉及到浏览器的原生 API 和二进制数据传输，这些在纯服务器端测试环境中难以完全模拟。

## 解决方案

### 1. 单元测试（推荐）

专注于测试可测试的部分：
- 组件渲染
- 表单提交逻辑
- 错误处理
- 状态管理

```elixir
# 测试空表单提交
test "验证空表单提交不显示成功消息", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/components/media_upload")
  
  result = view
           |> form("#product_images-form")
           |> render_submit()
  
  assert result =~ "请选择要上传的文件"
  refute result =~ "商品图片上传成功"
end
```

### 2. 集成测试

对于需要测试实际文件上传的场景，建议使用：
- Wallaby 或类似的端到端测试工具
- 使用真实浏览器环境的测试

### 3. 手动测试

某些功能可能需要通过手动测试来验证：
- 拖放上传
- 文件预览
- 上传进度显示
- 多文件选择

## 最佳实践

1. **分离关注点**：将文件处理逻辑与 UI 逻辑分开，使业务逻辑更容易测试。

2. **Mock 策略**：在测试中 mock 文件上传的结果，专注于测试组件的行为。

3. **文档化**：明确记录哪些功能通过自动化测试覆盖，哪些需要手动测试。

4. **持续关注**：Phoenix LiveView 正在不断改进，未来可能会提供更好的文件上传测试支持。

## 参考资源

- [Phoenix LiveView 文件上传文档](https://hexdocs.pm/phoenix_live_view/uploads.html)
- [Phoenix LiveView 测试文档](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
- [Wallaby 端到端测试](https://github.com/elixir-wallaby/wallaby)