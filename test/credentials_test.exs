defmodule OneAuth.CredentialsTest do
  use ExUnit.Case, async: false

  alias OneAuth.Credentials

  setup do
    clear_config()
    put_config(username: "admin", password: "secret")
    on_exit(&clear_config/0)
    :ok
  end

  describe "valid?/2" do
    test "returns true when the credentials are valid" do
      assert Credentials.valid?("admin", "secret")
    end

    test "returns false when the username is invalid" do
      refute Credentials.valid?("tom", "secret")
    end

    test "returns false when the password is invalid" do
      refute Credentials.valid?("admin", "password")
    end

    test "returns false when both credentials are invalid" do
      refute Credentials.valid?("tom", "password")
    end

    test "raises when credentials are not configured" do
      clear_config()

      assert_raise ArgumentError, ~r/Missing required OneAuth configuration/, fn ->
        Credentials.valid?("admin", "secret")
      end
    end
  end

  defp put_config(config) when is_list(config) do
    Enum.each(config, fn {key, value} ->
      Application.put_env(:one_auth, key, value)
    end)
  end

  defp clear_config do
    for key <- [:username, :password] do
      Application.delete_env(:one_auth, key)
    end
  end
end
