defmodule GithubIssuesService.HTTP.ClientBehaviour do
  @type headers :: [{binary(), binary()}]
  @type response :: {:ok, map()} | {:error, any()}

  @callback get(url :: binary(), headers()) :: response
  @callback get(String.t(), list()) :: {:ok, map()} | {:error, any()}

  @callback post(url :: binary(), body :: binary(), headers()) :: response
  @callback post(String.t(), String.t(), list()) :: {:ok, map()} | {:error, any()}
end
