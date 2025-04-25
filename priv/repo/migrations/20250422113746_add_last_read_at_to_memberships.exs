defmodule Rlinkx.Repo.Migrations.AddLastReadAtToMemberships do
  use Ecto.Migration

  def change do
    alter table(:user_bookmarks) do
      add :last_read_at, :utc_datetime
    end
  end
end
