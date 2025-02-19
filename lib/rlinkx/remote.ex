defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.{Bookmark, Insight}
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

  def list_insights_in_bookmark(%Bookmark{id: bookmark_id}) do
    Insight
    |> where([insight], insight.bookmark_id == ^bookmark_id)
    |> order_by([insight], asc: insight.inserted_at, asc: insight.id)
    |> preload(:user)
    |> Repo.all()
  end

  def change_insight(message, attrs \\ %{}) do
    Insight.changeset(message, attrs)
  end

  def create_insight(bookmark, attrs, user) do
    %Insight{bookmark: bookmark, user: user}
    |> Insight.changeset(attrs)
    |> Repo.insert()
  end
end
