defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  import Ecto.Query

  def get_bookmark!(id) do
    Repo.get!(Bookmark, id)
  end

  def list_bookmarks() do
    Repo.all(from Bookmark, order_by: [asc: :name])
  end

  def change_bookmark(bookmark, attrs \\ %{}) do
    Bookmark.changeset(bookmark, attrs)
  end

  def create_bookmark(attrs) do
    %Bookmark{}
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
  end

  def update_bookmark(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end
end
