defmodule Rlinkx.Repo.Migrations.CreateUniqueIndexOnBookmarkName do
  use Ecto.Migration

  def change do
    create unique_index(:bookmarks, :name)
  end
end
