# Shop UX Phoenix 组件统计报告

## 概览

本报告统计了 Shop UX Phoenix 项目中所有可用的组件，包括 Phoenix 原生组件、自定义组件和 PetalComponents 提供的组件。

## 1. Phoenix 原生组件 (core_components.ex)

从 `lib/shop_ux_phoenix_web/components/core_components.ex` 文件中定义的组件：

1. **modal** - 模态框组件
2. **flash** - Flash 消息通知组件
3. **flash_group** - Flash 消息组组件
4. **simple_form** - 简单表单组件
5. **button** - 按钮组件（支持多种颜色主题）
6. **input** - 输入组件（支持多种类型）
7. **label** - 标签组件
8. **error** - 错误消息组件
9. **header** - 页头组件
10. **table** - 表格组件
11. **list** - 数据列表组件
12. **back** - 返回导航链接组件
13. **icon** - 图标组件（使用 Heroicons）

**小计：13 个组件**

## 2. 自定义组件（从 shop_ux_components.ex 导入）

从 `lib/shop_ux_phoenix_web/components/shop_ux_components.ex` 文件的导入列表中获取：

### 基础 UI 组件
1. **Table** - 增强版表格组件
2. **Select** - 选择器组件
3. **Tag** - 标签组件
4. **Statistic** - 统计数值组件
5. **Steps** - 步骤条组件
6. **DatePicker** - 日期选择器组件
7. **RangePicker** - 日期范围选择器组件
8. **Cascader** - 级联选择器组件
9. **TreeSelect** - 树形选择器组件
10. **InputNumber** - 数字输入框组件
11. **Switch** - 开关组件
12. **Tabs** - 标签页组件
13. **Dropdown** - 下拉菜单组件
14. **Progress** - 进度条组件
15. **Tooltip** - 工具提示组件
16. **FilterForm** - 筛选表单组件
17. **SearchableSelect** - 可搜索选择器组件
18. **Breadcrumb** - 面包屑导航组件
19. **Card** - 卡片组件
20. **StatusBadge** - 状态徽章组件
21. **ActionButtons** - 操作按钮组组件
22. **AddressSelector** - 地址选择器组件
23. **Timeline** - 时间线组件
24. **FormBuilder** - 表单构建器组件
25. **MediaUpload** - 媒体上传组件

### 业务组件
26. **AppLayout** - 应用布局组件

**小计：26 个组件**

## 3. PetalComponents 库提供的组件 (v2.9.3)

项目使用了 PetalComponents 2.9.3 版本，该库提供了以下组件：

1. **accordion** - 手风琴/折叠面板组件
2. **alert** - 警告提示组件
3. **avatar** - 头像组件
4. **badge** - 徽章组件
5. **breadcrumbs** - 面包屑导航组件
6. **button** - 按钮组件
7. **button_group** - 按钮组组件
8. **card** - 卡片组件
9. **container** - 容器组件
10. **dropdown** - 下拉菜单组件
11. **field** - 表单字段组件
12. **form** - 表单组件
13. **icon** - 图标组件
14. **input** - 输入组件
15. **link** - 链接组件
16. **loading** - 加载状态组件
17. **marquee** - 跑马灯组件
18. **menu** - 菜单组件
19. **modal** - 模态框组件
20. **pagination** - 分页组件
21. **progress** - 进度条组件
22. **rating** - 评分组件
23. **skeleton** - 骨架屏组件
24. **slide_over** - 侧滑面板组件
25. **stepper** - 步进器组件
26. **table** - 表格组件
27. **tabs** - 标签页组件
28. **typography** - 排版组件
29. **user_dropdown_menu** - 用户下拉菜单组件

**小计：29 个组件**

## 4. 总计

- Phoenix 原生组件：**13 个**
- 自定义组件：**26 个**
- PetalComponents 组件：**29 个**

**总计：68 个可用组件**

## 注意事项

1. **组件重复**：某些组件在不同层次都有实现（如 table、dropdown、tabs 等），这提供了不同级别的功能和定制选项。

2. **命名空间**：
   - Phoenix 原生组件：直接在 `ShopUxPhoenixWeb.CoreComponents` 中定义
   - 自定义组件：在 `ShopUxPhoenixWeb.Components.*` 命名空间中
   - PetalComponents：在 `PetalComponents.*` 命名空间中

3. **使用方式**：
   - 通过 `use ShopUxPhoenixWeb.ShopUxComponents` 可以一次性导入所有自定义组件
   - PetalComponents 需要单独导入或通过配置使用

4. **扩展性**：项目采用了模块化的组件架构，便于添加新组件或扩展现有组件的功能。