defmodule Re.Mixfile do
  use Mix.Project

  def project do
    [
      app: :re,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    [
      mod: {Re.Application, []},
      extra_applications: [:logger, :runtime_tools, :sentry, :prometheus_ex]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.13.0 or ~> 0.14.0"},
      {:geo_postgis, "~> 3.1"},
      {:poison, "~> 3.0 or ~> 4.0"},
      {:comeonin, "~> 3.2"},
      {:ex_machina, "~> 2.2", only: :test},
      {:bodyguard, "~> 2.1"},
      {:faker, "~> 0.12.0", only: :test},
      {:email_checker, "~> 0.1"},
      {:dataloader, "~> 1.0"},
      {:currency_formatter, "~> 0.4"},
      {:timber, "~> 3.1"},
      {:timber_ecto, "~> 2.1"},
      {:nimble_csv, "~> 0.3"},
      {:timex, "~> 3.5"},
      {:tzdata, "~> 0.5.20"},
      {:account_kit, github: "rhnonose/account_kit"},
      {:xml_builder, "~> 2.1"},
      {:uuid, "~> 1.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:scrivener_ecto, "~> 2.1"},
      {:sentry, "~> 7.0"},
      {:jason, "~> 1.1"},
      {:ecto_job, "~> 2.0"},
      {:prometheus_ecto, "~> 1.4"},
      {:mockery, "~> 2.3", runtime: false},
      {:retry, "~> 0.10"},
      {:quantum, "~> 2.3"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
