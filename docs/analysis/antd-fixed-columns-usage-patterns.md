# Ant Design 固定列使用模式分析

## 📋 研究概述

通过分析 Ant Design 的官方示例，我总结了固定列功能的各种使用场景、API 模式和最佳实践。

## 🎯 核心 API 模式

### 1. 基础 API 结构

```typescript
interface ColumnType {
  fixed?: FixedType;  // 'left' | 'right' | boolean
  width?: number | string;
  // ... 其他属性
}
```

**FixedType 类型**：
- `'left'`: 左固定
- `'right'`: 右固定  
- `true`: 等同于 `'left'` (向后兼容)
- `false` 或 `undefined`: 不固定

## 📚 使用场景分析

### 1. 基础左固定列 (fixed-columns.tsx)

```typescript
const columns = [
  {
    title: 'Full Name',
    width: 100,
    dataIndex: 'name',
    key: 'name',
    fixed: 'left',        // 左固定
  },
  {
    title: 'Age',
    width: 100,
    dataIndex: 'age',
    key: 'age',
    fixed: 'left',        // 多个左固定列
    sorter: true,         // 与排序功能结合
  },
  // ... 普通列 ...
  {
    title: 'Action',
    key: 'operation',
    fixed: 'right',       // 右固定操作列
    width: 100,
    render: () => <a>action</a>,
  },
];
```

**使用要点**：
- ✅ 固定列必须设置 `width`
- ✅ 多个固定列按定义顺序排列
- ✅ 操作列通常右固定
- ✅ 固定列可以与其他功能（排序、筛选）结合

### 2. 固定表头 + 固定列 (fixed-columns-header.tsx)

```typescript
const App = () => (
  <Table
    columns={columns}
    dataSource={dataSource}
    scroll={{ x: 'max-content', y: 55 * 5 }}  // 关键配置
  />
);
```

**关键配置**：
- `scroll.x: 'max-content'`: 水平滚动
- `scroll.y: 55 * 5`: 垂直滚动，固定表头
- 同时启用水平和垂直滚动时的固定列表现

### 3. 间隔固定列 (fixed-gapped-columns.tsx)

```typescript
const columns = [
  {
    title: 'Full Name',
    width: 100,
    dataIndex: 'name',
    fixed: 'left',        // 左固定列1
  },
  {
    title: 'Age',
    width: 100,
    dataIndex: 'age',
    // 中间普通列
  },
  { 
    title: 'Column 1', 
    dataIndex: 'address', 
    key: '1', 
    fixed: 'left'         // 左固定列2（间隔）
  },
  // ... 更多普通列 ...
  {
    title: 'Action 1',
    fixed: 'right',       // 右固定列1
    width: 90,
  },
  {
    title: 'Action 2',
    width: 90,
    // 中间普通操作列
  },
  {
    title: 'Action 3',
    fixed: 'right',       // 右固定列2（间隔）
    width: 90,
  },
];
```

**间隔固定列特点**：
- ✅ 固定列之间可以有普通列
- ✅ 不显示阴影边界效果
- ✅ 每个固定列独立定位

## 🔍 使用模式总结

### 1. 固定列数量建议

| 场景 | 左固定列数 | 右固定列数 | 建议 |
|------|-----------|-----------|------|
| 标识列 | 1-2 | 0 | ID、名称等关键信息 |
| 操作列 | 0 | 1 | 常见的操作按钮 |
| 导航表格 | 2-3 | 1-2 | 完整的导航和操作 |
| 数据表格 | 1 | 0-1 | 保持简洁，避免过多固定 |

### 2. 列宽设置模式

```typescript
// 模式1：固定像素宽度
{
  title: 'ID',
  width: 80,          // 适合内容长度固定的列
  fixed: 'left',
}

// 模式2：较宽的固定列
{
  title: 'Name',
  width: 150,         // 适合重要的文本内容
  fixed: 'left',
}

// 模式3：操作列
{
  title: 'Action',
  width: 120,         // 根据按钮数量调整
  fixed: 'right',
}
```

### 3. 与其他功能的结合

#### 与排序功能结合
```typescript
{
  title: 'Age',
  dataIndex: 'age',
  fixed: 'left',
  sorter: true,       // 固定列支持排序
  sortDirections: ['descend', 'ascend'],
}
```

#### 与筛选功能结合
```typescript
{
  title: 'Status',
  dataIndex: 'status',
  fixed: 'left',
  filters: [          // 固定列支持筛选
    { text: 'Active', value: 'active' },
    { text: 'Inactive', value: 'inactive' },
  ],
  onFilter: (value, record) => record.status === value,
}
```

