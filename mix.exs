defmodule Golem.Mixfile do
  use Mix.Project

  def project do
    [
      app: :golem,
      version: "0.0.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),

      test_coverage: [tool: Coverex.Task, coveralls: true],

      # Docs
      name: "Golem",
      source_url: "https://github.com/ghaabor/golem",
      homepage: "https://github.com/ghaabor/golem",
      docs: [
        main: "Golem",
        logo: "",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      mod: {Golem, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 0.6.0"},
      {:socket, "~> 0.3"},
      {:poison, "~> 2.0"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:coverex, "~> 1.4.10", only: :test}
    ]
  end
end
