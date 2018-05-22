defmodule TwitterApiClient.API.Help do
  @moduledoc """
  Provides help API interfaces.
  """

  import TwitterApiClient.API.Base

  def rate_limit_status(options \\ []) do
    params = TwitterApiClient.Parser.parse_request_params(options)
    request(:get, "1.1/application/rate_limit_status.json", params)
  end
end
