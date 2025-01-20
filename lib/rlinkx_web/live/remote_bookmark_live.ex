defmodule RlinkxWeb.BookmarkLive do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo


  def render(assigns) do
    ~H"""
    <div class="flex flex-col grow shadow-lg">
      <div class="flex justify-between items-center shrink-0 h-16 bg-white border-b border-slate-300 px-4">
        <div class="flex flex-col gap-1.5">
          <h1 class="text-sm font-bold leading-none">
            #{@bookmark.name}
          </h1>
          <div class="text-xs leading-none h-3.5">
            {@bookmark.description}
          </div>
          <div class="text-xs leading-none h-3.5">
            {@bookmark.url_link}
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    bookmark = Bookmark |> Repo.all |> List.first()

    {:ok, assign(socket, bookmark: bookmark)}
  end
end
