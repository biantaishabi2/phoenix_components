defmodule ShopUxPhoenixWeb.ComponentsDemoLive do
  use ShopUxPhoenixWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(tags: ["Phoenix", "LiveView", "Elixir", "Tailwind"])
     |> assign(show_success: true)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-3xl font-bold mb-8">组件演示 - Tag 标签</h1>
      
      <!-- 基础用法 -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-4">基础用法</h2>
        <div class="flex flex-wrap gap-2">
          <PetalComponents.Custom.Tag.tag>默认标签</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="primary">主要标签</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="success">成功标签</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="danger">危险标签</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="warning">警告标签</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="info">信息标签</PetalComponents.Custom.Tag.tag>
        </div>
      </section>

      <!-- 可关闭标签 -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-4">可关闭标签</h2>
        <div class="flex flex-wrap gap-2">
          <PetalComponents.Custom.Tag.tag :for={tag <- @tags} 
                   closable 
                   color="primary"
                   on_close={JS.push("remove_tag", value: %{tag: tag})}>
            <%= tag %>
          </PetalComponents.Custom.Tag.tag>
        </div>
        <button phx-click="reset_tags" class="mt-4 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
          重置标签
        </button>
      </section>

      <!-- 带图标的标签 -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-4">带图标的标签</h2>
        <div class="flex flex-wrap gap-2">
          <PetalComponents.Custom.Tag.tag color="success">
            <:icon>
              <.icon name="hero-check-circle-mini" class="w-3 h-3" />
            </:icon>
            已完成
          </PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="warning">
            <:icon>
              <.icon name="hero-exclamation-triangle-mini" class="w-3 h-3" />
            </:icon>
            待处理
          </PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag color="danger">
            <:icon>
              <.icon name="hero-x-circle-mini" class="w-3 h-3" />
            </:icon>
            已失败
          </PetalComponents.Custom.Tag.tag>
        </div>
      </section>

      <!-- 无边框标签 -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-4">无边框标签</h2>
        <div class="flex flex-wrap gap-2">
          <PetalComponents.Custom.Tag.tag bordered={false}>无边框默认</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag bordered={false} color="primary">无边框主要</PetalComponents.Custom.Tag.tag>
          <PetalComponents.Custom.Tag.tag bordered={false} color="success">无边框成功</PetalComponents.Custom.Tag.tag>
        </div>
      </section>

      <!-- 动态标签 -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-4">动态标签示例</h2>
        <div class="flex items-center gap-4">
          <PetalComponents.Custom.Tag.tag :if={@show_success} 
                   color="success" 
                   closable
                   on_close={JS.push("hide_success")}>
            操作成功！
          </PetalComponents.Custom.Tag.tag>
          <button :if={!@show_success}
                  phx-click="show_success" 
                  class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
            显示成功标签
          </button>
        </div>
      </section>

      <!-- 实际应用场景 -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-4">实际应用场景</h2>
        
        <!-- 订单状态 -->
        <div class="mb-4">
          <h3 class="font-medium mb-2">订单状态：</h3>
          <div class="flex gap-2">
            <PetalComponents.Custom.Tag.tag color="warning">待支付</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag color="info">待发货</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag color="primary">运输中</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag color="success">已完成</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag color="danger">已取消</PetalComponents.Custom.Tag.tag>
          </div>
        </div>

        <!-- 商品分类 -->
        <div class="mb-4">
          <h3 class="font-medium mb-2">商品分类：</h3>
          <div class="flex gap-2">
            <PetalComponents.Custom.Tag.tag>电子产品</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag>图书</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag>服装</PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag>食品</PetalComponents.Custom.Tag.tag>
          </div>
        </div>

        <!-- 用户权限 -->
        <div class="mb-4">
          <h3 class="font-medium mb-2">用户权限：</h3>
          <div class="flex gap-2">
            <PetalComponents.Custom.Tag.tag color="primary">
              <:icon><.icon name="hero-shield-check-mini" class="w-3 h-3" /></:icon>
              管理员
            </PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag color="info">
              <:icon><.icon name="hero-user-mini" class="w-3 h-3" /></:icon>
              普通用户
            </PetalComponents.Custom.Tag.tag>
            <PetalComponents.Custom.Tag.tag color="warning">
              <:icon><.icon name="hero-eye-mini" class="w-3 h-3" /></:icon>
              访客
            </PetalComponents.Custom.Tag.tag>
          </div>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("remove_tag", %{"tag" => tag}, socket) do
    tags = Enum.reject(socket.assigns.tags, &(&1 == tag))
    {:noreply, assign(socket, tags: tags)}
  end

  def handle_event("reset_tags", _params, socket) do
    {:noreply, assign(socket, tags: ["Phoenix", "LiveView", "Elixir", "Tailwind"])}
  end

  def handle_event("hide_success", _params, socket) do
    {:noreply, assign(socket, show_success: false)}
  end

  def handle_event("show_success", _params, socket) do
    {:noreply, assign(socket, show_success: true)}
  end
end