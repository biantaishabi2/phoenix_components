# 待实现组件列表

本文档记录所有待实现的组件，包括基础组件和业务组件，以及它们的实现流程。

## 实现流程

每个组件都遵循以下实现流程：
1. 阅读Vue实现
2. 阅读规范
3. 写文档
4. 写测试（含LiveView测试）
5. 实现
6. 调试通过

## 待实现组件

### ~~1. DataCard 数据卡片~~（已跳过）
- **跳过原因**: 功能与已实现的 Statistic 组件重复，项目中实际使用的就是 Statistic
- **建议**: 直接使用 `<.statistic>` 组件


### ~~2. ImportExport 导入导出~~（已跳过）
- **跳过原因**: 这是功能模块而非 UI 组件，需要与后端紧密集成，每个业务模块的需求不同
- **建议**: 在具体业务功能中实现，如"商品批量导入"、"订单导出"等




### 3. MediaUploader 媒体上传（中优先级）
- **描述**: 图片/视频上传组件
- **参考文件**: 在商品编辑等页面中查找
- **关键功能**:
  - 拖拽上传
  - 预览功能
  - 批量上传
  - 裁剪功能


### ~~4. RichTextEditor 富文本编辑器~~（已跳过）
- **跳过原因**: 需要依赖外部 JS 库（如 Quill、Trix），违背自包含原则
- **建议**: 在需要的业务页面直接集成富文本库，或使用增强的 textarea


### ~~5. Calendar 日历~~（已跳过）
- **跳过原因**: Vue 项目中未使用该组件，DatePicker 已提供日期选择功能
- **建议**: 使用 DatePicker 满足日期选择需求，如需日历视图可后续按需实现


### ~~6. Dashboard 仪表盘~~（已跳过）
- **跳过原因**: 这是页面而非组件，主要是图表库的集成
- **建议**: 在具体页面中根据需求集成 Chart.js、ECharts 等图表库

### ~~7. Analytics 数据分析~~（已跳过）
- **跳过原因**: 这是页面而非组件，属于业务功能
- **建议**: 在具体的数据分析页面中实现，使用合适的图表库

## 其他任务

### ✅ 21. 调查哪些组件依赖外部CSS/JS（已完成）
- 已完成所有组件的依赖调查
- InputNumber 和 Switch 组件的外部依赖已移除

### ✅ 22. 重构 InputNumber 组件移除外部CSS/JS依赖（已完成）
- 已将所有样式转换为内联 Tailwind 类
- 组件现在完全自包含

### ✅ 23. 重构 Switch 组件移除外部CSS/JS依赖（已完成）
- 已将所有样式转换为内联 Tailwind 类
- 组件现在完全自包含

## 已完成的组件

### 基础组件 (PetalComponents.Custom.*)
1. ✅ Button 按钮
2. ✅ Modal 对话框
3. ✅ Table 表格
4. ✅ Select 选择器
5. ✅ DatePicker 日期选择器
6. ✅ Cascader 级联选择器
7. ✅ TreeSelect 树形选择器
8. ✅ Steps 步骤条
9. ✅ Tag 标签
10. ✅ Statistic 统计数值
11. ✅ RangePicker 日期范围选择器
12. ✅ InputNumber 数字输入框
13. ✅ Switch 开关
14. ✅ Tabs 标签页
15. ✅ Dropdown 下拉菜单
16. ✅ Progress 进度条
17. ✅ Tooltip 文字提示

### 业务组件 (ShopUxPhoenixWeb.BusinessComponents.*)
18. ✅ AppLayout 应用布局框架
19. ✅ FilterForm 筛选表单
20. ✅ SearchableSelect 可搜索选择器
21. ✅ Breadcrumb 面包屑导航
22. ✅ Card 卡片组件
23. ✅ StatusBadge 状态徽章
24. ✅ ActionButtons 操作按钮组
25. ✅ AddressSelector 地址选择器
26. ✅ Timeline 时间线
27. ✅ FormBuilder 表单构建器

## 实现优先级说明

- **中优先级**: DataCard、ImportExport（业务常用功能）  
- **低优先级**: MediaUploader、RichTextEditor（用户明确要求放到最后）
- **低优先级**: Calendar、Dashboard、Analytics（辅助功能）

## 注意事项

1. 所有组件都应该是自包含的，使用内联 Tailwind CSS，避免外部 CSS 依赖
2. 遵循 Petal Components 的设计规范
3. 确保组件有完整的文档和测试
4. LiveView 测试文件命名规范：`组件名_demo_live_test.exs`
5. 组件测试文件命名规范：`组件名_test.exs`