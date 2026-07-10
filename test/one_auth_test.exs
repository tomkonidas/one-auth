defmodule OneAuthTest do
  use ExUnit.Case, async: false

  import Plug.Conn
  import Plug.Test

  alias OneAuth.Session

  setup do
    clear_config()
    put_config(username: "admin", password: "password", signing_secret: "test-secret")
    on_exit(&clear_config/0)
    :ok
  end

  describe "login/2" do
    test "returns a session token for valid credentials" do
      assert {:ok, token} = OneAuth.login("admin", "password")
      assert {:ok, _payload} = Session.verify(token)
    end

    test "returns error for invalid credentials" do
      assert :error = OneAuth.login("admin", "wrong")
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
    for key <- [:username, :password, :signing_secret] do
      Application.delete_env(:one_auth, key)
    end
  end
end
