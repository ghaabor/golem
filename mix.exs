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
      {:poison, ">= 1.0.0"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
