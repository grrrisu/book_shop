defmodule BookShopWeb.SharedComponents do
  use Phoenix.Component

  import BookShopWeb.CoreComponents

  def stat(assigns) do
    ~H"""
    <div class="stat bg-base-300">
      <div class="stat-figure text-secondary">
        <.icon name={@icon} class="size-6" />
      </div>
      <div class="stat-title font-bold">{@title}</div>
      <div class="stat-value text-right">{@number}</div>
      <div class="stat-desc">event based calculation</div>
    </div>
    """
  end
end
