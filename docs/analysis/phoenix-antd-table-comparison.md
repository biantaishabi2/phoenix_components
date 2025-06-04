# Phoenix Table 与 Ant Design Table 功能对比

## 一、Phoenix Table 已实现的功能

### 基础功能
1. **数据展示** - 基本的表格数据渲染
2. **自定义列** - 通过 slot 方式定义列内容
3. **操作列** - 支持操作按钮列
4. **空状态** - 自定义空数据展示
5. **表格尺寸** - 支持 small、medium、large 三种尺寸
6. **颜色主题** - 支持 primary、info、success、warning、danger 五种颜色

### 交互功能
1. **行选择** - 支持 checkbox 选择行（单选/多选/全选）
2. **行点击** - 支持整行点击事件
3. **排序** - 基础的单列排序功能
4. **分页** - 内置分页组件，支持页码跳转

### 样式功能
1. **固定表头** - sticky_header 属性实现表头固定
2. **响应式** - 移动端适配的分页显示
3. **暗色模式** - 支持 dark mode
4. **自定义样式** - 通过 class 属性自定义样式

## 二、Ant Design Table 独有功能（Phoenix 未实现）

### 高级数据功能
1. **树形数据** - 支持树状结构数据展示
2. **展开行** - 可展开行显示更多内容
3. **嵌套子表格** - 在展开行中嵌套另一个表格
4. **虚拟滚动** - 大数据量优化渲染
5. **行/列合并** - colspan 和 rowspan 支持

### 高级筛选功能
1. **列筛选** - 每列独立的筛选器
2. **筛选菜单** - 内置筛选下拉菜单
3. **自定义筛选** - 自定义筛选组件
4. **树形筛选** - 支持树状筛选选项
5. **筛选搜索** - 筛选项支持搜索

### 高级排序功能
1. **多列排序** - 同时对多列进行排序
2. **自定义排序** - 自定义排序函数
3. **排序提示** - 排序图标和 tooltip
4. **默认排序** - 初始加载时的默认排序

### 高级选择功能
1. **单选模式** - radio 类型选择
2. **选择框固定** - 选择列可固定在左侧
3. **自定义选择** - 自定义选择框渲染
4. **跨页选择** - preserveSelectedRowKeys
5. **选择回调** - 更丰富的选择事件回调

### 列功能增强
1. **固定列** - 左右固定列（fixed: 'left' | 'right'）
2. **列分组** - 多级表头（ColumnGroup）
3. **列宽调整** - 可拖拽调整列宽
4. **响应式列** - 根据屏幕大小显示/隐藏列
5. **省略提示** - 文本省略和 tooltip

### 编辑功能
1. **单元格编辑** - 可编辑单元格
2. **行编辑** - 整行编辑模式
3. **表单验证** - 编辑时的数据验证

### 拖拽功能
1. **行拖拽排序** - 拖拽改变行顺序
2. **列拖拽排序** - 拖拽改变列顺序
3. **拖拽手柄** - 专门的拖拽控制区域

### 其他高级功能
1. **总结栏** - 表格底部的统计行
2. **Ajax 数据加载** - 异步加载数据
3. **动态表格设置** - 运行时改变表格配置
4. **导出功能** - 数据导出（需配合其他库）
5. **打印优化** - 打印时的样式优化

## 三、实现复杂度对比

### Phoenix Table 优势
1. **轻量级** - 功能精简，代码量小
2. **LiveView 集成** - 与 Phoenix LiveView 深度整合
3. **服务端渲染** - SSR 友好
4. **简单易用** - API 简洁，学习成本低

### Ant Design Table 优势
1. **功能全面** - 几乎涵盖所有表格场景
2. **生态完善** - 丰富的示例和文档
3. **社区活跃** - 持续更新和 bug 修复
4. **企业级** - 适合复杂业务场景

## 四、建议补充的功能

基于对比分析，Phoenix Table 可以考虑逐步添加以下功能：

### 优先级高
1. **列筛选** - 基础的筛选功能
2. **固定列** - 左右固定列
3. **文本省略** - 超长文本处理
4. **展开行** - 显示更多信息

### 优先级中
1. **多列排序** - 增强排序功能
2. **树形数据** - 支持层级数据
3. **列宽调整** - 提升交互体验
4. **虚拟滚动** - 大数据优化

