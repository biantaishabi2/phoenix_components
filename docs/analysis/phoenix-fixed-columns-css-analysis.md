# Phoenix Fixed Columns CSS 样式分析

## 📋 样式系统概述

基于 Ant Design 的固定列实现原理，我为 Phoenix LiveView Table 组件设计了完整的 CSS 样式系统。

## 🎨 样式架构设计

### 1. 命名规范

遵循 BEM 命名规范和项目的 `pc-table` 前缀：

```css
/* 基础组件类 */
.pc-table                       /* 表格容器 */
.pc-table__cell                 /* 表格单元格 */
.pc-table__header              /* 表格头部 */
.pc-table__container           /* 表格内容容器 */

/* 固定列修饰符 */
.pc-table__cell--fixed-left    /* 左固定列 */
.pc-table__cell--fixed-right   /* 右固定列 */
.pc-table__cell--fixed-left-last   /* 左固定列最后一个 */
.pc-table__cell--fixed-right-first /* 右固定列第一个 */

/* 状态类 */
.pc-table--ping-left          /* 向左滚动状态 */
.pc-table--ping-right         /* 向右滚动状态 */
.pc-table--has-fix-left       /* 有左固定列 */
.pc-table--has-fix-right      /* 有右固定列 */
.pc-table--fixed-column-gapped /* 间隔固定列 */
```

### 2. 样式层次结构

```
pc-table/
├── 基础固定列样式 (position: sticky, z-index)
├── 阴影边界效果 (::after 伪元素)
├── 滚动状态响应 (ping-left/right)
├── 深色模式适配 (@media prefers-color-scheme)
├── 响应式适配 (@media max-width)
└── 特殊情况处理 (gapped columns)
```

## 🔧 核心样式实现

### 1. 基础固定列样式

```css
.pc-table__cell--fixed-left,
.pc-table__cell--fixed-right {
  position: sticky !important;  /* 核心定位技术 */
  z-index: 2;                   /* 基础层级 */
  background: white;            /* 默认背景 */
}
```

**设计要点**：
- ✅ 使用 `!important` 确保样式优先级
- ✅ `z-index: 2` 确保在普通单元格之上
- ✅ `background: white` 遮盖滚动内容

### 2. 层级管理

```css
/* 表头固定列具有更高层级 */
.pc-table__header .pc-table__cell--fixed-left,
.pc-table__header .pc-table__cell--fixed-right {
  z-index: 3;
}
```

**层级设计**：
- 普通单元格：`z-index: 1` (默认)
- 固定列单元格：`z-index: 2`
- 表头固定列：`z-index: 3`
- 容器阴影：`z-index: 3`

### 3. 阴影边界效果

#### 左固定列右边界阴影
```css
.pc-table__cell--fixed-left-last::after {
  position: absolute;
  top: 0;
  right: 0;                    /* 定位到右边界 */
  bottom: -1px;               /* 覆盖边框 */
  width: 30px;                /* 阴影宽度 */
  transform: translateX(100%); /* 移出单元格外 */
  transition: box-shadow 0.3s ease;
  content: "";
  pointer-events: none;       /* 不影响交互 */
}
```

#### 右固定列左边界阴影
```css
.pc-table__cell--fixed-right-first::after {
  position: absolute;
  top: 0;
  left: 0;                     /* 定位到左边界 */
  bottom: -1px;
  width: 30px;
  transform: translateX(-100%); /* 移出单元格外 */
  transition: box-shadow 0.3s ease;
  content: "";
  pointer-events: none;
}
```

**阴影技术要点**：
- ✅ 使用 `::after` 伪元素避免额外 DOM
- ✅ `transform: translateX()` 精确定位
- ✅ `pointer-events: none` 不影响交互
- ✅ `transition` 提供平滑动画

### 4. 滚动状态响应

```css
/* 向左滚动时显示左边阴影 */
.pc-table--ping-left .pc-table__cell--fixed-left-last::after {
  box-shadow: inset 10px 0 8px -8px rgba(0, 0, 0, 0.15);
}

/* 向右滚动时显示右边阴影 */
.pc-table--ping-right .pc-table__cell--fixed-right-first::after {
  box-shadow: inset -10px 0 8px -8px rgba(0, 0, 0, 0.15);
}
```

**阴影参数解析**：
```css
box-shadow: inset 10px 0 8px -8px rgba(0, 0, 0, 0.15);
/*
  inset:    内阴影，在元素内部显示
  10px:     水平偏移，向内10px
  0:        垂直偏移，无偏移
  8px:      模糊半径，柔化边界
  -8px:     阴影收缩，使阴影更窄
  rgba():   半透明黑色，透明度15%
*/
```

## 🌙 深色模式适配

### 1. 背景色适配
```css
@media (prefers-color-scheme: dark) {
  .pc-table__cell--fixed-left,
  .pc-table__cell--fixed-right {
    background: rgb(31 41 55); /* bg-gray-800 */
  }
}
```

