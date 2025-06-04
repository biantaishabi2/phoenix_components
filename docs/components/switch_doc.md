# Switch 开关组件

## 概述
Switch 开关组件用于在两种状态间切换，和 Checkbox 的区别是 Switch 会直接触发状态改变，而 Checkbox 一般用于表单提交时的状态标记。

## 何时使用
- 需要表示开关状态时
- 两种状态之间的切换时
- 和 Checkbox 的区别是，Switch 会直接触发状态改变，而 Checkbox 一般用于状态标记

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 | 版本 |
|-----|------|------|--------|------|
| id | 开关唯一标识 | string | 必需 | 1.0 |
| name | 表单字段名 | string | - | 1.0 |
| checked | 指定当前是否选中 | boolean | false | 1.0 |
| disabled | 是否禁用 | boolean | false | 1.0 |
| size | 开关大小 | string | "medium" | 1.0 |
| color | 颜色主题 | string | "primary" | 1.0 |
| loading | 加载中状态 | boolean | false | 1.0 |
| checked_children | 选中时的内容 | string/slot | - | 1.0 |
| unchecked_children | 非选中时的内容 | string/slot | - | 1.0 |
| class | 自定义CSS类 | string | "" | 1.0 |
| on_change | 变化时回调函数 | JS | - | 1.0 |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | 高度 16px |
| medium | 中等尺寸(默认) | 高度 22px |
| large | 大尺寸 | 高度 28px |

### 颜色值
| 值 | 说明 | 用途 |
|----|------|------|
| primary | 主色(默认) | 品牌色 |
| info | 信息色 | 信息开关 |
| success | 成功色 | 成功状态 |
| warning | 警告色 | 警告状态 |
| danger | 危险色 | 危险操作 |

## 代码示例

### 基本用法
```heex
<.switch id="basic-switch" />
```

### 带文字和图标
```heex
<.switch 
  id="text-switch"
  checked_children="开"
  unchecked_children="关"
/>

<!-- 使用插槽 -->
<.switch id="icon-switch">
  <:checked_children>
    <.icon name="hero-check" class="w-3 h-3" />
  </:checked_children>
  <:unchecked_children>
    <.icon name="hero-x-mark" class="w-3 h-3" />
  </:unchecked_children>
</.switch>
```

### 不同尺寸
```heex
<.switch id="small-switch" size="small" />
<.switch id="medium-switch" size="medium" />
<.switch id="large-switch" size="large" />
```

### 不同颜色
```heex
<.switch id="primary-switch" color="primary" />
<.switch id="success-switch" color="success" />
<.switch id="danger-switch" color="danger" />
```

### 禁用状态
```heex
<.switch id="disabled-off" disabled />
<.switch id="disabled-on" checked disabled />
```

### 加载中状态
```heex
<.switch id="loading-switch" loading />
```

### 在表单中使用
```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <div class="space-y-4">
    <div>
      <label>启用规格</label>
      <.switch 
        id="enable-specs"
        name="product[enable_specs]"
        checked={@form[:enable_specs].value}
        on_change={JS.push("toggle_specs")}
      />
    </div>
    
    <div>
      <label>上架状态</label>
      <.switch 
        id="is-active"
        name="product[is_active]"
        checked={@form[:is_active].value}
        checked_children="上架"
        unchecked_children="下架"
      />
    </div>
  </div>
  
  <.button type="submit">保存</.button>
</.form>
```

### 受控组件
```heex
<div>
  <.switch 
    id="controlled-switch"
    checked={@is_enabled}
    on_change={JS.push("toggle_enabled")}
  />
  <p class="mt-2">当前状态: {@is_enabled && "启用" || "禁用"}</p>
</div>

<!-- LiveView 处理 -->
def handle_event("toggle_enabled", _, socket) do
  {:noreply, update(socket, :is_enabled, &(!&1))}
end
```

### 与其他组件配合
```heex
<div class="flex items-center justify-between p-4 border rounded">
  <div>
    <h4 class="font-semibold">开启通知</h4>
    <p class="text-sm text-gray-500">接收系统通知和更新</p>
  </div>
  <.switch 
    id="notification-switch"
    checked={@notifications_enabled}
    on_change={JS.push("toggle_notifications")}
  />
</div>
```

## 与 Checkbox 的区别

### 外观区别
- Switch: 滑动开关的形式
- Checkbox: 方框打勾的形式

### 使用场景区别
- Switch: 用于触发状态改变，如"开启/关闭"功能
- Checkbox: 用于在表单中标记选择，如"同意协议"

### 交互区别
- Switch: 点击后立即生效
- Checkbox: 通常需要提交表单后才生效

## 与 Vue 版本对比

### 属性映射
| Ant Design Vue | ShopUx Phoenix | 说明 |
|---------------|----------------|------|
| `v-model:checked` | `checked` + `on_change` | 双向绑定 |
| `:disabled` | `disabled` | 禁用状态 |
| `:loading` | `loading` | 加载状态 |
| `:size` | `size` | 尺寸 |
| `checked-children` | `checked_children` | 选中时的内容 |
| `un-checked-children` | `unchecked_children` | 非选中时的内容 |

### 迁移示例

Vue 代码：
```vue
<a-switch 
  v-model:checked="formState.enableSpecs"
  checked-children="开"
  un-checked-children="关"
  @change="handleChange"
/>
```

Phoenix 代码：
```heex
<.switch 
  id="enable-specs"
  checked={@form_state.enable_specs}
  checked_children="开"
  unchecked_children="关"
  on_change={JS.push("handle_change")}
/>
```

## 设计规范

### 颜色规范
- 选中态使用各主题色
- 未选中态使用 gray-300
- 禁用态降低透明度

### 动画规范
- 切换动画时长：200ms
- 使用 ease-in-out 缓动函数
- 滑块移动要平滑

### 尺寸规范
| 尺寸 | 高度 | 宽度 | 滑块直径 |
|-----|------|------|----------|
| small | 16px | 28px | 12px |
| medium | 22px | 44px | 18px |
| large | 28px | 56px | 24px |

## 无障碍设计
- 支持键盘操作（Space 键切换）
- 包含正确的 ARIA 属性
- 提供清晰的焦点样式
- 支持屏幕阅读器

## 注意事项
1. Switch 组件应该有明确的开/关语义
2. 避免在 Switch 旁边放置额外的操作按钮
3. 加载状态时应禁止操作
4. 切换动画要流畅，避免卡顿