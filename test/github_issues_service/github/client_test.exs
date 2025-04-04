defmodule GithubIssuesService.Github.ClientTest do
  use ExUnit.Case, async: true
  alias GithubIssuesService.Github.Client

  defmodule MockHTTP do
    def get(url, _headers) do
      cond do
        String.contains?(url, "/issues") ->
          {:ok, %{
            status_code: 200,
            body: Jason.encode!([%{
              "title" => "Test Issue",
              "user" => %{"login" => "test_user"},
              "labels" => [%{"name" => "bug"}]
            }])
          }}
        String.contains?(url, "/contributors") ->
          {:ok, %{
            status_code: 200,
            body: Jason.encode!([%{
              "login" => "test_user",
              "contributions" => 10
            }])
          }}
        true ->
          {:ok, %{status_code: 404}}
      end
    end
  end

  describe "get_issues/2" do
    test "successfully fetches issues" do
      assert {:ok, [%{"title" => "Test Issue"}]} = Client.get_issues("user", "repo", MockHTTP)
    end
  end

  describe "get_contributors/2" do
    test "successfully fetches contributors" do
      assert {:ok, [%{"login" => "test_user"}]} = Client.get_contributors("user", "repo", MockHTTP)
    end
  end
end
