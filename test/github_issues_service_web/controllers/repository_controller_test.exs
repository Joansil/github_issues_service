defmodule GithubIssuesServiceWeb.RepositoryControllerTest do
  use GithubIssuesServiceWeb.ConnCase
  import Mock

  alias GithubIssuesService.Repositories.Repository

  setup do
    conn = build_conn()
           |> put_req_header("content-type", "application/json")
    {:ok, conn: conn}
  end

  describe "create/2" do
    test "returns accepted when repository is found", %{conn: conn} do
      with_mock Repository, fetch_repository_data: fn _, _ ->
        {:ok, %{
          user: "test_user",
          repository: "test_repo",
          issues: [],
          contributors: []
        }}
      end do
        conn = post(conn, ~p"/api/repositories", %{user: "test_user", repository: "test_repo"})
        assert json_response(conn, 202)["message"] =~ "Request accepted"
      end
    end

    test "returns not found when repository doesn't exist", %{conn: conn} do
      with_mock Repository, fetch_repository_data: fn _, _ ->
        {:error, :not_found}
      end do
        conn = post(conn, ~p"/api/repositories", %{user: "invalid", repository: "invalid"})
        assert json_response(conn, 404)["error"] == "Repository not found"
      end
    end

    test "handles internal server error", %{conn: conn} do
      with_mock Repository, fetch_repository_data: fn _, _ ->
        {:error, "some error"}
      end do
        conn = post(conn, ~p"/api/repositories", %{user: "test_user", repository: "test_repo"})
        assert json_response(conn, 500)["error"] == "An error occurred"
      end
    end
  end
end
