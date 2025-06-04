defmodule ShopUxPhoenixWeb.MinimalTestLive do
  use ShopUxPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-2xl mb-4">Minimal LiveView Test</h1>
      <p class="mb-4">Count: <span class="font-bold"><%= @count %></span></p>
      <button phx-click="increment" class="px-4 py-2 bg-blue-500 text-white rounded">
        Click me
      </button>
    </div>
    """
  end
end