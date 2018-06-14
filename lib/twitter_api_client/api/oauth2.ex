defmodule TwitterApiClient.API.Oauth2 do
  @moduledoc """
  Provides users API interfaces.
  """

  import TwitterApiClient.API.Base

  require Logger

  def token do
    oauth = TwitterApiClient.Config.get_tuples |> verify_params
    auth = Base.encode64("#{URI.encode_www_form(oauth[:consumer_key])}:#{URI.encode_www_form(oauth[:consumer_secret])}")
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic #{auth}"}
    ]
    try do
      with {:ok, response} <- HTTPoison.post(request_url("oauth2/token"), "grant_type=client_credentials", headers),
           {:ok, data} <- Poison.decode(response.body) do
        cond do
          data["errors"] -> {:error, List.first(data["errors"])["message"]}
          true ->
            {:ok, data}
        end
      end
    rescue
      e -> Logger.error "TWITTER_API_CLIENT OAUTH2_TOKEN ERROR WITH MESSAGE - #{inspect e}"
    end
  end
end
