defmodule Golem.Mixfile do
  use Mix.Project

  def project do
    [
      app: :golem,
      version: "0.0.1-alpha3",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),

      test_coverage: [tool: Coverex.Task, coveralls: true],

      # Docs
      name: "Golem",
      source_url: "https://github.com/ghaabor/golem",
      homepage: "https://github.com/ghaabor/golem",
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:tesla, "~> 0.6.0"},
      {:socket, "~> 0.3"},
      {:poison, "~> 2.0"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:coverex, "~> 1.4.10", only: :test},
      {:git_cli, "~> 0.2", only: :dev}
    ]
  end

  defp description do
    """
    --- ALPHA ---
    Chatbot built in Elixir.
    """
  end

  defp package do
    [
      name: :golem,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Gábor Takács"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/ghaabor/golem",
              "Docs" => "https://github.com/ghaabor/golem"}
    ]
  end

  defp docs do
    [
      main: "Golem",
      extras: ["README.md"]
    ]
  end
end
