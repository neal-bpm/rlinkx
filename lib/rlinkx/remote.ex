defmodule Rlinkx.Remote do
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.{Bookmark, Insight}
  alias Rlinkx.Remote.UserBookmark
  alias Rlinkx.Repo

  import Ecto.Query

  @pubsub Rlinkx.PubSub

  def get_bookmark!(id) do
    Repo.get!(Bookmark, id)
  end

  def list_bookmarks() do
    Repo.all(from Bookmark, order_by: [asc: :name])
  end

  def list_joined_bookmarks(%User{} = user) do
    user
    |> Repo.preload(:bookmarks)
    |> Map.fetch!(:bookmarks)
    |> Enum.sort_by(& &1.name)
  end

  def list_bookmarks_with_joined(%User{} = user) do
    query =
      from b in Bookmark,
        left_join: m in UserBookmark,
        on: b.id == m.bookmark_id and m.user_id == ^user.id,
        select: {b, not is_nil(m.id)},
        order_by: [asc: :name]

    Repo.all(query)
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

  def join_bookmark!(bookmark, user) do
    Repo.insert!(%UserBookmark{bookmark: bookmark, user: user})
  end

  def joined?(%Bookmark{} = bookmark, %User{} = user) do
    Repo.exists?(
      from ub in UserBookmark, where: ub.bookmark_id == ^bookmark.id and ub.user_id == ^user.id
    )
  end

  def toggle_bookmark_membership(bookmark, user) do
    case get_user_bookmark(bookmark, user) do
      %UserBookmark{} = user_bookmark ->
        Repo.delete(user_bookmark)
        {bookmark, false}

      nil ->
        join_bookmark!(bookmark, user)
        {bookmark, true}
    end
  end

  defp get_user_bookmark(bookmark, user) do
    Repo.get_by(UserBookmark, bookmark_id: bookmark.id, user_id: user.id)
  end

  def update_last_read_at(bookmark, user) do
    case get_user_bookmark(bookmark, user) do
      %UserBookmark{} = user_bookmark ->
        timestamp =
          from(i in Insight, where: i.bookmark_id == ^bookmark.id, select: max(i.inserted_at))
          |> Repo.one()

        user_bookmark |> UserBookmark.add_last_read_at_change(timestamp) |> Repo.update()

      nil ->
        nil
    end
  end

  def get_last_read_at(%Bookmark{} = bookmark, user) do
    case get_user_bookmark(bookmark, user) do
      %UserBookmark{} = user_bookmark ->
        user_bookmark.last_read_at

      nil ->
        nil
    end
  end
end
