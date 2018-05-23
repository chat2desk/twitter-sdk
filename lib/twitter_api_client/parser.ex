defmodule TwitterApiClient.Parser do
  require Logger
  @moduledoc """
  Provides parser logics for API results.
  """

  @doc """
  Parse tweet record from the API response json.
  """
  def parse_tweet(object) do
    tweet = struct(TwitterApiClient.Model.Tweet, object)
    user  = parse_user(tweet.user)
    %{tweet | user: user}
  end

  @doc """
  Parse direct message record from the API response
  """
  def parse_direct_message(object) do
    direct_message = struct(TwitterApiClient.Model.DirectMessage, object)
    recipient      = parse_user(direct_message.recipient)
    sender         = parse_user(direct_message.sender)
    %{direct_message | recipient: recipient, sender: sender}
  end

  def parse_upload(object) do
    struct(TwitterApiClient.Model.Upload, object)
  end


  @doc """
  Parse user record from the API response json.
  """
  def parse_user(object) do
    struct(TwitterApiClient.Model.User, object)
  end

  @doc """
  Parse trend record from the API response json.
  """
  def parse_trend(object) do
    trend = struct(TwitterApiClient.Model.Trend, object)
    %{trend | query: (trend.query |> URI.decode)}
  end

  @doc """
  Parse list record from the API response json.
  """
  def parse_list(object) do
    list = struct(TwitterApiClient.Model.List, object)
    user = parse_user(list.user)
    %{list | user: user}
  end

  @doc """
  Parse trend record from the API response json.
  """
  def parse_ids(object) do
    Enum.find(object, fn({key, _value}) -> key == :ids end) |> elem(1)
  end

  @doc """
  Parse cursored ids.
  """
  def parse_ids_with_cursor(object) do
    ids = object |> TwitterApiClient.JSON.get(:ids)
    cursor = struct(TwitterApiClient.Model.Cursor, object)
    %{cursor | items: ids}
  end

  @doc """
  Parse cursored users.
  """
  def parse_users_with_cursor(object) do
    users = object |> TwitterApiClient.JSON.get(:users)
                   |> Enum.map(&TwitterApiClient.Parser.parse_user/1)
    cursor = struct(TwitterApiClient.Model.Cursor, object)
    %{cursor | items: users}
  end

  @doc """
  Parse place record from the API response json.
  """
  def parse_place(object) do
    place = struct(TwitterApiClient.Model.Place, object)

    geo = parse_geo(place.bounding_box)
    con = Enum.map(place.contained_within, &parse_contained_within/1)

    %{place | bounding_box: geo, contained_within: con}
  end

  defp parse_contained_within(object) do
    struct(TwitterApiClient.Model.Place, object)
  end

  @doc """
  Parse geo record from the API response json.
  """
  def parse_geo(object) do
    case object do
      nil    -> nil
      object -> struct(TwitterApiClient.Model.Geo, object)
    end
  end

  @doc """
  Parse request parameters for the API.
  """
  def parse_request_params(options) do
    Logger.info "parse_request_params options #{inspect options}"
    Enum.map(options, fn
      {k, v} when is_list(v) -> {to_string(k), elements_to_string(v)}
      {k, v} -> {to_string(k), to_string(v)}
    end)
  end

  defp elements_to_string(elements) do
    Enum.map_join(elements, ",", &to_string/1)
  end

  @doc """
  Parse batch user/lookup request parameters for the API.
  """
  def parse_batch_user_lookup_params(options) do
    Enum.map(options, fn({k,v}) ->
      if is_list(v) do
        {to_string(k), Enum.join(v, ",")}
      else
        {to_string(k), to_string(v)}
      end
    end)
  end

  @doc """
  Parse request_token response
  """
  def parse_request_token(object) do
    struct(TwitterApiClient.Model.RequestToken, object)
  end

  @doc """
  Parse access_token response
  """
  def parse_access_token(object) do
    struct(TwitterApiClient.Model.AccessToken, object)
  end

  @doc """
  Parse user profile banner from the API response json.
  """
  def parse_profile_banner(object) do
    struct(TwitterApiClient.Model.ProfileBanner, object)
  end
end
