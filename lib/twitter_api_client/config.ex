defmodule TwitterApiClient.Config do
  def current_scope do
    if Process.get(:_twitter_api_oauth, nil), do: :process, else: :global
  end

  @doc """
  Get OAuth configuration values.
  """
  def get, do: get(current_scope())
  def get(:global) do
    Application.get_env(:twitter_api_client, :oauth, nil)
  end
  def get(:process), do: Process.get(:_twitter_api_oauth, nil)

  @doc """
  Set OAuth configuration values.
  """
  def set(value), do: set(current_scope(), value)
  def set(:global, value), do: Application.put_env(:twitter_api_client, :oauth, value)
  def set(:process, value) do
    Process.put(:_twitter_api_oauth, value)
    :ok
  end

  @doc """
  Get OAuth configuration values in tuple format.
  """
  def get_tuples do
    case TwitterApiClient.Config.get do
      nil -> []
      tuples -> tuples
    end
  end
end
