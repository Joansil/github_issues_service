defmodule GithubIssuesService.Webhook.NotifierTest do
  use ExUnit.Case, async: true
  alias GithubIssuesService.Webhook.Notifier

  defmodule MockHTTP do
    def post(_url, _body, _headers), do: {:ok, %{status_code: 200}}
  end

  defmodule MockHTTPFailure do
    def post(_url, _body, _headers), do: {:ok, %{status_code: 500}}
  end

  setup do
    original_webhook_url = Application.get_env(:github_issues_service, :webhook_url)

    on_exit(fn ->
      if original_webhook_url do
        Application.put_env(:github_issues_service, :webhook_url, original_webhook_url)
      else
        Application.delete_env(:github_issues_service, :webhook_url)
      end
    end)

    :ok
  end

  describe "notify/1" do
    test "successfully sends webhook" do
      Application.put_env(:github_issues_service, :webhook_url, "http://test.com")
      assert {:ok, :webhook_sent} = Notifier.notify(%{test: "data"}, MockHTTP)
    end

    test "handles webhook failure" do
      Application.put_env(:github_issues_service, :webhook_url, "http://test.com")
      assert {:error, :webhook_failed} = Notifier.notify(%{test: "data"}, MockHTTPFailure)
    end

    test "handles missing webhook URL" do
      Application.delete_env(:github_issues_service, :webhook_url)
      assert {:error, :missing_webhook_url} = Notifier.notify(%{test: "data"}, MockHTTP)
    end

    test "handles invalid JSON data" do
      Application.put_env(:github_issues_service, :webhook_url, "http://test.com")
      data = %{key: self()}  #
      assert {:error, :json_encode_failed} = Notifier.notify(data, MockHTTP)
    end
  end
end
