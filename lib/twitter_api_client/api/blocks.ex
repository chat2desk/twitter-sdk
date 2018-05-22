defmodule TwitterApiClient.API.Blocks do
  @moduledoc """
  Provides user blocking API interfaces.
  """

  import TwitterApiClient.API.Base

  def block(id) do
    params = TwitterApiClient.Parser.parse_request_params(get_id_option(id))
    request(:post, "1.1/blocks/create.json", params)
    |> TwitterApiClient.Parser.parse_user
  end

  def unblock(id) do
    params = TwitterApiClient.Parser.parse_request_params(get_id_option(id))
    request(:post, "1.1/blocks/destroy.json", params)
    |> TwitterApiClient.Parser.parse_user
  end
end
