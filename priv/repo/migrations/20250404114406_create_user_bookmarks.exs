defmodule Rlinkx.Repo.Migrations.CreateUserBookmarks do
  use Ecto.Migration

  def change do
    create table(:user_bookmarks) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :bookmark_id, references(:bookmarks, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_bookmarks, [:user_id])
    create index(:user_bookmarks, [:bookmark_id])
    create unique_index(:user_bookmarks, [:user_id, :bookmark_id])
  end
end
