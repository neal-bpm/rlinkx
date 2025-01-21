defmodule RlinkxWeb.BookmarkLive do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo


  def render(assigns) do
    ~H"""
    <div class="bg-[#34d399] flex flex-col grow shadow-lg">
      <div class="bg-[#34d300] flex justify-between items-center shrink-0 h-16 bg-white border-b border-slate-300 px-4">
        <div class="bg-[#34a200] flex flex-col gap-1.5">
          <h1 class="text-sm font-bold leading-none">
            #{@bookmark.name}
          </h1>
          <div class={["bg-[#329200] text-xs leading-none h-3.5", @hide_description? && "text-slate-600"]} phx-click="toggle-description">
            <%= if @hide_description? do%>
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

  def mount(_params, _session, socket) do
    bookmark = Bookmark |> Repo.all |> List.first()

    {:ok, assign(socket, hide_description?: false, bookmark: bookmark)}
  end

  def handle_event("toggle-description", _params, socket) do
    {:noreply, update(socket, :hide_description?, &(!&1))}
  end
end