### 优先级低
1. **行编辑** - 简单的编辑功能
2. **拖拽排序** - 增强交互
3. **总结栏** - 统计功能
4. **响应式列** - 移动端优化

## 五、Phoenix LiveView Table 推荐实现的功能

基于 LiveView 的特性和实际需求，以下功能值得在 Phoenix Table 中实现：

### 列宽控制和文本省略
当前表格列宽完全由内容撑开，需要添加列宽控制能力。可以为每个列添加 width 属性来控制列宽分配，同时添加 ellipsis 属性实现文本省略。这在 Ant Design 中的实现位于：
- **列宽定义**：`components/table/interface.ts` 中 ColumnType 的 width 属性
- **文本省略**：`components/table/style/ellipsis.ts` 处理省略样式
- **示例代码**：`components/table/demo/ellipsis.tsx` 和 `ellipsis-custom-tooltip.tsx`

### 固定列功能
当表格列数较多需要横向滚动时，固定重要列（如 ID、操作列）能提升体验。通过 CSS position: sticky 即可实现，无需 JavaScript。Ant Design 的实现参考：
- **列固定定义**：`components/table/interface.ts` 中 ColumnType 的 fixed 属性（'left' | 'right'）
- **样式实现**：`components/table/style/fixed.ts` 处理固定列样式
- **示例代码**：`components/table/demo/fixed-columns.tsx` 展示左右固定列

### 简化的筛选接口
不需要在每列内置筛选器，而是提供筛选事件接口，让开发者在 LiveView 中处理。Ant Design 的筛选实现可以参考但不必照搬：
- **筛选逻辑**：`components/table/hooks/useFilter/` 文件夹
- **筛选接口**：`components/table/interface.ts` 中的 FilterDropdownProps
- **简化参考**：主要参考事件触发机制，而非完整的筛选 UI

### 批量操作优化
增加 selection_actions slot，当有行被选中时显示批量操作区域。Ant Design 的实现：
- **选择逻辑**：`components/table/hooks/useSelection.tsx`
- **示例代码**：`components/table/demo/row-selection-and-operation.tsx` 展示选择和操作结合

### 加载状态
添加 loading 属性显示加载反馈。Ant Design 通过 Spin 组件包裹实现：
- **加载实现**：`components/table/InternalTable.tsx` 中处理 loading 属性
- **示例代码**：`components/table/demo/ajax.tsx` 展示加载状态

### 响应式优化
添加 responsive 属性，在小屏幕上优化显示。Ant Design 的实现：
- **响应式定义**：`components/table/interface.ts` 中 ColumnType 的 responsive 属性
- **响应式逻辑**：`components/_util/responsiveObserver.ts` 处理断点
- **示例代码**：`components/table/demo/responsive.tsx`

## 六、实现建议

这些功能都应该遵循 LiveView 的设计理念：

服务端状态管理是 LiveView 的核心优势，不需要像 Ant Design 那样在组件内管理复杂状态。所有的筛选、排序、选择状态都应该在 LiveView 模块的 assigns 中管理，组件只负责展示和触发事件。

性能优化策略也不同。Ant Design 的虚拟滚动等优化是为了解决客户端渲染大量 DOM 的问题，而 LiveView 通过服务端渲染和增量更新本身就避免了这个问题。LiveView 只传输变化的部分，不需要在客户端维护完整数据集。

交互设计应该简化。Ant Design 的很多复杂交互（如行内编辑、拖拽排序）依赖客户端状态，在 LiveView 中实现会导致频繁的服务端往返。应该选择更适合服务端渲染的交互方式，比如点击进入编辑页面，而不是行内编辑。

样式实现可以大量借鉴。Ant Design 在 `components/table/style/` 目录下的 CSS 实现都可以参考，特别是固定列、文本省略、响应式等纯样式功能，这些不依赖 JavaScript 的功能在 LiveView 中可以直接使用。

## 七、总结

Phoenix Table 应该专注于发挥 LiveView 的优势，而不是机械复制 JavaScript 组件的所有功能。推荐实现的功能都是能够通过纯 CSS 或简单的服务端事件处理完成的，保持了组件的简洁性和 LiveView 的架构优势。