defmodule RlinkxWeb.BookmarkLive do
  use RlinkxWeb, :live_view

  alias Rlinkx.Accounts.User
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
      <%!-- TO Do Step 2:  make phx-update as stream at div  --%>
      <%!-- Add id to the main container --%>
      <div id="bookmark-insight" class="flex flex-col grow overflow-auto" phx-update="stream">
        <%!-- Get insights from stream instead of from assigns which returns a tuple with --%>

        <%!-- insight_id, insight. Pass both to function component insight --%>

        <.insight :for={{dom_id, insight} <- @streams.insights} dom_id={dom_id} insight={insight} timezone={@timezone} current_user={@current_user} />
      </div>
      <div class="h-12 bg-white px-4 pb-4">
        <.form
          id="new-insight-form"
          for={@new_insight_form}
          phx-change="validate-insight"
          phx-submit="submit-insight"
          class="flex items-center border-2 border-slate-300 rounded-sm p-1"
        >
          <textarea
            class="grow text-sm px-3 border-1 border-slate-300 mx-1 resize-none"
            cols=""
            id="bookmark-insight-textarea"
            name={@new_insight_form[:body].name}
            placeholder={"insight #{@bookmark.name}"}
            phx-debounce
            rows="1"
          >{Phoenix.HTML.Form.normalize_value("textarea", @new_insight_form[:body].value)}
        </textarea>
          <button class="shrink flex items-center justify-center h-6 w-6 rounded hover:bg-slate-200">
            <.icon name="hero-paper-airplane" class="h-4 w-4" />
          </button>
        </.form>
      </div>
    </div>
    """
  end

  attr :current_user, User, required: true
  attr :dom_id, :string, required: true
  attr :insight, Insight, required: true
  attr :timezone, :string, required: true

  defp insight(assigns) do
    ~H"""
    <div id={@dom_id} class="relative flex px-4 py-3">
      <div class="h-10 w-10 rounded shrink-0 bg-slate-300"></div>
      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span>{get_username(@insight.user.email)}</span>
          </.link>
          <span :if={@timezone} class="ml-1 text-xs text-gray-500">{message_timestamp(@insight, @timezone)}</span>
          <button :if={@current_user.id == @insight.user_id}
            class="absolute top-4 right-4 text-red-400 hover:text-red-800 cursor-pointer"
            data-confirm="Are you sure?"
            phx-click="delete-insight"
            phx-value-id={@insight.id}
            >
            <.icon name="hero-trash" class="h-4 w-4" />
          </button>
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

    timezone = get_connect_params(socket)["timezone"]

    #require IEx, IEx.pry()
    {:ok, assign(socket, bookmarks: bookmarks, timezone: timezone)}
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
     socket
     |> assign(
       hide_description?: false,
       bookmark: bookmark,
       # TO DO Step 1 - loading insights for each user is overload server.
       # Dedicate this is browser by streams
       # move out insights from assigns and pass it as stream in socket
       # On switching between bookmarks, need to reset the stream
       page_title: "#" <> bookmark.name
     )
     |> stream(:insights, insights, reset: true)
     |> assign_insight_form(Remote.change_insight(%Insight{}))}
  end

  def handle_event("toggle-description", _params, socket) do
    {:noreply, update(socket, :hide_description?, &(!&1))}
  end

  def handle_event("validate-insight", %{"insight" => insight_params}, socket) do
    changeset = Remote.change_insight(%Insight{}, insight_params)
    {:noreply, assign_insight_form(socket, changeset)}
  end

  # TO DO insight submit
  def handle_event("submit-insight", %{"insight" => insight_params}, socket) do
    # pull out room and user from assigns
    %{bookmark: bookmark, current_user: current_user} = socket.assigns

    socket =
      case Remote.create_insight(bookmark, insight_params, current_user) do
        {:ok, new_insight} ->
          socket
          # TO DO replace update assigns with stream insert
          |> stream_insert(:insights, new_insight)
          |> assign_insight_form(Remote.change_insight(%Insight{}))

        {:error, changeset} ->
          assign_insight_form(changeset, socket)
      end

    {:noreply, socket}
    # create Insight structure and include room and user
    # create changeset with body from form
    # Repo insert
    # handle succes and error case
    # success - append the new insight with existing insightns and create new blank form
    # error - create new blank form
  end

  def handle_event("delete-insight", %{"id" => id}, socket) do
    {:ok, insight} = Remote.delete_insight_by_id(id, socket.assigns.current_user)

    {:noreply, stream_delete(socket, :insights, insight)}
  end

  def assign_insight_form(socket, changeset) do
    IO.inspect("assign_insight_form")
    IO.inspect(changeset)
    assign(socket, :new_insight_form, to_form(changeset))
  end

  defp get_username(user_email) do
    user_email |> String.split("@") |> List.first() |> String.capitalize()
  end

  defp message_timestamp(insight, timezone) do
    insight.inserted_at
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%-l:%M %p", :strftime)
  end
end
