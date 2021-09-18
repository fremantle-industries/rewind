import Config

# Shared variables
env = config_env() |> Atom.to_string()
http_port = (System.get_env("HTTP_PORT") || "4000") |> String.to_integer()
rewind_host = System.get_env("REWIND_HOST") || "rewind.localhost"
workbench_host = System.get_env("WORKBENCH_HOST") || "workbench.localhost"
history_host = System.get_env("HISTORY_HOST") || "history.localhost"
livebook_host = System.get_env("LIVEBOOK_HOST") || "livebook.localhost"
grafana_host = System.get_env("GRAFANA_HOST") || "grafana.localhost"
prometheus_host = System.get_env("PROMETHEUS_HOST") || "prometheus.localhost"

rewind_secret_key_base = System.get_env("REWIND_SECRET_KEY_BASE") || "uIsXcCsXXptrAhMspslwWysO4zXUvMTannSJy6moML7in7349Ly7Xw5Rkxx/I2dN"
rewind_live_view_signing_salt = System.get_env("REWIND_LIVE_VIEW_SIGNING_SALT") || "YCe1E2To"
workbench_secret_key_base = System.get_env("WORKBENCH_SECRET_KEY_BASE") || "vJP36v4Gi2Orw8b8iBRg6ZFdzXKLvcRYkk1AaMLYX0+ry7k5XaJXd/LY/itmoxPP"
workbench_live_view_signing_salt = System.get_env("WORKBENCH_LIVE_VIEW_SIGNING_SALT") || "TolmUusQ6//zaa5GZHu7DG2V3YAgOoP/"
history_secret_key_base = System.get_env("HISTORY_SECRET_KEY_BASE") || "5E5zaJwG5w2ABR+0p+4GQs1nwzz5e7UbkEa6hlpel6wcrI6CAhWsrKWEecfYFWRF"
history_live_view_signing_salt = System.get_env("HISTORY_LIVE_VIEW_SIGNING_SALT") || "MXNTK//1Uc1R5wIKBGTZyTPPEQyVxSo3"
livebook_secret_key_base = System.get_env("LIVEBOOK_SECRET_KEY_BASE") || "vJP36v4Gi2Orw8b8iBRg6ZFdzXKLvcRYkk1AaMLYX0+ry7k5XaJXd/LY/itmoxPP"
livebook_live_view_signing_salt = System.get_env("LIVEBOOK_LIVE_VIEW_SIGNING_SALT") || "TolmUusQ6//zaa5GZHu7DG2V3YAgOoP/"

config :rewind,
       :prometheus_metrics_port,
       {:system, :integer, "REWIND_PROMETHEUS_METRICS_PORT", 9568}

# Telemetry
config :telemetry_poller, :default, period: 1_000

# Database
partition = System.get_env("MIX_TEST_PARTITION")
default_database_url = "postgres://postgres:postgres@localhost:5432/rewind_?"
configured_database_url = System.get_env("DATABASE_URL") || default_database_url
database_url = "#{String.replace(configured_database_url, "?", env)}#{partition}"

# Rewind
config :rewind,
       :prometheus_metrics_port,
       {:system, :integer, "REWIND_PROMETHEUS_METRICS_PORT", 9572}

config :rewind, Rewind.Repo,
  url: database_url,
  pool_size: 5

