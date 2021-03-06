defmodule BevagerScraper.Mixfile do
  use Mix.Project

  def project do
    [app: :bevager_scraper,
     version: "0.5.1",
     elixir: "~> 1.3",
     escript: [main_module: Main],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:floki, "~> 0.11.0"},
      {:poison, "~> 2.0"},
      {:timex, "~> 3.0"},
      {:tzdata, "~> 0.1.8"}
    ]
  end
end