### 2. 阴影色适配
```css
@media (prefers-color-scheme: dark) {
  .pc-table--ping-left .pc-table__cell--fixed-left-last::after {
    box-shadow: inset 10px 0 8px -8px rgba(255, 255, 255, 0.1);
  }
  
  .pc-table--ping-right .pc-table__cell--fixed-right-first::after {
    box-shadow: inset -10px 0 8px -8px rgba(255, 255, 255, 0.1);
  }
}
```

**深色模式要点**：
- ✅ 使用 `prefers-color-scheme` 自动检测
- ✅ 背景色匹配项目的深色主题
- ✅ 阴影改为白色半透明

## 📱 响应式设计

### 移动端适配
```css
@media (max-width: 768px) {
  .pc-table__cell--fixed-left,
  .pc-table__cell--fixed-right {
    position: static !important;  /* 禁用固定定位 */
    z-index: auto;
  }
  
  .pc-table__cell--fixed-left-last::after,
  .pc-table__cell--fixed-right-first::after {
    display: none;              /* 隐藏阴影效果 */
  }
}
```

**响应式策略**：
- ✅ 768px 以下禁用固定列
- ✅ 恢复正常表格滚动
- ✅ 避免移动端布局问题

## 🔍 特殊情况处理

### 1. 间隔固定列
```css
.pc-table--fixed-column-gapped .pc-table__cell--fixed-left-last::after,
.pc-table--fixed-column-gapped .pc-table__cell--fixed-right-first::after {
  box-shadow: none;  /* 间隔固定列不显示阴影 */
}
```

### 2. 容器级阴影备用方案
```css
.pc-table__container::before,
.pc-table__container::after {
  position: absolute;
  top: 0;
  bottom: 0;
  z-index: 3;
  width: 30px;
  transition: box-shadow 0.3s ease;
  content: "";
  pointer-events: none;
}

/* 无固定列时的容器阴影 */
.pc-table--ping-left:not(.pc-table--has-fix-left) .pc-table__container::before {
  box-shadow: inset 10px 0 8px -8px rgba(0, 0, 0, 0.15);
}
```

## 🎯 与 Ant Design 的差异

### 1. 命名规范
| Ant Design | Phoenix | 说明 |
|------------|---------|------|
| `.ant-table-cell-fix-left` | `.pc-table__cell--fixed-left` | 遵循 BEM 规范 |
| `.ant-table-ping-left` | `.pc-table--ping-left` | 更清晰的状态表示 |

### 2. 深色模式处理
| Ant Design | Phoenix | 说明 |
|------------|---------|------|
| CSS-in-JS 动态主题 | CSS 媒体查询 | 更简单的实现方式 |
| 主题变量 | 固定颜色值 | 适合项目需求 |

### 3. 响应式处理
| Ant Design | Phoenix | 说明 |
|------------|---------|------|
| JavaScript 控制 | CSS 媒体查询 | 纯 CSS 解决方案 |
| 复杂断点系统 | 简化的移动端处理 | 更易维护 |

## 🚀 性能优化

### 1. CSS 性能
- ✅ 使用 `transform` 代替 `left/right` 改变位置
- ✅ 合理的 `z-index` 分层避免重排
- ✅ `transition` 只应用于需要动画的属性
- ✅ `pointer-events: none` 避免不必要的事件处理

### 2. 浏览器兼容性
- ✅ `position: sticky` 支持所有现代浏览器
- ✅ CSS 媒体查询广泛支持
- ✅ 伪元素 `::after` 兼容性良好

## 📊 样式文件结构

```css
app.css
├── Tailwind 导入
├── 表格省略号样式
└── 固定列样式组
    ├── 基础固定列样式
    ├── 层级管理
    ├── 阴影边界效果
    ├── 滚动状态响应
    ├── 深色模式适配
    ├── 容器阴影备用
    └── 响应式适配
```

**总代码量**: 约 100 行 CSS，涵盖所有使用场景。

## 📝 使用指南

### 1. 基础使用
```html
<td class="pc-table__cell pc-table__cell--fixed-left">
  内容
</td>
```

### 2. 边界列使用
```html
<td class="pc-table__cell pc-table__cell--fixed-left pc-table__cell--fixed-left-last">
  最后一个左固定列
</td>
```

### 3. 状态控制
```html
<table class="pc-table pc-table--ping-left pc-table--has-fix-left">
  <!-- 表格内容 -->
</table>
```

## 🎉 总结

Phoenix 固定列 CSS 样式系统具有以下特点：

- 🎯 **完整性**: 覆盖所有使用场景
- 🎨 **一致性**: 遵循项目设计规范
- 📱 **响应式**: 适配各种设备
- 🌙 **主题化**: 支持深色模式
- ⚡ **性能优**: 纯 CSS 实现，性能优异
- 🔧 **可维护**: 清晰的结构和命名

准备在下一步中集成到 Phoenix 组件中！