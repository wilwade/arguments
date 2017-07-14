defmodule Arguments.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :arguments,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),

     # Docs
     name: "Arguments",
     source_url: "https://github.com/wilwade/arguments",
     docs: [main: "Arguments",
            source_ref: "v#{@version}",
            extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    []
  end

  # Dependencies can be Hex packages:
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Arguments parses command line arguments to a map with a declarative, simple setup
    """
  end

  defp package do
    [
      maintainers: ["Wil Wade"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/wilwade/arguments"},
    ]
  end
end
