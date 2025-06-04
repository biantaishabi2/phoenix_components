# Tabs 标签页组件

## 概述
标签页组件用于将内容组织在不同的标签页中，便于切换查看。适用于平级内容的分组展示。

## 何时使用
- 有多个同级内容需要切换展示
- 页面内容较多需要分组组织
- 表单分步骤填写
- 不同视图或数据的切换展示

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| active_tab | 当前激活的标签页key | string | 第一个tab的key |
| type | 标签页样式类型 | string | "line" |
| size | 标签页尺寸 | string | "medium" |
| position | 标签位置 | string | "top" |
| animated | 是否使用动画切换 | boolean | true |
| on_change | 切换标签页时的回调 | JS | - |
| class | 自定义CSS类 | string | "" |
| rest | 其他HTML属性 | global | - |

### 插槽
| 插槽名 | 说明 | 属性 |
|-------|------|------|
| tabs | 标签页定义 | key(必需), label(必需), icon(可选), disabled(可选) |

### 类型值
| 值 | 说明 | 样式特征 |
|----|------|---------|
| line | 线条风格(默认) | 底部带下划线 |
| card | 卡片风格 | 带边框的卡片样式 |
| pills | 药丸风格 | 圆角按钮样式 |

### 尺寸值
| 值 | 说明 | 应用场景 |
|----|------|----------|
| small | 小尺寸 | 紧凑布局 |
| medium | 中等尺寸(默认) | 标准场景 |
| large | 大尺寸 | 需要突出的场景 |

### 位置值
| 值 | 说明 | 应用场景 |
|----|------|----------|
| top | 顶部(默认) | 标准布局 |
| right | 右侧 | 侧边导航 |
| bottom | 底部 | 移动端底部导航 |
| left | 左侧 | 侧边导航 |

## 示例

### 基本使用
```heex
<.tabs active_tab="tab1" on_change={JS.push("change_tab")}>
  <:tabs key="tab1" label="标签一">
    <div>第一个标签页的内容</div>
  </:tabs>
  <:tabs key="tab2" label="标签二">
    <div>第二个标签页的内容</div>
  </:tabs>
  <:tabs key="tab3" label="标签三">
    <div>第三个标签页的内容</div>
  </:tabs>
</.tabs>
```

### 带图标的标签页
```heex
<.tabs active_tab="home">
  <:tabs key="home" label="首页">
    <:icon><.icon name="hero-home" /></:icon>
    <div>首页内容</div>
  </:tabs>
  <:tabs key="profile" label="个人资料">
    <:icon><.icon name="hero-user" /></:icon>
    <div>个人资料内容</div>
  </:tabs>
  <:tabs key="settings" label="设置">
    <:icon><.icon name="hero-cog-6-tooth" /></:icon>
    <div>设置内容</div>
  </:tabs>
</.tabs>
```

### 不同类型
```heex
<!-- 线条风格 -->
<.tabs type="line" active_tab="tab1">
  <:tabs key="tab1" label="线条风格1">内容1</:tabs>
  <:tabs key="tab2" label="线条风格2">内容2</:tabs>
</.tabs>

<!-- 卡片风格 -->
<.tabs type="card" active_tab="tab1">
  <:tabs key="tab1" label="卡片风格1">内容1</:tabs>
  <:tabs key="tab2" label="卡片风格2">内容2</:tabs>
</.tabs>

<!-- 药丸风格 -->
<.tabs type="pills" active_tab="tab1">
  <:tabs key="tab1" label="药丸风格1">内容1</:tabs>
  <:tabs key="tab2" label="药丸风格2">内容2</:tabs>
</.tabs>
```

### 不同尺寸
```heex
<.tabs size="small" active_tab="tab1">
  <:tabs key="tab1" label="小尺寸">小尺寸内容</:tabs>
  <:tabs key="tab2" label="标签2">内容2</:tabs>
</.tabs>

<.tabs size="large" active_tab="tab1">
  <:tabs key="tab1" label="大尺寸">大尺寸内容</:tabs>
  <:tabs key="tab2" label="标签2">内容2</:tabs>
</.tabs>
```

