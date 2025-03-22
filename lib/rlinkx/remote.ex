defmodule Rlinkx.Remote do
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.{Bookmark, Insight}
  alias Rlinkx.Repo

  import Ecto.Query

  @pubsub Rlinkx.PubSub

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
    with {:ok, insight} <-
           %Insight{bookmark: bookmark, user: user}
           |> Insight.changeset(attrs)
           |> Repo.insert() do
      Phoenix.PubSub.broadcast!(@pubsub, topic(bookmark.id), {:new_insight, insight})
    end
  end

  def delete_insight_by_id(id, %User{id: user_id}) do
    insight = %Insight{user_id: ^user_id} = Repo.get(Insight, id)

    Repo.delete(insight)

    Phoenix.PubSub.broadcast!(@pubsub, topic(insight.bookmark_id), {:insight_deleted, insight})
  end

  def subscribe_to_bookmark(bookmark) do
    Phoenix.PubSub.subscribe(@pubsub, topic(bookmark.id))
  end

  def unsubscribe_from_bookmark(bookmark) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(bookmark.id))
  end

  defp topic(bookmark_id), do: "remote_bookmark:#{bookmark_id}"
end
