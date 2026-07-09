# Configuration

OneAuth is configured using your application's runtime configuration.

## Required options

### `:username`

The username accepted during authentication.

```elixir
config :one_auth,
  username: "admin"
```


### `:password`

The password accepted during authentication.

```elixir
config :one_auth,
  password: "secret"
```

## Optional options


### `:max_session_age`

The maximum lifetime of an authenticated session.

Default:

```elixir
:timer.hours(24)
```

Example:

```elixir
config :one_auth,
  max_session_age: :timer.hours(12)
```


### `:login_path`

The path where unauthenticated users should be sent.

Default:

```elixir
"/login"
```

Example:

```elixir
config :one_auth,
  login_path: "/admin/login"
```

### `:after_login_path`

The fallback path to redirect users to after successful authentication when no
return path is available.

Default:

```elixir
"/"
```

Example:

```elixir
config :one_auth,
  after_login_path: "/dashboard"
```
