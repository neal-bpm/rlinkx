alias Rlinkx.Repo
alias Rlinkx.Remote
alias Rlinkx.Accounts
alias Rlinkx.Remote.{Bookmark, Insight}

import Ecto.Query

bookmark = Repo.get_by!(Bookmark, name: "postgresql")
user = Accounts.get_user_by_email("learn@daily.com")
