defmodule OneAuth.Credentials do
  @moduledoc """
  Credential verification for OneAuth.

  This module compares supplied credentials against the configured OneAuth
  account using constant-time comparison to help mitigate timing attacks.
  """

  alias OneAuth.Config

  @doc """
  Returns whether the supplied credentials match the configured OneAuth account.

  Both the username and password are compared using constant-time comparison.
  """
  @spec valid?(String.t(), String.t()) :: boolean()
  def valid?(username, password) do
    configured_username = Config.username()
    configured_password = Config.password()

    username_valid = Plug.Crypto.secure_compare(username, configured_username)
    password_valid = Plug.Crypto.secure_compare(password, configured_password)

    username_valid and password_valid
  end
end