#### 与省略号结合
```typescript
{
  title: 'Description',
  dataIndex: 'description',
  fixed: 'left',
  width: 200,
  ellipsis: true,     // 固定列支持文本省略
}
```

## 📐 布局最佳实践

### 1. 宽度分配策略

```typescript
// 推荐的宽度分配
const columns = [
  // 左固定：紧凑的关键信息
  { title: 'ID', width: 60, fixed: 'left' },
  { title: 'Name', width: 150, fixed: 'left' },
  
  // 中间：自适应内容
  { title: 'Description', minWidth: 200 },
  { title: 'Category', width: 120 },
  { title: 'Date', width: 100 },
  
  // 右固定：操作区域
  { title: 'Status', width: 80, fixed: 'right' },
  { title: 'Action', width: 120, fixed: 'right' },
];
```

### 2. 响应式考虑

```typescript
// 大屏幕：完整固定列
const desktopColumns = [
  { title: 'ID', width: 60, fixed: 'left' },
  { title: 'Name', width: 150, fixed: 'left' },
  // ... 更多列
  { title: 'Action', width: 120, fixed: 'right' },
];

// 移动端：简化或禁用固定列
const mobileColumns = [
  { title: 'Name', width: 150 },  // 不固定
  { title: 'Action', width: 80 },
];
```

### 3. 滚动配置

```typescript
// 基础水平滚动
scroll={{ x: 'max-content' }}

// 固定表头 + 水平滚动
scroll={{ x: 'max-content', y: 400 }}

// 响应式滚动
scroll={{ 
  x: 'max-content',
  y: window.innerHeight > 600 ? 400 : 300 
}}
```

## ⚠️ 常见问题和解决方案

### 1. 固定列不生效

**问题**：设置了 `fixed` 但列没有固定
**原因**：
- 没有设置 `width`
- 没有启用水平滚动 `scroll.x`
- 容器宽度问题

**解决方案**：
```typescript
// 正确配置
{
  title: 'Name',
  width: 150,        // 必须设置宽度
  fixed: 'left',
}
// 表格配置
scroll={{ x: 'max-content' }}  // 必须启用水平滚动
```

### 2. 阴影效果异常

**问题**：固定列边界没有阴影或阴影位置错误
**原因**：
- CSS 样式覆盖
- 间隔固定列的特殊情况

**解决方案**：
```css
/* 确保阴影样式优先级 */
.ant-table-ping-left .ant-table-cell-fix-left-last::after {
  box-shadow: inset 10px 0 8px -8px rgba(0,0,0,0.15) !important;
}
```

### 3. 性能问题

**问题**：大量数据时滚动卡顿
**原因**：
- 固定列过多
- 复杂的单元格内容

**解决方案**：
- 减少固定列数量（建议不超过3个）
- 使用虚拟滚动
- 简化单元格内容

### 4. 移动端适配

**问题**：移动端固定列布局混乱
**解决方案**：
```typescript
// 响应式列配置
const useResponsiveColumns = () => {
  const [isMobile, setIsMobile] = useState(false);
  
  return isMobile ? mobileColumns : desktopColumns;
};
```

## 🎯 Phoenix LiveView 适配建议

### 1. API 简化

```elixir
# Phoenix 版本的简化 API
slot :col do
  attr :fixed, :string, values: ["left", "right"]
  # 只支持字符串，不支持 boolean
end
```

### 2. 服务端渲染优势

```elixir
# 在服务端计算固定列位置
defp calculate_fixed_positions(cols) do
  # 服务端计算，减少客户端 JavaScript
end
```

### 3. LiveView 状态管理

```elixir
# 滚动状态可以通过 Phoenix.LiveView.JS 管理
def handle_event("table_scroll", %{"ping_left" => ping_left}, socket) do
  {:noreply, assign(socket, ping_left: ping_left)}
end
```

## 📊 使用场景优先级

### 高优先级（必须实现）
1. ✅ 基础左固定列
2. ✅ 基础右固定列
3. ✅ 固定列与宽度控制结合
4. ✅ 操作列固定

### 中优先级（建议实现）
1. ⏳ 多列固定
2. ⏳ 固定列与排序结合
3. ⏳ 阴影边界效果
4. ⏳ 响应式适配

### 低优先级（可选实现）
1. ⏳ 间隔固定列
2. ⏳ 复杂的滚动状态检测
3. ⏳ 高级动画效果

## 📝 结论

Ant Design 固定列的使用模式体现了以下设计原则：

- **简单易用**：API 简洁，配置直观
- **功能完整**：支持各种使用场景
- **性能优先**：使用浏览器原生 sticky 定位
- **体验友好**：细致的视觉效果和交互反馈

这为我们的 Phoenix LiveView 实现提供了明确的功能规范和实现目标。