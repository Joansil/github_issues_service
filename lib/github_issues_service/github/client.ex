defmodule GithubIssuesService.Github.Client do
  @moduledoc """
  Cliente para interação com a API do GitHub
  """

  use HTTPoison.Base

  require Logger

  @github_api "https://api.github.com"

  def get_issues(user, repo) do
    Logger.info("Fetching issues for #{user}/#{repo}")

    url = "#{@github_api}/repos/#{user}/#{repo}/issues"
    Logger.debug("Request URL: #{url}")

    url
    |> get([
      {"Accept", "application/vnd.github.v3+json"},
      {"User-Agent", "MyGithubApp"}
    ])
    |> handle_response()
  end

  def get_contributors(user, repo) do
    Logger.info("Fetching contributors for #{user}/#{repo}")

    url = "#{@github_api}/repos/#{user}/#{repo}/contributors"
    Logger.debug("Request URL: #{url}")

    url
    |> get([
      {"Accept", "application/vnd.github.v3+json"},
      {"User-Agent", "MyGithubApp"}
    ])
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    decoded_body = Jason.decode!(body)
    Logger.debug("Response body: #{inspect(decoded_body, pretty: true)}")
    {:ok, decoded_body}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    Logger.warning("Repository not found")
    {:error, :not_found}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.error("Error fetching from GitHub: #{inspect(reason)}")
    {:error, reason}
  end
end
