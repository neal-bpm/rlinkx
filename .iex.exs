alias Rlinkx.Repo
alias Rlinkx.Remote
alias Rlinkx.Accounts
alias Rlinkx.Remote.{Bookmark, Insight}

bookmark = Repo.get_by!(Bookmark, name: "postgresql")
user = Accounts.get_user_by_email("learn@daily.com")
