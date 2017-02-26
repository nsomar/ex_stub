defmodule ExStub.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_stub,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: Coverex.Task, coveralls: true],
     name: "ExStub",
     source_url: "https://github.com/oarrabi/ex_stub",
     homepage_url: "http://nsomar.com",
     docs: [main: "ExStub",
            extras: ["README.md"]],
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:inch_ex, "> 0.0.0", only: :docs},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:coverex, "~> 1.4.8", only: :test}
    ]
  end

  defp description do
    """
    ExStub provides an easy way to stub a module to facilitate writing clean, isolated unit tests.
    """
  end

  defp package do
    [ files: [ "lib", "mix.exs", "README.md",],
      maintainers: [ "Omar Abdelhafith" ],
      links: %{ "GitHub" => "https://github.com/oarrabi/ex_stub" } ]
  end
end
