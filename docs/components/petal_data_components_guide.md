# PetalComponents 数据展示组件使用指南

本文档详细介绍了 PetalComponents 库中的数据展示组件，包括 Table、Card、Badge、Avatar、Rating 和 Marquee 组件的使用方法和所有可用属性。

## 目录

1. [Table 表格组件](#table-表格组件)
2. [Card 卡片组件](#card-卡片组件)
3. [Badge 徽章组件](#badge-徽章组件)
4. [Avatar 头像组件](#avatar-头像组件)
5. [Rating 评分组件](#rating-评分组件)
6. [Marquee 跑马灯组件](#marquee-跑马灯组件)

## Table 表格组件

Table 组件用于展示结构化的表格数据。

### 基础用法

```elixir
<.table id="users-table" rows={@users}>
  <:col :let={user} label="ID"><%= user.id %></:col>
  <:col :let={user} label="姓名"><%= user.name %></:col>
  <:col :let={user} label="邮箱"><%= user.email %></:col>
</.table>
```

### 必需属性

- `id` (string): 表格的唯一标识符
- `rows` (list): 要渲染的数据行列表

### 可选属性

- `class` (any): 自定义 CSS 类
- `variant` (string): 表格样式变体，可选值："basic"（默认）、"ghost"
- `row_id` (function): 生成行 ID 的函数
- `row_click` (function): 处理行点击事件的函数
- `row_item` (function): 映射每行数据的函数，默认为 `Function.identity/1`

### 插槽

- `:col` - 表格列
  - `label` (string): 列标题
  - `class` (any): 列的 CSS 类
  - `row_class` (any): 单元格的 CSS 类
- `:empty_state` - 空数据时显示的内容
  - `row_class` (any): 空状态行的 CSS 类

### 高级用法示例

#### 可点击的表格行

```elixir
<.table 
  id="clickable-table" 
  rows={@users}
  row_id={fn user -> "user-#{user.id}" end}
  row_click={fn user -> JS.push("select_user", value: %{id: user.id}) end}
>
  <:col :let={user} label="姓名"><%= user.name %></:col>
</.table>
```

#### 带用户信息的表格

```elixir
<.table id="user-table" rows={@users}>
  <:col :let={user} label="用户">
    <.user_inner_td 
      avatar_assigns={%{src: user.avatar, name: user.name, size: "sm"}}
      label={user.name}
      sub_label={user.email}
    />
  </:col>
  <:col :let={user} label="状态">
    <.badge color={if user.active, do: "success", else: "gray"}>
      <%= if user.active, do: "活跃", else: "未激活" %>
    </.badge>
  </:col>
</.table>
```

#### 空数据状态

```elixir
<.table id="empty-table" rows={[]}>
  <:col label="ID"></:col>
  <:col label="姓名"></:col>
  <:empty_state>
    <div class="text-center py-8 text-gray-500">
      暂无数据
    </div>
  </:empty_state>
</.table>
```

### 辅助组件

#### user_inner_td

用于在表格单元格中显示用户信息（头像+文字）。

属性：
- `avatar_assigns` (map): 传递给 avatar 组件的属性
- `label` (string): 主标签文字
- `sub_label` (string): 副标签文字
- `class` (any): CSS 类

## Card 卡片组件

Card 组件提供了一个容器来展示相关内容。

### 基础用法

```elixir
<.card>
  <.card_content heading="卡片标题">
    这是卡片的内容。
  </.card_content>
</.card>
```

### card 属性

- `class` (any): 自定义 CSS 类
- `variant` (string): 卡片样式，可选值："basic"（默认）、"outline"

### card_content 属性

- `heading` (string): 卡片标题
- `category` (string): 分类标签
- `category_color_class` (any): 分类标签的颜色类，默认："pc-card__category--primary"
- `class` (any): CSS 类

### card_media 属性

- `src` (string): 图片 URL
- `aspect_ratio_class` (any): 宽高比类，默认："aspect-video"
- `class` (any): CSS 类

### card_footer 属性

- `class` (any): CSS 类

### 完整示例

```elixir
<.card variant="outline">
  <.card_media src="https://example.com/image.jpg" />
  <.card_content 
    heading="产品名称"
    category="新品"
    category_color_class="pc-card__category--success"
  >
    这是产品的描述信息。
  </.card_content>
  <.card_footer>
    <.button size="sm">查看详情</.button>
  </.card_footer>
</.card>
```

### review_card 评论卡片

专门用于显示用户评论的卡片组件。

必需属性：
- `name` (string): 评论者姓名
- `username` (string): 评论者用户名
- `img` (string): 评论者头像 URL
- `body` (string): 评论内容

可选属性：
- `class` (string): 额外的 CSS 类

```elixir
<.review_card
  name="张小明"
  username="@zhangxiaoming"
  img="https://example.com/avatar.jpg"
  body="这个产品非常好用，推荐购买！"
/>
```

## Badge 徽章组件

Badge 组件用于显示状态标签或小型信息。

### 基础用法

```elixir
<.badge>默认徽章</.badge>
<.badge color="success">成功</.badge>
<.badge color="danger" size="lg">重要</.badge>
```

### 属性

- `size` (string): 尺寸，可选值："xs"、"sm"、"md"（默认）、"lg"、"xl"
- `variant` (string): 样式变体，可选值："light"（默认）、"dark"、"soft"、"outline"
- `color` (string): 颜色，可选值："primary"（默认）、"secondary"、"info"、"success"、"warning"、"danger"、"gray"
- `role` (string): ARIA 角色，可选值："note"（默认）、"status"
- `with_icon` (boolean): 是否添加图标基础类，默认：false
- `label` (string): 徽章文本（可替代内部内容）
- `class` (any): 自定义 CSS 类

### 带图标的徽章

```elixir
<.badge color="success" with_icon>
  <.icon name="hero-check-circle" class="w-3 h-3 mr-1" />
  已完成
</.badge>
```

### 不同变体示例

```elixir
<.badge color="primary" variant="light">Light</.badge>
<.badge color="primary" variant="dark">Dark</.badge>
<.badge color="primary" variant="soft">Soft</.badge>
<.badge color="primary" variant="outline">Outline</.badge>
```

## Avatar 头像组件

Avatar 组件用于显示用户头像，支持图片、文字首字母和默认图标。

### 基础用法

```elixir
<!-- 图片头像 -->
<.avatar src="https://example.com/avatar.jpg" alt="用户头像" />

<!-- 文字头像 -->
<.avatar name="张三" />

<!-- 默认头像图标 -->
<.avatar />
```

### avatar 属性

- `src` (string): 头像图片 URL
- `alt` (string): 图片的替代文本
- `size` (string): 尺寸，可选值："xs"、"sm"、"md"（默认）、"lg"、"xl"
- `name` (string): 用于生成首字母的姓名
- `random_color` (boolean): 是否为文字头像生成随机颜色，默认：false
- `class` (any): 自定义 CSS 类

### 文字头像规则

- 单个词：取前两个字符
- 多个词：取第一个词和最后一个词的首字符

```elixir
<.avatar name="张三" />      <!-- 显示 "张三" -->
<.avatar name="王小明" />    <!-- 显示 "王明" -->
```

### 随机颜色头像

```elixir
<.avatar name="张三" random_color />
<.avatar name="李四" random_color />
```

### avatar_group 头像组

用于显示多个头像的组合。

属性：
- `size` (string): 头像尺寸，可选值："xs"、"sm"、"md"（默认）、"lg"、"xl"
- `avatars` (list): 头像 URL 列表
- `class` (any): CSS 类

```elixir
<.avatar_group 
  size="md"
  avatars={[
    "https://example.com/avatar1.jpg",
    "https://example.com/avatar2.jpg",
    "https://example.com/avatar3.jpg"
  ]}
/>
```

## Rating 评分组件

Rating 组件用于显示星级评分。

### 基础用法

```elixir
<.rating rating={4.5} />
<.rating rating={3.7} include_label />
```

### 属性

- `rating` (any): 评分值（整数或浮点数），默认：0
- `round_to_nearest_half` (boolean): 是否四舍五入到最近的半星，默认：true
- `total` (integer): 总星数，默认：5
- `include_label` (boolean): 是否显示评分标签，默认：false
- `star_class` (any): 星星的额外 CSS 类（如调整大小）
- `label_class` (any): 评分标签的 CSS 类
- `class` (any): 包装容器的 CSS 类

### 高级示例

#### 不同总星数

```elixir
<!-- 3星制 -->
<.rating rating={2} total={3} include_label />

<!-- 10星制 -->
<.rating rating={7.5} total={10} include_label />
```

#### 自定义星星大小

```elixir
<.rating rating={4} star_class="h-3 w-3" />
<.rating rating={4} star_class="h-8 w-8" />
<.rating rating={4} star_class="h-10 w-10" />
```

#### 精确显示（不四舍五入）

```elixir
<.rating rating={3.3} round_to_nearest_half={false} />  <!-- 显示3.3星 -->
<.rating rating={3.3} round_to_nearest_half={true} />   <!-- 显示3.5星 -->
```

## Marquee 跑马灯组件

Marquee 组件用于创建滚动动画效果，支持水平和垂直滚动。

### 基础用法

```elixir
<.marquee>
  <div class="flex gap-4">
    <span>滚动内容1</span>
    <span>滚动内容2</span>
    <span>滚动内容3</span>
  </div>
</.marquee>
```

### 属性

- `pause_on_hover` (boolean): 鼠标悬停时是否暂停，默认：false
- `repeat` (integer): 内容重复次数，默认：4
- `vertical` (boolean): 是否垂直滚动，默认：false
- `reverse` (boolean): 是否反向滚动，默认：false
- `duration` (string): 动画持续时间，默认："30s"
- `gap` (string): 项目间距，默认："1rem"
- `overlay_gradient` (boolean): 是否添加边缘渐变遮罩，默认：true
- `max_width` (string): 最大宽度，可选值："sm"、"md"、"lg"、"xl"、"2xl"、"none"（默认）
- `max_height` (string): 最大高度，可选值："sm"、"md"、"lg"、"xl"、"2xl"、"none"（默认）
- `class` (string): CSS 类

### 高级示例

#### 反向滚动

```elixir
<.marquee reverse>
  <div class="flex gap-6">
    <%= for i <- 1..5 do %>
      <.card class="w-48 flex-shrink-0">
        <.card_content heading={"卡片 #{i}"}>
          内容
        </.card_content>
      </.card>
    <% end %>
  </div>
</.marquee>
```

#### 垂直滚动

```elixir
<div class="h-64 overflow-hidden">
  <.marquee vertical max_height="md">
    <div class="space-y-4">
      <%= for i <- 1..5 do %>
        <.alert color="info">
          消息 <%= i %>
        </.alert>
      <% end %>
    </div>
  </.marquee>
</div>
```

#### 悬停暂停

```elixir
<.marquee pause_on_hover>
  <div class="flex gap-4">
    <!-- 内容 -->
  </div>
</.marquee>
```

#### 自定义速度

```elixir
<!-- 快速（10秒） -->
<.marquee duration="10s" repeat={2}>
  <!-- 内容 -->
</.marquee>

<!-- 慢速（60秒） -->
<.marquee duration="60s" repeat={2}>
  <!-- 内容 -->
</.marquee>
```

#### 无渐变遮罩

```elixir
<.marquee overlay_gradient={false}>
  <!-- 内容 -->
</.marquee>
```

## 组件组合示例

这些组件可以灵活组合使用，创建丰富的用户界面：

```elixir
<!-- 在表格中使用徽章和头像 -->
<.table id="user-table" rows={@users}>
  <:col :let={user} label="用户">
    <div class="flex items-center gap-2">
      <.avatar src={user.avatar} name={user.name} size="sm" />
      <span><%= user.name %></span>
    </div>
  </:col>
  <:col :let={user} label="评分">
    <.rating rating={user.rating} star_class="h-4 w-4" />
  </:col>
  <:col :let={user} label="状态">
    <.badge color={user.status_color} size="sm">
      <%= user.status %>
    </.badge>
  </:col>
</.table>

<!-- 在卡片中使用评分 -->
<.card>
  <.card_media src="product.jpg" />
  <.card_content heading="产品名称">
    <.rating rating={4.5} include_label />
    <p class="mt-2">产品描述...</p>
  </.card_content>
</.card>

<!-- 在跑马灯中使用卡片 -->
<.marquee pause_on_hover>
  <div class="flex gap-4">
    <%= for product <- @products do %>
      <.card class="w-64 flex-shrink-0">
        <.card_content heading={product.name}>
          <.badge color="primary"><%= product.category %></.badge>
          <.rating rating={product.rating} class="mt-2" />
        </.card_content>
      </.card>
    <% end %>
  </div>
</.marquee>
```

## 注意事项

1. **样式定制**：所有组件都支持通过 `class` 属性添加自定义样式
2. **响应式设计**：大部分组件都支持响应式，可以根据屏幕尺寸调整显示
3. **无障碍支持**：组件都包含适当的 ARIA 属性和语义化 HTML
4. **性能优化**：Table 组件支持 LiveView 的 stream 功能，适合处理大量数据

## 查看演示

您可以访问 `/components/petal_data` 查看所有数据展示组件的实际演示效果。