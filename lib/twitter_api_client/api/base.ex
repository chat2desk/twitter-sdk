defmodule TwitterApiClient.API.Base do
  require Logger
  @moduledoc """
  Provides basic and common functionalities for Twitter API.
  """

  # https://dev.twitter.com/overview/api/response-codes
  @error_code_rate_limit_exceeded 88

  @doc """
  Send request to the api.twitter.com server.
  """
  def request(method, path, params \\ []) do
    do_request(method, request_url(path), params)
  end

  @doc """
  Send request to the api.twitter.com server.
  """
  def request_json(method, path, params \\ []) do
    do_request_json(method, request_url(path), params)
  end

  @doc """
  Upload media in chunks
  """
  def upload_media(path, content_type, chunk_size \\ 65536) do
    media_id = init_media_upload(path, content_type)
    upload_file_chunks(path, media_id, chunk_size)
    finalize_upload(media_id)
    media_id
  end

  @doc """
  Upload media in chunks
  """
  def upload_media_by_link(path, content_type, file_size) do
    Logger.info "upload_media_by_link path - #{inspect path}"
    Logger.info "upload_media_by_link content_type - #{inspect content_type}"
    Logger.info "upload_media_by_link file_size - #{inspect file_size}"
    media_id = init_media_upload(path, content_type, file_size)
    upload_file_chunks_by_link(path, media_id)
    finalize_upload(media_id)
    Logger.info "after finalized - #{inspect media_id}"
    media_id
  end

  def get_file_size(path, file_size) do
    cond do
      file_size -> file_size
      true ->
        %{size: size} = File.stat! path
        size
    end
  end

  def init_media_upload(path, content_type, file_size \\ nil) do
    size = get_file_size(path, file_size)
    request_params = [command: "INIT", total_bytes: size, media_type: content_type]
    response = do_request(:post, media_upload_url(), request_params)
    response.media_id
  end

  def upload_file_chunks_by_link(path, media_id) do
    Logger.info "upload_file_chunks_by_link PATH - #{inspect path}"
    Logger.info "upload_file_chunks_by_link media_id - #{inspect media_id}"
    %HTTPoison.AsyncResponse{id: id} = HTTPoison.get! path, %{}, stream_to: self
    Logger.info "upload_file_chunks_by_link id - #{inspect id}"
    process_httpoison_chunks(id, media_id, 0)
  end

  def process_httpoison_chunks(id, media_id, segment_index) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id} ->
        # TODO handle status
        process_httpoison_chunks(id, media_id, segment_index)
      %HTTPoison.AsyncHeaders{id: ^id, headers: %{"Connection" => "keep-alive"}} ->
        # TODO handle headers
        process_httpoison_chunks(id, media_id, segment_index)
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk_data} ->
        Logger.info "process_httpoison_chunks id - #{inspect id}"
        Logger.info "process_httpoison_chunks media_id - #{inspect media_id}"
        Logger.info "process_httpoison_chunks segment_index - #{inspect segment_index}"
        Logger.info "process_httpoison_chunks chunk_data - #{inspect chunk_data}"
        request_params = [command: "APPEND", media_id: media_id, media_data: Base.encode64(chunk_data), segment_index: segment_index]
        do_request(:post, media_upload_url(), request_params)
        process_httpoison_chunks(id, media_id, segment_index + 1)
      %HTTPoison.AsyncEnd{id: ^id} ->
        {:ok}
    end
  end

  def upload_file_chunks(path, media_id, chunk_size) do
    stream = File.stream!(path, [], chunk_size)
    initial_segment_index = 0
    Enum.reduce(stream, initial_segment_index, fn(chunk, seg_index) ->
      Logger.info "upload_file_chunks chunk #{inspect chunk}"
      Logger.info "upload_file_chunks encode64 #{inspect Base.encode64(chunk)}"
      request_params = [command: "APPEND", media_id: media_id, media_data: Base.encode64(chunk), segment_index: seg_index]
      do_request(:post, media_upload_url(), request_params)
      Logger.info "upload_file_chunks AFTER SEND}"
      seg_index + 1
    end)
  end

  def finalize_upload(media_id) do
    Logger.info "finalize_upload media_id - #{inspect media_id}"
    request_params = [command: "FINALIZE", media_id: media_id]
    do_request(:post, media_upload_url(), request_params)
  end

  @doc """
  Send request to the upload.twitter.com server.
  """
  def upload_request(method, path, params \\ []) do
    do_request(method, upload_url(path), params)
  end

  defp do_request(method, url, params) do
    oauth = TwitterApiClient.Config.get_tuples |> verify_params
    response = TwitterApiClient.OAuth.request(method, url, params,
      oauth[:consumer_key], oauth[:consumer_secret], oauth[:access_token], oauth[:access_token_secret])
    Logger.info "do_request response - #{inpect response}"
    case response do
      {:error, reason} -> raise(TwitterApiClient.ConnectionError, reason: reason)
      r -> r |> parse_result
    end
  end

  defp do_request_json(method, url, params) do
    oauth = TwitterApiClient.Config.get_tuples |> verify_params
    response = TwitterApiClient.OAuth.request_json(method, url, params,
      oauth[:consumer_key], oauth[:consumer_secret], oauth[:access_token], oauth[:access_token_secret])
    case response do
      {:error, reason} -> raise(TwitterApiClient.ConnectionError, reason: reason)
      {:ok, data} -> {:ok, data}
    end
  end

  def verify_params([]) do
    raise TwitterApiClient.Error,
      message: "OAuth parameters are not set. Use TwitterApiClient.configure function to set parameters in advance."
  end

  def verify_params(params), do: params

  def get_id_option(id) do
    cond do
      is_number(id) ->
        [user_id: id]
      true ->
        [screen_name: id]
    end
  end

  def media_upload_url do
    "https://upload.twitter.com/1.1/media/upload.json"
  end

  def request_url(path) do
    "https://api.twitter.com/#{path}"
  end

  defp upload_url(path) do
    "https://upload.twitter.com/#{path}"
  end

  def parse_result(result) do
    {:ok, {_response, header, body}} = result
    verify_response(TwitterApiClient.JSON.decode!(body), header)
  end

  defp verify_response(body, header) do
    if is_list(body) do
      body
    else
      case Map.get(body, :errors, nil) || Map.get(body, :error, nil) do
        nil ->
          body
        errors when is_list(errors) ->
          parse_error(List.first(errors), header)
        error ->
          raise(TwitterApiClient.Error, message: inspect error)
      end
    end
  end

  defp parse_error(error, header) do
    %{:code => code, :message => message} = error
    case code do
      @error_code_rate_limit_exceeded ->
        reset_at = fetch_rate_limit_reset(header)
        reset_in = Enum.max([reset_at - now(), 0])
        raise TwitterApiClient.RateLimitExceededError,
          code: code, message: message, reset_at: reset_at, reset_in: reset_in
        _  ->
          raise TwitterApiClient.Error, code: code, message: message
    end
  end

  defp fetch_rate_limit_reset(header) do
    {_, reset_at_in_string} = List.keyfind(header, 'x-rate-limit-reset', 0)
    {reset_at, _} = Integer.parse(to_string(reset_at_in_string))
    reset_at
  end

  defp now do
    {megsec, sec, _microsec} = :os.timestamp
    megsec * 1_000_000 + sec
  end
end
