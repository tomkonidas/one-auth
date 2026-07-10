defmodule OneAuth.Plug do
  @moduledoc """
  Plug integration helpers for OneAuth.

  This module provides helpers for integrating OneAuth sessions with
  `Plug.Conn`.

  ## Plugs

  Add `OneAuth.Plug.LoadSession` to your pipeline to load the current
  OneAuth session into `conn.assigns`.

  Add `OneAuth.Plug.RequireAuth` to protected routes to require an
  authenticated session.

  ## Session lifecycle

  After a successful login, store the returned token in the Plug session:

      {:ok, token} = OneAuth.login(username, password)

      put_session(conn, :one_auth_session, token)

  To remove the current session:

      conn = OneAuth.logout(conn)

  """

  import Plug.Conn

  @session_key :one_auth_session

  @doc """
  Logs out the current OneAuth session.

  Removes the OneAuth session token from the connection.

  Since OneAuth sessions are stateless signed tokens, this removes the token
  from the client's session storage but does not revoke an already issued
  token.

  ## Examples

      conn
      |> OneAuth.logout()

  """
  @spec logout(Plug.Conn.t()) :: Plug.Conn.t()
  def logout(conn) do
    delete_session(conn, @session_key)
  end
end
