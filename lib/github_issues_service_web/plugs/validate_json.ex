# lib/github_issues_service_web/plugs/validate_json.ex
defmodule GithubIssuesServiceWeb.Plugs.ValidateJSON do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "content-type") do
      ["application/json" <> _] ->
        conn
      _ ->
        conn
        |> put_status(:unsupported_media_type)
        |> Phoenix.Controller.json(%{
          error: "Invalid content type",
          details: [
            "This API only accepts application/json",
            "Please set the Content-Type header to application/json"
          ]
        })
        |> halt()
    end
  end
end
