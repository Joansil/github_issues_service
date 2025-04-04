defmodule GithubIssuesServiceWeb.ErrorHandler do
  @moduledoc """
  Tratamento de erros para requisições HTTP
  """

  require Logger

  def handle_errors(conn, %{reason: %Plug.Parsers.ParseError{exception: %Jason.DecodeError{}}}) do
    Logger.warning("Invalid JSON received in request")

    conn
    |> Plug.Conn.put_status(:bad_request)
    |> Phoenix.Controller.json(%{
      error: "Invalid JSON format",
      details: [
        "The request body contains malformed JSON.",
        "Please verify the JSON syntax and try again."
      ],
      example: %{
        user: "username",
        repository: "repository-name"
      },
      documentation: "For more information, visit our API documentation at /api/docs"
    })
  end

  def handle_errors(conn, %{reason: %Plug.Parsers.ParseError{}} = error) do
    Logger.warning("Parse error: #{inspect(error)}")

    conn
    |> Plug.Conn.put_status(:bad_request)
    |> Phoenix.Controller.json(%{
      error: "Invalid request format",
      details: [
        "The request could not be parsed.",
        "Please ensure you're sending valid JSON data."
      ],
      example: %{
        user: "username",
        repository: "repository-name"
      }
    })
  end

  def handle_errors(conn, %{reason: :invalid_content_type}) do
    conn
    |> Plug.Conn.put_status(:unsupported_media_type)
    |> Phoenix.Controller.json(%{
      error: "Invalid content type",
      details: [
        "This API only accepts application/json",
        "Please set the Content-Type header to application/json"
      ]
    })
  end

  def handle_errors(conn, error) do
    Logger.error("Unexpected error: #{inspect(error)}")

    conn
    |> Plug.Conn.put_status(:bad_request)
    |> Phoenix.Controller.json(%{
      error: "Bad request",
      message: "The request could not be processed",
      details: [
        "An unexpected error occurred while processing your request.",
        "Please verify your request format and try again."
      ]
    })
  end
end
