defmodule OneAuth.Session do
  @moduledoc """
  Creates and verifies signed OneAuth session tokens.

  Session tokens are stateless and do not require server-side storage. Each
  token contains session metadata and is signed using the configured signing
  secret to prevent tampering.
  """

  alias OneAuth.Config
  alias Plug.Crypto.MessageVerifier

  @typedoc """
  The decoded session payload.
  """
  @type session() :: map()

  @doc """
  Creates a new signed session token.

  The token contains the session metadata and is signed using the configured
  signing secret.
  """
  @spec create() :: String.t()
  def create do
    payload()
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(Config.signing_secret())
  end

  @doc """
  Verifies a signed session token.

  Returns the decoded session payload when the token is valid and has not expired.
  Returns `:error` if the token is invalid or expired.
  """
  @spec verify(String.t()) :: {:ok, session()} | :error
  def verify(token) when is_binary(token) do
    with {:ok, binary} <- verify_signature(token),
         payload <- :erlang.binary_to_term(binary, [:safe]),
         true <- valid_age?(payload) do
      {:ok, payload}
    else
      _ ->
        :error
    end
  end

  def verify(_token), do: :error

  defp verify_signature(token) do
    MessageVerifier.verify(token, Config.signing_secret())
  end

  defp valid_age?(%{"issued_at" => issued_at}) do
    System.system_time(:millisecond) - issued_at <= Config.max_session_age()
  end

  defp valid_age?(_payload), do: false

  defp payload do
    %{
      "username" => Config.username(),
      "issued_at" => System.system_time(:millisecond)
    }
  end
end
