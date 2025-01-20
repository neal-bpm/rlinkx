defmodule Rlinkx.Repo.Migrations.CreateBookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks) do
      add :name, :string, null: false
      add :description, :text
      add :url_link, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
