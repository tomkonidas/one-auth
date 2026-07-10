defmodule OneAuth.Plug.LoadSession do
  @moduledoc """
  Loads the current OneAuth session into the connection.

  If a valid session token exists in the Plug session, it is verified and
  assigned to `conn.assigns.one_auth`.

  Invalid or missing sessions result in `conn.assigns.one_auth` being `nil`.
  """
  @behaviour Plug

  import Plug.Conn

  alias OneAuth.Session

  @session_key :one_auth_session
  @assign_key :one_auth

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    conn
    |> get_session(@session_key)
    |> Session.verify()
    |> case do
      {:ok, payload} ->
        assign(conn, @assign_key, payload)

      :error ->
        assign(conn, @assign_key, nil)
    end
  end
end
