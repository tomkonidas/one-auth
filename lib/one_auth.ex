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

  Authenticate users with `login/3`, access the current user with
  `current_user/1`, and end authenticated sessions with `logout/1`.

  Use `OneAuth.Plug.LoadSession` to load authenticated sessions and
  `OneAuth.Plug.RequireAuth` to protect routes.
  """

  alias OneAuth.Login

  @doc """
  Authenticates the provided credentials and starts a new session.

  When the supplied username and password match the configured OneAuth
  credentials, a signed session token is created and stored in the Plug
  session.

  Returns `{:ok, conn}` on success or `:error` when authentication fails.

  ## Examples

      case OneAuth.login(conn, username, password) do
        {:ok, conn} ->
          redirect(conn, to: "/")

        :error ->
          # Invalid credentials
      end

  """
  @spec login(Plug.Conn.t(), binary(), binary()) :: {:ok, Plug.Conn.t()} | :error
  defdelegate login(conn, username, password), to: Login, as: :authenticate

  @doc """
  Ends the current authenticated session.

  Removes the OneAuth session from the Plug session.

  ## Examples

      conn
      |> OneAuth.logout()
      |> redirect(to: "/login")

  """
  @spec logout(Plug.Conn.t()) :: Plug.Conn.t()
  defdelegate logout(conn), to: OneAuth.Plug

  @doc """
  Returns the username of the currently authenticated user.

  Returns `nil` when no authenticated session exists.

  The connection must have passed through `OneAuth.Plug.LoadSession`.

  ## Examples

      username = OneAuth.current_user(conn)

  """
  @spec current_user(Plug.Conn.t()) :: String.t() | nil
  defdelegate current_user(conn), to: OneAuth.Plug
end
