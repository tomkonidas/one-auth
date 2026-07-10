defmodule OneAuth.Plug.LoadSessionTest do
  use ExUnit.Case, async: true

  import Plug.Test

  alias OneAuth.Plug.LoadSession
  alias OneAuth.Session

  setup do
    clear_config()
    put_config(username: "admin", password: "password", signing_secret: "test-secret")
    on_exit(&clear_config/0)
    :ok
  end

  describe "init/1" do
    test "returns the given options unchanged" do
      opts = [some_option: :value]

      assert LoadSession.init(opts) == opts
    end
  end

  describe "call/2" do
    test "assigns the session payload when the token is valid" do
      token = Session.create()

      conn =
        :get
        |> conn("/")
        |> init_test_session(%{one_auth_session: token})
        |> LoadSession.call([])

      assert conn.assigns.one_auth["username"] == "admin"
      assert is_integer(conn.assigns.one_auth["issued_at"])
    end

    test "assigns nil when no session exists" do
      conn =
        :get
        |> conn("/")
        |> init_test_session(%{})
        |> LoadSession.call([])

      assert conn.assigns.one_auth == nil
    end

    test "assigns nil when the session token is invalid" do
      conn =
        :get
        |> conn("/")
        |> init_test_session(%{
          one_auth_session: "invalid-token"
        })
        |> LoadSession.call([])

      assert conn.assigns.one_auth == nil
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
