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

  def oauth_post_n(url, params, consumer_key, consumer_secret, access_token, access_token_secret, options) do
    credentials = OAuther.credentials(
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      token: access_token,
      token_secret: access_token_secret
    )
    Logger.info "START PARAMS - #{inspect params}"
    Logger.info "START options - #{inspect options}"
    params = OAuther.sign("post", url, params, credentials)
    Logger.info "START params - #{inspect params}"
    {header, req_params} = OAuther.header(params)
    Logger.info "START header - #{inspect header}"
    Logger.info "START req_params - #{inspect req_params}"
    HTTPoison.post(url, Poison.encode!(params), [{"Content-Type", "application/json"}, header])
#    signed_params = get_signed_params(
#      "post", url, Poison.encode!(params), consumer_key, consumer_secret, access_token, access_token_secret)
#    Logger.info "SIGNED PARAMS - #{inspect signed_params}"
#    Logger.info "oauth_post url - #{inspect url}"
##    Logger.info "oauth_post signed_params - #{inspect Enum.into(signed_params, %{})}"
#    Logger.info "oauth_post params - #{inspect params}"
#    headers = ["Content-Type": "application/json", "Authorization": URI.encode_query(signed_params)]
#    Logger.info "oauth_post headers - #{inspect headers}"
#    Logger.info "oauth_post encode params - #{inspect Poison.encode!(params)}"
#    HTTPoison.post(url, Poison.encode!(params), headers)
#    request = {to_charlist(url), [], "application/json", Poison.encode!(Map.merge(Enum.into(signed_params, %{}), params))}
#    request = {to_charlist(url), [{"Authorization", URI.encode_query(signed_params)}], 'application/json', Poison.encode!(params)}
#    Logger.info "oauth_post request - #{inspect request}"
#    send_httpc_request(:post, request, options)
  end

  def oauth_post(url, params, consumer_key, consumer_secret, access_token, access_token_secret, options) do
    Logger.info "POST CHECK params #{inspect params}"
    Logger.info "POST CHECK url #{inspect url}"
    signed_params = get_signed_params(
      "post", url, params, consumer_key, consumer_secret, access_token, access_token_secret)
    Logger.info "POST CHECK signed_params #{inspect signed_params}"
    encoded_params = URI.encode_query(signed_params)
    Logger.info "POST CHECK encoded_params #{inspect encoded_params}"
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
