defmodule OneAuth.Plug.RequireAuth do
  @moduledoc """
  Requires an authenticated OneAuth session.

  This plug expects `OneAuth.Plug.LoadSession` to run before it.

  Unauthenticated requests are redirected to the configured login path with the
  original request path preserved for redirecting after login.
  """
  @behaviour Plug

  import Plug.Conn

  alias OneAuth.Config

  @assign_key :one_auth
  @redirect_param "redirect_to"

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    case conn.assigns[@assign_key] do
      nil ->
        conn
        |> put_resp_header("location", login_path(conn))
        |> send_resp(:found, "")
        |> halt()

      _session ->
        conn
    end
  end

  defp login_path(conn) do
    query = URI.encode_query(%{@redirect_param => return_path(conn)})
    "#{Config.login_path()}?#{query}"
  end

  defp return_path(conn) do
    case conn.query_string do
      "" ->
        conn.request_path

      query_string ->
        "#{conn.request_path}?#{query_string}"
    end
  end
end
