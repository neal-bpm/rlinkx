defmodule RlinkxWeb.BookmarkLive do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote.{Bookmark, Insight}
  alias Rlinkx.Remote

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
            <.link
              class="font-normal text-xs text-blue-600 hover:text-blue-700"
              navigate={~p"/bookmarks/#{@bookmark}/edit"}
            >
              Edit
            </.link>
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
        <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
          <li class="text-[0.8125rem] leading-6 text-zinc-900">
            {@current_user.email}
          </li>
          <li>
            <.link
              href={~p"/users/settings"}
              class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
            >
              Settings
            </.link>
          </li>
          <li>
            <.link
              href={~p"/users/log_out"}
              method="delete"
              class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
            >
              Log out
            </.link>
          </li>
        </ul>
      </div>
      <div class="flex flex-col grow overflow-auto">
        <.insight :for={insight <- @insights} insight={insight} />
      </div>
    </div>
    """
  end

  attr :insight, Insight, required: true

  defp insight(assigns) do
    ~H"""
    <div class="relative flex px-4 py-3">
      <div class="h-10 w-10 rounded shrink-0 bg-slate-300">
      </div>
        <div class="ml-2">
          <div class="-mt-1">
            <.link class="text-sm font-semibold hover:underline">
              <span>User</span>
            </.link>
            <p class="text-sm">{@insight.body}</p>
          </div>
        </div>
    </div>
    """
  end

  attr :active, :boolean, required: true
  attr :bookmark, Bookmark, required: true

  defp bookmark_link(assigns) do
    ~H"""
    <.link
      class={[
        "flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      patch={~p"/bookmarks/#{@bookmark}"}
    >
      <.icon name="hero-hashtag" class="h-4 w-4" />
      <span class={["ml-2 leading-none", @active && "font-bold"]}>
        {@bookmark.name}
      </span>
    </.link>
    """
  end

  def mount(_params, _session, socket) do
    bookmarks = Remote.list_bookmarks()
    {:ok, assign(socket, bookmarks: bookmarks)}
  end

  def handle_params(params, _uri, socket) do
    bookmarks = socket.assigns.bookmarks

    bookmark =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          %Bookmark{} = Enum.find(bookmarks, &(to_string(&1.id) == id))

        :error ->
          List.first(bookmarks)
      end

    insights = Remote.list_insights_in_bookmark(bookmark)

    {:noreply,
     assign(socket,
       hide_description?: false,
       bookmark: bookmark,
       insights: insights,
       page_title: "#" <> bookmark.name
     )}
  end

  def handle_event("toggle-description", _params, socket) do
    {:noreply, update(socket, :hide_description?, &(!&1))}
  end
end
