defmodule GithubIssuesService.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    GithubIssuesService.ConfigEnvs.load_env()

    children = [
      GithubIssuesServiceWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: GithubIssuesService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GithubIssuesServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # defp load_env do
  #   if File.exists?(".env") do
  #     File.read!(".env")
  #     |> String.split("\n")
  #     |> Enum.filter(&(String.length(&1) > 0 && !String.starts_with?(&1, "#")))
  #     |> Enum.each(fn line ->
  #       [key, value] = String.split(line, "=", parts: 2)
  #       System.put_env(String.trim(key), String.trim(value))
  #     end)
  #   end
  # end
end
