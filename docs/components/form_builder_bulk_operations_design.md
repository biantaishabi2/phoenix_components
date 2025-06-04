# FormBuilder 批量操作功能设计文档

## 概述

本文档详细设计FormBuilder组件的批量操作功能，包括文件导入、数据验证、错误处理和用户反馈机制。

## 设计目标

### 主要功能
1. **文件导入支持**: Excel (.xlsx) 和 CSV (.csv) 文件导入
2. **智能字段映射**: 自动识别和映射表头到表单字段
3. **批量数据验证**: 使用现有的Changeset验证规则
4. **错误处理**: 详细的错误报告和恢复机制
5. **进度反馈**: 实时显示导入进度和状态
6. **历史记录**: 保存导入记录和映射设置

### 设计原则
- **向后兼容**: 不影响现有FormBuilder功能
- **可配置**: 通过配置启用批量操作功能
- **用户友好**: 提供直观的导入界面和清晰的错误信息
- **性能优化**: 支持大文件的流式处理

## 系统架构

### 组件结构
```
FormBuilder (主组件)
├── BulkImportDialog (批量导入对话框)
├── FileUploader (文件上传器)
├── FieldMapper (字段映射器)
├── ValidationResults (验证结果显示)
└── ImportHistory (导入历史)
```

### 数据流
```
文件上传 → 解析数据 → 字段映射 → 数据验证 → 批量保存 → 结果反馈
```

## API 设计

### FormBuilder 新增属性

```elixir
# 启用批量操作功能
bulk_operations: true | false (默认: false)

# 批量操作配置
bulk_config: %{
  # 支持的文件类型
  accepted_file_types: [".xlsx", ".csv"],
  
  # 最大文件大小 (字节)
  max_file_size: 50 * 1024 * 1024,  # 50MB
  
  # 批量验证函数
  validate_batch: &validate_batch_data/1,
  
  # 批量保存函数
  save_batch: &save_batch_data/1,
  
  # 字段映射规则
  field_mapping: %{
    "姓名" => "name",
    "邮箱" => "email",
    "电话" => "phone"
  },
  
  # 历史记录配置
  history: %{
    enabled: true,
    max_records: 100
  }
}
```

### 事件处理

```elixir
# 批量导入事件
handle_event("bulk_import", params, socket)

# 字段映射确认
handle_event("confirm_field_mapping", params, socket)

# 验证结果处理
handle_event("process_validation_results", params, socket)

# 导入历史查看
handle_event("view_import_history", params, socket)
```

## 数据格式要求

### Excel 文件格式
- **文件扩展名**: .xlsx
- **工作表**: 使用第一个工作表
- **表头**: 第一行作为字段名
- **数据行**: 从第二行开始
- **最大行数**: 10,000行（可配置）

```
示例Excel格式:
| 姓名   | 邮箱            | 电话        | 部门     |
|--------|----------------|-------------|----------|
| 张三   | zhang@test.com | 13800138000 | 技术部   |
| 李四   | li@test.com    | 13900139000 | 销售部   |
```

