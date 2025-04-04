import Config

config :github_issues_service, GithubIssuesServiceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ZFx6aJ0JtKgirBBTDkBx5WVaf97WC9fYQWfheSMabV/2DUnuqfblfNLqCH2+aSst",
  server: false

config :logger, level: :warning

# Configuração de teste para webhook
config :github_issues_service,
  webhook_url: "http://test-webhook.com"

