defmodule Rewind.MixProject do
  use Mix.Project

  def project do
    [
      app: :rewind,
      version: "0.0.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Rewind.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:accessible, "~> 0.3"},
      {:confex, "~> 3.5.0"},
      {:ecto_sql, "~> 3.4"},
      {:gettext, "~> 0.11"},
      # TODO: Need to add schedules to history
      # {:history, github: "fremantle-industries/history", branch: "main", override: true},
      {:history, "~> 0.0.15"},
      {:jason, "~> 1.0"},
      {:livebook, "~> 0.2"},
      {:logger_file_backend, "~> 0.0.12", only: :dev},
      {:master_proxy, "~> 0.1"},
      {:navigator, "~> 0.0.4"},
      {:notified_phoenix, "~> 0.0.4"},
      {:phoenix, "~> 1.5.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:phoenix_live_view, "~> 0.15"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      # {:stylish, github: "fremantle-industries/stylish", branch: "main", override: true},
      {:stylish, "~> 0.0.5"},
      # {:tai, github: "fremantle-industries/tai", sparse: "apps/tai", branch: "main", override: true},
      {:tai, "~> 0.0.70"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      # {:workbench, github: "fremantle-industries/workbench", branch: "main", override: true},
      {:workbench, "~> 0.0.15"},
      {:floki, ">= 0.30.0", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["setup.deps", "setup.tai", "setup.workbench", "setup.history", "ecto.setup", "run priv/repo/seeds.exs"],
      "setup.deps": ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "setup.tai": ["tai.gen.migration"],
      "setup.workbench": ["workbench.gen.migration"],
      "setup.history": ["history.gen.migration"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "test.watch": ["ecto.create --quiet", "ecto.migrate", "test.watch"]
    ]
  end
end
