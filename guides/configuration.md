# Configuration

OneAuth is configured using your application's runtime configuration.

## Required options

### `:username`

The username accepted during authentication.

```elixir
config :one_auth,
  username: System.fetch_env!("ONE_AUTH_USERNAME")
```


### `:password`

The password accepted during authentication.

```elixir
config :one_auth,
  password: System.fetch_env!("ONE_AUTH_PASSWORD")
```

### `:signing_secret`

A signing secret to generate and verify session tokens.

The secret should be a cryptographically random value and should be kept
private.

```elixir
config :one_auth,
  signing_secret: System.fetch_env!("ONE_AUTH_SIGNING_SECRET")
```

You can generate a safe and secure signing secret using:

```bash
elixir -e "IO.puts(:crypto.strong_rand_bytes(64) |> Base.url_encode64())"
```

## Optional options


### `:max_session_age`

The maximum lifetime of an authenticated session.

The value is expressed in milliseconds. The `:timer` module provides convenient
helpers such as `:timer.minutes/1` and `:timer.hours/1`.

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

### `:login_redirect_path`

The fallback path to redirect users to after successful authentication when no
return path is available.

Default:

```elixir
"/"
```

Example:

```elixir
config :one_auth,
  login_redirect_path: "/dashboard"
```
