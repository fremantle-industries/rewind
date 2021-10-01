defmodule Rewind.MixProject do
  use Mix.Project

  def project do
    [
      app: :rewind,
      version: "0.0.1",
      elixir: "~> 1.12",
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
      start_phases: [models: []],
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:accessible, "~> 0.3"},
      {:confex, "~> 3.5.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.4"},
      {:gettext, "~> 0.11"},
      # TODO: Need to add schedules to history
      # {:history, github: "fremantle-industries/history", branch: "main", override: true},
      {:history, "~> 0.0.23"},
      {:jason, "~> 1.0"},
      # Need to wait for a new release with:
      # https://github.com/livebook-dev/livebook/pull/799
      # {:livebook, "~> 0.4"},
      {:livebook, github: "livebook-dev/livebook", branch: "main"},
      {:logger_file_backend, "~> 0.0.12", only: :dev},
      {:master_proxy, "~> 0.1"},
      {:navigator, "~> 0.0.6"},
      {:notified_phoenix, "~> 0.0.4"},
      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix_live_view, "~> 0.17"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      # {:stylish, github: "fremantle-industries/stylish", branch: "main", override: true},
      {:stylish, "~> 0.0.7"},
      # {:tai, github: "fremantle-industries/tai", sparse: "apps/tai", branch: "main", override: true},
      {:tai, "~> 0.0.74"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      # {:workbench, github: "fremantle-industries/workbench", branch: "main", override: true},
      {:workbench, "~> 0.0.17"},
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
      "setup.deps": ["deps.get", "cmd npm install --prefix assets"],
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
