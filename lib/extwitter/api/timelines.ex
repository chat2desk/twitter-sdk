defmodule TwitterApiClient.API.Timelines do
  @moduledoc """
  Provides timeline API interfaces.
  """

  import TwitterApiClient.API.Base

  def mentions_timeline(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/statuses/mentions_timeline.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

  def user_timeline(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/statuses/user_timeline.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

  def home_timeline(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/statuses/home_timeline.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

  def retweets_of_me(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/statuses/retweets_of_me.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

end
