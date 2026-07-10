defmodule OneAuth.Plug.RequireAuthTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias OneAuth.Plug.RequireAuth

  describe "init/1" do
    test "returns the given options unchanged" do
      opts = [some_option: :value]

      assert RequireAuth.init(opts) == opts
    end
  end

  describe "call/2" do
    test "allows authenticated requests" do
      conn =
        :get
        |> conn("/")
        |> assign(:one_auth, %{"username" => "admin"})
        |> RequireAuth.call([])

      refute conn.halted
      assert conn.status == nil
    end

    test "redirects unauthenticated requests with the original path" do
      conn =
        :get
        |> conn("/")
        |> RequireAuth.call([])

      assert conn.halted
      assert conn.status == 302

      assert get_resp_header(conn, "location") == ["/login?redirect_to=%2F"]
    end

    test "preserves the original path when authentication interrupts a request" do
      conn =
        :get
        |> conn("/admin/settings")
        |> RequireAuth.call([])

      assert get_resp_header(conn, "location") == ["/login?redirect_to=%2Fadmin%2Fsettings"]
    end

    test "preserves the original query parameters" do
      conn =
        :get
        |> conn("/search?q=elixir")
        |> RequireAuth.call([])

      assert conn.halted
      assert get_resp_header(conn, "location") == ["/login?redirect_to=%2Fsearch%3Fq%3Delixir"]
    end
  end
end
