# PetalComponents 演示页面 TODO

本文档追踪 PetalComponents 演示页面的实现进度。PetalComponents 库共包含 30 个组件。

## 实现进度

### ✅ 已完成 (16/30)
- [x] **Button** - 按钮组件（包含所有变体、尺寸、状态等）
  - 基础用法
  - 不同尺寸 (xs, sm, md, lg, xl)
  - 按钮变体 (solid, light, outline, inverted, shadow, ghost)
  - 圆角设置 (none, sm, md, lg, xl, full)
  - 按钮状态 (disabled, loading, with icon)
  - 图标按钮 (icon_button)

- [x] **Field** - 表单字段包装器
  - 基础字段
  - 带错误提示的字段
  - 带帮助文本的字段

- [x] **Form** - 表单组件
  - 基础表单示例
  - 表单提交处理

- [x] **Input** - 输入框组件
  - 各种输入框类型（text, email, password, number, url, tel, search, date, time, datetime-local）
  - 输入框状态（disabled, readonly, required）
  - 输入框尺寸（sm, md, lg）
  - 特殊输入框（textarea, select, checkbox, radio, switch, range, color, file）
  - 输入框装饰（copyable, clearable, viewable）

- [x] **Alert** - 警告提示
  - 基础警告（info, success, warning, danger）
  - 带图标的警告
  - 带标题的警告
  - 可关闭的警告
  - 不同变体（light, soft, dark, outline）

- [x] **Loading** - 加载状态（Spinner）
  - 基础加载动画
  - 不同尺寸（sm, md, lg）
  - 自定义颜色
  - 条件显示

- [x] **Progress** - 进度条
  - 基础进度条
  - 不同颜色（primary, secondary, info, success, warning, danger, gray）
  - 不同尺寸（xs, sm, md, lg, xl）
  - 自定义最大值
  - 带标签的进度条

- [x] **Skeleton** - 骨架屏
  - 默认骨架屏
  - 文本骨架屏
  - 卡片骨架屏
  - 列表骨架屏
  - 图片骨架屏
  - 小部件骨架屏

- [x] **Modal** - 模态框
  - 基础模态框
  - 确认对话框
  - 不同尺寸（sm, md, lg, xl, 2xl, full）
  - 模态框显示/隐藏功能

- [x] **SlideOver** - 侧滑面板
  - 不同方向（right, left, top, bottom）
  - 不同尺寸（sm, md, lg, xl）
  - 面板显示/隐藏功能

- [x] **Table** - 表格组件
  - 基础表格
  - 可点击行的表格
  - 空状态表格
  - 与其他组件（Badge）的集成

- [x] **Card** - 卡片组件
  - 基础卡片（basic, outline）
  - 带媒体的卡片
  - 卡片内容区（heading, category）
  - 卡片页脚

- [x] **Badge** - 徽章组件
  - 基础用法（所有颜色）
  - 不同尺寸（xs, sm, md, lg, xl）
  - 不同变体（light, dark, soft, outline）
  - 带图标的徽章

- [x] **Avatar** - 头像组件
  - 图片头像
  - 名字首字母头像
  - 默认头像
  - 不同尺寸
  - 随机颜色
  - 头像组（avatar_group）

- [x] **Rating** - 评分组件
  - 基础评分（0-5星）
  - 半星显示
  - 自定义总星数
  - 带标签的评分
  - 不同尺寸

- [x] **Marquee** - 滚动文本组件
  - 水平滚动
  - 反向滚动
  - 悬停暂停
  - 自定义速度

### 📝 待实现 (14/30)

#### 表单组件
✅ 表单组件组已完成

#### 反馈组件
✅ 反馈组件组已完成

#### 数据展示
✅ 数据展示组件组已完成

#### 导航组件
- [ ] **Breadcrumbs** - 面包屑导航
- [ ] **Dropdown** - 下拉菜单
- [ ] **Menu** - 菜单组件
- [ ] **UserDropdownMenu** - 用户下拉菜单
- [ ] **Pagination** - 分页组件
- [ ] **Tabs** - 标签页
- [ ] **Stepper** - 步骤条
- [ ] **Link** - 链接组件

#### 布局组件
- [ ] **Container** - 容器组件
- [ ] **Accordion** - 折叠面板
- [ ] **ButtonGroup** - 按钮组

#### 其他组件
- [ ] **Icon** - 图标组件（展示 HeroiconsV1 的使用）
- [ ] **Typography** - 排版组件

## 实现建议

1. **分组展示**：按照上述分类，将相关组件放在同一个区域展示
2. **交互示例**：每个组件都应包含交互示例，展示事件处理
3. **配置选项**：展示每个组件的主要配置选项和变体
4. **代码示例**：考虑在每个组件下方添加代码示例
5. **响应式**：确保所有组件在移动端也能正常显示

## 下一步

建议按照以下顺序实现：
1. 先实现常用的表单组件（Field, Form, Input）
2. 然后是反馈组件（Alert, Loading, Modal）
3. 接着是数据展示组件（Table, Card, Badge）
4. 最后是导航和布局组件

每个组件的实现应包括：
- 基础用法
- 主要变体/样式
- 尺寸选项
- 状态展示（如禁用、加载等）
- 事件处理示例（如适用）