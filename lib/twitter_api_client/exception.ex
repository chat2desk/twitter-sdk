defmodule TwitterApiClient.Error do
  defexception [:code, :message]
end

defmodule TwitterApiClient.RateLimitExceededError do
  defexception [:code, :message, :reset_in, :reset_at]
end

defmodule TwitterApiClient.ConnectionError do
  defexception [:reason, message: "connection error"]
end
