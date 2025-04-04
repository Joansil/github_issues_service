defmodule GithubIssuesServiceWeb.Router do
  use GithubIssuesServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug GithubIssuesServiceWeb.Plugs.ValidateJSON
  end

  scope "/api", GithubIssuesServiceWeb do
    pipe_through :api

    post "/repositories", RepositoryController, :create
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:github_issues_service, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      # forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
