defmodule OneAuth.ConfigTest do
  use ExUnit.Case, async: false

  alias OneAuth.Config

  setup do
    clear_config()
    on_exit(&clear_config/0)
    :ok
  end

  describe "username/0" do
    test "returns the configured username" do
      put_config(username: "admin")

      assert Config.username() == "admin"
    end

    test "raises when username is not configured" do
      assert_raise RuntimeError,
                   ~r/Missing required OneAuth configuration for :username/,
                   fn ->
                     Config.username()
                   end
    end
  end

  describe "password/0" do
    test "returns the configured password" do
      put_config(password: "superstrongpass33")

      assert Config.password() == "superstrongpass33"
    end

    test "raises when password is not configured" do
      assert_raise RuntimeError,
                   ~r/Missing required OneAuth configuration for :password/,
                   fn ->
                     Config.password()
                   end
    end
  end

  describe "signing_secret/0" do
    test "returns the signing secret" do
      put_config(signing_secret: "secret")

      assert Config.signing_secret() == "secret"
    end

    test "raises when signing secret is not configured" do
      assert_raise RuntimeError,
                   ~r/Missing required OneAuth configuration for :signing_secret/,
                   fn ->
                     Config.signing_secret()
                   end
    end
  end

  describe "max_session_age/0" do
    test "returns the configured session age" do
      put_config(max_session_age: :timer.hours(12))

      assert Config.max_session_age() == :timer.hours(12)
    end

    test "returns the default session age when not configured" do
      assert Config.max_session_age() == :timer.hours(24)
    end

    test "raises when age is negative number" do
      put_config(max_session_age: -1)

      assert_raise RuntimeError, ~r/Invalid OneAuth configuration for :max_session_age/, fn ->
        Config.max_session_age()
      end
    end

    test "raises when age is zero" do
      put_config(max_session_age: 0)

      assert_raise RuntimeError, ~r/Invalid OneAuth configuration for :max_session_age/, fn ->
        Config.max_session_age()
      end
    end

    test "raises when age is not an integer" do
      put_config(max_session_age: :five)

      assert_raise RuntimeError, ~r/Invalid OneAuth configuration for :max_session_age/, fn ->
        Config.max_session_age()
      end
    end
  end

  describe "login_path/0" do
    test "returns the configured login path" do
      put_config(login_path: "/admin/login")

      assert Config.login_path() == "/admin/login"
    end

    test "returns the default login path when not configured" do
      assert Config.login_path() == "/login"
    end
  end

  describe "after_login_path/0" do
    test "returns the configured after login path" do
      put_config(after_login_path: "/dashboard")

      assert Config.after_login_path() == "/dashboard"
    end

    test "returns the default after login path when not configured" do
      assert Config.after_login_path() == "/"
    end
  end

  defp put_config(config) when is_list(config) do
    Enum.each(config, fn {key, value} ->
      Application.put_env(:one_auth, key, value)
    end)
  end

  defp clear_config do
    for key <- [
          :username,
          :password,
          :max_session_age,
          :login_path,
          :after_login_path,
          :signing_secret
        ] do
      Application.delete_env(:one_auth, key)
    end
  end
end
