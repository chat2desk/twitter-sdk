defmodule TwitterApiClientTest do
  use ExUnit.Case
  doctest TwitterApiClient

  test "greets the world" do
    assert TwitterApiClient.hello() == :world
  end
end
