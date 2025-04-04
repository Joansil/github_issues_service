defmodule GithubIssuesService.Repositories.Repository do
  @moduledoc """
  Contexto principal para gerenciamento de repositórios
  """

  alias GithubIssuesService.Github.Client
  alias GithubIssuesService.Webhook.Notifier

  require Logger

  @type repository_data :: %{
    user: binary(),
    repository: binary(),
    issues: list(map()),
    contributors: list(map())
  }

  @type repository_response :: {:ok, repository_data} | {:error, any()}

  @spec fetch_repository_data(binary(), binary()) :: repository_response
  def fetch_repository_data(user, repo) do
    Logger.info("Fetching repository data for #{user}/#{repo}")

    with {:ok, issues} <- Client.get_issues(user, repo),
         {:ok, contributors} <- Client.get_contributors(user, repo) do

      Logger.info("Successfully fetched data. Issues: #{length(issues)}, Contributors: #{length(contributors)}")

      data = %{
        user: user,
        repository: repo,
        issues: format_issues(issues),
        contributors: format_contributors(contributors)
      }

      Logger.info("Formatted data: #{inspect(data, pretty: true)}")

      # Agenda o envio do webhook para 24h depois
      # Process.send_after(self(), {:send_webhook, data}, 24 * 60 * 60 * 1000)

      # Envia o webhook imediatamente para teste
       Task.start(fn ->
         Logger.info("Sending webhook notification")
         Notifier.notify(data)
       end)

      {:ok, data}
    else
      {:error, reason} ->
        Logger.error("Error fetching data: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec format_issues(list(map())) :: list(map())
  defp format_issues(issues) do
    Enum.map(issues, fn issue ->
      %{
        title: issue["title"],
        author: issue["user"]["login"],
        labels: Enum.map(issue["labels"] || [], & &1["name"])
      }
    end)
  end

  @spec format_contributors(list(map())) :: list(map())
  defp format_contributors(contributors) do
    Enum.map(contributors, fn contributor ->
      %{
        name: contributor["login"],
        user: contributor["login"],
        qtd_commits: contributor["contributions"]
      }
    end)
  end

  # defp schedule_webhook_notification(data) do
  #   # Process.send_after(self(), {:send_webhook, data}, 24 * 60 * 60 * 1000)

  #   Process.send_after(self(), {:send_webhook, data}, 10 * 1000)
  # end
end
