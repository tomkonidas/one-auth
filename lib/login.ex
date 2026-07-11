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
  Returns the destination path after a successful login.

  If the login request includes a valid `redirect_to` query parameter, that
  path is returned. Otherwise, the configured `after_login_path` is used.

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
          Config.after_login_path()
        end

      _ ->
        Config.after_login_path()
    end
  end

  defp valid_redirect_path?(<<"/", "/", _::binary>>), do: false
  defp valid_redirect_path?(<<"/", _::binary>>), do: true
  defp valid_redirect_path?(_), do: false
end
