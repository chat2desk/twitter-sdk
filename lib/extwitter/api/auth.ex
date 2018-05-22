defmodule TwitterApiClient.API.Auth do
  @moduledoc """
  Provides Authorization and Authentication API interfaces.
  """
  import TwitterApiClient.API.Base

  def request_token(redirect_url \\ nil) do
    oauth = TwitterApiClient.Config.get_tuples |> verify_params
    params = if redirect_url, do: [{"oauth_callback", redirect_url}], else: []
    {:ok, {{_, 200, _}, _headers, body}} =
      TwitterApiClient.OAuth.request(:post, request_url("oauth/request_token"),
        params, oauth[:consumer_key], oauth[:consumer_secret], "", "")

    Elixir.URI.decode_query(to_string body)
    |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> TwitterApiClient.Parser.parse_request_token
  end

  def authorize_url(oauth_token, options \\ %{}) do
    args = Map.merge(%{oauth_token: oauth_token}, options)

    {:ok, request_url("oauth/authorize?" <> Elixir.URI.encode_query(args)) |> to_string}
  end

  def authenticate_url(oauth_token, options \\ %{}) do
    args = Map.merge(%{oauth_token: oauth_token}, options)

    {:ok, request_url("oauth/authenticate?" <> Elixir.URI.encode_query(args)) |> to_string}
  end

  def access_token(verifier, request_token) do
    oauth = TwitterApiClient.Config.get_tuples |> verify_params
    response = TwitterApiClient.OAuth.request(:post, request_url("oauth/access_token"),
      [oauth_verifier: verifier], oauth[:consumer_key], oauth[:consumer_secret], request_token, nil)
    case response do
      {:ok, {{_, 200, _}, _headers, body}} ->
        access_token = Elixir.URI.decode_query(to_string body)
        |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
        |> TwitterApiClient.Parser.parse_access_token
        {:ok, access_token}
      {:ok, {{_, code, _}, _, _}} ->
        {:error, code}
    end
  end
end
