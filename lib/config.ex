defmodule OneAuth.Config do
  @moduledoc """
  Provides access to the OneAuth configuration.

  Configuration values are read from the application environment and exposed
  through a small, typed API.

  OneAuth is typically configured in `config/runtime.exs`:

      config :one_auth,
        username: System.fetch_env!("ONE_AUTH_USERNAME"),
        password: System.fetch_env!("ONE_AUTH_PASSWORD"),
        signing_secret: System.fetch_env!("ONE_AUTH_SIGNING_SECRET")

  See the
  [Configuration Guide](configuration.html)
  for all available options, recommended configuration, and environment variable
  examples.

  ## See also

    * `OneAuth`
    * `OneAuth.Plug.LoadSession`
    * `OneAuth.Plug.RequireAuth`

  """

  @app :one_auth

  @default_max_session_age :timer.hours(24)
  @default_login_path "/login"
  @default_login_redirect_path "/"

  @doc """
  Returns the configured username.

  Raises an `ArgumentError` if no username has been configured.
  """
  @spec username() :: String.t()
  def username do
    case Application.fetch_env(@app, :username) do
      {:ok, value} ->
        value

      :error ->
        raise ArgumentError, """
        Missing required OneAuth configuration for :username.

        Add the following to your runtime.exs:

            config :one_auth,
              username: System.fetch_env!("ONE_AUTH_USERNAME")

        """
    end
  end

  @doc """
  Returns the configured password.

  Raises an `ArgumentError` if no password has been configured.
  """
  @spec password() :: String.t()
  def password do
    case Application.fetch_env(@app, :password) do
      {:ok, value} ->
        value

      :error ->
        raise ArgumentError, """
        Missing required OneAuth configuration for :password.

        Add the following to your runtime.exs:

            config :one_auth,
              password: System.fetch_env!("ONE_AUTH_PASSWORD")

        """
    end
  end

  @doc """
  Returns the configured signing secret.

  The signing secret is used to sign and verify OneAuth session tokens.

  Raises an `ArgumentError` if no signing secret has been configured.
  """
  @spec signing_secret() :: String.t()
  def signing_secret do
    case Application.fetch_env(@app, :signing_secret) do
      {:ok, value} ->
        value

      :error ->
        raise ArgumentError, """
        Missing required OneAuth configuration for :signing_secret.

        Add the following to your runtime.exs:

            config :one_auth,
              signing_secret: System.fetch_env!("ONE_AUTH_SIGNING_SECRET")

        """
    end
  end

  @doc """
  Returns the maximum session lifetime in milliseconds.

  The default is 24 hours.
  """
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

  @doc """
  Returns the configured login path.

  Unauthenticated requests are redirected to this path by
  `OneAuth.Plug.RequireAuth`.
  """
  @spec login_path() :: String.t()
  def login_path do
    Application.get_env(@app, :login_path, @default_login_path)
  end

  @doc """
  Returns the default destination after a successful login.

  This value is used by `OneAuth.login_redirect_path/1` when the login request
  does not include a valid `redirect_to` query parameter.
  """
  @spec login_redirect_path() :: String.t()
  def login_redirect_path do
    Application.get_env(@app, :login_redirect_path, @default_login_redirect_path)
  end
end
