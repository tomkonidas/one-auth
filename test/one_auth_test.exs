defmodule OneAuthTest do
  use ExUnit.Case, async: false

  import Plug.Conn
  import Plug.Test

  alias OneAuth.Session

  @session_key :one_auth_session

  setup do
    clear_config()

    put_config(
      username: "admin",
      password: "password",
      signing_secret: "test-secret",
      login_redirect_path: "/dashboard"
    )

    on_exit(&clear_config/0)
    :ok
  end

  describe "login/3" do
    test "returns a connection with a session for valid credentials" do
      conn =
        :post
        |> conn("/login")
        |> init_test_session(%{})

      assert {:ok, conn} = OneAuth.login(conn, "admin", "password")

      token = get_session(conn, @session_key)
      assert is_binary(token)
      assert {:ok, payload} = Session.verify(token)
      assert payload["username"] == "admin"
    end

    test "returns error for invalid credentials" do
      conn =
        :post
        |> conn("/login")
        |> init_test_session(%{})

      assert :error = OneAuth.login(conn, "admin", "wrong")
    end
  end

  describe "login_path/1" do
    test "returns configured login path on normal flow" do
      login_path = OneAuth.Config.login_path()
      conn = conn(:get, login_path)
      assert OneAuth.login_path(conn) == login_path
    end

    test "appends redirect_to derived from the given conn" do
      conn = conn(:get, "/admin/dashboard")
      assert OneAuth.login_path(conn) == "/login?redirect_to=%2Fadmin%2Fdashboard"
    end

    test "retains query string arguments" do
      conn = conn(:get, "/products?id=123")
      assert OneAuth.login_path(conn) == "/login?redirect_to=%2Fproducts%3Fid%3D123"
    end
  end

  describe "login_redirect_path/1" do
    test "returns the redirect_to query parameter when present" do
      conn = conn(:get, "/login?redirect_to=/admin")
      assert OneAuth.login_redirect_path(conn) == "/admin"
    end

    test "returns the configured login_redirect_path when redirect_to is missing" do
      conn = conn(:get, "/login")
      assert OneAuth.login_redirect_path(conn) == "/dashboard"
    end

    test "returns the configured login_redirect_path for an absolute URL" do
      conn = conn(:get, "/login?redirect_to=https://example.com")
      assert OneAuth.login_redirect_path(conn) == "/dashboard"
    end

    test "returns the configured login_redirect_path for a protocol-relative URL" do
      conn = conn(:get, "/login?redirect_to=//example.com")
      assert OneAuth.login_redirect_path(conn) == "/dashboard"
    end
  end

  describe "logout/1" do
    test "removes the OneAuth session" do
      conn =
        :get
        |> conn("/")
        |> init_test_session(%{
          one_auth_session: "token"
        })

      conn = OneAuth.logout(conn)

      assert get_session(conn, :one_auth_session) == nil
    end
  end

  describe "current_user/1" do
    test "returns the username from the session" do
      conn =
        :get
        |> conn("/")
        |> assign(:one_auth, %{
          "username" => "admin",
          "issued_at" => System.system_time(:millisecond)
        })

      assert OneAuth.current_user(conn) == "admin"
    end

    test "current_user returns nil without a session" do
      conn = conn(:get, "/")
      assert OneAuth.current_user(conn) == nil
    end
  end

  defp put_config(config) when is_list(config) do
    Enum.each(config, fn {key, value} ->
      Application.put_env(:one_auth, key, value)
    end)
  end

  defp clear_config do
    for key <- [:username, :password, :signing_secret, :login_redirect_path] do
      Application.delete_env(:one_auth, key)
    end
  end
end
