defmodule TwitterApiClient.OAuth do
  require Logger
  @moduledoc """
  Provide a wrapper for :oauth request methods.
  """

  @doc """
  Send request with get method.
  """
  def request(:get, url, params, consumer_key, consumer_secret, access_token, access_token_secret) do
    oauth_get(url, params, consumer_key, consumer_secret, access_token, access_token_secret, [])
  end

  @doc """
  Send request with post method.
  """
  def request(:post, url, params, consumer_key, consumer_secret, access_token, access_token_secret) do
    oauth_post(url, params, consumer_key, consumer_secret, access_token, access_token_secret, [])
  end

  @doc """
  Send request with post method.
  """
  def request_json(:post, url, params, consumer_key, consumer_secret, access_token, access_token_secret) do
    oauth_post_json(url, params, consumer_key, consumer_secret, access_token, access_token_secret, [])
  end

  @doc """
  Send async request with get method.
  """
  def request_async(:get, url, params, consumer_key, consumer_secret, access_token, access_token_secret) do
    oauth_get(url, params, consumer_key, consumer_secret, access_token, access_token_secret, stream_option())
  end

  @doc """
  Send async request with post method.
  """
  def request_async(:post, url, params, consumer_key, consumer_secret, access_token, access_token_secret) do
    oauth_post(url, params, consumer_key, consumer_secret, access_token, access_token_secret, stream_option())
  end

  def oauth_get(url, params, consumer_key, consumer_secret, access_token, access_token_secret, options) do
    signed_params = get_signed_params(
      "get", url, params, consumer_key, consumer_secret, access_token, access_token_secret)
    encoded_params = URI.encode_query(signed_params)
    request = {to_charlist(url <> "?" <> encoded_params), []}
    send_httpc_request(:get, request, options)
  end

  def oauth_post_json(url, params, consumer_key, consumer_secret, access_token, access_token_secret, options) do
    signed_params = get_signed_params(
      "post", url, [], consumer_key, consumer_secret, access_token, access_token_secret)
    {header, req_params} = OAuther.header(signed_params)
    headers = [{"Content-Type", "application/json"}, header]
    try do
      with {:ok, request} <- Poison.encode(params),
           {:ok, response} <- HTTPoison.post(url, request, headers),
           {:ok, data} <- Poison.decode(response.body) do
        cond do
          data["errors"] -> {:error, List.first(data["errors"])["message"]}
          true ->
            {:ok, data}
        end
      end
    rescue
       e -> Logger.error "TWITTER_API_CLIENT REQUEST_JSON ERROR WITH MESSAGE - #{inspect e}"
    end
  end

  def oauth_post(url, params, consumer_key, consumer_secret, access_token, access_token_secret, options) do
    signed_params = get_signed_params(
      "post", url, params, consumer_key, consumer_secret, access_token, access_token_secret)
    encoded_params = URI.encode_query(signed_params)
    request = {to_charlist(url), [], 'application/x-www-form-urlencoded', encoded_params}
    send_httpc_request(:post, request, options)
  end

  def send_httpc_request(method, request, options) do
    :httpc.request(method, request, [{:autoredirect, false}] ++ proxy_option(), options)
  end

  defp get_signed_params(method, url, params, consumer_key, consumer_secret, access_token, access_token_secret) do
    credentials = OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: access_token,
        token_secret: access_token_secret
    )
    OAuther.sign(method, url, params, credentials)
  end

  defp stream_option do
    [{:sync, false}, {:stream, :self}]
  end

  defp proxy_option do
    TwitterApiClient.Proxy.options
  end
end
