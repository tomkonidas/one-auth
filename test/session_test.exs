defmodule OneAuth.SessionTest do
  use ExUnit.Case, async: false

  alias OneAuth.Config
  alias OneAuth.Session
  alias Plug.Crypto.MessageVerifier

  setup do
    clear_config()
    put_config(username: "admin", signing_secret: "test-secret")
    on_exit(&clear_config/0)
    :ok
  end

  describe "create/0" do
    test "creates a signed session token" do
      assert is_binary(Session.create())
    end
  end

  describe "verify/1" do
    test "returns the session payload for a valid token" do
      token = Session.create()

      assert {:ok, session} = Session.verify(token)

      assert session["username"] == "admin"
      assert is_integer(session["issued_at"])
    end

    test "returns :error for an invalid token" do
      assert :error = Session.verify("invalid")
    end

    test "returns :error for an expired token" do
      put_config(max_session_age: 1)

      token = Session.create()
      Process.sleep(5)
      assert :error = Session.verify(token)
    end

    test "returns :error with valid token and no issued_at" do
      payload =
        %{"username" => "admin"}
        |> :erlang.term_to_binary()
        |> MessageVerifier.sign(Config.signing_secret())

      assert :error = Session.verify(payload)
    end
  end

  defp put_config(config) when is_list(config) do
    Enum.each(config, fn {key, value} ->
      Application.put_env(:one_auth, key, value)
    end)
  end

  defp clear_config do
    for key <- [:username, :signing_secret, :max_session_age] do
      Application.delete_env(:one_auth, key)
    end
  end
end
