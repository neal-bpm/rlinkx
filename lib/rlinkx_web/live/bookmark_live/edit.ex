defmodule RlinkxWeb.BookmarkLive.Edit do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote

  def render(assigns) do
    ~H"""
    <div class="mx-auto w-96 mt-12">
      <.header>
        {@page_title}
        <:actions>
          <.link
            class="font-normal text-xs text-blue-600 hover:text-blue-700"
            navigate={~p"/bookmarks/#{@bookmark}"}
          >
            Back
          </.link>
        </:actions>
      </.header>

      <.simple_form for={@form} phx-change="validate-bookmark" phx-submit="save-bookmark">
        <.input field={@form[:name]} label="Name" phx-debounce/>
        <.input field={@form[:url_link]} label="URL" type="text" phx-debounce/>
        <.input field={@form[:description]} label="Description" type="text" phx-debounce/>
        <:actions>
          <.button phx-disable-with="Saving..." class="w-full">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    bookmark = Remote.get_bookmark!(id)
    changeset = Remote.change_bookmark(bookmark)

    socket =
      socket
      |> assign(page_title: "Edit remote link", bookmark: bookmark)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate-bookmark", %{"bookmark" => bookmark_params}, socket) do
    changeset =
      socket.assigns.bookmark
      |> Remote.change_bookmark(bookmark_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save-bookmark", %{"bookmark" => bookmark_params}, socket) do
    case Remote.update_bookmark(socket.assigns.bookmark, bookmark_params) do
      {:ok, bookmark} ->
        {:noreply,
          socket
          |> put_flash(:info, "Bookmark updated successfully")
          |> push_navigate(to: ~p"/bookmarks/#{bookmark}")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
