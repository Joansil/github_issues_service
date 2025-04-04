defmodule GithubIssuesService.Github.Client do
  @moduledoc """
  Cliente para interação com a API do GitHub
  """
  require Logger

  @github_api "https://api.github.com"

  @type github_response :: {:ok, list(map())} | {:error, :not_found | any()}


  @spec get_issues(binary(), binary(), module()) :: github_response
  def get_issues(user, repo, http_client \\ http_client()) do
    Logger.info("Fetching issues for #{user}/#{repo}")

    url = "#{@github_api}/repos/#{user}/#{repo}/issues"
    Logger.debug("Request URL: #{url}")

    case http_client.get(url, [{"Accept", "application/vnd.github.v3+json"}]) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %{status_code: 404}} ->
        {:error, :not_found}
      {:error, reason} ->
        Logger.error("Error fetching from GitHub: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec get_contributors(binary(), binary(), module()) :: github_response
  def get_contributors(user, repo, http_client \\ http_client()) do
    Logger.info("Fetching contributors for #{user}/#{repo}")

    url = "#{@github_api}/repos/#{user}/#{repo}/contributors"
    Logger.debug("Request URL: #{url}")

    case http_client.get(url, [{"Accept", "application/vnd.github.v3+json"}]) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %{status_code: 404}} ->
        {:error, :not_found}
      {:error, reason} ->
        Logger.error("Error fetching from GitHub: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec http_client() :: module()
  defp http_client do
    Application.get_env(:github_issues_service, :http_client, HTTPoison)
  end
end
