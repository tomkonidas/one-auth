defmodule OneAuth do
  @moduledoc """
  OneAuth provides simple username and password authentication for Plug-based
  applications.

  ## Getting started

  Configure your credentials and signing secret:

      config :one_auth,
        username: "admin",
        password: "secret",
        signing_secret: "your-secret"

  Authenticate users with `login/3`, access the current user with
  `current_user/1`, and end authenticated sessions with `logout/1`.

  Use `login_path/1` to link to the login page — pass it the current conn and
  it preserves where to redirect back to afterward, whether that's a page a
  user was redirected away from or the login page's own form re-submitting
  after a failed attempt. After a successful login, `login_redirect_path/1`
  returns the destination to redirect the user to.

  Use `OneAuth.Plug.LoadSession` to load authenticated sessions and
  `OneAuth.Plug.RequireAuth` to protect routes.
  """

  import Plug.Conn

  alias OneAuth.Login

  @session_key :one_auth_session
  @assign_key :one_auth

  @doc """
  Authenticates the provided credentials and starts a new session.

  When the supplied username and password match the configured OneAuth
  credentials, a signed session token is created and stored in the Plug
  session.

  Returns `{:ok, conn}` on success or `:error` when authentication fails.

  ## Examples

      case OneAuth.login(conn, username, password) do
        {:ok, conn} ->
          redirect(conn, to: OneAuth.login_redirect_path(conn))

        :error ->
          # Invalid credentials
      end

  """
  @spec login(Plug.Conn.t(), binary(), binary()) :: {:ok, Plug.Conn.t()} | :error
  defdelegate login(conn, username, password), to: Login, as: :authenticate

  @doc """
  Returns the configured login path, optionally with a `redirect_to` query
  parameter appended so `login_redirect_path/1` can send the user back there
  after a successful login.

  Pass the current `Plug.Conn.t()` and the right thing happens either way:

    * If the conn already has a `redirect_to` query parameter (e.g. it's the
      request to render or submit the login page itself, after
      `OneAuth.Plug.RequireAuth` redirected here), that value is reused as-is.
    * Otherwise, the conn's own request path is used as the `redirect_to` —
      handy for a "Log in" link anywhere in your app that should return the
      user to the page they were on.

  ## Examples

      OneAuth.login_path(conn)
      #=> "/login"

      OneAuth.login_path(conn)
      #=> "/login?redirect_to=%2Fapps"

  """
  @spec login_path(Plug.Conn.t()) :: String.t()
  defdelegate login_path(conn), to: Login, as: :path

  @doc """
  Returns the destination path after a successful login.

  If the login request includes a valid `redirect_to` query parameter, that
  path is returned. Otherwise, the configured `login_redirect_path` is returned.

  Only relative paths beginning with `/` are accepted.

  ## Examples

      redirect(conn, to: OneAuth.login_redirect_path(conn))

  """
  @spec login_redirect_path(Plug.Conn.t()) :: String.t()
  defdelegate login_redirect_path(conn), to: Login, as: :redirect_path

  @doc """
  Ends the current authenticated session.

  Removes the OneAuth session from the Plug session.

  Since OneAuth sessions are stateless signed tokens, this removes the token
  from the client's session storage but does not revoke an already issued
  token.

  ## Examples

      conn
      |> OneAuth.logout()
      |> redirect(to: OneAuth.login_path(conn))

  """
  @spec logout(Plug.Conn.t()) :: Plug.Conn.t()
  def logout(conn) do
    delete_session(conn, @session_key)
  end

  @doc """
  Returns the username of the currently authenticated user.

  Returns `nil` when no authenticated session exists.

  The connection must have passed through `OneAuth.Plug.LoadSession`.

  ## Examples

      username = OneAuth.current_user(conn)

  """
  @spec current_user(Plug.Conn.t()) :: String.t() | nil
  def current_user(conn) do
    case conn.assigns[@assign_key] do
      %{"username" => username} ->
        username

      _ ->
        nil
    end
  end
end
