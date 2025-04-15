defmodule Rlinkx.Remote.UserBookmark do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.Bookmark

  schema "user_bookmarks" do
    belongs_to :user, User
    belongs_to :bookmark, Bookmark

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_bookmark, attrs) do
    user_bookmark
    |> cast(attrs, [])
    |> validate_required([])
  end
end
