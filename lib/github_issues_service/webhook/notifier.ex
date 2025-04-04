defmodule GithubIssuesService.Webhook.Notifier do
  @moduledoc """
  Serviço responsável pelo envio de webhooks
  """
  require Logger
  
  @webhook_url "https://webhook.site/b42eefc3-c368-4a90-ae0f-e33aa7f8883c"

  def notify(data) do
    Logger.info("Preparing to send webhook notification")
    Logger.debug("Webhook payload: #{inspect(data, pretty: true)}")

    case Jason.encode(data) do
      {:ok, json_data} ->
        Logger.info("Successfully encoded JSON payload")

        HTTPoison.post(@webhook_url, json_data, [
          {"Content-Type", "application/json"}
        ])
        |> handle_response()

      {:error, reason} ->
        Logger.error("Failed to encode JSON: #{inspect(reason)}")
        {:error, :json_encode_failed}
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status, body: body}}) when status in 200..299 do
    Logger.info("Webhook successfully sent")
    Logger.debug("Webhook response: #{inspect(body)}")
    {:ok, :webhook_sent}
  end

  defp handle_response({:ok, response}) do
    Logger.error("Webhook failed with response: #{inspect(response)}")
    {:error, :webhook_failed}
  end

  defp handle_response({:error, reason}) do
    Logger.error("Failed to send webhook: #{inspect(reason)}")
    {:error, reason}
  end
end
