defmodule Rlinkx.Remote.UserBookmark do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.Bookmark

  schema "user_bookmarks" do
    belongs_to :user, User
    belongs_to :bookmark, Bookmark

    field :last_read_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_bookmark, attrs) do
    user_bookmark
    |> cast(attrs, [])
    |> validate_required([])
  end

  def add_last_read_at_change(user_bookmark, timestamp) do
    user_bookmark
    |> change(%{last_read_at: timestamp})
  end

end
