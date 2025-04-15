defmodule RlinkxWeb.BookmarkController do
  use RlinkxWeb, :controller

  alias Rlinkx.Remote

  def redirect_to_first(conn, _params) do
    path =
      case Remote.list_joined_bookmarks(conn.assigns.current_user) do
        [] ->
          ~p"/bookmarks"

        [first | _] ->
          ~p"/bookmarks/#{first}"
      end

    redirect(conn, to: path)
  end
end