config :rewind, RewindWeb.Endpoint,
  server: true,
  url: [host: rewind_host, port: http_port],
  render_errors: [view: RewindWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tai.PubSub,
  secret_key_base: rewind_secret_key_base,
  live_view: [signing_salt: rewind_live_view_signing_salt]

config :rewind, models: %{}

# Workbench
config :workbench,
       :prometheus_metrics_port,
       {:system, :integer, "WORKBENCH_PROMETHEUS_METRICS_PORT", 9569}

config :workbench, Workbench.Repo,
  url: database_url,
  pool_size: 5

config :workbench, WorkbenchWeb.Endpoint,
  http: [port: http_port],
  url: [host: workbench_host, port: http_port],
  render_errors: [view: WorkbenchWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Tai.PubSub,
  secret_key_base: workbench_secret_key_base,
  live_view: [signing_salt: workbench_live_view_signing_salt],
  server: false

config :workbench,
  asset_aliases: %{
    btc: [:xbt],
    usd: [:busd, :pax, :usdc, :usdt, :tusd]
  },
  balance_snapshot: %{
    enabled: {:system, :boolean, "BALANCE_SNAPSHOT_ENABLED", false},
    boot_delay_ms: {:system, :integer, "BALANCE_SNAPSHOT_BOOT_DELAY_MS", 10_000},
    every_ms: {:system, :integer, "BALANCE_SNAPSHOT_EVERY_MS", 60_000},
    btc_usd_venue: {:system, :atom, "BALANCE_SNAPSHOT_BTC_USD_VENUE", :ftx},
    btc_usd_symbol: {:system, :atom, "BALANCE_SNAPSHOT_BTC_USD_SYMBOL", :"btc-perp"},
    usd_quote_venue: {:system, :atom, "BALANCE_SNAPSHOT_USD_QUOTE_VENUE", :ftx},
    usd_quote_asset: {:system, :atom, "BALANCE_SNAPSHOT_USD_QUOTE_ASSET", :usd},
    quote_pairs: [ftx: :usd]
  }

# History
config :history,
       :prometheus_metrics_port,
       {:system, :integer, "HISTORY_PROMETHEUS_METRICS_PORT", 9570}

config :history, History.Repo,
  url: database_url,
  pool_size: 5

config :history, HistoryWeb.Endpoint,
  http: [port: http_port],
  url: [host: history_host, port: http_port],
  render_errors: [view: HistoryWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Tai.PubSub,
  secret_key_base: history_secret_key_base,
  live_view: [signing_salt: history_live_view_signing_salt],
  server: false

config :history, :download_candle_chunks_concurrency, {:system, :integer, "DOWNLOAD_CANDLE_CHUNKS_CONCURRENCY", 2}

config :history,
  data_adapters: %{
    binance: History.Sources.Binance,
    bitmex: History.Sources.Bitmex,
    bybit: History.Sources.Bybit,
    gdax: History.Sources.Gdax,
    ftx: History.Sources.Ftx,
    okex: History.Sources.OkEx
  }

# Livebook
config :livebook, LivebookWeb.Endpoint,
  url: [host: livebook_host, port: http_port],
  pubsub_server: Livebook.PubSub,
  secret_key_base: livebook_secret_key_base,
  live_view: [signing_salt: livebook_live_view_signing_salt],
  server: false

config :livebook, :root_path, Livebook.Config.root_path!("LIVEBOOK_ROOT_PATH")

if password = Livebook.Config.password!("LIVEBOOK_PASSWORD") do
  config :livebook, authentication_mode: :password, password: password
else
  config :livebook, token: Livebook.Utils.random_id()
end

if ip = Livebook.Config.ip!("LIVEBOOK_IP") do
  config :livebook, LivebookWeb.Endpoint, http: [ip: ip]
end

config :livebook,
       :cookie,
       Livebook.Config.cookie!("LIVEBOOK_COOKIE") || Livebook.Utils.random_cookie()

config :livebook,
       :default_runtime,
       Livebook.Config.default_runtime!("LIVEBOOK_DEFAULT_RUNTIME") ||
         {Livebook.Runtime.ElixirStandalone, []}

# Master Proxy
config :master_proxy,
  # any Cowboy options are allowed
  http: [:inet6, port: http_port],
  # https: [:inet6, port: 4443],
  backends: [
    %{
      host: ~r/#{rewind_host}/,
      phoenix_endpoint: RewindWeb.Endpoint
    },
    %{
      host: ~r/#{workbench_host}/,
      phoenix_endpoint: WorkbenchWeb.Endpoint
    },
    %{
      host: ~r/#{history_host}/,
      phoenix_endpoint: HistoryWeb.Endpoint
    },
    %{
      host: ~r/#{livebook_host}/,
      phoenix_endpoint: LivebookWeb.Endpoint
    }
  ]

# Navigation
config :navigator,
  links: %{
    rewind: [
      %{
        label: "Rewind",
        link: {RewindWeb.Router.Helpers, :home_path, [RewindWeb.Endpoint, :index]},
        class: "text-4xl"
      },
      %{
        label: "Models",
        link: {RewindWeb.Router.Helpers, :model_path, [RewindWeb.Endpoint, :index]}
      },
      %{
        label: "Workbench",
        link: {WorkbenchWeb.Router.Helpers, :balance_all_url, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "History",
        link: {HistoryWeb.Router.Helpers, :trade_url, [HistoryWeb.Endpoint, :index]}
      },
      %{
        label: "Livebook",
        link: {LivebookWeb.Router.Helpers, :home_url, [LivebookWeb.Endpoint, :page]}
      },
      %{
        label: "Grafana",
        link: "http://#{grafana_host}"
      },
      %{
        label: "Prometheus",
        link: "http://#{prometheus_host}"
      }
    ],
    workbench: [
      %{
        label: "Workbench",
        link: {WorkbenchWeb.Router.Helpers, :balance_all_path, [WorkbenchWeb.Endpoint, :index]},
        class: "text-4xl"
      },
      %{
        label: "Balances",
        link: {WorkbenchWeb.Router.Helpers, :balance_day_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Wallets",
        link: {WorkbenchWeb.Router.Helpers, :wallet_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Accounts",
        link: {WorkbenchWeb.Router.Helpers, :account_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Orders",
        link: {WorkbenchWeb.Router.Helpers, :order_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Positions",
        link: {WorkbenchWeb.Router.Helpers, :position_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Products",
        link: {WorkbenchWeb.Router.Helpers, :product_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Fees",
        link: {WorkbenchWeb.Router.Helpers, :fee_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Venues",
        link: {WorkbenchWeb.Router.Helpers, :venue_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Fleets",
        link: {WorkbenchWeb.Router.Helpers, :fleet_path, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Rewind",
        link: {RewindWeb.Router.Helpers, :home_url, [RewindWeb.Endpoint, :index]}
      },
      %{
        label: "History",
        link: {HistoryWeb.Router.Helpers, :trade_url, [HistoryWeb.Endpoint, :index]}
      },
      %{
        label: "Livebook",
        link: {LivebookWeb.Router.Helpers, :home_url, [LivebookWeb.Endpoint, :page]}
      },
      %{
        label: "Grafana",
        link: "http://#{grafana_host}"
      },
      %{
        label: "Prometheus",
        link: "http://#{prometheus_host}"
      }
    ],
    history: [
      %{
        label: "History",
        link: {HistoryWeb.Router.Helpers, :trade_path, [HistoryWeb.Endpoint, :index]},
        class: "text-4xl"
      },
      %{
        label: "Data",
        link: {HistoryWeb.Router.Helpers, :trade_path, [HistoryWeb.Endpoint, :index]}
      },
      %{
        label: "Products",
        link: {HistoryWeb.Router.Helpers, :product_path, [HistoryWeb.Endpoint, :index]}
      },
      %{
        label: "Tokens",
        link: {HistoryWeb.Router.Helpers, :token_path, [HistoryWeb.Endpoint, :index]}
      },
      %{
        label: "Rewind",
        link: {RewindWeb.Router.Helpers, :home_url, [RewindWeb.Endpoint, :index]}
      },
      %{
        label: "Workbench",
        link: {WorkbenchWeb.Router.Helpers, :balance_all_url, [WorkbenchWeb.Endpoint, :index]}
      },
      %{
        label: "Livebook",
        link: {LivebookWeb.Router.Helpers, :home_url, [LivebookWeb.Endpoint, :page]}
      },
      %{
        label: "Grafana",
        link: "http://#{grafana_host}"
      },
      %{
        label: "Prometheus",
        link: "http://#{prometheus_host}"
      }
    ]
  }

# Notifications
config :notified, pubsub_server: Tai.PubSub

config :notified,
  receivers: [
    {NotifiedPhoenix.Receivers.Speech, []},
    {NotifiedPhoenix.Receivers.BrowserNotification, []}
  ]

config :notified_phoenix,
  to_list: {WorkbenchWeb.Router.Helpers, :notification_path, [WorkbenchWeb.Endpoint, :index]}

# Tai
config :tai, Tai.Orders.OrderRepo,
  url: database_url,
  pool_size: 5

config :tai, order_workers: 2
config :tai, order_workers_max_overflow: 0
config :tai, order_transition_workers: 2

config :tai, send_orders: false
config :tai, fleets: %{}
config :tai, venues: %{}

# Conditional configuration
if config_env() == :dev do
  # Set a higher stacktrace during development. Avoid configuring such
  # in production as building large stacktraces may be expensive.
  config :phoenix, :stacktrace_depth, 20

  # Initialize plugs at runtime for faster development compilation
  config :phoenix, :plug_init_mode, :runtime

  # Configure your database
  config :rewind, Rewind.Repo, show_sensitive_data_on_connection_error: true

  # For development, we disable any cache and enable
  # debugging and code reloading.
  #
  # The watchers configuration can be used to run external
  # watchers to your application. For example, we use it
  # with webpack to recompile .js and .css sources.
  config :rewind, RewindWeb.Endpoint,
    debug_errors: true,
    code_reloader: true,
    check_origin: false,
    watchers: [
      npm: [
        "run",
        "watch",
        cd: Path.expand("../assets", __DIR__)
      ]
    ]

  # ## SSL Support
  #
  # In order to use HTTPS in development, a self-signed
  # certificate can be generated by running the following
  # Mix task:
  #
  #     mix phx.gen.cert
  #
  # Note that this task requires Erlang/OTP 20 or later.
  # Run `mix help phx.gen.cert` for more information.
  #
  # The `http:` config above can be replaced with:
  #
  #     https: [
  #       port: 4001,
  #       cipher_suite: :strong,
  #       keyfile: "priv/cert/selfsigned_key.pem",
  #       certfile: "priv/cert/selfsigned.pem"
  #     ],
  #
  # If desired, both `http:` and `https:` keys can be
  # configured to run both http and https servers on
  # different ports.

  # Watch static and templates for browser reloading.
  config :rewind, RewindWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
        ~r"priv/gettext/.*(po)$",
        ~r"lib/rewind_web/(live|views)/.*(ex)$",
        ~r"lib/rewind_web/templates/.*(eex)$"
      ]
    ]

  config :rewind, :download_candle_chunks_concurrency, {:system, :integer, "DOWNLOAD_CANDLE_CHUNKS_CONCURRENCY", 2}

  config :tai, venues: %{
    ftx: [
      start_on_boot: true,
      adapter: Tai.VenueAdapters.Ftx,
      products: "*",
      order_books: ""
    ]
  }

  unless System.get_env("DOCKER") == "true" do
    config :logger, backends: [{LoggerFileBackend, :file_log}]
    config :logger, :file_log, path: "./logs/#{config_env()}.log", level: :info
  end
end

if config_env() == :test do
  config :tai, Tai.Orders.OrderRepo,
    pool: Ecto.Adapters.SQL.Sandbox,
    show_sensitive_data_on_connection_error: true

  config :tai, e2e_app: :rewind

  # config :echo_boy, port: 4100

  config :logger, backends: [{LoggerFileBackend, :file_log}]
  config :logger, :file_log, path: "./logs/#{config_env()}.log", level: :info
end
