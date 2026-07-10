defmodule OneAuth.Login do
  @moduledoc """
  Provides the authentication workflow for OneAuth.

  This module coordinates credential verification and session creation.
  Applications should typically use `OneAuth.login/2` instead of calling this
  module directly.

  A successful login returns a signed session token that can be stored using the
  application's session mechanism.
  """

  alias OneAuth.Credentials
  alias OneAuth.Session

  @doc """
  Authenticates a user and creates a new session token.

  The provided credentials are compared against the configured OneAuth
  credentials. When valid, a signed session token is returned.

  ## Returns

    * `{:ok, token}` - Credentials are valid and a new session was created.
    * `:error` - The provided credentials are invalid.

  """
  @spec authenticate(String.t(), String.t()) :: {:ok, String.t()} | :error
  def authenticate(username, password) do
    if Credentials.valid?(username, password) do
      {:ok, Session.create()}
    else
      :error
    end
  end
end
