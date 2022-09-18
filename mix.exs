defmodule WatchMake.MixProject do
  use Mix.Project

  def project do
    [
      app: :watchmake,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {WatchMake, []}
    ]
  end

  defp deps do
    [
      {:file_system, "~> 0.2.10"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end
end
