defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  import Ecto.Query

  def list_bookmarks() do
    Repo.all(from Bookmark, order_by: [asc: :name])
  end
end
