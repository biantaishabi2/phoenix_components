# InputNumber 数字输入框组件

## 概述
InputNumber 是一个数字输入框组件，通过鼠标或键盘输入范围内的数值。相比普通的 input，它提供了更好的数字输入体验，包括步进器按钮、精度控制、范围限制等功能。

## 何时使用
- 当需要用户输入数字时，尤其是有明确范围或精度要求的数字
- 需要提供快速增减数值的场景（如购物车数量、价格设置等）
- 需要格式化显示数字（如货币、百分比等）

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| id | 输入框唯一标识 | string | 必需 | 1.0 |
| name | 表单字段名 | string | - | 1.0 |
| value | 当前值 | number | nil | 1.0 |
| min | 最小值 | number | nil | 1.0 |
| max | 最大值 | number | nil | 1.0 |
| step | 每次改变步数 | number | 1 | 1.0 |
| precision | 数值精度（小数位数） | integer | nil | 1.0 |
| placeholder | 占位文字 | string | "" | 1.0 |
| disabled | 是否禁用 | boolean | false | 1.0 |
| readonly | 是否只读 | boolean | false | 1.0 |
| size | 尺寸 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| controls | 是否显示增减按钮 | boolean | true | 1.0 |
| keyboard | 是否启用键盘快捷键 | boolean | true | 1.0 |
| formatter | 格式化显示函数 | function | - | 1.0 |
| parser | 解析输入值函数 | function | - | 1.0 |
| class | 自定义CSS类 | string | "" | 1.0 |
| on_change | 值改变时的回调 | JS | - | 1.0 |
| on_focus | 获得焦点时的回调 | JS | - | 1.0 |
| on_blur | 失去焦点时的回调 | JS | - | 1.0 |
| prefix | 前缀图标或文字 | slot | - | 1.0 |
| suffix | 后缀图标或文字 | slot | - | 1.0 |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | text-sm, h-8 |
| medium | 中等尺寸(默认) | text-sm, h-10 |
| large | 大尺寸 | text-base, h-12 |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 焦点和激活状态 |
| info | 信息色 | 信息类输入 |
| success | 成功色 | 成功状态输入 |
| warning | 警告色 | 警告状态输入 |
| danger | 危险色 | 错误状态输入 |

### 键盘快捷键
- `↑` - 增加一个步长
- `↓` - 减少一个步长
- `Ctrl/Cmd + ↑` - 增加十个步长
- `Ctrl/Cmd + ↓` - 减少十个步长

## 代码示例

### 基础用法
```heex
<.input_number 
  id="basic-number"
  name="quantity"
  value={1}
  min={1}
  max={10}
/>
```

### 设置精度
```heex
<!-- 保留两位小数 -->
<.input_number 
  id="price-input"
  name="price"
  value={99.99}
  precision={2}
  step={0.01}
/>

<!-- 整数输入 -->
<.input_number 
  id="age-input"
  name="age"
  value={18}
  precision={0}
  min={0}
  max={150}
/>
```

### 设置步长
```heex
<!-- 每次增减0.1 -->
<.input_number 
  id="rate-input"
  name="rate"
  value={0.5}
  min={0}
  max={1}
  step={0.1}
  precision={1}
/>

<!-- 每次增减5 -->
<.input_number 
  id="score-input"
  name="score"
  value={60}
  min={0}
  max={100}
  step={5}
/>
```

### 格式化展示
```heex
<!-- 货币格式 -->
<.input_number 
  id="currency-input"
  name="amount"
  value={1000}
  precision={2}
  formatter={&("¥ #{&1}")}
  parser={&(String.replace(&1, ~r/\¥\s?|(,*)/g, ""))}
>
  <:prefix>¥</:prefix>
</.input_number>

<!-- 百分比格式 -->
<.input_number 
  id="percent-input"
  name="percent"
  value={50}
  min={0}
  max={100}
  formatter={&("#{&1}%")}
  parser={&(String.replace(&1, "%", ""))}
>
  <:suffix>%</:suffix>
</.input_number>
```

### 带前缀和后缀
```heex
<!-- 带图标前缀 -->
<.input_number 
  id="price-with-icon"
  name="price"
  value={99}
  precision={2}
>
  <:prefix>
    <.icon name="hero-currency-dollar" class="w-4 h-4 text-gray-400" />
  </:prefix>
</.input_number>

<!-- 带单位后缀 -->
<.input_number 
  id="weight-input"
  name="weight"
  value={50}
  min={0}
>
  <:suffix>kg</:suffix>
</.input_number>

<!-- 温度输入 -->
<.input_number 
  id="temperature"
  name="temperature"
  value={25}
  min={-50}
  max={50}
>
  <:suffix>°C</:suffix>
</.input_number>
```

