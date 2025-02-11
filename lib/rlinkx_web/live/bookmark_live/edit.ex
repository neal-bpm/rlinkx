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

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} label="Name" />
        <.input field={@form[:url_link]} label="URL" type="text"/>
        <.input field={@form[:description]} label="Description" type="text"/>
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

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
