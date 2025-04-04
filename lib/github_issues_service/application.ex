defmodule GithubIssuesService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GithubIssuesServiceWeb.Telemetry,
      GithubIssuesService.Repo,
      {DNSCluster, query: Application.get_env(:github_issues_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GithubIssuesService.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GithubIssuesService.Finch},
      # Start a worker by calling: GithubIssuesService.Worker.start_link(arg)
      # {GithubIssuesService.Worker, arg},
      # Start to serve requests, typically the last entry
      GithubIssuesServiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GithubIssuesService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GithubIssuesServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
