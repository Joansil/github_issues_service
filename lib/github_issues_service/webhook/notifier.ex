defmodule GithubIssuesService.Webhook.Notifier do
  @moduledoc """
  Serviço responsável pelo envio de webhooks
  """
  require Logger

  alias GithubIssuesService.ConfigEnvs

  @type webhook_response ::
    {:ok, :webhook_sent} |
    {:error, :missing_webhook_url | :webhook_failed | :json_encode_failed | any()}


  @spec notify(map(), module()) :: webhook_response
  def notify(data, http_client \\ http_client()) do
   Logger.info("Current webhook URL: #{inspect(ConfigEnvs.webhook_url())}")

    with {:ok, webhook_url} <- get_webhook_url(),
         {:ok, json_data} <- Jason.encode(data) do
      do_notify(webhook_url, json_data, http_client)
    else
      {:error, :missing_webhook_url} = error ->
        Logger.error("WEBHOOK_URL not configured")
        error
      {:error, reason} ->
        Logger.error("Failed to encode JSON: #{inspect(reason)}")
        {:error, :json_encode_failed}
    end
  end

  @spec get_webhook_url() :: {:ok, binary()} | {:error, :missing_webhook_url}
  defp get_webhook_url do
    case Application.get_env(:github_issues_service, :webhook_url) do
      nil -> {:error, :missing_webhook_url}
      url -> {:ok, url}
    end
  end

  @spec do_notify(binary(), binary(), module()) :: webhook_response
  defp do_notify(webhook_url, json_data, http_client) do
   Logger.info("Sending webhook to: #{webhook_url}")

    case http_client.post(webhook_url, json_data, [{"Content-Type", "application/json"}]) do
      {:ok, %{status_code: status}} when status in 200..299 ->
        Logger.info("Webhook successfully sent")
        {:ok, :webhook_sent}
      {:ok, response} ->
        Logger.error("Webhook failed with response: #{inspect(response)}")
        {:error, :webhook_failed}
      {:error, reason} ->
        Logger.error("Failed to send webhook: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec http_client() :: module()
  defp http_client do
    Application.get_env(:github_issues_service, :http_client, HTTPoison)
  end
end
