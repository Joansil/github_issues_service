defmodule GithubIssuesServiceWeb.FallbackController do
  use GithubIssuesServiceWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{
      error: "Repository not found",
      details: [
        "Please ensure that:",
        "1. The repository exists",
        "2. The repository is public",
        "3. The user name is correct",
        "4. The repository name is correct"
      ]
    })
  end

  def call(conn, {:error, :invalid_json}) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Invalid JSON format",
      details: [
        "Please ensure that:",
        "1. The request body is valid JSON",
        "2. All required fields are present",
        "3. The JSON structure follows the expected format"
      ],
      example: %{
        user: "username",
        repository: "repository-name"
      }
    })
  end

  def call(conn, {:error, :missing_fields}) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Missing required fields",
      details: [
        "The following fields are required:",
        "1. user",
        "2. repository"
      ],
      example: %{
        user: "username",
        repository: "repository-name"
      }
    })
  end

  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{
      error: "An error occurred",
      message: reason
    })
  end

  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{
      error: "Internal server error",
      message: "An unexpected error occurred"
    })
  end
end
