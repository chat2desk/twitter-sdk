defmodule TwitterApiClient.API.Trends do
  @moduledoc """
  Provides trends API interfaces.
  """

  import TwitterApiClient.API.Base

  def trends(id, options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params([id: id] ++ options)
    json = request(:get, "1.1/trends/place.json", params)
    List.first(json) |> TwitterApiClient.JSON.get(:trends) |> Enum.map(&TwitterApiClient.Parser.parse_trend/1)
  end
end
