defmodule OneAuth do
  @moduledoc """
  OneAuth provides simple username and password authentication with signed
  session tokens for Plug-based applications.

  It provides the building blocks needed to authenticate users, create and
  verify sessions, and protect authenticated routes.

  ## Getting started

  Configure your credentials and signing secret:

      config :one_auth,
        username: "admin",
        password: "secret",
        signing_secret: "your-secret"

  Authenticate users with `login/2`:

      case OneAuth.login(username, password) do
        {:ok, token} ->
          # Store the token in your session

        :error ->
          # Invalid credentials
      end

  Use `OneAuth.Plug.LoadSession` and `OneAuth.Plug.RequireAuth` to load and
  protect authenticated requests.
  """

  alias OneAuth.Login

  @doc """
  Authenticates credentials and creates a new session token.

  Returns `{:ok, token}` when the provided username and password match the
  configured OneAuth credentials.

  Returns `:error` when authentication fails.

  ## Examples

      case OneAuth.login(username, password) do
        {:ok, token} ->
          put_session(conn, :one_auth_session, token)

        :error ->
          # Handle invalid credentials
      end

  """
  @spec login(String.t(), String.t()) :: {:ok, String.t()} | :error
  defdelegate login(username, password), to: Login, as: :authenticate
end
