# OneAuth

[![CI](https://github.com/tomkonidas/one-auth/actions/workflows/ci.yml/badge.svg)](https://github.com/tomkonidas/one-auth/actions/workflows/ci.yml)

A simple, database-free alternative to HTTP Basic Auth with session-based
authentication for Plug-compatible applications.

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

## API

OneAuth.login(conn, username, password)
# => {:ok, conn} | :error

OneAuth.logout(conn)
# => conn

OneAuth.current_user(conn)
# => username | nil