### CSV 文件格式
- **文件扩展名**: .csv
- **编码**: UTF-8
- **分隔符**: 逗号 (,)
- **引号**: 双引号 (") 用于包含逗号的字段
- **换行符**: LF (\n) 或 CRLF (\r\n)

```
示例CSV格式:
姓名,邮箱,电话,部门
张三,zhang@test.com,13800138000,技术部
李四,li@test.com,13900139000,销售部
```

### 字段类型映射

| 表单字段类型 | 支持的导入格式 | 转换规则 |
|-------------|---------------|----------|
| input       | 文本         | 直接映射 |
| email       | 文本         | 邮箱格式验证 |
| number      | 数字/文本     | 转换为数字 |
| date        | 日期/文本     | 解析日期格式 |
| select      | 文本         | 匹配选项值或标签 |
| checkbox    | 布尔/文本     | true/false/是/否 |

## 错误处理机制

### 错误类型分类

#### 1. 文件级错误
- **文件格式不支持**: 提示支持的文件类型
- **文件大小超限**: 显示最大文件大小限制
- **文件损坏**: 提示重新上传
- **编码错误**: 建议使用UTF-8编码

#### 2. 数据级错误
- **字段映射失败**: 显示未映射的字段
- **数据类型错误**: 指出具体的类型转换问题
- **必填字段缺失**: 列出缺失的必填字段
- **数据格式错误**: 提供正确的格式示例

#### 3. 验证级错误
- **单行验证失败**: 显示具体的行号和错误信息
- **重复数据**: 检测并标记重复记录
- **业务规则违反**: 应用自定义验证规则

### 错误报告格式

```elixir
%{
  status: :error | :partial_success | :success,
  total_rows: 1000,
  processed_rows: 850,
  success_count: 800,
  error_count: 50,
  errors: [
    %{
      row: 15,
      field: "email",
      value: "invalid-email",
      message: "邮箱格式不正确",
      type: :validation_error
    },
    %{
      row: 23,
      field: "phone",
      value: "abc",
      message: "电话号码必须是数字",
      type: :format_error
    }
  ],
  warnings: [
    %{
      row: 45,
      field: "department",
      value: "研发部",
      message: "部门名称已自动映射为'技术部'",
      type: :auto_correction
    }
  ]
}
```

## 用户界面设计

### 导入流程界面

#### 1. 文件上传阶段
```heex
<div class="bulk-import-upload">
  <div class="upload-area">
    <.icon name="upload" />
    <p>点击上传或拖拽Excel/CSV文件到此处</p>
    <p class="text-gray-500">支持 .xlsx 和 .csv 格式，最大50MB</p>
  </div>
  
  <div class="upload-progress" :if={@uploading}>
    <.progress value={@upload_progress} />
    <p>上传中... {@upload_progress}%</p>
  </div>
</div>
```

#### 2. 字段映射阶段
```heex
<div class="field-mapping">
  <h3>字段映射确认</h3>
  <p>请确认Excel/CSV表头与表单字段的对应关系：</p>
  
  <div class="mapping-table">
    <div class="mapping-row" :for={{header, field} <- @field_mappings}>
      <div class="source-field">{header}</div>
      <.icon name="arrow-right" />
      <div class="target-field">
        <.select options={@form_fields} value={field} name="mapping[#{header}]" />
      </div>
    </div>
  </div>
  
  <div class="mapping-actions">
    <.button phx-click="auto_map_fields">智能映射</.button>
    <.button phx-click="save_mapping">保存映射</.button>
  </div>
</div>
```

#### 3. 验证结果阶段
```heex
<div class="validation-results">
  <div class="results-summary">
    <.statistic title="总计" value={@total_rows} />
    <.statistic title="成功" value={@success_count} status="success" />
    <.statistic title="失败" value={@error_count} status="error" />
  </div>
  
  <div class="error-details" :if={@error_count > 0}>
    <h4>错误详情</h4>
    <.table rows={@errors}>
      <:col :let={error} label="行号">{error.row}</:col>
      <:col :let={error} label="字段">{error.field}</:col>
      <:col :let={error} label="值">{error.value}</:col>
      <:col :let={error} label="错误信息">{error.message}</:col>
    </.table>
  </div>
  
  <div class="results-actions">
    <.button phx-click="download_error_report">下载错误报告</.button>
    <.button phx-click="import_valid_data" :if={@success_count > 0}>
      导入有效数据 ({@success_count}条)
    </.button>
  </div>
</div>
```

### 历史记录界面

```heex
<div class="import-history">
  <h3>导入历史</h3>
  
  <.table rows={@import_history}>
    <:col :let={record} label="导入时间">{record.imported_at}</:col>
    <:col :let={record} label="文件名">{record.filename}</:col>
    <:col :let={record} label="总行数">{record.total_rows}</:col>
    <:col :let={record} label="成功数">{record.success_count}</:col>
    <:col :let={record} label="状态">
      <.status_badge status={record.status} />
    </:col>
    <:col :let={record} label="操作">
      <.button size="small" phx-click="view_details" phx-value-id={record.id}>
        查看详情
      </.button>
    </:col>
  </.table>
</div>
```

## 性能优化策略

### 1. 文件处理优化
- **流式解析**: 使用流式API避免内存溢出
- **分批处理**: 将大文件分批次处理
- **异步处理**: 后台处理避免界面阻塞
- **进度反馈**: 实时更新处理进度

### 2. 数据验证优化
- **并行验证**: 多进程并行验证数据
- **早期失败**: 遇到严重错误立即停止
- **缓存映射**: 缓存字段映射关系
- **增量验证**: 只验证变化的数据

### 3. 用户体验优化
- **预览功能**: 导入前预览前几行数据
- **智能映射**: 基于历史记录智能推荐映射
- **错误导出**: 支持导出错误数据进行修正
- **断点续传**: 支持大文件的断点续传

## 安全考虑

### 1. 文件安全
- **文件类型验证**: 严格验证文件MIME类型
- **文件大小限制**: 防止过大文件攻击
- **病毒扫描**: 集成病毒扫描（可选）
- **临时文件清理**: 及时清理临时文件

### 2. 数据安全
- **输入验证**: 严格验证所有输入数据
- **SQL注入防护**: 使用参数化查询
- **权限检查**: 验证用户导入权限
- **敏感数据**: 特殊处理敏感字段

### 3. 操作审计
- **导入记录**: 记录所有导入操作
- **用户跟踪**: 记录操作用户信息
- **数据变更**: 跟踪数据变更历史
- **错误日志**: 详细记录错误信息

## 配置示例

### 基础配置
```elixir
config = %{
  bulk_operations: true,
  bulk_config: %{
    accepted_file_types: [".xlsx", ".csv"],
    max_file_size: 50 * 1024 * 1024,
    batch_size: 1000,
    timeout: 300_000,  # 5分钟
    field_mapping: %{
      "姓名" => "name",
      "邮箱" => "email",
      "手机" => "phone"
    }
  }
}
```

### 高级配置
```elixir
config = %{
  bulk_operations: true,
  bulk_config: %{
    # 文件配置
    file_config: %{
      accepted_types: [".xlsx", ".csv"],
      max_size: 100 * 1024 * 1024,
      encoding: "utf-8"
    },
    
    # 处理配置
    processing: %{
      batch_size: 500,
      max_workers: 4,
      timeout: 600_000
    },
    
    # 验证配置
    validation: %{
      strict_mode: false,
      auto_correct: true,
      custom_validators: [&validate_phone_format/1]
    },
    
    # 历史配置
    history: %{
      enabled: true,
      retention_days: 30,
      max_records: 1000
    }
  }
}
```

## 扩展点

### 1. 自定义文件解析器
```elixir
defmodule MyCustomParser do
  @behaviour ShopUxPhoenix.BulkOperations.FileParser
  
  def parse_file(file_path, options \\ []) do
    # 自定义解析逻辑
  end
end
```

### 2. 自定义验证器
```elixir
defmodule MyCustomValidator do
  def validate_batch(data, config) do
    # 自定义批量验证逻辑
  end
end
```

### 3. 自定义保存器
```elixir
defmodule MyCustomSaver do
  def save_batch(data, config) do
    # 自定义批量保存逻辑
  end
end
```

## 总结

批量操作功能将为FormBuilder组件带来强大的数据导入能力，支持Excel和CSV文件的智能解析、字段映射、数据验证和错误处理。通过合理的架构设计和用户界面，能够提供良好的用户体验和稳定的性能表现。

下一步将编写详细的测试用例文档，确保功能的可靠性和稳定性。