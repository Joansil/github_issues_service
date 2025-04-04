defmodule GithubIssuesService.Repositories.RepositoryTest do
  use ExUnit.Case

  import Mock

  alias GithubIssuesService.Repositories.Repository
  alias GithubIssuesService.Github.Client

  describe "fetch_repository_data/2" do
    test "success: fetches and formats repository data" do
      issues = [
        %{
          "title" => "Test Issue",
          "user" => %{"login" => "test_user"},
          "labels" => [%{"name" => "bug"}]
        }
      ]

      contributors = [
        %{
          "login" => "test_user",
          "contributions" => 10
        }
      ]

      with_mocks([
        {Client, [],
         [
           get_issues: fn _, _ -> {:ok, issues} end,
           get_contributors: fn _, _ -> {:ok, contributors} end
         ]}
      ]) do
        {:ok, result} = Repository.fetch_repository_data("test_user", "test_repo")

        assert result.user == "test_user"
        assert result.repository == "test_repo"
        assert length(result.issues) == 1
        assert length(result.contributors) == 1

        [issue] = result.issues
        assert issue.title == "Test Issue"
        assert issue.author == "test_user"
        assert issue.labels == ["bug"]

        [contributor] = result.contributors
        assert contributor.name == "test_user"
        assert contributor.qtd_commits == 10
      end
    end

    test "handles empty issues and contributors" do
      with_mocks([
        {Client, [],
         [
           get_issues: fn _, _ -> {:ok, []} end,
           get_contributors: fn _, _ -> {:ok, []} end
         ]}
      ]) do
        {:ok, result} = Repository.fetch_repository_data("test_user", "test_repo")

        assert result.issues == []
        assert result.contributors == []
      end
    end

    test "handles error from issues request" do
      with_mocks([
        {Client, [],
         [
           get_issues: fn _, _ -> {:error, :not_found} end
         ]}
      ]) do
        assert {:error, :not_found} = Repository.fetch_repository_data("test_user", "test_repo")
      end
    end

    test "handles error from contributors request" do
      with_mocks([
        {Client, [],
         [
           get_issues: fn _, _ -> {:ok, []} end,
           get_contributors: fn _, _ -> {:error, :not_found} end
         ]}
      ]) do
        assert {:error, :not_found} = Repository.fetch_repository_data("test_user", "test_repo")
      end
    end
  end
end
