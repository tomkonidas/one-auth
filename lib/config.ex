defmodule OneAuth.Config do
  @moduledoc false

  @app :one_auth

  @default_max_session_age :timer.hours(24)
  @default_login_path "/login"
  @default_after_login_path "/"

  @doc false
  @spec username() :: String.t()
  def username do
    case Application.fetch_env(@app, :username) do
      {:ok, value} ->
        value

      :error ->
        raise """
        Missing required OneAuth configuration: :username.

        Add the following to your runtime.exs:

            config :one_auth,
              username: System.fetch_env!("ONE_AUTH_USERNAME")

        """
    end
  end

  @doc false
  @spec password() :: String.t()
  def password do
    case Application.fetch_env(@app, :password) do
      {:ok, value} ->
        value

      :error ->
        raise """
        Missing required OneAuth configuration: :password.

        Add the following to your runtime.exs:

            config :one_auth,
              password: System.fetch_env!("ONE_AUTH_PASSWORD")

        """
    end
  end

  @doc false
  @spec max_session_age() :: pos_integer()
  def max_session_age do
    case Application.get_env(@app, :max_session_age, @default_max_session_age) do
      age when is_integer(age) and age > 0 ->
        age

      age ->
        raise """
        Invalid OneAuth configuration for :max_session_age.

        Expected a positive integer, got:

            #{inspect(age)}

        """
    end
  end

  @doc false
  @spec login_path() :: String.t()
  def login_path do
    Application.get_env(@app, :login_path, @default_login_path)
  end

  @doc false
  @spec after_login_path() :: String.t()
  def after_login_path do
    Application.get_env(@app, :after_login_path, @default_after_login_path)
  end
end
