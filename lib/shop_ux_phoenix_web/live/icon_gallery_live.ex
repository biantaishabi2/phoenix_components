defmodule ShopUxPhoenixWeb.IconGalleryLive do
  use Phoenix.LiveView, layout: {ShopUxPhoenixWeb.Layouts, :app}
  use PetalComponents

  @icon_names [
    "academic-cap", "adjustments-horizontal", "adjustments-vertical", "archive-box",
    "archive-box-arrow-down", "archive-box-x-mark", "arrow-down", "arrow-down-circle",
    "arrow-down-left", "arrow-down-on-square", "arrow-down-on-square-stack",
    "arrow-down-right", "arrow-down-tray", "arrow-left", "arrow-left-circle",
    "arrow-left-end-on-rectangle", "arrow-left-on-rectangle", "arrow-left-start-on-rectangle",
    "arrow-long-down", "arrow-long-left", "arrow-long-right", "arrow-long-up",
    "arrow-path", "arrow-path-rounded-square", "arrow-right", "arrow-right-circle",
    "arrow-right-end-on-rectangle", "arrow-right-on-rectangle", "arrow-right-start-on-rectangle",
    "arrow-small-down", "arrow-small-left", "arrow-small-right", "arrow-small-up",
    "arrows-pointing-in", "arrows-pointing-out", "arrows-right-left", "arrows-up-down",
    "arrow-top-right-on-square", "arrow-trending-down", "arrow-trending-up", "arrow-up",
    "arrow-up-circle", "arrow-up-left", "arrow-up-on-square", "arrow-up-on-square-stack",
    "arrow-up-right", "arrow-up-tray", "arrow-uturn-down", "arrow-uturn-left",
    "arrow-uturn-right", "arrow-uturn-up", "at-symbol", "backspace", "backward",
    "banknotes", "bars-2", "bars-3", "bars-3-bottom-left", "bars-3-bottom-right",
    "bars-3-center-left", "bars-4", "bars-arrow-down", "bars-arrow-up", "battery-0",
    "battery-100", "battery-50", "beaker", "bell", "bell-alert", "bell-slash",
    "bell-snooze", "bolt", "bolt-slash", "bookmark", "bookmark-slash", "bookmark-square",
    "book-open", "briefcase", "bug-ant", "building-library", "building-office",
    "building-office-2", "building-storefront", "cake", "calculator", "calendar",
    "calendar-days", "camera", "chart-bar", "chart-bar-square", "chart-pie",
    "chat-bubble-bottom-center", "chat-bubble-bottom-center-text", "chat-bubble-left",
    "chat-bubble-left-ellipsis", "chat-bubble-left-right", "chat-bubble-oval-left",
    "chat-bubble-oval-left-ellipsis", "check", "check-badge", "check-circle",
    "chevron-double-down", "chevron-double-left", "chevron-double-right",
    "chevron-double-up", "chevron-down", "chevron-left", "chevron-right", "chevron-up",
    "chevron-up-down", "circle-stack", "clipboard", "clipboard-document",
    "clipboard-document-check", "clipboard-document-list", "clock", "cloud",
    "cloud-arrow-down", "cloud-arrow-up", "code-bracket", "code-bracket-square",
    "cog", "cog-6-tooth", "cog-8-tooth", "command-line", "computer-desktop", "cpu-chip",
    "credit-card", "cube", "cube-transparent", "currency-bangladeshi", "currency-dollar",
    "currency-euro", "currency-pound", "currency-rupee", "currency-yen",
    "cursor-arrow-rays", "cursor-arrow-ripple", "device-phone-mobile", "device-tablet",
    "document", "document-arrow-down", "document-arrow-up", "document-chart-bar",
    "document-check", "document-duplicate", "document-magnifying-glass", "document-minus",
    "document-plus", "document-text", "ellipsis-horizontal", "ellipsis-horizontal-circle",
    "ellipsis-vertical", "envelope", "envelope-open", "exclamation-circle",
    "exclamation-triangle", "eye", "eye-dropper", "eye-slash", "face-frown",
    "face-smile", "film", "finger-print", "fire", "flag", "folder", "folder-arrow-down",
    "folder-minus", "folder-open", "folder-plus", "forward", "funnel", "gif", "gift",
    "gift-top", "globe-alt", "globe-americas", "globe-asia-australia",
    "globe-europe-africa", "hand-raised", "hand-thumb-down", "hand-thumb-up", "hashtag",
    "heart", "home", "home-modern", "identification", "inbox", "inbox-arrow-down",
    "inbox-stack", "information-circle", "key", "language", "lifebuoy", "light-bulb",
    "link", "list-bullet", "lock-closed", "lock-open", "magnifying-glass",
    "magnifying-glass-circle", "magnifying-glass-minus", "magnifying-glass-plus", "map",
    "map-pin", "megaphone", "microphone", "minus", "minus-circle", "minus-small", "moon",
    "musical-note", "newspaper", "no-symbol", "paint-brush", "paper-airplane",
    "paper-clip", "pause", "pause-circle", "pencil", "pencil-square", "phone",
    "phone-arrow-down-left", "phone-arrow-up-right", "phone-x-mark", "photo", "play",
    "play-circle", "play-pause", "plus", "plus-circle", "plus-small", "power",
    "presentation-chart-bar", "presentation-chart-line", "printer", "puzzle-piece",
    "qr-code", "question-mark-circle", "queue-list", "radio", "receipt-percent",
    "receipt-refund", "rectangle-group", "rectangle-stack", "rocket-launch", "rss",
    "scale", "scissors", "server", "server-stack", "share", "shield-check",
    "shield-exclamation", "shopping-bag", "shopping-cart", "signal", "signal-slash",
    "sparkles", "speaker-wave", "speaker-x-mark", "square-2-stack", "square-3-stack-3d",
    "squares-2x2", "squares-plus", "star", "stop", "stop-circle", "sun", "swatch",
    "table-cells", "tag", "ticket", "trash", "trophy", "truck", "tv", "user",
    "user-circle", "user-group", "user-minus", "user-plus", "users", "variable",
    "video-camera", "video-camera-slash", "view-columns", "viewfinder-circle", "wallet",
    "wifi", "window", "wrench", "wrench-screwdriver", "x-circle", "x-mark"
  ]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Heroicons 图标库")
     |> assign(:icons, @icon_names)
     |> assign(:total_count, length(@icon_names))
     |> assign(:search_query, "")
     |> assign(:filtered_icons, @icon_names)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    filtered_icons = if query == "" do
      @icon_names
    else
      Enum.filter(@icon_names, &String.contains?(&1, query))
    end

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:filtered_icons, filtered_icons)}
  end

  def handle_event("copy_icon", %{"name" => name}, socket) do
    # 这里可以添加复制到剪贴板的逻辑
    {:noreply, put_flash(socket, :info, "已复制图标名称: #{name}")}
  end

  def render(assigns) do
    ~H"""
    <div class="p-8 w-full max-w-7xl mx-auto">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Heroicons 图标库</h1>
        <p class="text-gray-600">
          共 <span class="font-semibold text-gray-900"><%= @total_count %></span> 个图标，
          当前显示 <span class="font-semibold text-gray-900"><%= length(@filtered_icons) %></span> 个
        </p>
      </div>

      <!-- 搜索框 -->
      <div class="mb-8">
        <form phx-change="search" class="max-w-md">
          <div class="relative">
            <input
              type="text"
              name="query"
              value={@search_query}
              placeholder="搜索图标..."
              class="w-full px-4 py-2 pl-10 pr-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-400" />
            </div>
          </div>
        </form>
      </div>

      <!-- 图标网格 -->
      <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 xl:grid-cols-8 gap-4">
        <%= for icon_name <- @filtered_icons do %>
          <div
            class="group relative p-4 border border-gray-200 rounded-lg hover:border-gray-300 hover:shadow-md transition-all duration-200 cursor-pointer"
            phx-click="copy_icon"
            phx-value-name={icon_name}
          >
            <div class="flex flex-col items-center space-y-3">
              <.icon name={"hero-#{icon_name}"} class="h-6 w-6 text-gray-700 group-hover:text-blue-600" />
              <span class="text-xs text-gray-600 text-center break-all">
                <%= icon_name %>
              </span>
            </div>
            
            <!-- 悬停时显示的复制提示 -->
            <div class="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-0 group-hover:bg-opacity-5 rounded-lg transition-all duration-200">
              <span class="opacity-0 group-hover:opacity-100 text-xs text-gray-700 bg-white px-2 py-1 rounded shadow-lg">
                点击复制
              </span>
            </div>
          </div>
        <% end %>
      </div>

      <!-- 空状态 -->
      <%= if @filtered_icons == [] do %>
        <div class="text-center py-12">
          <.icon name="hero-magnifying-glass" class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-medium text-gray-900">没有找到图标</h3>
          <p class="mt-1 text-sm text-gray-500">
            尝试使用其他关键词搜索
          </p>
        </div>
      <% end %>
    </div>
    """
  end
end