### 禁用某个标签页
```heex
<.tabs active_tab="tab1">
  <:tabs key="tab1" label="可用标签">正常内容</:tabs>
  <:tabs key="tab2" label="禁用标签" disabled>
    这个标签页被禁用了
  </:tabs>
  <:tabs key="tab3" label="另一个可用标签">正常内容</:tabs>
</.tabs>
```

### 不同位置
```heex
<!-- 标签在右侧 -->
<.tabs position="right" active_tab="tab1">
  <:tabs key="tab1" label="右侧标签1">内容1</:tabs>
  <:tabs key="tab2" label="右侧标签2">内容2</:tabs>
</.tabs>

<!-- 标签在底部 -->
<.tabs position="bottom" active_tab="tab1">
  <:tabs key="tab1" label="底部标签1">内容1</:tabs>
  <:tabs key="tab2" label="底部标签2">内容2</:tabs>
</.tabs>
```

### 无动画切换
```heex
<.tabs animated={false} active_tab="tab1">
  <:tabs key="tab1" label="标签1">无动画切换内容1</:tabs>
  <:tabs key="tab2" label="标签2">无动画切换内容2</:tabs>
</.tabs>
```

### 受控模式（在LiveView中）
```heex
# 在LiveView中
def mount(_params, _session, socket) do
  {:ok, assign(socket, active_tab: "tab1")}
end

def handle_event("change_tab", %{"tab" => tab_key}, socket) do
  {:noreply, assign(socket, active_tab: tab_key)}
end

# 模板中
<.tabs active_tab={@active_tab} on_change={JS.push("change_tab")}>
  <:tabs key="tab1" label="标签1">
    <div>内容1</div>
  </:tabs>
  <:tabs key="tab2" label="标签2">
    <div>内容2</div>
  </:tabs>
</.tabs>
```

### 复杂内容示例
```heex
<.tabs type="card" size="large" active_tab="orders">
  <:tabs key="orders" label="订单管理">
    <:icon><.icon name="hero-shopping-cart" /></:icon>
    <div class="p-4">
      <h3 class="text-lg font-semibold mb-4">订单列表</h3>
      <.table rows={@orders}>
        <:col label="订单号" field={:order_no} />
        <:col label="金额" field={:amount} />
        <:col label="状态" field={:status} />
      </.table>
    </div>
  </:tabs>
  
  <:tabs key="products" label="商品管理">
    <:icon><.icon name="hero-cube" /></:icon>
    <div class="p-4">
      <h3 class="text-lg font-semibold mb-4">商品列表</h3>
      <.table rows={@products}>
        <:col label="商品名" field={:name} />
        <:col label="价格" field={:price} />
        <:col label="库存" field={:stock} />
      </.table>
    </div>
  </:tabs>
  
  <:tabs key="stats" label="统计分析" disabled>
    <:icon><.icon name="hero-chart-bar" /></:icon>
    <div class="p-4">统计功能开发中...</div>
  </:tabs>
</.tabs>
```

## 设计规范
- 遵循 Petal Components 的设计风格
- 使用 pc-tabs 作为CSS类前缀
- 支持响应式设计
- 确保键盘导航支持（Tab键和方向键）
- 提供合适的 ARIA 属性支持

## 从 Vue 迁移指南

### Ant Design Vue 对照
| Ant Design Vue | Phoenix Tabs | 说明 |
|----------------|--------------|------|
| `<a-tabs v-model:activeKey="activeKey">` | `<.tabs active_tab={@active_tab}>` | 激活标签页绑定 |
| `<a-tab-pane key="1" tab="Tab 1">` | `<:tabs key="tab1" label="Tab 1">` | 标签页定义 |
| `@change="handleChange"` | `on_change={JS.push("handle_change")}` | 切换事件 |
| `:type="card"` | `type="card"` | 样式类型 |
| `:size="large"` | `size="large"` | 尺寸设置 |
| `:tabPosition="left"` | `position="left"` | 标签位置 |
| `:animated="false"` | `animated={false}` | 动画设置 |

### 功能差异
1. Phoenix 版本使用插槽而不是子组件
2. 事件处理使用 Phoenix 的 JS 命令
3. 样式完全基于 Tailwind CSS
4. 不支持的功能：
   - 标签页的增加/删除（可编辑模式）
   - 标签页的拖拽排序
   - 懒加载（需要在 LiveView 中自行实现）