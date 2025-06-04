# Table 组件重构计划

## 🎯 重构目标

当前 `table.ex` 文件在添加固定列功能后将接近 600-700 行，需要进行模块化拆分以提高可维护性。

## 📊 当前状态

- **文件**: `lib/shop_ux_phoenix_web/components/table.ex`
- **当前行数**: 450 行
- **预计添加固定列后**: 600-700 行

## 📁 计划的文件结构

```
lib/shop_ux_phoenix_web/components/
├── table.ex                    # 主组件文件（~200行）
└── table/
    ├── width.ex               # 列宽功能（~80-100行）
    ├── ellipsis.ex            # 文本省略功能（~50-80行）
    ├── selection.ex           # 选择功能（~100-120行）
    ├── sorting.ex             # 排序功能（~80-100行）
    ├── pagination.ex          # 分页功能（~60-80行）
    ├── fixed_columns.ex       # 固定列功能（~150-200行）
    ├── styles.ex              # CSS 类生成函数（~80行）
    └── helpers.ex             # 通用辅助函数（~50行）
```

## 🔧 重构策略

### 阶段 1：功能模块化（优先）
将各个功能拆分为独立模块，每个模块负责：
- 处理相关的 assigns
- 生成对应的 CSS 类
- 提供功能相关的辅助函数

### 阶段 2：主文件简化
`table.ex` 将只负责：
- 组件的主要结构
- 调用各个功能模块
- 渲染最终的 HTML

### 阶段 3：测试文件整理
相应地整理测试文件：
```
test/shop_ux_phoenix_web/components/
├── table_test.exs                    # 基础功能测试
├── table_width_test.exs              # 列宽测试
├── table_ellipsis_test.exs           # 省略号测试
├── table_selection_test.exs          # 选择功能测试
├── table_sorting_test.exs            # 排序测试
├── table_pagination_test.exs         # 分页测试
└── table_fixed_columns_test.exs      # 固定列测试（已创建）
```

## 📝 模块接口设计

### 1. Width 模块
```elixir
defmodule ShopUxPhoenixWeb.Components.Table.Width do
  def process_width_attributes(assigns)
  def build_width_style(col)
  def build_width_style_string(width, min_width, max_width)
end
```

### 2. FixedColumns 模块
```elixir
defmodule ShopUxPhoenixWeb.Components.Table.FixedColumns do
  def process_fixed_columns(assigns)
  def build_fixed_column_classes(col, position_info, type \\ :normal)
  def build_fixed_column_style(col, position_info)
  def calculate_left_fixed_positions(cols)
  def calculate_right_fixed_positions(cols)
end
```

### 3. Selection 模块
```elixir
defmodule ShopUxPhoenixWeb.Components.Table.Selection do
  def process_selection(assigns)
  def render_checkbox(row, assigns)
  def handle_selection_events(params, socket)
end
```

## 🚀 实施计划

### 时机
在完成固定列功能并通过所有测试后进行重构（任务 #30）

### 步骤
1. 创建新的模块文件
2. 逐步移动功能代码到对应模块
3. 在主文件中导入和使用模块
4. 运行测试确保功能正常
5. 优化模块间的接口

### 优势
- **可维护性**: 每个文件专注单一功能
- **可测试性**: 独立测试各个模块
- **可复用性**: 其他组件可以使用这些模块
- **性能**: 编译更快，热重载更高效
- **团队协作**: 多人可以同时开发不同模块

## ⚠️ 注意事项

1. **保持向后兼容**: 重构不应该改变组件的公共 API
2. **测试覆盖**: 确保所有功能都有测试保护
3. **文档更新**: 重构后更新相关文档
4. **渐进式重构**: 一次只移动一个功能模块

## 📅 时间线

- **当前**: 实现固定列功能（任务 #22-29）
- **功能完成后**: 开始重构（任务 #30）
- **预计时间**: 2-3 天完成重构

## 🎉 预期结果

重构后的代码结构将：
- 更易于理解和维护
- 方便添加新功能
- 提高开发效率
- 便于团队协作