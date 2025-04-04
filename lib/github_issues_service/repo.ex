defmodule GithubIssuesService.Repo do
  use Ecto.Repo,
    otp_app: :github_issues_service,
    adapter: Ecto.Adapters.Postgres
end
