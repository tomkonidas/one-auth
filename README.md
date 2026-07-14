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

## Table of Contents

- [Why OneAuth?](#why-oneauth)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Phoenix Setup](#phoenix-setup)
- [Login Example](#login-example)
- [Protecting Routes](#protecting-routes)
- [Accessing the Current User](#accessing-the-current-user)
  - [In a Layout](#in-a-layout)
- [Logout Example](#logout-example)
- [Public API](#public-api)
- [License](#license)

## Why OneAuth?

Some applications only need to protect access behind a single account —
a personal dashboard, an internal tool, an admin interface. Pulling in a
full user-authentication system for that is overkill, and relying on the
browser's built-in HTTP Basic Auth dialog is a poor experience with no
real logout flow.

OneAuth fills that gap: a normal, session-backed login flow, configured
with a single username and password, and no database required.

Good fits include:

- Personal dashboards
- Internal tools
- Admin interfaces
- Small private applications

OneAuth is **not** intended for applications requiring:

- Multiple users
- User registration
- Password recovery
- OAuth providers
- Roles and permissions

OneAuth is built on [Plug](https://plug.hexdocs.pm/), so it isn't tied to a specific web framework.
It works with any `Plug`-compatible application, including Phoenix and
other frameworks built on top of `Plug`. The examples below use Phoenix
since it's the most common target.

## Features

- **Database-free** — configuration lives in `runtime.exs`, no schema or migrations
- **Session-based** — a real login/logout flow instead of a browser Basic Auth dialog
- **Single account** — built for the "one user" use case, not multi-tenant auth
- **Framework-agnostic** — works with any `Plug`-based application
- **Small surface area** — a handful of plugs and functions, easy to audit

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

Additional options are available for customizing session behavior and
routes. See the [Configuration guide](guides/configuration.md)
for the full list.

## Phoenix Setup

Add `OneAuth.Plug.LoadSession` to your `:browser` pipeline, after
`:fetch_session`, so the current session is loaded on every request.
Add a separate `:require_auth` pipeline for routes that need to be
protected:

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
```

## Login Example

Add routes for rendering the login form and submitting credentials,
scoped to your `:browser` pipeline:

```elixir
scope "/", MyAppWeb do
  pipe_through :browser

  get "/login", SessionController, :new
  post "/login", SessionController, :create
end
```

Handle both actions in a controller. `OneAuth.login/3` verifies the
submitted credentials and starts the session:

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
        |> redirect(to: OneAuth.login_path(conn))
    end
  end
end
```

`OneAuth.login_redirect_path/1` is where a successful login sends the
user. If they were redirected to `/login` from a protected page (see
[Protecting Routes](#protecting-routes)), they're sent back there.
Otherwise it falls back to
[`:login_redirect_path`](guides/configuration.md#login_redirect_path),
which defaults to `"/"`.

Then render the form itself. `OneAuth.login_path/1` gives you the
correct action URL without hardcoding it:

```elixir
defmodule MyAppWeb.SessionHTML do
  use MyAppWeb, :html

  def new(assigns) do
    ~H"""
    <h1>Log in to your account</h1>

    <.simple_form for={%{}} action={OneAuth.login_path(@conn)}>
      <input
        id="username"
        type="text"
        name="username"
        placeholder="Username"
        autocomplete="username"
        aria-label="Username"
        required
      />

      <input
        id="password"
        type="password"
        name="password"
        placeholder="Password"
        autocomplete="current-password"
        aria-label="Password"
        required
      />

      <:actions>
        <.button phx-disable-with="Logging in...">Log in</.button>
      </:actions>
    </.simple_form>
    """
  end
end
```

## Protecting Routes

Pipe any scope you want to protect through `:require_auth` in addition
to `:browser`. Unauthenticated requests are redirected to the
[`:login_path`](guides/configuration.md#login_path) (`"/login"` by
default), with the originally requested path remembered so the user is
sent back there after logging in:

```elixir
scope "/admin", MyAppWeb do
  pipe_through [:browser, :require_auth]

  get "/", AdminController, :index
end
```

Everything under `/admin` in this example now requires a logged-in
session — no per-action checks needed.

## Accessing the Current User

Once a session is loaded, `OneAuth.current_user/1` returns the logged-in
username (or `nil` if there isn't one). This works anywhere you have
access to `conn`, including in controllers and templates:

```elixir
def index(conn, _params) do
  current_user = OneAuth.current_user(conn)
  render(conn, :index, current_user: current_user)
end
```

Then reference the assign in your template:

```heex
<p>Signed in as {@current_user}</p>
```

### In a Layout

A single controller assign only covers one action. For something like a
root layout, where you want a greeting or login/logout link on every
page, assign `current_user` once in your pipeline instead:

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  # ...
  plug OneAuth.Plug.LoadSession
  plug :assign_current_user
end

def assign_current_user(conn, _opts) do
  Plug.Conn.assign(conn, :current_user, OneAuth.current_user(conn))
end
```

`@current_user` is now available in every template rendered through
that pipeline, including your root layout:

```heex
<header>
  <%= if @current_user do %>
    <span>Hi, {@current_user}</span>
    <.link href={~p"/logout"} method="delete">Log out</.link>
  <% else %>
    <.link href={~p"/login"}>Log in</.link>
  <% end %>
</header>
```

## Logout Example

Add a logout route:

```elixir
scope "/", MyAppWeb do
  pipe_through :browser

  delete "/logout", SessionController, :delete
end
```

Handle it in your controller:

```elixir
def delete(conn, _params) do
  conn
  |> OneAuth.logout()
  |> redirect(to: OneAuth.login_path(conn))
end
```

Wire up a logout link wherever you need one:

```heex
<.link href={~p"/logout"} method="delete">Log out</.link>
```

## Public API

OneAuth intentionally exposes a small public API.

```elixir
OneAuth.login(conn, username, password)
OneAuth.login_path(conn)
OneAuth.login_redirect_path(conn)
OneAuth.current_user(conn)
OneAuth.logout(conn)
```

Most applications should only need these functions together with
`OneAuth.Plug.LoadSession` and `OneAuth.Plug.RequireAuth`.

## License

OneAuth is released under the [MIT License](LICENSE).
