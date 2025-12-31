defmodule TwitterApiClient.Mixfile do
  use Mix.Project

  def project do
    [ app: :twitter_api_client,
      version: "0.1.0",
      elixir: ">= 1.4.0",
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: cli_env_for(:test, [
        "coveralls", "coveralls.detail", "coveralls.post",
        "vcr", "vcr.delete", "vcr.check", "vcr.show"
      ]),
      docs: [main: TwitterApiClient] ]
  end

  defp cli_env_for(env, tasks) do
    Enum.reduce(tasks, [], fn(key, acc) -> Keyword.put(acc, :"#{key}", env) end)
  end

  # Configuration for the OTP application
  def application do
    [ mod: { TwitterApiClient, [] },
      applications: [:inets, :ssl, :crypto, :logger]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  def deps do
    [
      {:oauther, "~> 1.1"},
      {:poison, "~> 3.0"},
      {:exvcr, "~> 0.8", only: :test},
      {:excoveralls, "~> 0.7", only: :test},
      {:meck, "~> 0.8.9", only: [:dev, :test]},
      {:mock, "~> 0.2", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      {:inch_ex, "~> 0.5", only: :docs},
      {:benchfella, "~> 0.3.3", only: :dev},
      {:httpoison, "~> 1.8"}
    ]
  end

  defp description do
    """
    Twitter client library for elixir.
    """
  end

  defp package do
    [ maintainers: ["chat2desk"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/chat2desk/twitter_api_client"} ]
  end
end