### 禁用和只读状态
```heex
<!-- 禁用状态 -->
<.input_number 
  id="disabled-input"
  name="disabled"
  value={100}
  disabled
/>

<!-- 只读状态 -->
<.input_number 
  id="readonly-input"
  name="readonly"
  value={50}
  readonly
/>
```

### 不显示控制按钮
```heex
<.input_number 
  id="no-controls"
  name="custom"
  value={10}
  controls={false}
/>
```

### 不同尺寸
```heex
<div class="space-y-4">
  <.input_number 
    id="small-input"
    size="small"
    value={1}
    placeholder="小尺寸"
  />
  
  <.input_number 
    id="medium-input"
    size="medium"
    value={2}
    placeholder="中等尺寸"
  />
  
  <.input_number 
    id="large-input"
    size="large"
    value={3}
    placeholder="大尺寸"
  />
</div>
```

### 在表单中使用
```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <div class="space-y-4">
    <!-- 商品价格 -->
    <div>
      <label>商品价格</label>
      <.input_number 
        id="product-price"
        name="product[price]"
        value={@form[:price].value}
        min={0}
        precision={2}
        on_change={JS.push("validate")}
      >
        <:prefix>¥</:prefix>
      </.input_number>
    </div>
    
    <!-- 库存数量 -->
    <div>
      <label>库存数量</label>
      <.input_number 
        id="product-stock"
        name="product[stock]"
        value={@form[:stock].value}
        min={0}
        precision={0}
      />
    </div>
    
    <!-- 折扣率 -->
    <div>
      <label>折扣率</label>
      <.input_number 
        id="discount-rate"
        name="product[discount]"
        value={@form[:discount].value}
        min={0}
        max={100}
        precision={0}
      >
        <:suffix>%</:suffix>
      </.input_number>
    </div>
  </div>
  
  <.button type="submit">保存</.button>
</.form>
```

### 购物车数量选择
```heex
<div class="flex items-center gap-4">
  <span>购买数量：</span>
  <.input_number 
    id="cart-quantity"
    name="quantity"
    value={@quantity}
    min={1}
    max={@stock}
    on_change={JS.push("update_quantity")}
  />
  <span class="text-sm text-gray-500">库存：{@stock}件</span>
</div>
```

### 价格区间输入
```heex
<div class="flex items-center gap-2">
  <.input_number 
    id="min-price"
    name="min_price"
    value={@min_price}
    min={0}
    max={@max_price}
    placeholder="最低价"
    on_change={JS.push("update_price_range")}
  >
    <:prefix>¥</:prefix>
  </.input_number>
  
  <span>-</span>
  
  <.input_number 
    id="max-price"
    name="max_price"
    value={@max_price}
    min={@min_price}
    placeholder="最高价"
    on_change={JS.push("update_price_range")}
  >
    <:prefix>¥</:prefix>
  </.input_number>
</div>
```

## 与Vue版本对比

### 属性映射
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `v-model` | `value` + `on_change` | 双向绑定 |
| `:min` | `min` | 最小值 |
| `:max` | `max` | 最大值 |
| `:step` | `step` | 步长 |
| `:precision` | `precision` | 精度 |
| `:disabled` | `disabled` | 禁用状态 |
| `:read-only` | `readonly` | 只读状态 |
| `:controls` | `controls` | 是否显示控制按钮 |
| `:formatter` | `formatter` | 格式化函数 |
| `:parser` | `parser` | 解析函数 |
| `:size` | `size` | 尺寸 |

### 迁移示例

Vue代码：
```vue
<a-input-number
  v-model:value="price"
  :min="0"
  :precision="2"
  :formatter="value => `¥ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
  :parser="value => value.replace(/\¥\s?|(,*)/g, '')"
  @change="handlePriceChange"
/>
```

Phoenix代码：
```heex
<.input_number 
  id="price"
  value={@price}
  min={0}
  precision={2}
  formatter={&format_currency/1}
  parser={&parse_currency/1}
  on_change={JS.push("handle_price_change")}
>
  <:prefix>¥</:prefix>
</.input_number>
```

## 注意事项

1. **精度处理**
   - 设置 precision 后，会自动四舍五入到指定小数位
   - 浮点数计算可能存在精度问题，建议在后端处理金额计算

2. **性能优化**
   - 频繁变化的场景建议加入防抖处理
   - 大范围数值选择考虑直接输入而非步进

3. **可访问性**
   - 确保键盘操作正常工作
   - 提供清晰的错误提示
   - 支持屏幕阅读器

4. **用户体验**
   - 合理设置步长，便于快速调整
   - 提供明确的范围提示
   - 格式化显示要符合用户习惯

## 相关组件
- Input 输入框 - 普通文本输入
- Slider 滑动输入条 - 可视化数值选择
- Select 选择器 - 从预设选项中选择