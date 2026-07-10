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

  @doc """
  Logs out the current OneAuth session.

  Removes the OneAuth session token from the connection.

  This does not invalidate previously issued tokens. Since OneAuth uses
  signed stateless sessions, logout removes the token from the client's
  session storage.

  ## Examples

      conn
      |> OneAuth.logout()
  """
  @spec logout(Plug.Conn.t()) :: Plug.Conn.t()
  defdelegate logout(conn), to: OneAuth.Plug

  @doc """
  Returns the username of the currently authenticated user.

  Returns `nil` when the connection does not contain a valid OneAuth session.

  The connection must have passed through `OneAuth.Plug.LoadSession`.

  ## Examples

      username = OneAuth.current_user(conn)

  """
  @spec current_user(Plug.Conn.t()) :: String.t() | nil
  defdelegate current_user(conn), to: OneAuth.Plug
end
