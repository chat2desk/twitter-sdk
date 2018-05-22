defmodule TwitterApiClient.API.Favorites do
  @moduledoc """
  Provides favorites API interfaces.
  """

  import TwitterApiClient.API.Base

  def favorites(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/favorites/list.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

  def create_favorite(id, options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params([id: id] ++ options)
    request(:post, "1.1/favorites/create.json", params)
    |> TwitterApiClient.Parser.parse_tweet
  end

  def destroy_favorite(id, options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params([id: id] ++ options)
    request(:post, "1.1/favorites/destroy.json", params)
    |> TwitterApiClient.Parser.parse_tweet
  end
end
