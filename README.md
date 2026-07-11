# OneAuth

[![CI](https://github.com/tomkonidas/one-auth/actions/workflows/ci.yml/badge.svg)](https://github.com/tomkonidas/one-auth/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/one_auth.svg)](https://hex.pm/packages/one_auth)
[![Documentation](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/one_auth)

A simple, database-free alternative to HTTP Basic Auth with session-based
authentication for Plug-compatible applications.

See the [Releases page](https://github.com/tomkonidas/one-auth/releases) for
a changelog of notable changes between versions.


> [!WARNING]
> OneAuth is under active development. APIs may change before the first stable release.

## What is OneAuth?

OneAuth provides lightweight authentication for applications that only need a
single account and where a full user authentication system would be unnecessary.

Instead of relying on browser-managed HTTP Basic Auth dialogs, OneAuth provides
a normal login flow with session-backed authentication.

## When to use OneAuth?

OneAuth is designed for applications that need to protect access with a
single account, without introducing a database-backed authentication system.

Good fits include:

- Personal dashboards
- Internal tools
- Admin interfaces
- Small private applications

OneAuth is not intended for applications requiring:

- Multiple users
- User registration
- Password recovery
- OAuth providers
- Roles and permissions

## Framework Compatibility

OneAuth is built on `Plug` and is not tied to a specific web framework.

It can be used with any `Plug`-compatible application, including Phoenix and
other frameworks built on top of `Plug`.

## Installation

Add `:one_auth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:one_auth, "~> 0.1"}
  ]
end
```

## Configuration

OneAuth is configured through your application's `runtime.exs`.

The minimum required configuration is:

```elixir
config :one_auth,
  username: System.fetch_env!("ONE_AUTH_USERNAME"),
  password: System.fetch_env!("ONE_AUTH_PASSWORD"),
  signing_secret: System.fetch_env!("ONE_AUTH_SIGNING_SECRET")
```

Additional options are available for customizing session behavior and routes.
See the [Configuration guide](guides/configuration.md) for the full list.

## Usage

These examples use Phoenix, since it's the most common target for
Plug-compatible applications. See [Framework Compatibility](#framework-compatibility)
if you're using OneAuth outside of Phoenix.

Add `OneAuth.Plug.LoadSession` to your `:browser` pipeline, after
`:fetch_session`, so the current session is loaded on every request. Add
`OneAuth.Plug.RequireAuth` to a separate pipeline for routes that require
authentication:

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  # ...
  plug OneAuth.Plug.LoadSession
end

pipeline :require_auth do
  plug OneAuth.Plug.RequireAuth
end

scope "/", MyAppWeb do
  pipe_through :browser

  get "/login", SessionController, :new
  post "/login", SessionController, :create
  delete "/logout", SessionController, :delete
end

scope "/admin", MyAppWeb do
  pipe_through [:browser, :require_auth]

  get "/", AdminController, :index
end
```

Handle the login and logout actions in a controller:

```elixir
defmodule MyAppWeb.SessionController do
  use MyAppWeb, :controller

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"username" => username, "password" => password}) do
    case OneAuth.login(conn, username, password) do
      {:ok, conn} ->
        redirect(conn, to: OneAuth.login_redirect_path(conn))

      :error ->
        conn
        |> put_flash(:error, "Invalid username or password")
        |> redirect(to: "/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> OneAuth.logout()
    |> redirect(to: "/login")
  end
end
```

Read the current user in any controller or template with `OneAuth.current_user/1`:

```elixir
OneAuth.current_user(conn)
# => "admin" | nil
```

## API

```elixir
OneAuth.login(conn, username, password)
# => {:ok, conn} | :error

OneAuth.logout(conn)
# => conn

OneAuth.current_user(conn)
# => username | nil

OneAuth.login_redirect_path(conn)
# => path
```

## License

OneAuth is released under the [MIT License](LICENSE).

---

Maintainers: see [RELEASING.md](RELEASING.md) for the release process.
