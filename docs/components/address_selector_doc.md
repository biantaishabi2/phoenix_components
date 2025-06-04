# AddressSelector 地址选择器组件

## 组件概述

AddressSelector 组件是一个用于选择省市区三级地址的级联选择器。它提供了中国地区的标准化地址选择功能，支持动态加载地址数据、搜索过滤、自定义字段映射等功能。

## 特性

- 支持省市区三级联动
- 支持动态加载地址数据
- 支持搜索过滤
- 支持自定义字段映射
- 支持默认值设置
- 支持禁用特定地区
- 支持详细地址输入
- 内置常用地址数据

## API

### 属性 (Attributes)

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| id | string | - | 元素 ID |
| name | string | - | 表单字段名称 |
| value | list | [] | 选中的地址值 [省code, 市code, 区code] |
| placeholder | string | "请选择省/市/区" | 占位文本 |
| size | string | "medium" | 尺寸，可选值："small", "medium", "large" |
| disabled | boolean | false | 是否禁用 |
| searchable | boolean | true | 是否可搜索 |
| clearable | boolean | true | 是否可清除 |
| options | list | [] | 地址数据，如果为空则使用内置数据 |
| field_names | map | - | 自定义字段名映射 |
| load_data | function | nil | 动态加载数据的函数 |
| show_detail | boolean | false | 是否显示详细地址输入框 |
| detail_value | string | "" | 详细地址值 |
| detail_placeholder | string | "请输入详细地址" | 详细地址占位文本 |
| required | boolean | false | 是否必填 |
| error | string | nil | 错误提示信息 |
| class | string | "" | 自定义 CSS 类 |
| rest | global | - | 其他 HTML 属性 |

### 事件 (Events)

| 事件名 | 说明 | 回调参数 |
|--------|------|----------|
| change | 选择地址时触发 | {value: [省, 市, 区], labels: [省名, 市名, 区名]} |
| detail-change | 详细地址改变时触发 | {detail: string} |
| clear | 清除选择时触发 | - |

### 插槽 (Slots)

| 插槽名 | 说明 |
|--------|------|
| label | 自定义标签内容 |
| error | 自定义错误提示 |

## 使用示例

### 基础用法

```elixir
<.form for={@form} phx-submit="save">
  <.address_selector 
    field={@form[:address]}
    placeholder="请选择地址"
  />
</.form>
```

### 带详细地址

```elixir
<.address_selector 
  value={@address_codes}
  show_detail={true}
  detail_value={@detail_address}
  on_change="address_changed"
  on_detail_change="detail_changed"
/>
```

### 自定义数据源

```elixir
<.address_selector 
  options={@custom_locations}
  field_names=%{
    value: "code",
    label: "name",
    children: "districts"
  }
/>
```

### 动态加载数据

```elixir
<.address_selector 
  load_data={&load_address_data/1}
  searchable={true}
/>

# LiveView 中的处理函数
def load_address_data(parent_code) do
  # 根据父级编码加载子级数据
  case AddressService.get_children(parent_code) do
    {:ok, children} -> children
    _ -> []
  end
end
```

### 表单验证

```elixir
<.form for={@form} phx-submit="save" phx-change="validate">
  <.field
    field={@form[:address]}
    label="所在地区"
    required={true}
  >
    <.address_selector 
      field={@form[:address]}
      required={true}
      error={@form.errors[:address]}
    />
  </.field>
  
  <.field
    field={@form[:detail_address]}
    label="详细地址"
  >
    <.input 
      field={@form[:detail_address]}
      placeholder="请输入街道、门牌号等"
    />
  </.field>
</.form>
```

### 禁用特定地区

```elixir
<.address_selector 
  options={@locations}
  disabled_values={["110000", "120000"]} # 禁用北京、天津
/>
```

### 完整示例

```elixir
defmodule MyAppWeb.AddressFormLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:address_codes, [])
     |> assign(:detail_address, "")
     |> assign(:locations, load_locations())}
  end
  
  def handle_event("address_changed", %{"value" => codes, "labels" => labels}, socket) do
    {:noreply,
     socket
     |> assign(:address_codes, codes)
     |> put_flash(:info, "选择了: #{Enum.join(labels, " - ")}")}
  end
  
  def handle_event("detail_changed", %{"detail" => detail}, socket) do
    {:noreply, assign(socket, :detail_address, detail)}
  end
  
  def handle_event("save", %{"address" => address_data}, socket) do
    # 保存地址信息
    case save_address(address_data) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "地址保存成功")}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "保存失败")}
    end
  end
  
  defp load_locations do
    # 加载地址数据
    [
      %{
        value: "110000",
        label: "北京市",
        children: [
          %{
            value: "110100",
            label: "北京市",
            children: [
              %{value: "110101", label: "东城区"},
              %{value: "110102", label: "西城区"},
              # ...
            ]
          }
        ]
      },
      # ... 其他省份
    ]
  end
end
```

## 内置地址数据

组件内置了中国省市区的基础数据，包括：
- 34个省级行政区（省、直辖市、自治区、特别行政区）
- 300+个地级市
- 2800+个区县

数据格式示例：
```elixir
[
  %{
    value: "110000",
    label: "北京市",
    children: [
      %{
        value: "110100", 
        label: "北京市",
        children: [
          %{value: "110101", label: "东城区"},
          %{value: "110102", label: "西城区"},
          # ...
        ]
      }
    ]
  }
]
```

## 与 Vue 版本的对比

| Vue/Ant Design | Phoenix | 说明 |
|----------------|---------|------|
| `<a-cascader>` | `<.address_selector>` | 组件名称 |
| `:options` | `options` | 数据源 |
| `v-model` | `value` | 选中值 |
| `@change` | `phx-change` | 变更事件 |
| `fieldNames` | `field_names` | 字段映射 |

## 样式定制

组件支持通过 CSS 变量定制样式：

```css
/* 自定义样式变量 */
.address-selector {
  --selector-height: 36px;
  --selector-font-size: 14px;
  --selector-border-color: #d9d9d9;
  --selector-hover-border-color: #40a9ff;
  --selector-focus-border-color: #40a9ff;
}
```

## 最佳实践

1. **数据加载**：对于大量地址数据，建议使用动态加载而非一次性加载全部数据
2. **缓存策略**：地址数据相对稳定，建议在客户端或服务端进行缓存
3. **验证规则**：配合表单验证，确保用户选择完整的地址信息
4. **用户体验**：提供搜索功能，让用户快速找到目标地址
5. **默认值**：根据用户位置或历史记录设置合理的默认值

## 注意事项

1. 地址编码使用国家标准的行政区划代码
2. 支持港澳台地区的选择
3. 详细地址建议限制最大长度（如200字符）
4. 考虑移动端的使用体验，可能需要不同的交互方式