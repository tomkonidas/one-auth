defmodule OneAuth.Login do
  @moduledoc """
  Implements the OneAuth login workflow.

  This module validates the configured credentials, creates and stores a signed
  session token, and determines where users should be redirected after a
  successful login.
  """

  import Plug.Conn

  alias OneAuth.Config
  alias OneAuth.Credentials
  alias OneAuth.Session

  @session_key :one_auth_session

  @doc """
  Authenticates the provided credentials and starts a new session.

  When the supplied username and password match the configured OneAuth
  credentials, a signed session token is created and stored in the Plug
  session.

  Returns `{:ok, conn}` on success or `:error` when authentication fails.

  ## Examples

      case Login.authenticate(conn, username, password) do
        {:ok, conn} ->
          # Redirect the authenticated user

        :error ->
          # Invalid credentials
      end

  """
  @spec authenticate(Plug.Conn.t(), String.t(), String.t()) :: {:ok, Plug.Conn.t()} | :error
  def authenticate(conn, username, password) do
    if Credentials.valid?(username, password) do
      {:ok, put_session(conn, @session_key, Session.create())}
    else
      :error
    end
  end

  @doc """
  Returns the configured login path, optionally with a `redirect_to` query
  parameter appended so `redirect_path/1` can send the user back there after
  a successful login.

  Pass the current `Plug.Conn.t()` and the right thing happens either way:

    * If the conn already has a `redirect_to` query parameter (e.g. it's the
      request to render or submit the login page itself, after
      `OneAuth.Plug.RequireAuth` redirected here), that value is reused as-is.
    * Otherwise, the conn's own request path (and query string, if any) is
      used as the `redirect_to` — handy for a "Log in" link anywhere in your
      app that should return the user to the page they were on.

  This mirrors what `OneAuth.Plug.RequireAuth` builds internally when it
  redirects an unauthenticated request to the login page, so it's the same
  URL format `redirect_path/1` expects to read back.

  ## Examples

      Login.path(conn)
      #=> "/login"

      Login.path(conn)
      #=> "/login?redirect_to=%2Fadmin"

  """
  @spec path(Plug.Conn.t()) :: String.t()
  def path(%Plug.Conn{} = conn) do
    redirect_to = existing_redirect_to(conn) || return_path(conn)
    default_login_path = Config.login_path()

    if redirect_to == default_login_path do
      default_login_path
    else
      query = URI.encode_query(%{"redirect_to" => redirect_to})
      "#{Config.login_path()}?#{query}"
    end
  end

  defp existing_redirect_to(conn) do
    conn
    |> fetch_query_params()
    |> Map.fetch!(:query_params)
    |> Map.get("redirect_to")
  end

  defp return_path(conn) do
    case conn.query_string do
      "" ->
        conn.request_path

      query_string ->
        "#{conn.request_path}?#{query_string}"
    end
  end

  @doc """
  Returns the destination path after a successful login.

  If the login request includes a valid `redirect_to` query parameter, that
  path is returned. Otherwise, the configured `login_redirect_path` is used.

  Only relative paths beginning with `/` are accepted. Any other value is
  ignored to prevent open redirect vulnerabilities.

  ## Examples

      Login.redirect_path(conn)
      #=> "/admin"

      Login.redirect_path(conn)
      #=> "/"

  """
  @spec redirect_path(Plug.Conn.t()) :: String.t()
  def redirect_path(conn) do
    conn = fetch_query_params(conn)

    case conn.query_params["redirect_to"] do
      path when is_binary(path) ->
        if valid_redirect_path?(path) do
          path
        else
          Config.login_redirect_path()
        end

      _ ->
        Config.login_redirect_path()
    end
  end

  defp valid_redirect_path?(<<"/", "/", _::binary>>), do: false
  defp valid_redirect_path?(<<"/", _::binary>>), do: true
  defp valid_redirect_path?(_), do: false
end
