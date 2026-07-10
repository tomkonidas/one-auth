defmodule OneAuth.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/tomkonidas/one-auth"

  def project do
    [
      app: :one_auth,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "OneAuth",
      docs: docs(),
      package: package(),
      description: description(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.20"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false, warn_if_outdated: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: [
        "compile --warnings-as-errors",
        "format",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Tom Konidas"],
      links: %{
        "GitHub" => @url
      }
    ]
  end

  defp docs do
    [
      main: "OneAuth",
      source_ref: "v#{@version}",
      source_url: @url,
      extras: [
        "README.md",
        "LICENSE",
        "guides/configuration.md"
      ],
      groups_for_modules: [
        Plugs: [
          OneAuth.FetchAuth,
          OneAuth.RequireAuth
        ],
        Internal: [
          OneAuth.Session,
          OneAuth.Credentials,
          OneAuth.Login
        ]
      ]
    ]
  end

  defp description do
    "A simple, database-free alternative to HTTP Basic Auth with session-based authentication for Plug-compatible applications"
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/one_auth.plt"},
      plt_core_path: "priv/plts",
      plt_add_apps: [:mix]
    ]
  end
end
