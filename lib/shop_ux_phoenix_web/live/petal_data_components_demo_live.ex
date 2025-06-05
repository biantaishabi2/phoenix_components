defmodule ShopUxPhoenixWeb.PetalDataComponentsDemoLive do
  use Phoenix.LiveView, layout: {ShopUxPhoenixWeb.Layouts, :app}
  use PetalComponents
  
  alias Phoenix.LiveView.JS
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      # Table data
      users: [
        %{id: 1, name: "张三", email: "zhangsan@example.com", role: "管理员", status: "active", avatar: "https://i.pravatar.cc/150?img=1"},
        %{id: 2, name: "李四", email: "lisi@example.com", role: "用户", status: "inactive", avatar: "https://i.pravatar.cc/150?img=2"},
        %{id: 3, name: "王五", email: "wangwu@example.com", role: "编辑", status: "active", avatar: "https://i.pravatar.cc/150?img=3"},
        %{id: 4, name: "赵六", email: "zhaoliu@example.com", role: "用户", status: "active", avatar: nil}
      ],
      # Rating values
      ratings: [4.5, 3.8, 5.0, 2.3, 4.0],
      # Selected row
      selected_row: nil
    )}
  end
  
  @impl true
  def handle_event("row_click", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_row: String.to_integer(id))}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 space-y-12">
      <h1 class="text-3xl font-bold mb-8">Petal Components - 数据展示组件演示</h1>
      
      <!-- Table 表格组件 -->
      <section>
        <h2 class="text-2xl font-semibold mb-4">Table 表格</h2>
        
        <!-- 基础表格 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">基础表格</h3>
          <.table id="basic-table" rows={@users}>
            <:col :let={user} label="ID">
              <%= user.id %>
            </:col>
            <:col :let={user} label="姓名">
              <%= user.name %>
            </:col>
            <:col :let={user} label="邮箱">
              <%= user.email %>
            </:col>
            <:col :let={user} label="角色">
              <%= user.role %>
            </:col>
            <:col :let={user} label="状态">
              <.badge color={if user.status == "active", do: "success", else: "gray"}>
                <%= if user.status == "active", do: "活跃", else: "未激活" %>
              </.badge>
            </:col>
          </.table>
        </div>
        
        <!-- 可点击行的表格 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">可点击行的表格</h3>
          <p class="text-sm text-gray-600 mb-3">
            当前选中的行ID: <%= @selected_row || "无" %>
          </p>
          <.table 
            id="clickable-table" 
            rows={@users}
            row_id={fn user -> "user-#{user.id}" end}
            row_click={fn user -> JS.push("row_click", value: %{id: user.id}) end}
          >
            <:col :let={user} label="ID">
              <%= user.id %>
            </:col>
            <:col :let={user} label="姓名">
              <%= user.name %>
            </:col>
            <:col :let={user} label="邮箱">
              <%= user.email %>
            </:col>
          </.table>
        </div>
        
        <!-- 带用户信息的表格 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">带用户信息的表格</h3>
          <.table id="user-table" rows={@users}>
            <:col :let={user} label="用户">
              <.user_inner_td 
                avatar_assigns={%{src: user.avatar, name: user.name, size: "sm"}}
                label={user.name}
                sub_label={user.email}
              />
            </:col>
            <:col :let={user} label="角色">
              <%= user.role %>
            </:col>
            <:col :let={user} label="状态">
              <.badge 
                color={if user.status == "active", do: "success", else: "gray"}
                size="sm"
              >
                <%= if user.status == "active", do: "活跃", else: "未激活" %>
              </.badge>
            </:col>
          </.table>
        </div>
        
        <!-- Ghost 风格表格 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">Ghost 风格表格</h3>
          <.table id="ghost-table" rows={@users} variant="ghost">
            <:col :let={user} label="ID"><%= user.id %></:col>
            <:col :let={user} label="姓名"><%= user.name %></:col>
            <:col :let={user} label="邮箱"><%= user.email %></:col>
          </.table>
        </div>
        
        <!-- 空表格 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">空表格</h3>
          <.table id="empty-table" rows={[]}>
            <:col label="ID"></:col>
            <:col label="姓名"></:col>
            <:col label="邮箱"></:col>
            <:empty_state>
              <div class="text-center py-8 text-gray-500">
                暂无数据
              </div>
            </:empty_state>
          </.table>
        </div>
      </section>
      
      <!-- Card 卡片组件 -->
      <section>
        <h2 class="text-2xl font-semibold mb-4">Card 卡片</h2>
        
        <!-- 基础卡片 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">基础卡片</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <.card>
              <.card_content heading="基础卡片">
                这是一个基础卡片，包含标题和内容。
              </.card_content>
            </.card>
            
            <.card variant="outline">
              <.card_content heading="轮廓卡片">
                这是一个轮廓样式的卡片。
              </.card_content>
            </.card>
            
            <.card>
              <.card_content 
                heading="带分类的卡片"
                category="新闻"
                category_color_class="pc-card__category--info"
              >
                这是一个带分类标签的卡片。
              </.card_content>
            </.card>
          </div>
        </div>
        
        <!-- 带图片的卡片 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">带图片的卡片</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <.card>
              <.card_media src="https://picsum.photos/400/250?random=1" />
              <.card_content heading="图片卡片">
                这是一个带图片的卡片
              </.card_content>
              <.card_footer>
                <.button size="sm">查看详情</.button>
              </.card_footer>
            </.card>
            
            <.card>
              <.card_media aspect_ratio_class="aspect-square" src="https://picsum.photos/400/400?random=2" />
              <.card_content 
                heading="正方形图片"
                category="图片"
                category_color_class="pc-card__category--success"
              >
                使用 aspect-square 类设置正方形比例
              </.card_content>
            </.card>
            
            <.card>
              <.card_media />
              <.card_content heading="占位图片">
                当没有提供 src 时，显示占位符
              </.card_content>
            </.card>
          </div>
        </div>
        
        <!-- 评论卡片 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">评论卡片</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.review_card
              name="张小明"
              username="@zhangxiaoming"
              img="https://i.pravatar.cc/150?img=5"
              body="这个产品真的很棒！使用体验非常流畅，界面设计也很美观。强烈推荐给大家。"
            />
            
            <.review_card
              name="李小红"
              username="@lixiaohong"
              img="https://i.pravatar.cc/150?img=6"
              body="客服响应速度很快，解决问题也很专业。整体服务体验让我很满意。"
            />
          </div>
        </div>
      </section>
      
      <!-- Badge 徽章组件 -->
      <section>
        <h2 class="text-2xl font-semibold mb-4">Badge 徽章</h2>
        
        <!-- 基础徽章 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">基础徽章</h3>
          <div class="flex flex-wrap gap-2">
            <.badge>默认</.badge>
            <.badge color="primary">主要</.badge>
            <.badge color="secondary">次要</.badge>
            <.badge color="info">信息</.badge>
            <.badge color="success">成功</.badge>
            <.badge color="warning">警告</.badge>
            <.badge color="danger">危险</.badge>
            <.badge color="gray">灰色</.badge>
          </div>
        </div>
        
        <!-- 不同变体 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">不同变体</h3>
          <div class="space-y-3">
            <div class="flex flex-wrap gap-2">
              <.badge color="primary" variant="light">Light</.badge>
              <.badge color="primary" variant="dark">Dark</.badge>
              <.badge color="primary" variant="soft">Soft</.badge>
              <.badge color="primary" variant="outline">Outline</.badge>
            </div>
            <div class="flex flex-wrap gap-2">
              <.badge color="success" variant="light">Light</.badge>
              <.badge color="success" variant="dark">Dark</.badge>
              <.badge color="success" variant="soft">Soft</.badge>
              <.badge color="success" variant="outline">Outline</.badge>
            </div>
          </div>
        </div>
        
        <!-- 不同尺寸 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">不同尺寸</h3>
          <div class="flex flex-wrap items-center gap-2">
            <.badge size="xs" color="info">超小</.badge>
            <.badge size="sm" color="info">小</.badge>
            <.badge size="md" color="info">中</.badge>
            <.badge size="lg" color="info">大</.badge>
            <.badge size="xl" color="info">超大</.badge>
          </div>
        </div>
        
        <!-- 带图标的徽章 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">带图标的徽章</h3>
          <div class="flex flex-wrap gap-2">
            <.badge color="success" with_icon>
              <.icon name="hero-check-circle" class="w-3 h-3 mr-1" />
              已完成
            </.badge>
            <.badge color="warning" with_icon>
              <.icon name="hero-clock" class="w-3 h-3 mr-1" />
              处理中
            </.badge>
            <.badge color="danger" with_icon>
              <.icon name="hero-x-circle" class="w-3 h-3 mr-1" />
              已取消
            </.badge>
          </div>
        </div>
        
        <!-- 角色属性 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">角色属性</h3>
          <div class="flex flex-wrap gap-2">
            <.badge role="note" color="info">笔记角色</.badge>
            <.badge role="status" color="success">状态角色</.badge>
          </div>
        </div>
      </section>
      
      <!-- Avatar 头像组件 -->
      <section>
        <h2 class="text-2xl font-semibold mb-4">Avatar 头像</h2>
        
        <!-- 图片头像 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">图片头像</h3>
          <div class="flex items-center gap-4">
            <.avatar src="https://i.pravatar.cc/150?img=7" size="xs" alt="用户头像" />
            <.avatar src="https://i.pravatar.cc/150?img=8" size="sm" alt="用户头像" />
            <.avatar src="https://i.pravatar.cc/150?img=9" size="md" alt="用户头像" />
            <.avatar src="https://i.pravatar.cc/150?img=10" size="lg" alt="用户头像" />
            <.avatar src="https://i.pravatar.cc/150?img=11" size="xl" alt="用户头像" />
          </div>
        </div>
        
        <!-- 文字头像 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">文字头像（姓名首字母）</h3>
          <div class="flex items-center gap-4">
            <.avatar name="张三" size="xs" />
            <.avatar name="李四" size="sm" />
            <.avatar name="王小明" size="md" />
            <.avatar name="赵六" size="lg" />
            <.avatar name="孙悟空" size="xl" />
          </div>
        </div>
        
        <!-- 随机颜色的文字头像 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">随机颜色的文字头像</h3>
          <div class="flex items-center gap-4">
            <.avatar name="张三" size="md" random_color />
            <.avatar name="李四" size="md" random_color />
            <.avatar name="王五" size="md" random_color />
            <.avatar name="赵六" size="md" random_color />
            <.avatar name="钱七" size="md" random_color />
          </div>
        </div>
        
        <!-- 默认头像（无图片无名字） -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">默认头像图标</h3>
          <div class="flex items-center gap-4">
            <.avatar size="xs" />
            <.avatar size="sm" />
            <.avatar size="md" />
            <.avatar size="lg" />
            <.avatar size="xl" />
          </div>
        </div>
        
        <!-- 头像组 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">头像组</h3>
          <div class="space-y-4">
            <div>
              <p class="text-sm text-gray-600 mb-2">小尺寸头像组</p>
              <.avatar_group 
                size="sm"
                avatars={[
                  "https://i.pravatar.cc/150?img=12",
                  "https://i.pravatar.cc/150?img=13",
                  "https://i.pravatar.cc/150?img=14",
                  "https://i.pravatar.cc/150?img=15"
                ]}
              />
            </div>
            
            <div>
              <p class="text-sm text-gray-600 mb-2">中等尺寸头像组</p>
              <.avatar_group 
                size="md"
                avatars={[
                  "https://i.pravatar.cc/150?img=16",
                  "https://i.pravatar.cc/150?img=17",
                  "https://i.pravatar.cc/150?img=18",
                  "https://i.pravatar.cc/150?img=19",
                  "https://i.pravatar.cc/150?img=20"
                ]}
              />
            </div>
            
            <div>
              <p class="text-sm text-gray-600 mb-2">大尺寸头像组</p>
              <.avatar_group 
                size="lg"
                avatars={[
                  "https://i.pravatar.cc/150?img=21",
                  "https://i.pravatar.cc/150?img=22",
                  "https://i.pravatar.cc/150?img=23"
                ]}
              />
            </div>
          </div>
        </div>
      </section>
      
      <!-- Rating 评分组件 -->
      <section>
        <h2 class="text-2xl font-semibold mb-4">Rating 评分</h2>
        
        <!-- 基础评分 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">基础评分</h3>
          <div class="space-y-3">
            <.rating rating={0} />
            <.rating rating={1} />
            <.rating rating={2.5} />
            <.rating rating={3.7} />
            <.rating rating={5} />
          </div>
        </div>
        
        <!-- 不同评分值 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">各种评分值</h3>
          <div class="space-y-3">
            <%= for rating <- @ratings do %>
              <div class="flex items-center gap-4">
                <.rating rating={rating} />
                <span class="text-sm text-gray-600"><%= rating %> 分</span>
              </div>
            <% end %>
          </div>
        </div>
        
        <!-- 带标签的评分 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">带标签的评分</h3>
          <div class="space-y-3">
            <.rating rating={3.8} include_label />
            <.rating rating={4.2} include_label />
            <.rating rating={2.5} include_label />
          </div>
        </div>
        
        <!-- 不同总星数 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">不同总星数</h3>
          <div class="space-y-3">
            <div>
              <p class="text-sm text-gray-600 mb-1">3星制</p>
              <.rating rating={2} total={3} include_label />
            </div>
            <div>
              <p class="text-sm text-gray-600 mb-1">10星制</p>
              <.rating rating={7.5} total={10} include_label />
            </div>
          </div>
        </div>
        
        <!-- 不同尺寸的星星 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">自定义星星尺寸</h3>
          <div class="space-y-3">
            <.rating rating={4} star_class="h-3 w-3" />
            <.rating rating={4} star_class="h-5 w-5" />
            <.rating rating={4} star_class="h-8 w-8" />
            <.rating rating={4} star_class="h-10 w-10" />
          </div>
        </div>
        
        <!-- 不四舍五入到半星 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">精确显示（不四舍五入）</h3>
          <div class="space-y-3">
            <div class="flex items-center gap-4">
              <.rating rating={3.3} round_to_nearest_half={false} />
              <span class="text-sm text-gray-600">3.3分（不四舍五入）</span>
            </div>
            <div class="flex items-center gap-4">
              <.rating rating={3.3} round_to_nearest_half={true} />
              <span class="text-sm text-gray-600">3.3分（四舍五入到3.5）</span>
            </div>
          </div>
        </div>
      </section>
      
      <!-- Marquee 跑马灯组件 -->
      <section>
        <h2 class="text-2xl font-semibold mb-4">Marquee 跑马灯</h2>
        
        <!-- 水平跑马灯 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">水平跑马灯</h3>
          <.marquee>
            <div class="flex gap-8">
              <.badge color="primary" size="lg">Phoenix</.badge>
              <.badge color="secondary" size="lg">Elixir</.badge>
              <.badge color="info" size="lg">Tailwind CSS</.badge>
              <.badge color="success" size="lg">Alpine JS</.badge>
              <.badge color="warning" size="lg">LiveView</.badge>
              <.badge color="danger" size="lg">HEEX</.badge>
            </div>
          </.marquee>
        </div>
        
        <!-- 反向跑马灯 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">反向跑马灯</h3>
          <.marquee reverse>
            <div class="flex gap-6">
              <%= for i <- 1..5 do %>
                <.card class="w-48 flex-shrink-0">
                  <.card_content heading={"卡片 #{i}"}>
                    这是跑马灯中的卡片内容
                  </.card_content>
                </.card>
              <% end %>
            </div>
          </.marquee>
        </div>
        
        <!-- 垂直跑马灯 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">垂直跑马灯</h3>
          <div class="h-64 overflow-hidden">
            <.marquee vertical max_height="md">
              <div class="space-y-4">
                <%= for i <- 1..5 do %>
                  <.alert color={Enum.random(["info", "success", "warning"])}>
                    这是第 <%= i %> 条滚动消息
                  </.alert>
                <% end %>
              </div>
            </.marquee>
          </div>
        </div>
        
        <!-- 悬停暂停 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">悬停暂停</h3>
          <.marquee pause_on_hover>
            <div class="flex gap-4">
              <%= for user <- @users do %>
                <div class="flex items-center gap-2 px-4 py-2 bg-gray-100 rounded-lg flex-shrink-0">
                  <.avatar src={user.avatar} name={user.name} size="sm" />
                  <span><%= user.name %></span>
                </div>
              <% end %>
            </div>
          </.marquee>
        </div>
        
        <!-- 自定义速度 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">不同速度</h3>
          <div class="space-y-4">
            <div>
              <p class="text-sm text-gray-600 mb-2">快速（10秒）</p>
              <.marquee duration="10s" repeat={2}>
                <div class="flex gap-4">
                  <span class="text-lg">🚀 快速滚动</span>
                  <span class="text-lg">⚡ 闪电般的速度</span>
                  <span class="text-lg">🏃 飞快移动</span>
                </div>
              </.marquee>
            </div>
            
            <div>
              <p class="text-sm text-gray-600 mb-2">慢速（60秒）</p>
              <.marquee duration="60s" repeat={2}>
                <div class="flex gap-4">
                  <span class="text-lg">🐌 缓慢滚动</span>
                  <span class="text-lg">🐢 慢慢移动</span>
                  <span class="text-lg">🦥 悠闲滑动</span>
                </div>
              </.marquee>
            </div>
          </div>
        </div>
        
        <!-- 无渐变遮罩 -->
        <div class="mb-8">
          <h3 class="text-lg font-medium mb-3">无渐变遮罩</h3>
          <.marquee overlay_gradient={false}>
            <div class="flex gap-6">
              <.rating rating={4.5} star_class="h-8 w-8" />
              <.rating rating={5} star_class="h-8 w-8" />
              <.rating rating={3.5} star_class="h-8 w-8" />
              <.rating rating={4} star_class="h-8 w-8" />
            </div>
          </.marquee>
        </div>
      </section>
    </div>
    """
  end
end