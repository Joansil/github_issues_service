defmodule GithubIssuesServiceWeb.RepositoryController do
  use GithubIssuesServiceWeb, :controller
  require Logger

  alias GithubIssuesService.Repositories.Repository

  def create(conn, %{"user" => user, "repository" => repository}) do
    clean_repository = repository |> String.replace("https://github.com/", "") |> String.replace(~r/.*\//, "")

    Logger.info("Fetching data for user: #{user}, repository: #{clean_repository}")

    case Repository.fetch_repository_data(user, clean_repository) do
      {:ok, _data} ->
        conn
        |> put_status(:accepted)
        |> json(%{
          message: "Request accepted, webhook will be sent in 24 hours",
          details: %{
            user: user,
            repository: clean_repository
          }
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          error: "Repository not found",
          details: [
            "Please ensure that:",
            "1. The repository exists",
            "2. The repository is public",
            "3. The user name is correct",
            "4. The repository name is correct (don't include the full GitHub URL)"
          ],
          example: %{
            correct_format: %{
              user: "username",
              repository: "repository-name"
            },
            example_request: %{
              user: "phoenixframework",
              repository: "phoenix"
            }
          }
        })

      {:error, reason} ->
        Logger.error("Error processing request: #{inspect(reason)}")
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          error: "An error occurred",
          message: "#{inspect(reason)}",
          details: "Please check the request format and try again"
        })
    end
  end
end
