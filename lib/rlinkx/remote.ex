defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  def list_bookmarks() do
    Repo.all(Bookmark)
  end
end
