defmodule Rlinkx.Remote.Bookmark do
  use Ecto.Schema

  import Ecto.Changeset

  schema "bookmarks" do
    field :name, :string
    field :description, :string
    field :url_link, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:name, :description, :url_link])
    |> validate_required([:name, :url_link])
    |> validate_format(:name, ~r/\A[a-z0-9-]+\z/)
    |> validate_length(:name, max: 30)
    |> validate_length(:url_link, max: 200)
    |> validate_change(:url_link, &validate_URL/2)
  end

  # TO DO use URI new and then current logic
  def validate_URL(:url_link, url) do
    with {:ok, uri} = URI.new(url),
         schema when schema in ["http", "https"] <- Map.get(uri, :scheme),
         host when is_binary(host) <- Map.get(uri, :host) do
      []
    else
      _other_case ->
        [url_link: "invalid url link"]
    end
  end
end
