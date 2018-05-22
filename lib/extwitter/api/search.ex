defmodule TwitterApiClient.API.Search do
  @moduledoc """
  Provides search API interfaces.
  """

  import TwitterApiClient.API.Base
  alias TwitterApiClient.Model.SearchResponse

  def search(query, options \\ []) do
    case Keyword.fetch(options, :search_metadata) do
      {:ok, true} ->
        params = TwitterApiClient.Parser.parse_request_params([q: query] ++ Keyword.drop(options, [:search_metadata]))
        search_with_metadata(params)
      _ ->
        do_search(query, options)
    end
  end

  def search_next_page(metadata) do
    if metadata[:next_results] != nil do
      params = parse_next_results(metadata[:next_results])
      search_with_metadata(params)
    else
      nil
    end
  end

  defp search_with_metadata(params) do
    json = request(:get, "1.1/search/tweets.json", params)
    statuses = TwitterApiClient.JSON.get(json, :statuses) |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
    metadata = TwitterApiClient.JSON.get(json, :search_metadata)
    %SearchResponse{statuses: statuses, metadata: metadata}
  end

  defp do_search(query, options) do
    params = TwitterApiClient.Parser.parse_request_params([q: query] ++ options)
    json = request(:get, "1.1/search/tweets.json", params)
    TwitterApiClient.JSON.get(json, :statuses) |> Enum.map(&TwitterApiClient.Parser.parse_tweet/1)
  end

  # ref: https://dev.twitter.com/rest/reference/get/search/tweets
  # example: "?max_id=249279667666817023&q=%23freebandnames&count=4&include_entities=1&result_type=mixed"
  defp parse_next_results(next_results) do
    results = String.replace_leading(next_results, "?", "")
    Map.to_list(URI.decode_query(results))
  end
end
