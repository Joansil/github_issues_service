defmodule GithubIssuesService.ConfigEnvs do
  @moduledoc """
  Módulo responsável por gerenciar configurações da aplicação
  """

  def webhook_url do
    Application.get_env(:github_issues_service, :webhook_url) ||
      System.get_env("WEBHOOK_URL")
  end

  def load_env do
    if File.exists?(".env") do
      File.read!(".env")
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) > 0 && !String.starts_with?(&1, "#")))
      |> Enum.each(fn line ->
        case String.split(line, "=", parts: 2) do
          [key, value] ->
            key = String.trim(key)
            value = String.trim(value)
            System.put_env(key, value)

            if key == "WEBHOOK_URL" do
              Application.put_env(:github_issues_service, :webhook_url, value)
            end
          _ -> :ok
        end
      end)
    end
  end
end
