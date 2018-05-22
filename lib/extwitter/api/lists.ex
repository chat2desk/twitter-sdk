defmodule TwitterApiClient.API.Lists do
  @moduledoc """
  Provides lists API interfaces.
  """

  import TwitterApiClient.API.Base

  def lists(id_or_screen_name, options \\ []) do
    id_option = get_id_option(id_or_screen_name)
    params = TwitterApiClient.Parser.parse_request_params(id_option ++ options)
    request(:get, "1.1/lists/list.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_list/1)
  end

  def list_timeline(list, owner, options \\ []) do
    list_timeline([slug: list, owner_screen_name: owner] ++ options)
  end

  def list_timeline(options) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/lists/statuses.json", params)
    |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

  def list_memberships(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/lists/memberships.json", params)
    |> TwitterApiClient.JSON.get(:lists)
    |> Enum.map(&TwitterApiClient.Parser.parse_list/1)
  end

  def list_subscribers(list, owner, options \\ []) do
    list_subscribers([slug: list, owner_screen_name: owner] ++ options)
  end

  def list_subscribers(options) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/lists/subscribers.json", params)
    |> TwitterApiClient.JSON.get(:users)
    |> Enum.map(&TwitterApiClient.Parser.parse_user/1)
  end

  def list_members(list, owner, options \\ []) do
    list_members([slug: list, owner_screen_name: owner] ++ options)
  end

  def list_members(options) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/lists/members.json", params)
    |> TwitterApiClient.JSON.get(:users)
    |> Enum.map(&TwitterApiClient.Parser.parse_user/1)
  end
end
