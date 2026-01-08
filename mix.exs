defmodule HealthCheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_health_check,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      description:
        "Simple health check library for Elixir applications with support for Ecto, Redix and Kaffe.",
      package: package(),
      name: "ElixirHealthCheck",
      source_url: "https://github.com/zakurakin/elixir-health-check",
      homepage_url: "https://github.com/zakurakin/elixir-health-check",
      docs: [
        main: "ElixirHealthCheck",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.14"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.0"},
      {:ecto, "~> 3.0", optional: true},
      {:ecto_sql, "~> 3.0", optional: true},
      {:redix, "~> 1.0", optional: true},
      {:kaffe, "~> 1.0", optional: true},
      {:mongodb_driver, "~> 1.0", optional: true},
      {:ex_aws, "~> 2.1", optional: true},
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:hackney, "~> 1.9", optional: true},
      {:sweet_xml, "~> 0.6", optional: true},
      {:ex_doc, "~> 0.32", runtime: false},
      {:excoveralls, "~> 0.18", only: [:dev, :test]},
      {:credo, "~> 1.7", runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/zakurakin/elixir-health-check"}
    ]
  end
end
