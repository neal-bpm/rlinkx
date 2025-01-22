defmodule RlinkxWeb.BookmarkLive do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  def render(assigns) do
    ~H"""
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <div class="flex justify-between items-center shrink-0 h-16 border-b border-slate-300 px-4">
        <div class="flex flex-col gap-1.5">
          <h1 class="text-lg font-bold text-gray-800">
            Rlinkx
          </h1>
        </div>
      </div>
      <div class="mt-4 overflow-auto">
        <div class="flex items-center h-8 px-3">
          <span class="ml-2 leading-none font-medium text-sm">Bookmarks</span>
        </div>
        <div id="bookmarks-list">
          <.bookmark_link
            :for={bookmark <- @bookmarks}
            bookmark={bookmark}
            active={bookmark.id == @bookmark.id}
          />
        </div>
      </div>
    </div>
    <div class="bg-[#34d399] flex flex-col grow shadow-lg">
      <div class="bg-[#34d300] flex justify-between items-center shrink-0 h-16 bg-white border-b border-slate-300 px-4">
        <div class="bg-[#34a200] flex flex-col gap-1.5">
          <h1 class="text-sm font-bold leading-none">
            #{@bookmark.name}
          </h1>
          <div
            class={["bg-[#329200] text-xs leading-none h-3.5", @hide_description? && "text-slate-600"]}
            phx-click="toggle-description"
          >
            <%= if @hide_description? do %>
              [Description hidden]
            <% else %>
              {@bookmark.description}
            <% end %>
          </div>
          <div class="text-xs leading-none h-3.5">
            {@bookmark.url_link}
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :active, :boolean, required: true
  attr :bookmark, Bookmark, required: true

  defp bookmark_link(assigns) do
    ~H"""
    <a
      class={[
        "flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      href={~p"/bookmarks/#{@bookmark}"}
    >
      <.icon name="hero-hashtag" class="h-4 w-4" />
      <span class={["ml-2 leading-none", @active && "font-bold"]}>
        {@bookmark.name}
      </span>
    </a>
    """
  end

  def mount(params, _session, socket) do
    bookmarks = Repo.all(Bookmark)

    bookmark =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          %Room{} = Enum.find(bookmarks, &(to_string(&1.id) == id))

        :error ->
          List.first(bookmarks)
      end

    {:ok, assign(socket, hide_description?: false, bookmark: bookmark, bookmarks: bookmarks)}
  end

  def handle_event("toggle-description", _params, socket) do
    {:noreply, update(socket, :hide_description?, &(!&1))}
  end
end
