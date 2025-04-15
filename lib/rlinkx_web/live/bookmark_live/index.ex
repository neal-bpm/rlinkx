defmodule RlinkxWeb.BookmarkLive.Index do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote

  def render(assigns) do
    ~H"""
    <main class="flex-1 p-6 max-w-4x1 mx-auto">
      <div class="mb-4">
        <h1 class="text-x1 font-semibold">{@page_title}</h1>
      </div>
      <div class="bg-slate-50 border rounded">
        <div id="rooms" class="divide-y" phx-update="stream">
          <.link
            :for={{id, {bookmark, joined?}} <- @streams.bookmarks}
            class="cursor-pointer p-4 flex justify-between items-center group first:rounded-t last-rounded-b"
            id={id}
            navigate={~p"/bookmarks/#{bookmark}"}
          >
            <div>
              <div class="font-medium mb-1">
                #{bookmark.name}
                <span class="mx-1 text-gray-500 font-light text-sm hidden group-hover:inline group-focus:inline">
                  View Bookmark
                </span>
              </div>
              <div class="text-gray-500 text-sm">
                <%= if joined? do %>
                  <span class="text-green-600 font-bold">Joined </span>
                <% end %>
                <%= if joined? && bookmark.name do %>
                  <span class="mx-1">.</span>
                <% end %>
                <%= if bookmark.url_link do %>
                  {bookmark.url_link}
                <% end %>
              </div>
            </div>
          </.link>
        </div>
      </div>
    </main>
    """
  end

  def mount(_param, _session, socket) do
    bookmarks = Remote.list_bookmarks_with_joined(socket.assigns.current_user)
    socket = socket
      |> assign(page_title: "All bookmarks")
      |> stream_configure(:bookmarks, dom_id: fn {bookmark, _} -> "bookmarks-#{bookmark.id}" end)
      |> stream(:bookmarks, bookmarks)
    {:ok, socket}
  end
end
