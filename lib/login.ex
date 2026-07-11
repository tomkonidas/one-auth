defmodule OneAuth.Login do
  @moduledoc """
  Implements the OneAuth login workflow.

  This module validates the configured credentials and, on success,
  creates and stores a signed session token in the Plug session.

  Applications should typically use `OneAuth.login/3` instead of calling this
  module directly.
  """

  import Plug.Conn

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
end
