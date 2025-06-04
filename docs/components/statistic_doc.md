# Statistic 统计数值组件

## 概述
展示统计数值，用于突出某个或某组数字时使用，可以用于展示成就、数据等。

## 何时使用
- 当需要突出某个或某组数字时
- 用于展示成就数据、统计图表等场景
- 需要展示增长率、变化趋势等数据

## 特性
- 支持自定义前缀和后缀
- 支持数字动画效果
- 支持不同颜色主题
- 支持增长率显示
- 支持自定义精度
- 支持数字格式化
- 支持加载状态

## API

### 属性
| 属性 | 说明 | 类型 | 默认值 |
|-----|------|------|--------|
| id | 统计数值唯一标识 | string | 必填 |
| title | 数值标题 | string | - |
| value | 数值内容 | number/string | 必填 |
| size | 统计数值尺寸 | string | "medium" |
| precision | 精度，保留小数点后位数 | integer | 0 |
| prefix | 前缀 | string/slot | - |
| suffix | 后缀 | string/slot | - |
| value_style | 数值的样式 | string | - |
| loading | 加载中状态 | boolean | false |
| color | 数值颜色 | string | "default" |
| group_separator | 千分位分隔符 | string | "," |
| decimal_separator | 小数点分隔符 | string | "." |
| formatter | 自定义数值格式化函数 | function | - |
| animation | 是否开启动画 | boolean | true |
| animation_duration | 动画持续时间(ms) | integer | 2000 |
| animation_delay | 动画延迟时间(ms) | integer | 0 |
| trend | 趋势方向 | string (up/down) | - |
| trend_color | 趋势颜色 | boolean | true |
| class | 自定义CSS类 | string | "" |
| rest | 其他HTML属性 | global | - |

### 尺寸值
| 值 | 说明 | 样式 |
|----|------|------|
| small | 小尺寸 | 较小的标题和数值字体 |
| medium | 中等尺寸(默认) | 标准字体大小 |
| large | 大尺寸 | 较大的标题和数值字体 |

### 颜色主题
- default: 默认颜色
- primary: 主要颜色 (#FD8E25)
- success: 成功状态（绿色）
- warning: 警告状态（橙色）
- danger: 危险状态（红色）
- info: 信息状态（蓝色）

## 示例

### 基本使用
```heex
<.statistic 
  id="basic-stat"
  title="用户总数"
  value={112893}
/>
```

### 带前缀和后缀
```heex
<.statistic 
  id="prefix-suffix"
  title="月收入"
  value={568.08}
  precision={2}
  prefix="¥"
  suffix="万"
/>
```

### 自定义样式
```heex
<.statistic 
  id="custom-style"
  title="增长率"
  value={7.28}
  precision={2}
  suffix="%"
  color="success"
  value_style="font-bold text-2xl"
/>
```

### 带趋势指示
```heex
<.statistic 
  id="trend-up"
  title="本月销售"
  value={2548}
  trend="up"
  color="success"
/>

<.statistic 
  id="trend-down"
  title="库存"
  value={1423}
  trend="down"
  color="danger"
/>
```

### 加载状态
```heex
<.statistic 
  id="loading-stat"
  title="数据加载中"
  value={0}
  loading={true}
/>
```

### 数字动画
```heex
<.statistic 
  id="animated"
  title="在线用户"
  value={8846}
  animation={true}
  animation_duration={3000}
/>
```

### 自定义格式化
```heex
<.statistic 
  id="formatted"
  title="文件大小"
  value={1024}
  formatter={&format_bytes/1}
/>
```

### 使用插槽前缀和后缀
```heex
<.statistic id="slot-example" title="评分" value={4.5}>
  <:prefix>
    <svg class="w-4 h-4 text-yellow-400" fill="currentColor">
      <!-- 星星图标 -->
    </svg>
  </:prefix>
  <:suffix>
    <span class="text-gray-500 text-sm">/ 5.0</span>
  </:suffix>
</.statistic>
```

### 卡片样式组合
```heex
<div class="grid grid-cols-1 md:grid-cols-4 gap-4">
  <div class="bg-white p-6 rounded-lg shadow">
    <.statistic 
      id="card-1"
      title="总用户"
      value={40689}
      color="primary"
    />
  </div>
  
  <div class="bg-white p-6 rounded-lg shadow">
    <.statistic 
      id="card-2"
      title="活跃用户"
      value={6560}
      color="success"
      trend="up"
    />
  </div>
  
  <div class="bg-white p-6 rounded-lg shadow">
    <.statistic 
      id="card-3"
      title="本月收入"
      value={9876.54}
      precision={2}
      prefix="¥"
      color="warning"
    />
  </div>
  
  <div class="bg-white p-6 rounded-lg shadow">
    <.statistic 
      id="card-4"
      title="转化率"
      value={82.5}
      precision={1}
      suffix="%"
      color="info"
    />
  </div>
</div>
```

### 对比展示
```heex
<div class="space-y-4">
  <.statistic 
    id="compare-this-month"
    title="本月销售额"
    value={125000}
    prefix="¥"
    color="primary"
  />
  
  <.statistic 
    id="compare-last-month"
    title="上月销售额"
    value={98000}
    prefix="¥"
    color="default"
  />
  
  <.statistic 
    id="compare-growth"
    title="增长率"
    value={27.55}
    precision={2}
    suffix="%"
    color="success"
    trend="up"
  />
</div>
```

### 实时数据
```heex
<.statistic 
  id="realtime"
  title="实时访问"
  value={@live_visitors}
  animation={false}
  color="info"
/>
```

### 分组显示
```heex
<div class="bg-gray-50 p-6 rounded-lg">
  <h3 class="text-lg font-semibold mb-4">今日概览</h3>
  <div class="grid grid-cols-2 gap-4">
    <.statistic 
      id="today-orders"
      title="今日订单"
      value={168}
      color="primary"
    />
    <.statistic 
      id="today-revenue"
      title="今日收入"
      value={23456.78}
      precision={2}
      prefix="¥"
      color="success"
    />
  </div>
</div>
```

## 高级用法

### 自定义数值格式化
```elixir
def format_bytes(bytes) when is_number(bytes) do
  cond do
    bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
    bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
    bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
    true -> "#{bytes} B"
  end
end
```

### 动态颜色
```elixir
def get_trend_color(value, target) do
  cond do
    value >= target * 1.1 -> "success"
    value >= target * 0.9 -> "warning"
    true -> "danger"
  end
end
```

### 实时更新
```elixir
def handle_info(:update_stats, socket) do
  # 定时更新统计数据
  Process.send_after(self(), :update_stats, 5000)
  
  new_stats = fetch_realtime_stats()
  {:noreply, assign(socket, stats: new_stats)}
end
```

### 数据变化动画
```javascript
// 在 app.js 中添加动画效果
window.addEventListener("phx:statistic-update", (e) => {
  const element = document.getElementById(e.detail.id);
  element.classList.add("animate-pulse");
  setTimeout(() => {
    element.classList.remove("animate-pulse");
  }, 1000);
});
```

## 可访问性
- 使用语义化的HTML结构
- 添加适当的ARIA标签
- 支持屏幕阅读器
- 提供键盘导航支持

## 设计规范
- 参考 Ant Design Statistic 组件
- 数值应突出显示，标题相对次要
- 保持一致的间距和对齐
- 合理使用颜色表达数据含义
- 动画应该平滑自然，不影响可读性

## 注意事项
- 确保数值的准确性和实时性
- 避免过度使用动画效果
- 大数值建议使用千分位分隔符
- 小数位数应该根据业务场景合理设置
- 考虑不同屏幕尺寸的显示效果