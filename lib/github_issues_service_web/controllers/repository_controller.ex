defmodule GithubIssuesServiceWeb.RepositoryController do
  use GithubIssuesServiceWeb, :controller
  require Logger

  alias GithubIssuesService.Repositories.Repository

  action_fallback GithubIssuesServiceWeb.FallbackController

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    with {:ok, user, repository} <- validate_params(params),
         {:ok, _data} <- Repository.fetch_repository_data(user, repository) do
      conn
      |> put_status(:accepted)
      |> json(%{
        message: "Request accepted, webhook will be sent in 24 hours",
        details: %{
          user: user,
          repository: repository
        }
      })
    end
  end

  defp validate_params(%{"user" => user, "repository" => repository}) when is_binary(user) and is_binary(repository) do
    {:ok, user, repository}
  end

  defp validate_params(_) do
    {:error, :missing_fields}
  end
end
